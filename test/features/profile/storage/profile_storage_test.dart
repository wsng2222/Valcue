import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:valcue/features/profile/models/weight_entry.dart';
import 'package:valcue/features/profile/models/workout_session.dart';
import 'package:valcue/features/profile/storage/weight_storage.dart';
import 'package:valcue/features/profile/storage/workout_session_storage.dart';
import 'package:valcue/features/routines/models/machine_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('WorkoutSession.fromJson accepts int-backed numeric fields', () {
    final session = WorkoutSession.fromJson({
      'id': 'session-1',
      'machineType': 'treadmill',
      'dateTime': '2026-07-09T10:00:00.000',
      'durationSeconds': 75,
      'elapsedMilliseconds': 75600,
      'distanceMeters': 250,
      'averageRpm': 88,
      'averageLevel': 6,
      'routineName': 'Morning Run',
      'routineId': 'routine-1',
    });

    expect(session.machineType, MachineType.treadmill);
    expect(session.durationSeconds, 75);
    expect(session.elapsedMilliseconds, 75600);
    expect(session.distanceMeters, 250.0);
    expect(session.averageRpm, 88.0);
    expect(session.averageLevel, 6.0);
  });

  test('WorkoutSessionStorage skips malformed entries and keeps valid ones',
      () async {
    final validSession = WorkoutSession(
      id: 'valid-session',
      machineType: MachineType.treadmill,
      dateTime: DateTime(2026, 7, 9, 10),
      durationSeconds: 120,
      elapsedMilliseconds: 120400,
      distanceMeters: 320.5,
      routineName: 'Intervals',
      routineId: 'routine-1',
    );

    SharedPreferences.setMockInitialValues({
      'workout_sessions': jsonEncode([
        validSession.toJson(),
        'bad-entry',
        {
          'id': 'broken-session',
          'machineType': 'treadmill',
          'dateTime': '2026-07-09T10:00:00.000',
        },
      ]),
    });

    final storage = WorkoutSessionStorage();
    final loaded = await storage.loadSessions();

    expect(loaded, hasLength(1));
    expect(loaded.single.id, 'valid-session');
    expect(loaded.single.elapsedMilliseconds, 120400);
    expect(loaded.single.distanceMeters, 320.5);
  });

  test('WeightEntry.fromJson accepts int-backed values', () {
    final entry = WeightEntry.fromJson({
      'id': 'weight-1',
      'dateTime': '2026-07-09T10:00:00.000',
      'weightKg': 70,
    });

    expect(entry.weightKg, 70.0);
  });

  test('WeightStorage skips malformed entries and keeps valid ones', () async {
    final validEntry = WeightEntry(
      id: 'valid-weight',
      dateTime: DateTime(2026, 7, 9, 10),
      weightKg: 70.5,
    );

    SharedPreferences.setMockInitialValues({
      'weight_entries': jsonEncode([
        validEntry.toJson(),
        'bad-entry',
        {
          'id': 'broken-weight',
          'dateTime': '2026-07-09T10:00:00.000',
        },
      ]),
    });

    final storage = WeightStorage();
    final loaded = await storage.loadEntries();

    expect(loaded, hasLength(1));
    expect(loaded.single.id, 'valid-weight');
    expect(loaded.single.weightKg, 70.5);
  });
}
