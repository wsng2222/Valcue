import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:valcue/features/profile/models/workout_session.dart';
import 'package:valcue/features/routines/models/machine_type.dart';
import 'package:valcue/services/health_sync_service.dart';

void main() {
  group('choosing the activity each platform accepts', () {
    test('Health Connect gets the machine-specific types', () {
      HealthWorkoutActivityType typeFor(MachineType machine) =>
          HealthSyncService.activityTypeFor(machine, isAndroid: true);

      expect(
        typeFor(MachineType.treadmill),
        HealthWorkoutActivityType.RUNNING_TREADMILL,
      );
      expect(
        typeFor(MachineType.cycle),
        HealthWorkoutActivityType.BIKING_STATIONARY,
      );
      expect(
        typeFor(MachineType.stairmaster),
        HealthWorkoutActivityType.STAIR_CLIMBING_MACHINE,
      );
    });

    test('Apple Health gets types it actually supports', () {
      // HealthKit throws on the Android-only names, so iOS must fall back.
      HealthWorkoutActivityType typeFor(MachineType machine) =>
          HealthSyncService.activityTypeFor(machine, isAndroid: false);

      expect(typeFor(MachineType.treadmill), HealthWorkoutActivityType.RUNNING);
      expect(typeFor(MachineType.cycle), HealthWorkoutActivityType.BIKING);
      expect(
        typeFor(MachineType.stairmaster),
        HealthWorkoutActivityType.STAIR_CLIMBING,
      );
    });

    test('every machine is mapped on both platforms', () {
      for (final machine in MachineType.values) {
        for (final isAndroid in [true, false]) {
          expect(
            () => HealthSyncService.activityTypeFor(
              machine,
              isAndroid: isAndroid,
            ),
            returnsNormally,
          );
        }
      }
    });
  });

  group('distance', () {
    test('is passed through as whole metres', () {
      expect(
        HealthSyncService.distanceMetersFor(_session(distanceMeters: 5432.7)),
        5433,
      );
    });

    test('is omitted for machines that do not measure it', () {
      expect(HealthSyncService.distanceMetersFor(_session()), isNull);
    });

    test('is omitted rather than logging a 0 m workout', () {
      expect(
        HealthSyncService.distanceMetersFor(_session(distanceMeters: 0)),
        isNull,
      );
    });
  });

  group('the setting is respected before anything else', () {
    test('a switched-off setting writes nothing', () async {
      final service = HealthSyncService(
        isIOS: () => true,
        isAndroid: () => false,
      );

      final outcome = await service.writeWorkout(_session(), enabled: false);

      expect(outcome, HealthSyncOutcome.disabled);
    });

    test('an unsupported platform reports itself instead of failing',
        () async {
      final service = HealthSyncService(
        isIOS: () => false,
        isAndroid: () => false,
      );

      expect(service.isSupportedPlatform, isFalse);
      expect(await service.requestPermission(), isFalse);
      expect(await service.hasPermission(), isFalse);
      expect(
        await service.writeWorkout(_session(), enabled: true),
        HealthSyncOutcome.unavailable,
      );
    });
  });
}

WorkoutSession _session({double? distanceMeters}) {
  return WorkoutSession(
    id: 'session-1',
    machineType: MachineType.treadmill,
    dateTime: DateTime(2026, 5, 1, 7, 30),
    durationSeconds: 1800,
    distanceMeters: distanceMeters,
    routineName: 'Intervals',
    routineId: 'routine-1',
  );
}
