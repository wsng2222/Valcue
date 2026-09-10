import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valcue/features/profile/models/weight_entry.dart';
import 'package:valcue/features/profile/models/workout_session.dart';
import 'package:valcue/features/profile/storage/weight_storage.dart';
import 'package:valcue/features/profile/storage/workout_session_storage.dart';
import 'package:valcue/features/routines/models/machine_type.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  group('moving old history to the new format', () {
    test('keeps every workout that was saved by the old version', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        WorkoutSessionStorage.legacyStorageKey: jsonEncode([
          _session('old-1', DateTime(2026, 1, 1)).toJson(),
          _session('old-2', DateTime(2026, 1, 2)).toJson(),
          _session('old-3', DateTime(2026, 1, 3)).toJson(),
        ]),
      });

      final loaded = await WorkoutSessionStorage().loadSessions();

      expect(loaded.map((s) => s.id), ['old-3', 'old-2', 'old-1']);
    });

    test('gives each old workout its own key and drops the old blob',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        WorkoutSessionStorage.legacyStorageKey: jsonEncode([
          _session('old-1', DateTime(2026, 1, 1)).toJson(),
          _session('old-2', DateTime(2026, 1, 2)).toJson(),
        ]),
      });

      await WorkoutSessionStorage().loadSessions();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(WorkoutSessionStorage.legacyStorageKey), isNull);
      expect(
        prefs.getKeys().where(
              (k) => k.startsWith(WorkoutSessionStorage.keyPrefix),
            ),
        hasLength(2),
      );
    });

    test('runs once, so a later read does not resurrect deleted history',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        WorkoutSessionStorage.legacyStorageKey: jsonEncode([
          _session('old-1', DateTime(2026, 1, 1)).toJson(),
        ]),
      });
      final storage = WorkoutSessionStorage();

      await storage.loadSessions();
      await storage.deleteSession('old-1');

      expect(await storage.loadSessions(), isEmpty);
    });

    test('a malformed old entry does not take the rest down with it',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        WorkoutSessionStorage.legacyStorageKey: jsonEncode([
          _session('good', DateTime(2026, 1, 1)).toJson(),
          'not-a-record',
          {'id': 'incomplete', 'machineType': 'treadmill'},
        ]),
      });

      final loaded = await WorkoutSessionStorage().loadSessions();

      expect(loaded.map((s) => s.id), ['good']);
    });

    test('unreadable old data leaves the app usable rather than crashing',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        WorkoutSessionStorage.legacyStorageKey: 'this is not json',
      });

      expect(await WorkoutSessionStorage().loadSessions(), isEmpty);
    });

    test('weight entries migrate the same way', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        WeightStorage.legacyStorageKey: jsonEncode([
          _weight('w1', DateTime(2026, 1, 1), 70.5).toJson(),
          _weight('w2', DateTime(2026, 1, 2), 70.0).toJson(),
        ]),
      });

      final loaded = await WeightStorage().loadEntries();

      expect(loaded.map((e) => e.id), ['w2', 'w1']);
      expect(loaded.last.weightKg, 70.5);
    });
  });

  group('saving one record leaves the others alone', () {
    test('a delete that overlaps a save cannot swallow the new workout',
        () async {
      // The old code read the whole list, edited it, and wrote it back. Two
      // overlapping edits both started from the same list, so the slower
      // write erased the other one's change.
      final storage = WorkoutSessionStorage();
      await storage.addSession(_session('kept', DateTime(2026, 1, 1)));

      await Future.wait([
        storage.addSession(_session('new', DateTime(2026, 1, 3))),
        storage.deleteSession('kept'),
      ]);

      final loaded = await storage.loadSessions();
      expect(loaded.map((s) => s.id), ['new']);
    });

    test('adding a workout only writes that one key', () async {
      final storage = WorkoutSessionStorage();
      await storage.addSession(_session('a', DateTime(2026, 1, 1)));
      await storage.addSession(_session('b', DateTime(2026, 1, 2)));

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString('${WorkoutSessionStorage.keyPrefix}a'),
        isNotNull,
      );
      expect(
        prefs.getString('${WorkoutSessionStorage.keyPrefix}b'),
        isNotNull,
      );
    });

    test('saving the same id twice updates instead of duplicating', () async {
      final storage = WorkoutSessionStorage();
      await storage.addSession(_session('same', DateTime(2026, 1, 1)));
      await storage.addSession(
        _session('same', DateTime(2026, 1, 1), routineName: 'Renamed'),
      );

      final loaded = await storage.loadSessions();
      expect(loaded, hasLength(1));
      expect(loaded.single.routineName, 'Renamed');
    });

    test('deleting something already gone is harmless', () async {
      final storage = WorkoutSessionStorage();
      await storage.addSession(_session('a', DateTime(2026, 1, 1)));

      await storage.deleteSession('never-existed');

      expect(await storage.loadSessions(), hasLength(1));
    });
  });

  group('weight entry edits', () {
    test('editing an entry replaces it in place', () async {
      final storage = WeightStorage();
      await storage.addEntry(_weight('w1', DateTime(2026, 1, 1), 70.0));

      await storage.updateEntry(
        'w1',
        _weight('w1', DateTime(2026, 1, 1), 68.4),
      );

      final loaded = await storage.loadEntries();
      expect(loaded, hasLength(1));
      expect(loaded.single.weightKg, 68.4);
    });

    test('an edit that changes the id does not leave a duplicate', () async {
      final storage = WeightStorage();
      await storage.addEntry(_weight('old-id', DateTime(2026, 1, 1), 70.0));

      await storage.updateEntry(
        'old-id',
        _weight('new-id', DateTime(2026, 1, 1), 68.4),
      );

      final loaded = await storage.loadEntries();
      expect(loaded.map((e) => e.id), ['new-id']);
    });
  });

  group('reading back what was written', () {
    test('a workout survives a full save and load round trip', () async {
      final storage = WorkoutSessionStorage();
      final session = WorkoutSession(
        id: 'round-trip',
        machineType: MachineType.cycle,
        dateTime: DateTime(2026, 3, 4, 9, 30),
        durationSeconds: 1800,
        elapsedMilliseconds: 1800500,
        averageRpm: 84.5,
        routineName: 'Tempo',
        routineId: 'routine-9',
      );

      await storage.addSession(session);
      final loaded = (await storage.loadSessions()).single;

      expect(loaded.id, session.id);
      expect(loaded.machineType, MachineType.cycle);
      expect(loaded.dateTime, session.dateTime);
      expect(loaded.durationSeconds, 1800);
      expect(loaded.elapsedMilliseconds, 1800500);
      expect(loaded.averageRpm, 84.5);
      expect(loaded.routineName, 'Tempo');
      expect(loaded.routineId, 'routine-9');
    });

    test('filters still work on top of the new format', () async {
      final storage = WorkoutSessionStorage();
      await storage.addSession(
        _session('run', DateTime(2026, 1, 1), machine: MachineType.treadmill),
      );
      await storage.addSession(
        _session('ride', DateTime(2026, 1, 2), machine: MachineType.cycle),
      );

      final bikes = await storage.getSessionsByMachineType(MachineType.cycle);

      expect(bikes.map((s) => s.id), ['ride']);
    });

    test('a corrupt single record does not hide the healthy ones', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        '${WorkoutSessionStorage.keyPrefix}broken': 'not json',
        '${WorkoutSessionStorage.keyPrefix}fine':
            jsonEncode(_session('fine', DateTime(2026, 1, 1)).toJson()),
      });

      final loaded = await WorkoutSessionStorage().loadSessions();

      expect(loaded.map((s) => s.id), ['fine']);
    });

    test('unrelated preferences are never mistaken for records', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_settings': '{"isPremium":true}',
        'ad_post_workout_counter': 2,
        '${WorkoutSessionStorage.keyPrefix}fine':
            jsonEncode(_session('fine', DateTime(2026, 1, 1)).toJson()),
      });

      final loaded = await WorkoutSessionStorage().loadSessions();

      expect(loaded.map((s) => s.id), ['fine']);
    });
  });
}

WorkoutSession _session(
  String id,
  DateTime dateTime, {
  MachineType machine = MachineType.treadmill,
  String routineName = 'Intervals',
}) {
  return WorkoutSession(
    id: id,
    machineType: machine,
    dateTime: dateTime,
    durationSeconds: 600,
    routineName: routineName,
    routineId: 'routine-1',
  );
}

WeightEntry _weight(String id, DateTime dateTime, double weightKg) {
  return WeightEntry(id: id, dateTime: dateTime, weightKg: weightKg);
}
