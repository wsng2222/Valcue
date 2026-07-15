import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valcue/features/routines/models/interval.dart';
import 'package:valcue/features/routines/models/machine_type.dart';
import 'package:valcue/features/routines/models/routine.dart';
import 'package:valcue/features/workout/state/workout_state.dart';

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

  test('reconciles a suspended clock jump across multiple intervals', () {
    fakeAsync((async) {
      final baseTime = DateTime(2026, 7, 9, 10);
      var now = baseTime;
      final routine = Routine(
        id: 'multi-interval',
        name: 'Background Test',
        difficulty: '중간',
        machineType: MachineType.treadmill,
        intervals: [
          Interval.treadmill(
            id: 'one',
            durationSeconds: 10,
            speedKmh: 6,
            grade: 0,
          ),
          Interval.treadmill(
            id: 'two',
            durationSeconds: 5,
            speedKmh: 12,
            grade: 2,
          ),
          Interval.treadmill(
            id: 'three',
            durationSeconds: 10,
            speedKmh: 3,
            grade: 0,
          ),
        ],
      );
      final state = WorkoutState(
        routine: routine,
        startTime: baseTime,
        nowProvider: () => now,
      );

      // Finish the actual 2.7-second initial countdown without firing timers.
      now = baseTime.add(const Duration(milliseconds: 2700));
      state.synchronizeWithClock();
      expect(state.status, WorkoutStatus.running);

      // A 12-second OS suspension crosses the first interval boundary.
      now = baseTime.add(const Duration(milliseconds: 14700));
      state.synchronizeWithClock();

      expect(state.currentIntervalIndex, 1);
      expect(state.remainingSeconds, 3);
      expect(state.totalElapsedMilliseconds, 12000);
      // 10s @ 6km/h + 2s @ 12km/h.
      expect(state.distanceMeters, closeTo(23.33, 0.02));

      // Exact boundaries select the newly started interval.
      now = baseTime.add(const Duration(milliseconds: 17700));
      state.synchronizeWithClock();
      expect(state.currentIntervalIndex, 2);
      expect(state.remainingSeconds, 10);

      state.dispose();
    });
  });

  test('background resume clamps natural completion to the routine plan', () {
    fakeAsync((async) {
      final baseTime = DateTime(2026, 7, 9, 10);
      var now = baseTime;
      final routine = buildRoutine(
        machineType: MachineType.treadmill,
        speedKmh: 6,
      );
      final state = WorkoutState(
        routine: routine,
        startTime: baseTime,
        nowProvider: () => now,
      );

      now = baseTime.add(const Duration(milliseconds: 2700));
      state.synchronizeWithClock();
      now = baseTime.add(const Duration(milliseconds: 12700));
      state.suspendForBackground();

      now = baseTime.add(const Duration(minutes: 5));
      state.resumeFromBackground();

      expect(state.status, WorkoutStatus.finished);
      expect(state.totalElapsedMilliseconds, 60000);
      expect(state.remainingSeconds, 0);
      expect(state.stoppedEarly, isFalse);
      expect(state.distanceMeters, closeTo(100, 0.02));

      state.dispose();
    });
  });

  test('user pause freezes time while resume countdown stays excluded', () {
    fakeAsync((async) {
      final baseTime = DateTime(2026, 7, 9, 10);
      var now = baseTime;
      final state = WorkoutState(
        routine: buildRoutine(machineType: MachineType.cycle),
        startTime: baseTime,
        nowProvider: () => now,
      );

      now = baseTime.add(const Duration(milliseconds: 2700));
      state.synchronizeWithClock();
      now = baseTime.add(const Duration(milliseconds: 7700));
      state.pauseWorkout();
      expect(state.totalElapsedMilliseconds, 5000);

      now = baseTime.add(const Duration(minutes: 2));
      state.synchronizeWithClock();
      expect(state.totalElapsedMilliseconds, 5000);

      state.startResumeCountdown();
      now = now.add(const Duration(milliseconds: 2700));
      state.synchronizeWithClock();
      expect(state.status, WorkoutStatus.running);
      expect(state.totalElapsedMilliseconds, 5000);

      now = now.add(const Duration(seconds: 2));
      state.synchronizeWithClock();
      expect(state.totalElapsedMilliseconds, 7000);

      state.dispose();
    });
  });
}
