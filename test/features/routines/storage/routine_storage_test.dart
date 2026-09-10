import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:valcue/features/routines/models/interval.dart';
import 'package:valcue/features/routines/models/machine_type.dart';
import 'package:valcue/features/routines/models/routine.dart';
import 'package:valcue/features/routines/storage/routine_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late RoutineStorage storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = RoutineStorage();
  });

  test(
      'saveRoutines and loadRoutines preserve machine-specific interval values',
      () async {
    final routines = [
      Routine(
        id: 'treadmill-routine',
        name: 'Treadmill',
        difficulty: '중간',
        machineType: MachineType.treadmill,
        intervals: [
          Interval.treadmill(
            id: 'tm-1',
            durationSeconds: 75,
            speedKmh: 8.5,
            grade: 1.5,
          ),
        ],
      ),
      Routine(
        id: 'cycle-routine',
        name: 'Cycle',
        difficulty: '쉬움',
        machineType: MachineType.cycle,
        intervals: [
          Interval.cycle(
            id: 'cy-1',
            durationSeconds: 90,
            rpm: 82,
            resistance: 7,
          ),
        ],
      ),
      Routine(
        id: 'stair-routine',
        name: 'Stair',
        difficulty: '높음',
        machineType: MachineType.stairmaster,
        intervals: [
          Interval.stairmaster(
            id: 'st-1',
            durationSeconds: 45,
            level: 9,
          ),
        ],
      ),
    ];

    for (final routine in routines) {
      await storage.addRoutine(routine);
    }

    final loaded = await storage.loadRoutines();
    Routine byId(String id) => loaded.firstWhere((r) => r.id == id);

    expect(loaded, hasLength(3));
    expect(byId('treadmill-routine').intervals.single.speedKmh,
        closeTo(8.5, 0.0001));
    expect(byId('treadmill-routine').intervals.single.grade,
        closeTo(1.5, 0.0001));
    expect(byId('cycle-routine').intervals.single.rpm, 82);
    expect(byId('cycle-routine').intervals.single.resistance, 7);
    expect(byId('stair-routine').intervals.single.level, 9);
  });

  test('keeps routines in the order they were created', () async {
    // Ids carry the creation time, and the list has always shown oldest
    // first. Storing one routine per key must not scramble that.
    for (final id in ['1700000000003', '1700000000001', '1700000000002']) {
      await storage.addRoutine(_routine(id));
    }

    final loaded = await storage.loadRoutines();

    expect(
      loaded.map((r) => r.id),
      ['1700000000001', '1700000000002', '1700000000003'],
    );
  });

  test('imported routines are ordered by their creation time too', () async {
    await storage.addRoutine(_routine('imported_1700000000002'));
    await storage.addRoutine(_routine('1700000000001'));

    final loaded = await storage.loadRoutines();

    expect(loaded.map((r) => r.id), ['1700000000001', 'imported_1700000000002']);
  });

  test('an id with no timestamp still loads, ordered last', () async {
    await storage.addRoutine(_routine('legacy-routine'));
    await storage.addRoutine(_routine('1700000000001'));

    final loaded = await storage.loadRoutines();

    expect(loaded.map((r) => r.id), ['1700000000001', 'legacy-routine']);
  });

  test('deleting a routine is remembered for backup', () async {
    await storage.addRoutine(_routine('1700000000001'));

    await storage.deleteRoutine('1700000000001');

    expect(await storage.deletedRoutineIds(), contains('1700000000001'));
    expect(await storage.loadRoutines(), isEmpty);
  });

  test('deleting one routine leaves the others readable', () async {
    await storage.addRoutine(_routine('1700000000001'));
    await storage.addRoutine(_routine('1700000000002'));

    await storage.deleteRoutine('1700000000001');

    expect((await storage.loadRoutines()).map((r) => r.id),
        ['1700000000002']);
  });

  test('routines saved by the old version are migrated once', () async {
    SharedPreferences.setMockInitialValues({
      'routines': jsonEncode([
        _routine('1700000000001').toJson(),
        _routine('1700000000002').toJson(),
      ]),
    });

    expect(await storage.loadRoutines(), hasLength(2));

    await storage.deleteRoutine('1700000000001');

    // The old blob must be gone, or the delete would be undone next read.
    expect((await storage.loadRoutines()).map((r) => r.id),
        ['1700000000002']);
  });

  test('add, update, and delete mutate persisted routines by id', () async {
    final original = Routine(
      id: 'routine-1',
      name: 'Original',
      difficulty: '중간',
      machineType: MachineType.treadmill,
      intervals: [
        Interval.treadmill(
          id: 'interval-1',
          durationSeconds: 60,
          speedKmh: 7.0,
          grade: 0.5,
        ),
      ],
    );

    await storage.addRoutine(original);
    expect(await storage.loadRoutines(), hasLength(1));

    final updated = original.copyWith(
      name: 'Updated',
      intervals: [
        Interval.treadmill(
          id: 'interval-1',
          durationSeconds: 120,
          speedKmh: 9.0,
          grade: 2.0,
        ),
      ],
    );

    await storage.updateRoutine(updated);
    final loadedAfterUpdate = await storage.loadRoutines();
    expect(loadedAfterUpdate.single.name, 'Updated');
    expect(loadedAfterUpdate.single.intervals.single.durationSeconds, 120);
    expect(loadedAfterUpdate.single.intervals.single.speedKmh, 9.0);

    await storage.deleteRoutine('routine-1');
    expect(await storage.loadRoutines(), isEmpty);
  });

  test('loadRoutines returns empty list for corrupt stored JSON', () async {
    SharedPreferences.setMockInitialValues({'routines': 'not-json'});

    expect(await storage.loadRoutines(), isEmpty);
  });

  test('loadRoutines skips malformed entries and keeps valid routines',
      () async {
    final validRoutine = Routine(
      id: 'valid-routine',
      name: 'Valid',
      difficulty: '중간',
      machineType: MachineType.treadmill,
      intervals: [
        Interval.treadmill(
          id: 'valid-interval',
          durationSeconds: 60,
          speedKmh: 7.5,
          grade: 1.0,
        ),
      ],
    );

    SharedPreferences.setMockInitialValues({
      'routines': jsonEncode([
        validRoutine.toJson(),
        'bad-entry',
        {
          'id': 'broken-routine',
          'name': 'Broken',
          'difficulty': '중간',
          'machineType': 'treadmill',
        },
      ]),
    });

    final loaded = await storage.loadRoutines();

    expect(loaded, hasLength(1));
    expect(loaded.single.id, 'valid-routine');
    expect(loaded.single.intervals.single.speedKmh, 7.5);
  });
}

Routine _routine(String id) {
  return Routine(
    id: id,
    name: 'Routine $id',
    difficulty: '중간',
    machineType: MachineType.treadmill,
    intervals: [
      Interval.treadmill(
        id: 'interval-$id',
        durationSeconds: 60,
        speedKmh: 8,
        grade: 1,
      ),
    ],
  );
}
