import 'package:flutter_test/flutter_test.dart';
import 'package:valcue/features/profile/models/workout_session.dart';
import 'package:valcue/features/routines/models/machine_type.dart';
import 'package:valcue/services/workout_energy_estimate.dart';

/// These numbers end up in someone's health record, so the guardrails matter
/// more than the exact figure: never wildly high, never negative, never a
/// crash on odd input.
void main() {
  group('treadmill', () {
    test('a 30 minute 10 km/h run lands in a believable range', () {
      final kcal = WorkoutEnergyEstimate.kilocaloriesFor(
        _treadmill(minutes: 30, distanceMeters: 5000),
        bodyWeightKg: 70,
      );

      // Published tables put a 70 kg runner at roughly 350-380 kcal here.
      expect(kcal, greaterThan(300));
      expect(kcal, lessThan(420));
    });

    test('walking burns clearly less than running for the same time', () {
      final walk = WorkoutEnergyEstimate.kilocaloriesFor(
        _treadmill(minutes: 30, distanceMeters: 2500), // 5 km/h
        bodyWeightKg: 70,
      )!;
      final run = WorkoutEnergyEstimate.kilocaloriesFor(
        _treadmill(minutes: 30, distanceMeters: 6000), // 12 km/h
        bodyWeightKg: 70,
      )!;

      expect(walk, lessThan(run / 2));
    });

    test('faster is always more, never less', () {
      var previous = 0;
      for (final metres in [1500, 2500, 4000, 5000, 6000, 7500, 9000]) {
        final kcal = WorkoutEnergyEstimate.kilocaloriesFor(
          _treadmill(minutes: 30, distanceMeters: metres.toDouble()),
          bodyWeightKg: 70,
        )!;
        expect(kcal, greaterThan(previous));
        previous = kcal;
      }
    });

    test('an absurd speed is still capped at a sane rate', () {
      final kcal = WorkoutEnergyEstimate.kilocaloriesFor(
        _treadmill(minutes: 30, distanceMeters: 40000), // 80 km/h
        bodyWeightKg: 70,
      )!;

      // Even the top MET anchor must not produce a four-figure half hour.
      expect(kcal, lessThan(800));
    });

    test('no distance recorded still gives a moderate estimate', () {
      final kcal = WorkoutEnergyEstimate.kilocaloriesFor(
        _treadmill(minutes: 30),
        bodyWeightKg: 70,
      )!;

      expect(kcal, greaterThan(100));
      expect(kcal, lessThan(400));
    });
  });

  group('other machines', () {
    test('every machine produces an estimate', () {
      for (final machine in MachineType.values) {
        final kcal = WorkoutEnergyEstimate.kilocaloriesFor(
          _session(machine: machine, minutes: 30),
          bodyWeightKg: 70,
        );
        expect(kcal, isNotNull, reason: '$machine');
        expect(kcal, greaterThan(0), reason: '$machine');
      }
    });

    test('stair climbing is treated as harder than cycling', () {
      final cycle = WorkoutEnergyEstimate.kilocaloriesFor(
        _session(machine: MachineType.cycle, minutes: 30),
        bodyWeightKg: 70,
      )!;
      final stairs = WorkoutEnergyEstimate.kilocaloriesFor(
        _session(machine: MachineType.stairmaster, minutes: 30),
        bodyWeightKg: 70,
      )!;

      expect(stairs, greaterThan(cycle));
    });
  });

  group('body weight', () {
    test('a heavier person burns more for the same workout', () {
      final light = WorkoutEnergyEstimate.kilocaloriesFor(
        _treadmill(minutes: 30, distanceMeters: 5000),
        bodyWeightKg: 55,
      )!;
      final heavy = WorkoutEnergyEstimate.kilocaloriesFor(
        _treadmill(minutes: 30, distanceMeters: 5000),
        bodyWeightKg: 95,
      )!;

      expect(heavy, greaterThan(light));
    });

    test('falls back to the assumed weight when none was ever recorded', () {
      final withoutWeight = WorkoutEnergyEstimate.kilocaloriesFor(
        _treadmill(minutes: 30, distanceMeters: 5000),
      );
      final withAssumed = WorkoutEnergyEstimate.kilocaloriesFor(
        _treadmill(minutes: 30, distanceMeters: 5000),
        bodyWeightKg: WorkoutEnergyEstimate.assumedBodyWeightKg,
      );

      expect(withoutWeight, withAssumed);
    });

    test('a nonsense weight is ignored rather than trusted', () {
      for (final weight in [0.0, -70.0]) {
        expect(
          WorkoutEnergyEstimate.kilocaloriesFor(
            _treadmill(minutes: 30, distanceMeters: 5000),
            bodyWeightKg: weight,
          ),
          WorkoutEnergyEstimate.kilocaloriesFor(
            _treadmill(minutes: 30, distanceMeters: 5000),
          ),
        );
      }
    });
  });

  group('degenerate input', () {
    test('a zero-length workout produces nothing', () {
      expect(
        WorkoutEnergyEstimate.kilocaloriesFor(
          _treadmill(minutes: 0),
          bodyWeightKg: 70,
        ),
        isNull,
      );
    });

    test('a workout too short to burn a calorie produces nothing', () {
      expect(
        WorkoutEnergyEstimate.kilocaloriesFor(
          _session(machine: MachineType.cycle, minutes: 0.005),
          bodyWeightKg: 70,
        ),
        isNull,
      );
    });

    test('a negative distance does not flip the estimate', () {
      final kcal = WorkoutEnergyEstimate.kilocaloriesFor(
        _treadmill(minutes: 30, distanceMeters: -5000),
        bodyWeightKg: 70,
      )!;

      expect(kcal, greaterThan(0));
    });
  });
}

WorkoutSession _treadmill({required double minutes, double? distanceMeters}) {
  return _session(
    machine: MachineType.treadmill,
    minutes: minutes,
    distanceMeters: distanceMeters,
  );
}

WorkoutSession _session({
  required MachineType machine,
  required double minutes,
  double? distanceMeters,
}) {
  return WorkoutSession(
    id: 'session-1',
    machineType: machine,
    dateTime: DateTime(2026, 5, 1, 7),
    durationSeconds: (minutes * 60).round(),
    distanceMeters: distanceMeters,
    routineName: 'Intervals',
    routineId: 'routine-1',
  );
}
