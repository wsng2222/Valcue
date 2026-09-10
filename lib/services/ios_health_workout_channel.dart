import 'package:flutter/services.dart';

import '../features/routines/models/machine_type.dart';
import '../utils/debug_log.dart';

/// Writes workouts straight to HealthKit through the app's own native bridge.
///
/// The `health` plugin saves workouts with no metadata, and HealthKit records
/// indoor-ness as metadata rather than as an activity type - so a treadmill
/// session written by the plugin is filed as an outdoor run. Going native also
/// lets the workout carry active energy, which is what moves the rings.
class IosHealthWorkoutChannel {
  IosHealthWorkoutChannel({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(channelName);

  static const String channelName = 'valcue/health_workout';

  final MethodChannel _channel;

  /// Whether this device has a health store at all.
  Future<bool> isAvailable() async {
    try {
      return await _channel.invokeMethod<bool>('isAvailable') ?? false;
    } on MissingPluginException {
      return false;
    } catch (e) {
      debugLog('[IosHealthWorkoutChannel] isAvailable failed: $e');
      return false;
    }
  }

  /// Saves one workout. Returns false if HealthKit refused it.
  ///
  /// [start] and [end] are the real wall-clock span, worked out by the caller
  /// - a workout session records when it *finished*, not when it began.
  Future<bool> writeWorkout({
    required DateTime start,
    required DateTime end,
    required MachineType machineType,
    String title = '',
    int? distanceMeters,
    int? activeEnergyKcal,
  }) async {
    try {
      final written = await _channel.invokeMethod<bool>('writeWorkout', {
        'activityType': activityNameFor(machineType),
        'startMs': start.millisecondsSinceEpoch,
        'endMs': end.millisecondsSinceEpoch,
        'distanceMeters': distanceMeters,
        'activeEnergyKcal': activeEnergyKcal,
        'title': title,
      });
      return written ?? false;
    } on MissingPluginException {
      return false;
    } catch (e) {
      debugLog('[IosHealthWorkoutChannel] writeWorkout failed: $e');
      return false;
    }
  }

  /// HealthKit has no treadmill or stationary-bike activity, so the machine
  /// maps to the general activity and the native side marks it indoors.
  static String activityNameFor(MachineType machineType) {
    switch (machineType) {
      case MachineType.treadmill:
        return 'running';
      case MachineType.cycle:
        return 'cycling';
      case MachineType.stairmaster:
        return 'stairClimbing';
    }
  }
}
