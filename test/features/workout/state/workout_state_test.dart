import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:interval_cardio/features/routines/models/interval.dart';
import 'package:interval_cardio/features/routines/models/machine_type.dart';
import 'package:interval_cardio/features/routines/models/routine.dart';
import 'package:interval_cardio/features/workout/state/workout_state.dart';

void main() {
  Routine buildRoutine({
    required MachineType machineType,
    double? speedKmh,
  }) {
    return Routine(
      id: 'routine-1',
      name: 'Test Routine',
      difficulty: '중간',
      machineType: machineType,
      intervals: [
        Interval(
          id: 'interval-1',
          durationSeconds: 60,
          speedKmh: speedKmh,
        ),
      ],
    );
  }

  test('tracks active elapsed milliseconds without counting paused time', () {
    fakeAsync((async) {
      final baseTime = DateTime(2026, 7, 9, 10);
      final routine = buildRoutine(machineType: MachineType.treadmill);
      final state = WorkoutState(
        routine: routine,
        startTime: baseTime,
        nowProvider: () => baseTime.add(async.elapsed),
      );

      async.elapse(const Duration(milliseconds: 2700));
      expect(state.status, WorkoutStatus.running);

      async.elapse(const Duration(milliseconds: 2500));
      expect(state.totalElapsedMilliseconds, 2500);
      expect(state.roundedElapsedSeconds, 3);

      state.pauseWorkout();
      expect(state.status, WorkoutStatus.paused);

      async.elapse(const Duration(seconds: 5));
      expect(state.totalElapsedMilliseconds, 2500);

      state.startResumeCountdown();
      async.elapse(const Duration(milliseconds: 2700));
      expect(state.status, WorkoutStatus.running);

      async.elapse(const Duration(milliseconds: 1500));
      expect(state.totalElapsedMilliseconds, 4000);
      expect(state.roundedElapsedSeconds, 4);
    });
  });

  test('tracks treadmill distance from active time progression', () {
    fakeAsync((async) {
      final baseTime = DateTime(2026, 7, 9, 10);
      final routine = buildRoutine(
        machineType: MachineType.treadmill,
        speedKmh: 6.0,
      );
      final state = WorkoutState(
        routine: routine,
        startTime: baseTime,
        nowProvider: () => baseTime.add(async.elapsed),
      );

      async.elapse(const Duration(milliseconds: 2700));
      expect(state.status, WorkoutStatus.running);

      async.elapse(const Duration(seconds: 10));

      // 6.0 km/h == 1.666... m/s, so 10 seconds is about 16.67 m.
      expect(state.distanceMeters, closeTo(16.67, 0.2));
      expect(state.roundedElapsedSeconds, 10);
    });
  });
}
