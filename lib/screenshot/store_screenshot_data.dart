import '../features/profile/models/workout_session.dart';
import '../features/routines/models/interval.dart';
import '../features/routines/models/machine_type.dart';
import '../features/routines/models/routine.dart';

/// Enables deterministic, in-memory content for App Store captures.
///
/// Run with:
/// Debug builds default to screenshot mode while the store assets are being
/// captured. Release builds remain on real user data unless explicitly enabled.
const bool kStoreScreenshotMode = bool.fromEnvironment(
  'STORE_SCREENSHOT_MODE',
  defaultValue: false,
);

Routine buildStoreScreenshotRoutine({
  String name = '30-Minute Interval Run',
}) {
  final workBlock = <Interval>[];
  for (var repetition = 0; repetition < 5; repetition++) {
    workBlock.addAll([
      Interval.treadmill(
        id: 'store-fast-$repetition',
        durationSeconds: 120,
        speedKmh: 10.0,
        grade: 1.0,
        groupId: 'store-main-set',
        repeatCount: 5,
      ),
      Interval.treadmill(
        id: 'store-recovery-$repetition',
        durationSeconds: 120,
        speedKmh: 6.0,
        grade: 1.0,
        groupId: 'store-main-set',
        repeatCount: 5,
      ),
    ]);
  }

  return Routine(
    id: 'store-30-minute-intervals',
    name: name,
    difficulty: '중간',
    machineType: MachineType.treadmill,
    intervals: [
      Interval.treadmill(
        id: 'store-warm-up',
        durationSeconds: 300,
        speedKmh: 6.0,
        grade: 1.0,
      ),
      ...workBlock,
      Interval.treadmill(
        id: 'store-cool-down',
        durationSeconds: 300,
        speedKmh: 5.5,
        grade: 0.0,
      ),
    ],
  );
}

Routine buildStoreLiveWorkoutRoutine({required String name}) {
  const durations = <int>[240, 180, 180, 180, 180, 180, 180, 180, 180, 60, 60];
  const speeds = <double>[
    9.0,
    9.0,
    6.0,
    10.0,
    6.0,
    10.5,
    6.0,
    11.0,
    6.0,
    9.5,
    5.5
  ];

  return Routine(
    id: 'store-live-workout',
    name: name,
    difficulty: '중간',
    machineType: MachineType.treadmill,
    intervals: [
      for (var index = 0; index < durations.length; index++)
        Interval.treadmill(
          id: 'store-live-$index',
          durationSeconds: durations[index],
          speedKmh: speeds[index],
          grade: index == durations.length - 1 ? 0.0 : 1.0,
        ),
    ],
  );
}

List<WorkoutSession> buildStoreScreenshotSessions({
  DateTime? now,
  String morningTempo = 'Morning Tempo',
  String speedIntervals = 'Speed Intervals',
  String enduranceRun = 'Endurance Run',
}) {
  final anchor = now ?? DateTime.now();

  DateTime atDaysAgo(int days, int hour, int minute) {
    final date = anchor.subtract(Duration(days: days));
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  return [
    WorkoutSession(
      id: 'store-treadmill-today',
      machineType: MachineType.treadmill,
      dateTime: atDaysAgo(0, 7, 30),
      durationSeconds: 32 * 60,
      elapsedMilliseconds: 32 * 60 * 1000,
      distanceMeters: 5250,
      routineName: morningTempo,
      routineId: 'store-morning-tempo',
    ),
    WorkoutSession(
      id: 'store-cycle-today',
      machineType: MachineType.cycle,
      dateTime: atDaysAgo(0, 18, 10),
      durationSeconds: 35 * 60,
      averageRpm: 86,
      routineName: 'Power Ride',
      routineId: 'store-power-ride',
    ),
    WorkoutSession(
      id: 'store-treadmill-yesterday',
      machineType: MachineType.treadmill,
      dateTime: atDaysAgo(1, 18, 20),
      durationSeconds: 28 * 60,
      elapsedMilliseconds: 28 * 60 * 1000,
      distanceMeters: 4100,
      routineName: speedIntervals,
      routineId: 'store-speed-intervals',
    ),
    WorkoutSession(
      id: 'store-stairs-yesterday',
      machineType: MachineType.stairmaster,
      dateTime: atDaysAgo(1, 12, 15),
      durationSeconds: 24 * 60,
      averageLevel: 7.5,
      routineName: 'Steady Climb',
      routineId: 'store-steady-climb',
    ),
    WorkoutSession(
      id: 'store-treadmill-three-days',
      machineType: MachineType.treadmill,
      dateTime: atDaysAgo(3, 7, 10),
      durationSeconds: 42 * 60,
      elapsedMilliseconds: 42 * 60 * 1000,
      distanceMeters: 6800,
      routineName: enduranceRun,
      routineId: 'store-endurance-run',
    ),
    WorkoutSession(
      id: 'store-cycle-four-days',
      machineType: MachineType.cycle,
      dateTime: atDaysAgo(4, 19, 0),
      durationSeconds: 30 * 60,
      averageRpm: 82,
      routineName: 'Tempo Ride',
      routineId: 'store-tempo-ride',
    ),
    WorkoutSession(
      id: 'store-stairs-five-days',
      machineType: MachineType.stairmaster,
      dateTime: atDaysAgo(5, 6, 50),
      durationSeconds: 27 * 60,
      averageLevel: 8.0,
      routineName: 'Summit Steps',
      routineId: 'store-summit-steps',
    ),
  ];
}
