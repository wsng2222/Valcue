import 'package:flutter_test/flutter_test.dart';
import 'package:valcue/features/routines/models/interval.dart';
import 'package:valcue/features/routines/models/machine_type.dart';
import 'package:valcue/features/routines/models/routine.dart';
import 'package:valcue/services/workout_live_activity_schedule_models.dart';
import 'package:valcue/services/workout_live_activity_schedule_planner.dart';

void main() {
  final capturedAt = DateTime.fromMillisecondsSinceEpoch(1700000000000);

  WorkoutLiveActivityScheduleLabels labelsFor(MachineType machineType) {
    return WorkoutLiveActivityScheduleLabels(
      machineName: machineType.name,
      preparingStatusText: 'Preparing',
      runningStatusText: 'In progress',
      finishedStatusText: 'Complete',
      intervalText: (number, total) => '$number/$total',
      durationText: (seconds) => 'duration:$seconds',
      speedLabel: 'Speed',
      inclineLabel: 'Incline',
      resistanceLabel: 'Resistance',
      levelLabel: 'Level',
    );
  }

  final treadmillRoutine = Routine(
    id: 'run',
    name: 'Intervals',
    difficulty: 'medium',
    machineType: MachineType.treadmill,
    intervals: [
      Interval.treadmill(
        id: 'run-1',
        durationSeconds: 60,
        speedKmh: 8,
        grade: 1,
      ),
      Interval.treadmill(
        id: 'run-2',
        durationSeconds: 120,
        speedKmh: 10,
        grade: 2.5,
      ),
      Interval.treadmill(
        id: 'run-3',
        durationSeconds: 30,
        speedKmh: 6,
        grade: 0,
      ),
    ],
  );

  WorkoutLiveActivityScheduleSnapshot snapshot({
    required WorkoutLiveActivitySchedulePhase phase,
    Routine? routine,
    int currentIntervalIndex = 0,
    Duration currentIntervalRemaining = const Duration(seconds: 60),
    Duration totalRemaining = const Duration(seconds: 210),
    Duration countdownRemaining = Duration.zero,
    double progress = 0,
    String measurement = 'kmh',
  }) {
    final selectedRoutine = routine ?? treadmillRoutine;
    return WorkoutLiveActivityScheduleSnapshot(
      routine: selectedRoutine,
      phase: phase,
      currentIntervalIndex: currentIntervalIndex,
      currentIntervalRemaining: currentIntervalRemaining,
      totalRemaining: totalRemaining,
      countdownRemaining: countdownRemaining,
      progress: progress,
      measurement: measurement,
      capturedAt: capturedAt,
      labels: labelsFor(selectedRoutine.machineType),
    );
  }

  group('active boundary semantics', () {
    test('initial countdown starts interval zero then every later interval',
        () {
      final plan = WorkoutLiveActivitySchedulePlanner.build(
        snapshot(
          phase: WorkoutLiveActivitySchedulePhase.initialCountdown,
          countdownRemaining: const Duration(seconds: 3),
        ),
      );

      expect(plan.disposition, WorkoutLiveActivityScheduleDisposition.active);
      expect(
        plan.events.map((event) => event.action),
        [
          WorkoutLiveActivityScheduleEventAction.update,
          WorkoutLiveActivityScheduleEventAction.update,
          WorkoutLiveActivityScheduleEventAction.update,
          WorkoutLiveActivityScheduleEventAction.end,
        ],
      );
      expect(
        plan.events.map((event) => event.deliverAt.millisecondsSinceEpoch),
        [
          1700000003000,
          1700000063000,
          1700000183000,
          1700000213000,
        ],
      );
      expect(
        plan.events.take(3).map((event) => event.contentState['intervalIndex']),
        [1, 2, 3],
      );
      expect(plan.events.first.contentState['timerStartAtMs'], 1700000003000);
      expect(plan.events.first.contentState['timerEndAtMs'], 1700000063000);
      expect(plan.events.first.contentState['workoutEndAtMs'], 1700000213000);
      expect(plan.events.first.contentState['durationText'], 'duration:60');
      expect(
        plan.events.first.staleAt?.millisecondsSinceEpoch,
        1700000063000,
      );
      expect(
        plan.events.last.dismissalAt?.millisecondsSinceEpoch,
        1700000273000,
      );
    });

    test('running begins with the next actual interval boundary', () {
      final plan = WorkoutLiveActivitySchedulePlanner.build(
        snapshot(
          phase: WorkoutLiveActivitySchedulePhase.running,
          currentIntervalRemaining: const Duration(seconds: 20),
          totalRemaining: const Duration(seconds: 170),
          progress: 40 / 210,
        ),
      );

      expect(
        plan.events.map((event) => event.deliverAt.millisecondsSinceEpoch),
        [1700000020000, 1700000140000, 1700000170000],
      );
      expect(plan.events.first.contentState['intervalIndex'], 2);
      expect(plan.events.first.contentState['timerEndAtMs'], 1700000140000);
      expect(plan.events.first.contentState['workoutEndAtMs'], 1700000170000);
      expect(
          plan.events.last.action, WorkoutLiveActivityScheduleEventAction.end);
    });

    test('resume countdown restores the same interval before the next one', () {
      final plan = WorkoutLiveActivitySchedulePlanner.build(
        snapshot(
          phase: WorkoutLiveActivitySchedulePhase.resumeCountdown,
          currentIntervalIndex: 1,
          currentIntervalRemaining: const Duration(seconds: 45),
          totalRemaining: const Duration(seconds: 75),
          countdownRemaining: const Duration(milliseconds: 2700),
          progress: 135 / 210,
        ),
      );

      expect(
        plan.events.map((event) => event.deliverAt.millisecondsSinceEpoch),
        [1700000002700, 1700000047700, 1700000077700],
      );
      expect(plan.events.first.contentState['intervalIndex'], 2);
      expect(plan.events.first.contentState['status'], 'running');
      expect(plan.events.first.contentState['timerEndAtMs'], 1700000047700);
      expect(plan.events[1].contentState['intervalIndex'], 3);
      expect(
          plan.events.last.action, WorkoutLiveActivityScheduleEventAction.end);
    });
  });

  test('pause, finish, and stop contain no future events', () {
    final cases = <WorkoutLiveActivitySchedulePhase,
        WorkoutLiveActivityScheduleDisposition>{
      WorkoutLiveActivitySchedulePhase.paused:
          WorkoutLiveActivityScheduleDisposition.paused,
      WorkoutLiveActivitySchedulePhase.finished:
          WorkoutLiveActivityScheduleDisposition.finished,
      WorkoutLiveActivitySchedulePhase.stopped:
          WorkoutLiveActivityScheduleDisposition.stopped,
    };

    for (final entry in cases.entries) {
      final plan = WorkoutLiveActivitySchedulePlanner.build(
        snapshot(phase: entry.key),
      );
      expect(plan.disposition, entry.value);
      expect(plan.events, isEmpty);
    }
  });

  test('builds display-ready metrics for all three machine types', () {
    final routines = <Routine>[
      Routine(
        id: 'treadmill',
        name: 'Run',
        difficulty: 'easy',
        machineType: MachineType.treadmill,
        intervals: [
          Interval.treadmill(
            durationSeconds: 30,
            speedKmh: 10,
            grade: 2.5,
          ),
        ],
      ),
      Routine(
        id: 'cycle',
        name: 'Ride',
        difficulty: 'easy',
        machineType: MachineType.cycle,
        intervals: [
          Interval.cycle(
            durationSeconds: 30,
            rpm: 85,
            resistance: 7,
          ),
        ],
      ),
      Routine(
        id: 'stairs',
        name: 'Climb',
        difficulty: 'easy',
        machineType: MachineType.stairmaster,
        intervals: [
          Interval.stairmaster(durationSeconds: 30, level: 6),
        ],
      ),
    ];

    final payloads = routines.map((routine) {
      return WorkoutLiveActivitySchedulePlanner.build(
        snapshot(
          phase: WorkoutLiveActivitySchedulePhase.initialCountdown,
          routine: routine,
          currentIntervalRemaining: const Duration(seconds: 30),
          totalRemaining: const Duration(seconds: 30),
          measurement:
              routine.machineType == MachineType.treadmill ? 'mph' : 'kmh',
        ),
      ).events.first.contentState;
    }).toList(growable: false);

    expect(payloads[0]['primaryMetric'], 'Speed 6.2 mph');
    expect(payloads[0]['secondaryMetric'], 'Incline 2.5%');
    expect(payloads[1]['primaryMetric'], 'Resistance 7');
    expect(payloads[1]['secondaryMetric'], '85 RPM');
    expect(payloads[2]['primaryMetric'], 'Level 6');
    expect(payloads[2]['secondaryMetric'], isEmpty);
    expect(payloads.map((payload) => payload['durationText']), [
      'duration:30',
      'duration:30',
      'duration:30',
    ]);
  });

  test('rejects an active empty routine and an invalid current index', () {
    final empty = Routine(
      id: 'empty',
      name: 'Empty',
      difficulty: 'easy',
      intervals: const [],
    );
    expect(
      () => WorkoutLiveActivitySchedulePlanner.build(
        snapshot(
          phase: WorkoutLiveActivitySchedulePhase.running,
          routine: empty,
        ),
      ),
      throwsArgumentError,
    );
    expect(
      () => WorkoutLiveActivitySchedulePlanner.build(
        snapshot(
          phase: WorkoutLiveActivitySchedulePhase.running,
          currentIntervalIndex: 3,
        ),
      ),
      throwsRangeError,
    );
  });

  test('marks plans over the backend event limit without throwing', () {
    final oversizedRoutine = Routine(
      id: 'many-intervals',
      name: 'Many intervals',
      difficulty: 'easy',
      machineType: MachineType.treadmill,
      intervals: List.generate(
        WorkoutLiveActivitySchedulePlan.maximumRemoteEventCount,
        (index) => Interval.treadmill(
          id: 'interval-$index',
          durationSeconds: 1,
          speedKmh: 8,
          grade: 1,
        ),
      ),
    );

    final plan = WorkoutLiveActivitySchedulePlanner.build(
      snapshot(
        phase: WorkoutLiveActivitySchedulePhase.initialCountdown,
        routine: oversizedRoutine,
        currentIntervalRemaining: const Duration(seconds: 1),
        totalRemaining: Duration(
          seconds: oversizedRoutine.totalDurationSeconds,
        ),
      ),
    );

    expect(
      plan.events,
      hasLength(WorkoutLiveActivitySchedulePlan.maximumRemoteEventCount + 1),
    );
    expect(plan.remoteRegistrationValidation.isValid, isFalse);
    expect(
      plan.remoteRegistrationValidation.issue,
      WorkoutLiveActivityScheduleValidationIssue.tooManyEvents,
    );
  });

  test('marks plans beyond the backend eight-hour horizon', () {
    final longRoutine = Routine(
      id: 'long-routine',
      name: 'Long routine',
      difficulty: 'easy',
      machineType: MachineType.stairmaster,
      intervals: List.generate(
        3,
        (index) => Interval.stairmaster(
          id: 'interval-$index',
          durationSeconds: 3 * 60 * 60,
          level: 5,
        ),
      ),
    );

    final plan = WorkoutLiveActivitySchedulePlanner.build(
      snapshot(
        phase: WorkoutLiveActivitySchedulePhase.initialCountdown,
        routine: longRoutine,
        currentIntervalRemaining: const Duration(hours: 3),
        totalRemaining: const Duration(hours: 9),
      ),
    );

    expect(plan.remoteRegistrationValidation.isValid, isFalse);
    expect(
      plan.remoteRegistrationValidation.issue,
      WorkoutLiveActivityScheduleValidationIssue.exceedsMaximumHorizon,
    );
  });
}
