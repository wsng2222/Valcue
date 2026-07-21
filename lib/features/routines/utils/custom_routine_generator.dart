import '../models/interval.dart';
import '../models/machine_type.dart';
import 'dart:math';

List<Interval> buildCustomRoutineIntervals({
  required MachineType machineType,
  required int durationMinutes,
  required double distanceTargetKm,
  required int caloriesTarget,
  required double bodyWeightKg,
  required bool includeIncline,
  String difficulty = 'medium',
}) {
  final random = Random();
  final intervals = <Interval>[];
  final totalSeconds = durationMinutes * 60;
  int remainingSeconds = totalSeconds - 180 - 120;
  if (remainingSeconds < 120) remainingSeconds = 120;

  if (machineType == MachineType.treadmill) {
    double avgSpeed = distanceTargetKm / (durationMinutes / 60.0);
    avgSpeed = avgSpeed.clamp(4.0, 15.0);

    final speedSpread = difficulty == 'easy'
        ? 0.4
        : (difficulty == 'hard' ? 1.2 : 0.8);

    double baseWarmupSpeed = (avgSpeed - 0.5).clamp(3.5, 6.0);
    double cooldownSpeed = (avgSpeed - 0.8).clamp(3.0, 5.0);

    double speedMMin = avgSpeed * 16.67;
    double baseCaloriesPerMin =
        (3.5 + 0.2 * speedMMin) * bodyWeightKg / 200.0;
    double baseKcal = baseCaloriesPerMin * durationMinutes;

    double avgGrade = 0.0;
    double workGrade = 0.0;
    double restGrade = 0.0;
    double warmupGrade = 0.0;

    if (includeIncline) {
      if (caloriesTarget > baseKcal) {
        double diff =
            (caloriesTarget * 200.0 / bodyWeightKg) / durationMinutes -
                (3.5 + 0.2 * speedMMin);
        if (diff > 0) {
          avgGrade = (diff / (0.9 * speedMMin)) * 100.0;
        }
      }
      avgGrade = avgGrade.clamp(0.0, 12.0);
      workGrade = (avgGrade * 1.4).clamp(0.0, 15.0);
      restGrade = (avgGrade * 0.6).clamp(0.0, 8.0);
      warmupGrade = 1.0;
    } else {
      if (caloriesTarget > baseKcal) {
        double targetPerMin =
            (caloriesTarget * 200.0) / (bodyWeightKg * durationMinutes);
        double neededSpeedMMin = (targetPerMin - 3.5) / 0.2;
        avgSpeed = neededSpeedMMin / 16.67;
        avgSpeed = avgSpeed.clamp(4.0, 16.0);
        baseWarmupSpeed = (avgSpeed - 1.5).clamp(3.5, 6.0);
        cooldownSpeed = (avgSpeed - 2.0).clamp(3.0, 5.0);
      }
    }

    double workSpeed = (avgSpeed + speedSpread).clamp(4.5, 16.0);
    double restSpeed = (avgSpeed - speedSpread).clamp(3.0, 10.0);

    intervals.add(Interval.treadmill(
      durationSeconds: 180,
      speedKmh: double.parse(baseWarmupSpeed.toStringAsFixed(1)),
      grade: warmupGrade,
    ));

    final workBlockDuration = difficulty == 'easy'
        ? 120
        : (difficulty == 'hard' ? 240 : 180);
    final recoveryBlockDuration = difficulty == 'easy'
        ? 90
        : (difficulty == 'hard' ? 60 : 120);
    final groupId = 'ai_group_${random.nextInt(10000)}';

    var mainSecondsLeft = remainingSeconds;
    while (mainSecondsLeft > 0) {
      final workDuration = mainSecondsLeft >= workBlockDuration
          ? workBlockDuration
          : mainSecondsLeft;
      intervals.add(Interval.treadmill(
        durationSeconds: workDuration,
        speedKmh: double.parse(workSpeed.toStringAsFixed(1)),
        grade: double.parse(workGrade.toStringAsFixed(1)),
        groupId: groupId,
        repeatCount: 1,
      ));
      mainSecondsLeft -= workDuration;
      if (mainSecondsLeft <= 0) break;

      final recoveryDuration = mainSecondsLeft >= recoveryBlockDuration
          ? recoveryBlockDuration
          : mainSecondsLeft;
      intervals.add(Interval.treadmill(
        durationSeconds: recoveryDuration,
        speedKmh: double.parse(restSpeed.toStringAsFixed(1)),
        grade: double.parse(restGrade.toStringAsFixed(1)),
        groupId: groupId,
        repeatCount: 1,
      ));
      mainSecondsLeft -= recoveryDuration;
    }

    intervals.add(Interval.treadmill(
      durationSeconds: 120,
      speedKmh: double.parse(cooldownSpeed.toStringAsFixed(1)),
      grade: 0.0,
    ));
  } else if (machineType == MachineType.cycle) {
    double avgSpeed = distanceTargetKm / (durationMinutes / 60.0);
    double avgRpm = (avgSpeed * 2.8).clamp(50.0, 110.0);

    double avgRes = caloriesTarget /
        (avgRpm * durationMinutes * 0.002 * (bodyWeightKg / 200.0));
    avgRes = avgRes.clamp(2.0, 18.0);

    intervals.add(Interval.cycle(
      durationSeconds: 180,
      rpm: (avgRpm - 10).clamp(50, 90).toInt(),
      resistance: (avgRes - 2).clamp(1, 15).toInt(),
    ));

    final workBlockDuration = difficulty == 'easy'
        ? 120
        : (difficulty == 'hard' ? 240 : 180);
    final recoveryBlockDuration = difficulty == 'easy'
        ? 90
        : (difficulty == 'hard' ? 60 : 120);
    final groupId = 'ai_group_${random.nextInt(10000)}';

    var mainSecondsLeft = remainingSeconds;
    while (mainSecondsLeft > 0) {
      final workDuration = mainSecondsLeft >= workBlockDuration
          ? workBlockDuration
          : mainSecondsLeft;
      intervals.add(Interval.cycle(
        durationSeconds: workDuration,
        rpm: (avgRpm + 12).clamp(60, 120).toInt(),
        resistance: (avgRes + 2).clamp(2, 20).toInt(),
        groupId: groupId,
        repeatCount: 1,
      ));
      mainSecondsLeft -= workDuration;
      if (mainSecondsLeft <= 0) break;

      final recoveryDuration = mainSecondsLeft >= recoveryBlockDuration
          ? recoveryBlockDuration
          : mainSecondsLeft;
      intervals.add(Interval.cycle(
        durationSeconds: recoveryDuration,
        rpm: (avgRpm - 8).clamp(45, 95).toInt(),
        resistance: (avgRes - 1).clamp(1, 16).toInt(),
        groupId: groupId,
        repeatCount: 1,
      ));
      mainSecondsLeft -= recoveryDuration;
    }

    intervals.add(Interval.cycle(
      durationSeconds: 120,
      rpm: (avgRpm - 15).clamp(45, 80).toInt(),
      resistance: (avgRes - 3).clamp(1, 12).toInt(),
    ));
  } else {
    double floorsPerMin = 0.0;
    if (durationMinutes > 0) {
      floorsPerMin = 50 / durationMinutes;
    }
    double stepsPerMin = floorsPerMin * 16.0;
    double avgLevel = (stepsPerMin / 6.0).clamp(3.0, 15.0);

    double baseCaloriesPerMin = avgLevel * bodyWeightKg * 0.05;
    double baseKcal = baseCaloriesPerMin * durationMinutes;
    double levelDelta = 0.0;
    if (caloriesTarget > baseKcal) {
      levelDelta = ((caloriesTarget - baseKcal) /
              (bodyWeightKg * durationMinutes * 0.05))
          .clamp(0.0, 4.0);
    }

    intervals.add(Interval.stairmaster(
      durationSeconds: 180,
      level: (avgLevel - 2).clamp(2, 12).toInt(),
    ));

    final workBlockDuration = difficulty == 'easy'
        ? 120
        : (difficulty == 'hard' ? 240 : 180);
    final recoveryBlockDuration = difficulty == 'easy'
        ? 90
        : (difficulty == 'hard' ? 60 : 120);
    final groupId = 'ai_group_${random.nextInt(10000)}';

    var mainSecondsLeft = remainingSeconds;
    while (mainSecondsLeft > 0) {
      final workDuration = mainSecondsLeft >= workBlockDuration
          ? workBlockDuration
          : mainSecondsLeft;
      intervals.add(Interval.stairmaster(
        durationSeconds: workDuration,
        level: (avgLevel + levelDelta).clamp(4, 20).toInt(),
        groupId: groupId,
        repeatCount: 1,
      ));
      mainSecondsLeft -= workDuration;
      if (mainSecondsLeft <= 0) break;

      final recoveryDuration = mainSecondsLeft >= recoveryBlockDuration
          ? recoveryBlockDuration
          : mainSecondsLeft;
      intervals.add(Interval.stairmaster(
        durationSeconds: recoveryDuration,
        level: (avgLevel - (levelDelta / 2)).clamp(2, 14).toInt(),
        groupId: groupId,
        repeatCount: 1,
      ));
      mainSecondsLeft -= recoveryDuration;
    }

    intervals.add(Interval.stairmaster(
      durationSeconds: 120,
      level: (avgLevel - 3).clamp(1, 10).toInt(),
    ));
  }

  return intervals;
}
