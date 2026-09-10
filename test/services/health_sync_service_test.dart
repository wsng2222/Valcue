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

  group('what permission is asked for', () {
    test('covers energy and distance, not just the workout', () {
      // Asking only for WORKOUT saves the session but silently drops its
      // calories and distance, leaving the activity rings empty.
      final ios = HealthSyncService.writeTypesFor(isAndroid: false);

      expect(ios, contains(HealthDataType.WORKOUT));
      expect(ios, contains(HealthDataType.ACTIVE_ENERGY_BURNED));
      expect(ios, contains(HealthDataType.DISTANCE_WALKING_RUNNING));
    });

    test('uses the distance name each store accepts', () {
      final android = HealthSyncService.writeTypesFor(isAndroid: true);

      expect(android, contains(HealthDataType.DISTANCE_DELTA));
      expect(android, isNot(contains(HealthDataType.DISTANCE_WALKING_RUNNING)));
    });

    test('never asks to read anything', () {
      for (final isAndroid in [true, false]) {
        final types = HealthSyncService.writeTypesFor(isAndroid: isAndroid);
        expect(types.toSet(), hasLength(types.length));
      }
    });
  });

  group('when the workout actually happened', () {
    test('ends at the recorded time and starts a duration earlier', () {
      // A session records when it *finished*. Treating that as the start
      // would file a 07:00-07:30 run as 07:30-08:00.
      final session = _session(); // ended 07:30, ran 30 minutes
      final (start, end) = HealthSyncService.intervalFor(session);

      expect(end, DateTime(2026, 5, 1, 7, 30));
      expect(start, DateTime(2026, 5, 1, 7, 0));
    });

    test('never reaches into the future', () {
      final (start, end) = HealthSyncService.intervalFor(_session());

      expect(start.isBefore(end), isTrue);
      expect(end.isAfter(DateTime(2026, 5, 1, 7, 29)), isTrue);
    });

    test('a zero-length session collapses instead of inverting', () {
      final (start, end) = HealthSyncService.intervalFor(
        _session(durationSeconds: 0),
      );

      expect(start, end);
    });

    test('a negative duration cannot flip the interval', () {
      final (start, end) = HealthSyncService.intervalFor(
        _session(durationSeconds: -600),
      );

      expect(start, end);
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

WorkoutSession _session({double? distanceMeters, int durationSeconds = 1800}) {
  return WorkoutSession(
    id: 'session-1',
    machineType: MachineType.treadmill,
    dateTime: DateTime(2026, 5, 1, 7, 30), // when it finished
    durationSeconds: durationSeconds,
    distanceMeters: distanceMeters,
    routineName: 'Intervals',
    routineId: 'routine-1',
  );
}
