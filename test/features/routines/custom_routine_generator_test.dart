import 'package:flutter_test/flutter_test.dart';
import 'package:valcue/features/routines/models/interval.dart';
import 'package:valcue/features/routines/models/machine_type.dart';
import 'package:valcue/features/routines/utils/custom_routine_generator.dart';

void main() {
  group('CustomRoutineGenerator', () {
    test('builds block-based intervals instead of 60-second chunks', () {
      final intervals = buildCustomRoutineIntervals(
        machineType: MachineType.treadmill,
        durationMinutes: 60,
        distanceTargetKm: 10.0,
        caloriesTarget: 50,
        bodyWeightKg: 70.0,
        includeIncline: true,
      );

      expect(intervals.first.durationSeconds, 180);
      expect(intervals.last.durationSeconds, 120);
      expect(intervals.any((interval) => interval.durationSeconds == 60), isFalse);
      expect(intervals.where((interval) => interval.durationSeconds == 180).length,
          greaterThan(0));
      expect(intervals.where((interval) => interval.durationSeconds == 120).length,
          greaterThan(0));
    });

    test('matches the requested time and distance for easy treadmill routines', () {
      final intervals = buildCustomRoutineIntervals(
        machineType: MachineType.treadmill,
        durationMinutes: 60,
        distanceTargetKm: 8.0,
        caloriesTarget: 180,
        bodyWeightKg: 70.0,
        includeIncline: false,
        difficulty: 'easy',
      );

      final totalSeconds = intervals.fold<int>(0, (sum, interval) => sum + interval.durationSeconds);
      final totalDistanceKm = intervals.fold<double>(0.0, (sum, interval) {
        final speed = interval.speedKmh;
        if (speed == null) return sum;
        return sum + (speed * interval.durationSeconds / 3600.0);
      });

      expect(totalSeconds, equals(3600));
      expect(totalDistanceKm, inInclusiveRange(7.8, 8.2));
    });
  });

  // Every combination the form can produce, checked against the promises a
  // generated routine makes: its length, its target, and its safety limits.
  group('every reachable combination', () {
    double measure(MachineType machine, List<Interval> intervals) =>
        switch (machine) {
          MachineType.treadmill => treadmillDistanceKm(intervals),
          MachineType.cycle => cycleDistanceKm(intervals),
          MachineType.stairmaster => stairmasterFloorsClimbed(intervals),
        };

    for (final machine in MachineType.values) {
      test('${machine.name} routines keep their promises', () {
        for (var minutes = 10; minutes <= 60; minutes += 5) {
          for (final difficulty in ['easy', 'medium', 'hard']) {
            for (final warmup in [true, false]) {
              final range = customRoutineTargetRange(
                machineType: machine,
                durationMinutes: minutes,
                difficulty: difficulty,
                includeWarmupCooldown: warmup,
              );
              expect(range.max, greaterThan(range.min));

              for (var pattern = 0; pattern < 3; pattern++) {
                for (final fraction in [0.0, 0.5, 1.0]) {
                  final target = range.min + (range.max - range.min) * fraction;
                  final label = '${machine.name} ${minutes}min $difficulty '
                      'warmup=$warmup pattern=$pattern target=$target';
                  final intervals = buildCustomRoutineIntervals(
                    machineType: machine,
                    durationMinutes: minutes,
                    distanceTargetKm: target,
                    caloriesTarget: 0,
                    bodyWeightKg: 70,
                    includeWarmupCooldown: warmup,
                    stairsTargetFloors: target.round(),
                    variationSeed: pattern,
                    difficulty: difficulty,
                    randomSeed: 42,
                  );

                  final seconds = intervals.fold<int>(
                      0, (sum, interval) => sum + interval.durationSeconds);
                  expect(seconds, minutes * 60, reason: label);
                  for (final interval in intervals) {
                    expect(interval.durationSeconds, greaterThanOrEqualTo(60),
                        reason: label);
                    expect(interval.durationSeconds % 30, 0, reason: label);
                  }

                  final goal = machine == MachineType.stairmaster
                      ? target.roundToDouble()
                      : target;
                  final tolerance =
                      machine == MachineType.stairmaster ? 0.10 : 0.03;
                  expect(
                    (measure(machine, intervals) - goal).abs() / goal,
                    lessThanOrEqualTo(tolerance),
                    reason: label,
                  );

                  final main = intervals
                      .where((interval) => interval.groupId != null)
                      .toList();
                  if (machine == MachineType.treadmill) {
                    final cap = {'easy': 11.0, 'medium': 13.0, 'hard': 16.0}[
                        difficulty]!;
                    final speeds = main.map((i) => i.speedKmh!).toList();
                    final fastest = speeds.reduce((a, b) => a > b ? a : b);
                    final slowest = speeds.reduce((a, b) => a < b ? a : b);
                    expect(fastest, lessThanOrEqualTo(cap), reason: label);
                    expect(fastest - slowest, greaterThanOrEqualTo(2.0),
                        reason: label);
                  }
                  if (machine == MachineType.stairmaster) {
                    final levels = main.map((i) => i.level!).toList();
                    final highest = levels.reduce((a, b) => a > b ? a : b);
                    final lowest = levels.reduce((a, b) => a < b ? a : b);
                    expect(highest - lowest, greaterThanOrEqualTo(3),
                        reason: label);
                  }
                }
              }
            }
          }
        }
      });
    }
  });
}
