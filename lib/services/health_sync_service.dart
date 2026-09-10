import 'dart:io';

import 'package:health/health.dart';

import '../features/profile/models/workout_session.dart';
import '../features/routines/models/machine_type.dart';
import '../utils/debug_log.dart';
import 'ios_health_workout_channel.dart';
import 'workout_energy_estimate.dart';

/// What happened when a workout was handed to the platform health store.
enum HealthSyncOutcome {
  /// The workout is now in Apple Health / Health Connect.
  written,

  /// The person has not switched the setting on.
  disabled,

  /// No health store on this platform or device.
  unavailable,

  /// The person declined, or has not granted write access yet.
  permissionDenied,

  /// The store rejected or errored on the write.
  failed,
}

/// Mirrors finished workouts into Apple Health (iOS) and Health Connect
/// (Android), so a session logged here also counts towards the rings and
/// weekly totals people actually check.
///
/// Every entry point is failure tolerant: a health store that is missing,
/// denied, or broken must never stop a workout from being saved locally.
class HealthSyncService {
  HealthSyncService({
    Health? health,
    IosHealthWorkoutChannel? iosChannel,
    bool Function()? isAndroid,
    bool Function()? isIOS,
  })  : _health = health ?? Health(),
        _iosChannel = iosChannel ?? IosHealthWorkoutChannel(),
        _isAndroid = isAndroid ?? (() => Platform.isAndroid),
        _isIOS = isIOS ?? (() => Platform.isIOS);

  static final HealthSyncService instance = HealthSyncService();

  final Health _health;
  final IosHealthWorkoutChannel _iosChannel;
  final bool Function() _isAndroid;
  final bool Function() _isIOS;

  bool _configured = false;

  /// Types this app writes. Energy and distance need their own grants: a
  /// workout-only permission saves the session but silently drops its
  /// calories and distance, which is what made the rings stay empty.
  ///
  /// Reading is never requested, so the prompt stays easy to say yes to.
  static List<HealthDataType> writeTypesFor({required bool isAndroid}) {
    return <HealthDataType>[
      HealthDataType.WORKOUT,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      // The two stores name the same measurement differently, and each
      // rejects the other's name.
      if (isAndroid)
        HealthDataType.DISTANCE_DELTA
      else
        HealthDataType.DISTANCE_WALKING_RUNNING,
    ];
  }

  List<HealthDataType> get _writeTypes =>
      writeTypesFor(isAndroid: _isAndroid());

  bool get isSupportedPlatform => _isIOS() || _isAndroid();

  /// Asks for write access. Returns false when the platform has no health
  /// store or the person declined.
  Future<bool> requestPermission() async {
    if (!isSupportedPlatform) return false;
    try {
      await _ensureConfigured();
      final types = _writeTypes;
      return await _health.requestAuthorization(
        types,
        permissions: List<HealthDataAccess>.filled(
          types.length,
          HealthDataAccess.WRITE,
        ),
      );
    } catch (e) {
      debugLog('[HealthSyncService] Permission request failed: $e');
      return false;
    }
  }

  /// Whether write access has already been granted.
  Future<bool> hasPermission() async {
    if (!isSupportedPlatform) return false;
    try {
      await _ensureConfigured();
      final types = _writeTypes;
      return await _health.hasPermissions(
            types,
            permissions: List<HealthDataAccess>.filled(
              types.length,
              HealthDataAccess.WRITE,
            ),
          ) ??
          false;
    } catch (e) {
      debugLog('[HealthSyncService] Permission check failed: $e');
      return false;
    }
  }

  /// Writes one finished workout.
  ///
  /// [enabled] is the person's setting - passing it in keeps the decision in
  /// one place instead of each caller checking first.
  Future<HealthSyncOutcome> writeWorkout(
    WorkoutSession session, {
    required bool enabled,
    double? bodyWeightKg,
  }) async {
    if (!enabled) return HealthSyncOutcome.disabled;
    if (!isSupportedPlatform) return HealthSyncOutcome.unavailable;

    // Deliberately not gated on a permission check: HealthKit does not report
    // write authorization reliably, so asking first would refuse every
    // workout on iOS. An unauthorized write simply fails below instead.
    try {
      final distance = distanceMetersFor(session);
      final energy = WorkoutEnergyEstimate.kilocaloriesFor(
        session,
        bodyWeightKg: bodyWeightKg,
      );

      final (start, end) = intervalFor(session);

      // iOS goes through the app's own bridge so the workout can be marked
      // indoors and carry active energy; the plugin can do neither.
      if (_isIOS()) {
        final written = await _iosChannel.writeWorkout(
          start: start,
          end: end,
          machineType: session.machineType,
          title: session.routineName,
          distanceMeters: distance,
          activeEnergyKcal: energy,
        );
        return written ? HealthSyncOutcome.written : HealthSyncOutcome.failed;
      }

      await _ensureConfigured();
      final written = await _health.writeWorkoutData(
        activityType: activityTypeFor(
          session.machineType,
          isAndroid: _isAndroid(),
        ),
        start: start,
        end: end,
        totalDistance: distance,
        totalEnergyBurned: energy,
        title: session.routineName.isEmpty ? null : session.routineName,
      );
      return written ? HealthSyncOutcome.written : HealthSyncOutcome.failed;
    } catch (e) {
      debugLog('[HealthSyncService] Failed to write workout: $e');
      return HealthSyncOutcome.failed;
    }
  }

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  /// Maps a machine to the closest activity each platform understands.
  ///
  /// Health Connect has machine-specific types; HealthKit does not, and
  /// rejects the Android-only names outright, so iOS falls back to the
  /// general activity it does support.
  static HealthWorkoutActivityType activityTypeFor(
    MachineType machineType, {
    required bool isAndroid,
  }) {
    switch (machineType) {
      case MachineType.treadmill:
        return isAndroid
            ? HealthWorkoutActivityType.RUNNING_TREADMILL
            : HealthWorkoutActivityType.RUNNING;
      case MachineType.cycle:
        return isAndroid
            ? HealthWorkoutActivityType.BIKING_STATIONARY
            : HealthWorkoutActivityType.BIKING;
      case MachineType.stairmaster:
        return isAndroid
            ? HealthWorkoutActivityType.STAIR_CLIMBING_MACHINE
            : HealthWorkoutActivityType.STAIR_CLIMBING;
    }
  }

  /// The wall-clock span the workout actually occupied.
  ///
  /// [WorkoutSession.dateTime] is the moment the workout *ended*, so treating
  /// it as the start would file every session one full duration into the
  /// future - a 07:00-07:30 run would show up as 07:30-08:00.
  static (DateTime, DateTime) intervalFor(WorkoutSession session) {
    final end = session.dateTime;
    final seconds = session.durationSeconds > 0 ? session.durationSeconds : 0;
    return (end.subtract(Duration(seconds: seconds)), end);
  }

  /// Distance in whole metres, or null when the machine does not measure it.
  ///
  /// A zero or negative reading is dropped rather than written, so a health
  /// store never shows a 0 m run.
  static int? distanceMetersFor(WorkoutSession session) {
    final distance = session.distanceMeters;
    if (distance == null || distance <= 0) return null;
    return distance.round();
  }
}
