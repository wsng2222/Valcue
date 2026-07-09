import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:interval_cardio/features/routines/models/interval.dart';
import 'package:interval_cardio/features/routines/models/machine_type.dart';
import 'package:interval_cardio/features/routines/models/routine.dart';
import 'package:interval_cardio/features/routines/storage/routine_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late RoutineStorage storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    RoutineStorage.diagnosticsEnabled = false;
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

    await storage.saveRoutines(routines);

    final loaded = await storage.loadRoutines();

    expect(loaded, hasLength(3));
    expect(loaded[0].machineType, MachineType.treadmill);
    expect(loaded[0].intervals.single.speedKmh, closeTo(8.5, 0.0001));
    expect(loaded[0].intervals.single.grade, closeTo(1.5, 0.0001));
    expect(loaded[1].machineType, MachineType.cycle);
    expect(loaded[1].intervals.single.rpm, 82);
    expect(loaded[1].intervals.single.resistance, 7);
    expect(loaded[2].machineType, MachineType.stairmaster);
    expect(loaded[2].intervals.single.level, 9);
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
