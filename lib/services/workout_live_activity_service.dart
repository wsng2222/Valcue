import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Safe Flutter-side bridge for the iOS workout Live Activity.
///
/// Live Activities are an iOS-only capability. Calls made on any other
/// platform, or calls that fail in the native implementation, intentionally
/// resolve to a safe fallback instead of surfacing an exception to the workout
/// flow.
class WorkoutLiveActivityService {
  WorkoutLiveActivityService._();

  static final WorkoutLiveActivityService instance =
      WorkoutLiveActivityService._();

  static const MethodChannel _channel = MethodChannel('valcue/live_activity');
  static const EventChannel _eventChannel =
      EventChannel('valcue/live_activity/events');

  bool get _canUseLiveActivities =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  Future<bool> isSupported() async {
    if (!_canUseLiveActivities) return false;

    try {
      return await _channel.invokeMethod<bool>('isSupported') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> areActivitiesEnabled() async {
    if (!_canUseLiveActivities) return false;

    try {
      return await _channel.invokeMethod<bool>('areActivitiesEnabled') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> start(Map<String, dynamic> payload) async {
    if (!_canUseLiveActivities) return false;

    try {
      return await _channel.invokeMethod<bool>('start', payload) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<WorkoutLiveActivityStartResult> startSession(
    Map<String, dynamic> payload,
  ) async {
    if (!_canUseLiveActivities) {
      return WorkoutLiveActivityStartResult.failed(
        workoutSessionId: payload['workoutSessionId'] as String?,
      );
    }

    try {
      final value = await _channel.invokeMethod<Object?>(
        'startSession',
        payload,
      );
      if (value is Map) {
        return WorkoutLiveActivityStartResult.fromMap(value);
      }
    } catch (_) {
      // Fall through to a result that keeps local notifications active.
    }
    return WorkoutLiveActivityStartResult.failed(
      workoutSessionId: payload['workoutSessionId'] as String?,
    );
  }

  Future<List<WorkoutLiveActivityNativeEvent>> getPushRegistrations() async {
    if (!_canUseLiveActivities) return const [];

    try {
      final values = await _channel.invokeListMethod<Object?>(
        'getPushRegistrations',
      );
      if (values == null) return const [];
      return values
          .whereType<Map>()
          .map(WorkoutLiveActivityNativeEvent.fromMap)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Stream<WorkoutLiveActivityNativeEvent> get events {
    if (!_canUseLiveActivities) return const Stream.empty();

    return _eventChannel
        .receiveBroadcastStream()
        .where((value) => value is Map)
        .map((value) => WorkoutLiveActivityNativeEvent.fromMap(value as Map));
  }

  Future<void> update(Map<String, dynamic> payload) {
    return _invokeCommand('update', payload);
  }

  Future<void> end(Map<String, dynamic> payload) {
    return _invokeCommand('end', payload);
  }

  Future<void> cleanup() {
    return _invokeCommand('cleanup');
  }

  Future<void> _invokeCommand(
    String method, [
    Map<String, dynamic>? payload,
  ]) async {
    if (!_canUseLiveActivities) return;

    try {
      await _channel.invokeMethod<void>(method, payload);
    } catch (_) {
      // A Live Activity is supplementary to the workout. Native availability,
      // encoding, and lifecycle failures must not interrupt the active session.
    }
  }
}

class WorkoutLiveActivityStartResult {
  const WorkoutLiveActivityStartResult({
    required this.started,
    required this.activityId,
    required this.workoutSessionId,
    required this.remotePushEnabled,
    required this.environment,
  });

  factory WorkoutLiveActivityStartResult.fromMap(Map<dynamic, dynamic> map) {
    return WorkoutLiveActivityStartResult(
      started: map['started'] == true,
      activityId: _string(map['activityId']),
      workoutSessionId: _string(map['workoutSessionId']),
      remotePushEnabled: map['remotePushEnabled'] == true,
      environment: _string(map['environment']),
    );
  }

  factory WorkoutLiveActivityStartResult.failed({
    String? workoutSessionId,
  }) {
    return WorkoutLiveActivityStartResult(
      started: false,
      activityId: '',
      workoutSessionId: workoutSessionId ?? '',
      remotePushEnabled: false,
      environment: '',
    );
  }

  final bool started;
  final String activityId;
  final String workoutSessionId;
  final bool remotePushEnabled;
  final String environment;

  static String _string(Object? value) => value is String ? value : '';
}

enum WorkoutLiveActivityNativeEventType {
  activityStarted,
  activitySnapshot,
  pushToken,
  pushTokenInvalidated,
  activityState,
  unknown,
}

/// Parsed form of the native ActivityKit lifecycle/token stream.
class WorkoutLiveActivityNativeEvent {
  const WorkoutLiveActivityNativeEvent({
    required this.type,
    required this.schemaVersion,
    required this.activityId,
    required this.routineId,
    required this.workoutSessionId,
    required this.environment,
    required this.timestampMs,
    required this.tokenVersion,
    this.tokenHex,
    this.previousTokenHex,
    this.activityState,
    this.reason,
  });

  factory WorkoutLiveActivityNativeEvent.fromMap(Map<dynamic, dynamic> map) {
    return WorkoutLiveActivityNativeEvent(
      type: _eventType(map['type']),
      schemaVersion: _integer(map['schemaVersion']),
      activityId: _string(map['activityId']),
      routineId: _string(map['routineId']),
      workoutSessionId: _string(map['workoutSessionId']),
      environment: _string(map['environment']),
      timestampMs: _integer(map['timestampMs']),
      tokenVersion: _integer(map['version']),
      tokenHex: _optionalString(map['tokenHex']),
      previousTokenHex: _optionalString(map['previousTokenHex']),
      activityState: _optionalString(map['state']),
      reason: _optionalString(map['reason']),
    );
  }

  final WorkoutLiveActivityNativeEventType type;
  final int schemaVersion;
  final String activityId;
  final String routineId;
  final String workoutSessionId;
  final String environment;
  final int timestampMs;
  final int tokenVersion;
  final String? tokenHex;
  final String? previousTokenHex;
  final String? activityState;
  final String? reason;

  bool get hasPushToken => tokenHex != null && tokenHex!.isNotEmpty;

  static WorkoutLiveActivityNativeEventType _eventType(Object? value) {
    return switch (value) {
      'activityStarted' => WorkoutLiveActivityNativeEventType.activityStarted,
      'activitySnapshot' => WorkoutLiveActivityNativeEventType.activitySnapshot,
      'pushToken' => WorkoutLiveActivityNativeEventType.pushToken,
      'pushTokenInvalidated' =>
        WorkoutLiveActivityNativeEventType.pushTokenInvalidated,
      'activityState' => WorkoutLiveActivityNativeEventType.activityState,
      _ => WorkoutLiveActivityNativeEventType.unknown,
    };
  }

  static String _string(Object? value) => value is String ? value : '';

  static String? _optionalString(Object? value) {
    return value is String && value.isNotEmpty ? value : null;
  }

  static int _integer(Object? value) => value is num ? value.toInt() : 0;
}
