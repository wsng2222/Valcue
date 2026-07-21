import 'package:flutter_test/flutter_test.dart';
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
}
