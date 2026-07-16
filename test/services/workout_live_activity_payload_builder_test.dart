import 'package:flutter_test/flutter_test.dart';
import 'package:valcue/features/routines/models/interval.dart';
import 'package:valcue/features/routines/models/machine_type.dart';
import 'package:valcue/features/routines/models/routine.dart';
import 'package:valcue/services/workout_live_activity_payload_builder.dart';

void main() {
  final now = DateTime.fromMillisecondsSinceEpoch(1700000000000);

  Map<String, dynamic> build(
    Routine routine, {
    WorkoutLiveActivityPhase phase = WorkoutLiveActivityPhase.running,
    String measurement = 'kmh',
  }) {
    return WorkoutLiveActivityPayloadBuilder.build(
      routine: routine,
      intervalIndex: 0,
      phase: phase,
      intervalRemaining: const Duration(seconds: 61, milliseconds: 1),
      totalRemaining: const Duration(minutes: 5),
      countdownRemaining: const Duration(seconds: 3),
      progress: 0.25,
      measurement: measurement,
      now: now,
      machineName: routine.machineType.name,
      statusText: phase.name,
      intervalText: '1/1',
      durationText: '2 min',
      speedLabel: 'Speed',
      inclineLabel: 'Incline',
      resistanceLabel: 'Resistance',
      levelLabel: 'Level',
    );
  }

  test('builds treadmill metrics and precise running deadlines', () {
    final payload = build(
      Routine(
        id: 'run',
        name: 'Run',
        difficulty: 'easy',
        machineType: MachineType.treadmill,
        intervals: [
          Interval.treadmill(
            durationSeconds: 120,
            speedKmh: 10,
            grade: 2.5,
          ),
        ],
      ),
      measurement: 'mph',
    );

    expect(payload['primaryMetric'], 'Speed 6.2 mph');
    expect(payload['secondaryMetric'], 'Incline 2.5%');
    expect(payload['machineSymbol'], 'figure.run');
    expect(payload['timerEndAtMs'], 1700000061001);
    expect(payload['workoutEndAtMs'], 1700000300000);
    expect(payload['pausedRemainingSeconds'], 62);
    expect(payload['progress'], 0.25);
  });

  test('builds cycle metrics', () {
    final payload = build(
      Routine(
        id: 'cycle',
        name: 'Cycle',
        difficulty: 'easy',
        machineType: MachineType.cycle,
        intervals: [
          Interval.cycle(
            durationSeconds: 120,
            resistance: 7,
            rpm: 85,
          ),
        ],
      ),
    );

    expect(payload['primaryMetric'], 'Resistance 7');
    expect(payload['secondaryMetric'], '85 RPM');
    expect(payload['machineSymbol'], 'bicycle');
  });

  test('builds stairmaster metrics without a secondary value', () {
    final payload = build(
      Routine(
        id: 'stairs',
        name: 'Stairs',
        difficulty: 'easy',
        machineType: MachineType.stairmaster,
        intervals: [
          Interval.stairmaster(durationSeconds: 120, level: 6),
        ],
      ),
    );

    expect(payload['primaryMetric'], 'Level 6');
    expect(payload['secondaryMetric'], isEmpty);
    expect(payload['machineSymbol'], 'figure.stair.stepper');
  });

  test('preparing deadline includes countdown and paused stops timers', () {
    final routine = Routine(
      id: 'run',
      name: 'Run',
      difficulty: 'easy',
      intervals: [
        Interval.treadmill(
          durationSeconds: 120,
          speedKmh: 8,
          grade: 0,
        ),
      ],
    );

    final preparing = build(
      routine,
      phase: WorkoutLiveActivityPhase.preparing,
    );
    final paused = build(
      routine,
      phase: WorkoutLiveActivityPhase.paused,
    );

    expect(preparing['timerEndAtMs'], 1700000003000);
    expect(preparing['workoutEndAtMs'], 1700000303000);
    expect(paused['timerEndAtMs'], 0);
    expect(paused['workoutEndAtMs'], 0);
  });

  test('rejects an empty routine', () {
    final routine = Routine(
      id: 'empty',
      name: 'Empty',
      difficulty: 'easy',
      intervals: const [],
    );

    expect(() => build(routine), throwsArgumentError);
  });
}
