import 'dart:convert';

import 'package:crypto/crypto.dart';

/// The logical point in the workout from which a remote Live Activity
/// schedule is built.
enum WorkoutLiveActivitySchedulePhase {
  initialCountdown,
  running,
  resumeCountdown,
  paused,
  finished,
  stopped,
}

/// Whether a plan contains future updates or represents a state that must
/// invalidate all previously scheduled updates.
enum WorkoutLiveActivityScheduleDisposition {
  active,
  paused,
  finished,
  stopped,
}

enum WorkoutLiveActivityScheduleEventAction {
  update,
  end,
}

enum WorkoutLiveActivityPushEnvironment {
  sandbox,
  production,
}

enum WorkoutLiveActivityScheduleCancelReason {
  paused,
  finished,
  stopped,
  featureDisabled,
  premiumRevoked,
  disposed,
  staleSession,
}

/// Client-side mirror of the backend's bounded remote-schedule contract.
///
/// An ineligible plan is still useful to the foreground Live Activity and the
/// local-notification fallback. It is simply not uploaded until a later
/// current-state replan fits inside these limits.
enum WorkoutLiveActivityScheduleValidationIssue {
  tooManyEvents,
  exceedsMaximumHorizon,
}

class WorkoutLiveActivityScheduleValidationResult {
  const WorkoutLiveActivityScheduleValidationResult.valid() : issue = null;

  const WorkoutLiveActivityScheduleValidationResult.invalid(this.issue);

  final WorkoutLiveActivityScheduleValidationIssue? issue;

  bool get isValid => issue == null;
}

/// One future ActivityKit update. The backend turns this provider-neutral
/// model into the final APNs request at delivery time.
class WorkoutLiveActivityScheduledEvent {
  const WorkoutLiveActivityScheduledEvent({
    required this.sequence,
    required this.deliverAt,
    required this.action,
    required this.contentState,
    this.staleAt,
    this.dismissalAt,
  });

  final int sequence;
  final DateTime deliverAt;
  final WorkoutLiveActivityScheduleEventAction action;
  final Map<String, dynamic> contentState;
  final DateTime? staleAt;
  final DateTime? dismissalAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'sequence': sequence,
      'deliverAtMs': deliverAt.millisecondsSinceEpoch,
      'action': action.name,
      'contentState': contentState,
      if (staleAt != null) 'staleAtMs': staleAt!.millisecondsSinceEpoch,
      if (dismissalAt != null)
        'dismissalAtMs': dismissalAt!.millisecondsSinceEpoch,
    };
  }
}

/// A deterministic, provider-independent list of all remaining interval
/// boundaries for one workout timeline.
class WorkoutLiveActivitySchedulePlan {
  static const int maximumRemoteEventCount = 56;
  static const Duration maximumRemoteHorizon = Duration(hours: 8);

  WorkoutLiveActivitySchedulePlan({
    required this.generatedAt,
    required this.disposition,
    required List<WorkoutLiveActivityScheduledEvent> events,
  }) : events = List<WorkoutLiveActivityScheduledEvent>.unmodifiable(events);

  final DateTime generatedAt;
  final WorkoutLiveActivityScheduleDisposition disposition;
  final List<WorkoutLiveActivityScheduledEvent> events;

  bool get isActive =>
      disposition == WorkoutLiveActivityScheduleDisposition.active;

  DateTime get endsAt => events.isEmpty ? generatedAt : events.last.deliverAt;

  late final WorkoutLiveActivityScheduleValidationResult
      remoteRegistrationValidation = _validateRemoteRegistration();

  /// Used only for client-side mutation de-duplication. Backend idempotency is
  /// still enforced with the session ID and monotonic schedule revision.
  late final String fingerprint = _buildFingerprint();

  WorkoutLiveActivityScheduleValidationResult _validateRemoteRegistration() {
    if (!isActive) {
      return const WorkoutLiveActivityScheduleValidationResult.valid();
    }
    if (events.length > maximumRemoteEventCount) {
      return const WorkoutLiveActivityScheduleValidationResult.invalid(
        WorkoutLiveActivityScheduleValidationIssue.tooManyEvents,
      );
    }
    final latestAllowed = generatedAt.add(maximumRemoteHorizon);
    if (events.any((event) => event.deliverAt.isAfter(latestAllowed))) {
      return const WorkoutLiveActivityScheduleValidationResult.invalid(
        WorkoutLiveActivityScheduleValidationIssue.exceedsMaximumHorizon,
      );
    }
    return const WorkoutLiveActivityScheduleValidationResult.valid();
  }

