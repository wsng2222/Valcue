import 'dart:io';

import 'package:health/health.dart';

import '../features/profile/models/workout_session.dart';
import '../features/routines/models/machine_type.dart';
import '../utils/debug_log.dart';

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
    bool Function()? isAndroid,
    bool Function()? isIOS,
  })  : _health = health ?? Health(),
        _isAndroid = isAndroid ?? (() => Platform.isAndroid),
        _isIOS = isIOS ?? (() => Platform.isIOS);

  static final HealthSyncService instance = HealthSyncService();

  final Health _health;
  final bool Function() _isAndroid;
  final bool Function() _isIOS;

  bool _configured = false;

  /// Only workouts are written. Reading health data is never requested, so
  /// the permission prompt stays narrow and easy to say yes to.
  static const List<HealthDataType> writeTypes = <HealthDataType>[
    HealthDataType.WORKOUT,
  ];

  static const List<HealthDataAccess> writeAccess = <HealthDataAccess>[
    HealthDataAccess.WRITE,
  ];

  bool get isSupportedPlatform => _isIOS() || _isAndroid();

  /// Asks for write access. Returns false when the platform has no health
  /// store or the person declined.
  Future<bool> requestPermission() async {
    if (!isSupportedPlatform) return false;
    try {
      await _ensureConfigured();
      return await _health.requestAuthorization(
        writeTypes,
        permissions: writeAccess,
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
      return await _health.hasPermissions(
            writeTypes,
            permissions: writeAccess,
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
  }) async {
    if (!enabled) return HealthSyncOutcome.disabled;
    if (!isSupportedPlatform) return HealthSyncOutcome.unavailable;

    try {
      await _ensureConfigured();

      // Deliberately not gated on hasPermission: HealthKit does not report
      // write authorization reliably, so asking first would refuse every
      // workout on iOS. An unauthorized write simply fails below instead.
      final written = await _health.writeWorkoutData(
        activityType: activityTypeFor(
          session.machineType,
          isAndroid: _isAndroid(),
        ),
        start: session.dateTime,
        end: session.dateTime.add(Duration(seconds: session.durationSeconds)),
        totalDistance: distanceMetersFor(session),
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
