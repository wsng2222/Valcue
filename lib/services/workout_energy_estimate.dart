import '../features/profile/models/workout_session.dart';
import '../features/routines/models/machine_type.dart';

/// Estimates the active energy of a finished workout so it can count towards
/// the activity rings.
///
/// The app measures time, and distance on a treadmill - it does not measure
/// effort, so this is an estimate and nothing more. It uses the standard MET
/// method: kcal = MET x 3.5 x bodyWeightKg / 200 x minutes.
///
/// Everything here is deliberately conservative. Overstating burned calories
/// is the failure people notice and resent, so where a machine gives us no
/// intensity signal we assume a moderate effort rather than a hard one.
class WorkoutEnergyEstimate {
  /// Used when the person has never recorded a weight. Roughly the global
  /// adult average; without it nobody who skips weight tracking would ever
  /// see their rings move.
  static const double assumedBodyWeightKg = 70;

  /// Below this, treat treadmill work as walking rather than running.
  static const double _walkRunThresholdKmh = 7.0;

  /// Active energy in kilocalories, or null when the workout is too short or
  /// the inputs make no sense.
  static int? kilocaloriesFor(
    WorkoutSession session, {
    double? bodyWeightKg,
  }) {
    final minutes = session.durationSeconds / 60;
    if (minutes <= 0) return null;

    final weight = (bodyWeightKg != null && bodyWeightKg > 0)
        ? bodyWeightKg
        : assumedBodyWeightKg;

    final met = _metFor(session);
    final kcal = met * 3.5 * weight / 200 * minutes;
    if (kcal < 1) return null;
    return kcal.round();
  }

  static double _metFor(WorkoutSession session) {
    switch (session.machineType) {
      case MachineType.treadmill:
        return _treadmillMet(_averageSpeedKmh(session));
      case MachineType.cycle:
        // RPM alone says nothing about resistance, so this stays at the
        // compendium's "moderate effort" stationary cycling value.
        return 7.0;
      case MachineType.stairmaster:
        return 9.0;
    }
  }

  /// Average speed over the session, or null when distance was not measured.
  static double? _averageSpeedKmh(WorkoutSession session) {
    final distance = session.distanceMeters;
    if (distance == null || distance <= 0) return null;
    if (session.durationSeconds <= 0) return null;
    return (distance / 1000) / (session.durationSeconds / 3600);
  }

  /// Compendium of Physical Activities values, interpolated between the
  /// anchor speeds so a small pace change does not jump the estimate.
  static double _treadmillMet(double? speedKmh) {
    // No distance recorded - assume a moderate jog rather than a sprint.
    if (speedKmh == null || speedKmh <= 0) return 7.0;

    const anchors = <(double, double)>[
      (3.2, 2.8), // slow walk
      (5.6, 4.3), // brisk walk
      (_walkRunThresholdKmh, 6.0), // walk/run boundary
      (8.0, 8.3),
      (9.7, 9.8),
      (11.3, 11.0),
      (12.9, 11.8),
      (14.5, 12.8),
      (16.1, 14.5),
    ];

    if (speedKmh <= anchors.first.$1) return anchors.first.$2;
    if (speedKmh >= anchors.last.$1) return anchors.last.$2;

    for (var i = 0; i < anchors.length - 1; i++) {
      final (lowSpeed, lowMet) = anchors[i];
      final (highSpeed, highMet) = anchors[i + 1];
      if (speedKmh <= highSpeed) {
        final t = (speedKmh - lowSpeed) / (highSpeed - lowSpeed);
        return lowMet + (highMet - lowMet) * t;
      }
    }
    return anchors.last.$2;
  }
}