  String _buildFingerprint() {
    final canonicalEvents = events.map((event) {
      return <String, dynamic>{
        'sequence': event.sequence,
        'deliverAtMs': event.deliverAt.millisecondsSinceEpoch,
        'action': event.action.name,
        'contentState': _canonicalize(event.contentState),
        'staleAtMs': event.staleAt?.millisecondsSinceEpoch,
        'dismissalAtMs': event.dismissalAt?.millisecondsSinceEpoch,
      };
    }).toList(growable: false);
    final canonicalJson = jsonEncode(<String, dynamic>{
      'disposition': disposition.name,
      'events': canonicalEvents,
    });
    return sha256.convert(utf8.encode(canonicalJson)).toString();
  }

  static Object? _canonicalize(Object? value) {
    if (value is Map) {
      final keys = value.keys.map((key) => key.toString()).toList()..sort();
      return <String, Object?>{
        for (final key in keys) key: _canonicalize(value[key]),
      };
    }
    if (value is Iterable) {
      return value.map(_canonicalize).toList(growable: false);
    }
    return value;
  }
}

/// Full replacement request. Scheduled jobs must retain session/revision and
/// re-check the latest backend record immediately before delivery.
class WorkoutLiveActivityScheduleRegistration {
  const WorkoutLiveActivityScheduleRegistration({
    required this.sessionId,
    required this.activityId,
    required this.pushToken,
    required this.tokenVersion,
    required this.environment,
    required this.scheduleRevision,
    required this.generatedAt,
    required this.expiresAt,
    required this.plan,
  });

  final String sessionId;
  final String activityId;
  final String pushToken;
  final int tokenVersion;
  final WorkoutLiveActivityPushEnvironment environment;
  final int scheduleRevision;
  final DateTime generatedAt;
  final DateTime expiresAt;
  final WorkoutLiveActivitySchedulePlan plan;

  String get idempotencyKey =>
      '$sessionId:upsert:$scheduleRevision:$tokenVersion';

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'schemaVersion': 1,
      'sessionId': sessionId,
      'activityId': activityId,
      'token': pushToken,
      'tokenVersion': tokenVersion,
      'environment': environment.name,
      'scheduleRevision': scheduleRevision,
      'fingerprint': plan.fingerprint,
      'generatedAtMs': generatedAt.millisecondsSinceEpoch,
      'expiresAtMs': expiresAt.millisecondsSinceEpoch,
      'events': plan.events.map((event) => event.toJson()).toList(
            growable: false,
          ),
    };
  }
}

/// A higher-revision tombstone. It intentionally doesn't require a token so
/// pause/stop can win even if native token creation is still pending.
class WorkoutLiveActivityScheduleCancellation {
  const WorkoutLiveActivityScheduleCancellation({
    required this.sessionId,
    required this.scheduleRevision,
    required this.reason,
    required this.canceledAt,
    this.activityId,
  });

  final String sessionId;
  final String? activityId;
  final int scheduleRevision;
  final WorkoutLiveActivityScheduleCancelReason reason;
  final DateTime canceledAt;

  String get idempotencyKey => '$sessionId:cancel:$scheduleRevision';

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'schemaVersion': 1,
      'sessionId': sessionId,
      if (activityId != null) 'activityId': activityId,
      'scheduleRevision': scheduleRevision,
      'reason': reason.name,
      'canceledAtMs': canceledAt.millisecondsSinceEpoch,
    };
  }
}

class WorkoutLiveActivityScheduleAck {
  const WorkoutLiveActivityScheduleAck({
    required this.accepted,
    required this.acceptedRevision,
  });

  const WorkoutLiveActivityScheduleAck.accepted(int revision)
      : accepted = true,
        acceptedRevision = revision;

  const WorkoutLiveActivityScheduleAck.ignored(int currentRevision)
      : accepted = false,
        acceptedRevision = currentRevision;

  final bool accepted;
  final int acceptedRevision;
}
