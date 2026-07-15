import 'package:flutter_test/flutter_test.dart';
import 'package:valcue/features/routines/models/interval.dart';
import 'package:valcue/features/routines/models/machine_type.dart';
import 'package:valcue/features/routines/models/routine.dart';
import 'package:valcue/services/workout_interval_notification_planner.dart';

void main() {
  const labels = WorkoutNotificationLabels(
    newInterval: '새 구간 시작',
    workoutComplete: '운동 완료',
    speed: '속도',
    incline: '경사도',
    resistance: '저항',
    level: '레벨',
    duration: '시간',
  );

  Routine routineFor(MachineType machineType, List<Interval> intervals) {
    return Routine(
      id: 'routine-1',
      name: '테스트 루틴',
      difficulty: '중간',
      machineType: machineType,
      intervals: intervals,
    );
  }

  test('plans only future interval starts and includes full duration', () {
    final routine = routineFor(MachineType.treadmill, [
      Interval.treadmill(
        id: 'one',
        durationSeconds: 60,
        speedKmh: 6,
        grade: 1,
      ),
      Interval.treadmill(
        id: 'two',
        durationSeconds: 90,
        speedKmh: 8,
        grade: 3,
      ),
    ]);

    final planned = WorkoutIntervalNotificationPlanner.build(
      routine: routine,
      firstIntervalIndex: 1,
      delayUntilFirstInterval: const Duration(seconds: 30),
      measurement: 'kmh',
      languageCode: 'ko',
      labels: labels,
    );

    expect(planned, hasLength(2));
    expect(planned.first.intervalIndex, 1);
    expect(planned.first.delay, const Duration(seconds: 30));
    expect(planned.first.title, '새 구간 시작 · 2/2');
    expect(
      planned.first.body,
      '속도 8.0 km/h · 경사도 3% · 1분 30초 동안',
    );
    expect(planned.last.intervalIndex, isNull);
    expect(planned.last.delay, const Duration(seconds: 120));
  });

  test('initial countdown plans interval one at countdown completion', () {
    final routine = routineFor(MachineType.cycle, [
      Interval.cycle(
        id: 'one',
        durationSeconds: 120,
        rpm: 80,
        resistance: 7,
      ),
    ]);

    final planned = WorkoutIntervalNotificationPlanner.build(
      routine: routine,
      firstIntervalIndex: 0,
      delayUntilFirstInterval: const Duration(milliseconds: 2700),
      measurement: 'kmh',
      languageCode: 'ko',
      labels: labels,
    );

    expect(planned.first.delay, const Duration(milliseconds: 2700));
    expect(planned.first.title, '새 구간 시작 · 1/1');
    expect(planned.first.body, '저항 7 · 80 RPM · 2분 동안');
    expect(planned.last.delay, const Duration(milliseconds: 122700));
  });

  test('formats StairMaster level and converts treadmill speed to mph', () {
    final stairRoutine = routineFor(MachineType.stairmaster, [
      Interval.stairmaster(
        id: 'stairs',
        durationSeconds: 70,
        level: 6,
      ),
    ]);
    final stairPlan = WorkoutIntervalNotificationPlanner.build(
      routine: stairRoutine,
      firstIntervalIndex: 0,
      delayUntilFirstInterval: Duration.zero,
      measurement: 'kmh',
      languageCode: 'ko',
      labels: labels,
    );
    expect(stairPlan.first.body, '레벨 6 · 1분 10초 동안');

    final treadmillRoutine = routineFor(MachineType.treadmill, [
      Interval.treadmill(
        id: 'treadmill',
        durationSeconds: 60,
        speedKmh: 8,
        grade: 2.5,
      ),
    ]);
    final treadmillPlan = WorkoutIntervalNotificationPlanner.build(
      routine: treadmillRoutine,
      firstIntervalIndex: 0,
      delayUntilFirstInterval: Duration.zero,
      measurement: 'mph',
      languageCode: 'ko',
      labels: labels,
    );
    expect(
      treadmillPlan.first.body,
      '속도 5.0 mph · 경사도 2.5% · 1분 동안',
    );
  });

  test('does not duplicate the current final interval', () {
    final routine = routineFor(MachineType.stairmaster, [
      Interval.stairmaster(
        id: 'final',
        durationSeconds: 60,
        level: 5,
      ),
    ]);

    final planned = WorkoutIntervalNotificationPlanner.build(
      routine: routine,
      firstIntervalIndex: 1,
      delayUntilFirstInterval: const Duration(seconds: 25),
      measurement: 'kmh',
      languageCode: 'ko',
      labels: labels,
    );

    expect(planned, hasLength(1));
    expect(planned.single.intervalIndex, isNull);
    expect(planned.single.delay, const Duration(seconds: 25));
  });

  test('formats hours, minutes, and seconds in supported duration styles', () {
    expect(
      WorkoutIntervalNotificationPlanner.formatDuration(3670, 'ko'),
      '1시간 1분 10초',
    );
    expect(
      WorkoutIntervalNotificationPlanner.formatDuration(90, 'en'),
      '1 min 30 sec',
    );
    expect(
      WorkoutIntervalNotificationPlanner.formatDuration(90, 'ja'),
      '1分30秒',
    );
  });
}
