import 'package:cloud_functions/cloud_functions.dart';

import 'workout_live_activity_firebase_runtime.dart';
import 'workout_live_activity_schedule_backend.dart';
import 'workout_live_activity_schedule_models.dart';

typedef WorkoutLiveActivityCallableInvoker = Future<Object?> Function(
  String functionName,
  Map<String, dynamic> payload,
);

/// Firebase callable implementation of the provider-neutral schedule backend.
///
/// Authentication and App Check tokens are attached by FlutterFire. The
/// coordinator remains responsible for revisions and retry decisions, while
/// the server performs the authoritative Firestore compare-and-set.
class FirebaseWorkoutLiveActivityScheduleBackend
    implements WorkoutLiveActivityScheduleBackend {
  FirebaseWorkoutLiveActivityScheduleBackend({
    WorkoutLiveActivityFirebaseRuntime? runtime,
    WorkoutLiveActivityCallableInvoker? callableInvoker,
  })  : _runtime = runtime ?? WorkoutLiveActivityFirebaseRuntime.instance,
        _callableInvoker = callableInvoker;

  static const String upsertFunctionName = 'upsertLiveActivitySchedule';
  static const String cancelFunctionName = 'cancelLiveActivitySchedule';

  final WorkoutLiveActivityFirebaseRuntime _runtime;
  final WorkoutLiveActivityCallableInvoker? _callableInvoker;

  bool get isConfigured => _callableInvoker != null || _runtime.isConfigured;

  @override
  Future<WorkoutLiveActivityScheduleAck> upsertSchedule(
    WorkoutLiveActivityScheduleRegistration registration,
  ) async {
    if (!isConfigured) {
      return WorkoutLiveActivityScheduleAck.ignored(
        registration.scheduleRevision,
      );
    }
    final data = await _invoke(
      upsertFunctionName,
      registration.toJson(),
    );
    return _parseAck(data, requestedRevision: registration.scheduleRevision);
  }

  @override
  Future<WorkoutLiveActivityScheduleAck> cancelSchedule(
    WorkoutLiveActivityScheduleCancellation cancellation,
  ) async {
    if (!isConfigured) {
      return WorkoutLiveActivityScheduleAck.ignored(
        cancellation.scheduleRevision,
      );
    }
    final data = await _invoke(
      cancelFunctionName,
      cancellation.toJson(),
    );
    return _parseAck(data, requestedRevision: cancellation.scheduleRevision);
  }

  Future<Object?> _invoke(
    String functionName,
    Map<String, dynamic> payload,
  ) async {
    final override = _callableInvoker;
    if (override != null) return override(functionName, payload);

    final functions = await _runtime.functions();
    if (functions == null) return null;
    final callable = functions.httpsCallable(
      functionName,
      options: HttpsCallableOptions(
        timeout: const Duration(seconds: 15),
      ),
    );
    return (await callable.call<Object?>(payload)).data;
  }

  static WorkoutLiveActivityScheduleAck _parseAck(
    Object? value, {
    required int requestedRevision,
  }) {
    if (value is! Map) {
      throw const FormatException(
        'Live Activity schedule callable returned a non-map response.',
      );
    }
    final accepted = value['accepted'];
    final acceptedRevision = value['acceptedRevision'];
    if (accepted is! bool || acceptedRevision is! num) {
      throw const FormatException(
        'Live Activity schedule callable returned an invalid acknowledgement.',
      );
    }

    final revision = acceptedRevision.toInt();
    if (revision < 0) {
      throw const FormatException(
        'Live Activity schedule acknowledgement has a negative revision.',
      );
    }
    return accepted
        ? WorkoutLiveActivityScheduleAck.accepted(revision)
        : WorkoutLiveActivityScheduleAck.ignored(revision);
  }
}
