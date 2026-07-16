import 'dart:math';

import 'workout_live_activity_schedule_backend.dart';
import 'workout_live_activity_schedule_models.dart';

String generateWorkoutLiveActivitySessionId([Random? random]) {
  final source = random ?? Random.secure();
  final bytes = List<int>.generate(16, (_) => source.nextInt(256));
  // RFC 4122 version 4 / variant 1 bits. This avoids adding a package solely
  // for a short-lived workout session identifier.
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex =
      bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-'
      '${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-'
      '${hex.substring(16, 20)}-'
      '${hex.substring(20)}';
}

/// Owns one workout session's desired remote schedule and reconciles native
/// activity/token events with a provider-independent backend.
///
/// Local state changes are reduced synchronously, while backend mutations may
/// complete out of order. Monotonic revisions and backend tombstones make the
/// latest desired state win without making pause/stop wait behind a slow
/// upsert.
class WorkoutLiveActivityScheduleCoordinator {
  WorkoutLiveActivityScheduleCoordinator({
    required this.sessionId,
    required WorkoutLiveActivityScheduleBackend backend,
    DateTime Function()? nowProvider,
    this.expirationGrace = const Duration(minutes: 5),
  })  : _backend = backend,
        _now = nowProvider ?? DateTime.now {
    if (sessionId.isEmpty) {
      throw ArgumentError.value(sessionId, 'sessionId', 'Must not be empty.');
    }
  }

  final String sessionId;
  final WorkoutLiveActivityScheduleBackend _backend;
  final DateTime Function() _now;
  final Duration expirationGrace;

  WorkoutLiveActivitySchedulePlan? _desiredPlan;
  WorkoutLiveActivityScheduleCancelReason? _desiredCancellation;
  String? _activityId;
  String? _pushToken;
  WorkoutLiveActivityPushEnvironment? _environment;
  int _tokenVersion = -1;
  int _scheduleRevision = 0;
  bool _terminal = false;
  bool _disposed = false;
  String? _acknowledgedUpsertKey;
  String? _acknowledgedCancelKey;
  Object? _lastError;

  final Map<String, _PendingToken> _pendingTokens = <String, _PendingToken>{};
  final Set<String> _inFlightUpserts = <String>{};
  final Set<String> _inFlightCancellations = <String>{};

  int get scheduleRevision => _scheduleRevision;
  bool get isTerminal => _terminal;
  String? get activityId => _activityId;
  int get tokenVersion => _tokenVersion;
  WorkoutLiveActivityPushEnvironment? get environment => _environment;
  Object? get lastError => _lastError;
  WorkoutLiveActivitySchedulePlan? get desiredPlan => _desiredPlan;
  WorkoutLiveActivityScheduleCancelReason? get desiredCancellation =>
      _desiredCancellation;
  WorkoutLiveActivityScheduleValidationResult? get desiredPlanValidation =>
      _desiredPlan?.remoteRegistrationValidation;

  bool get isDesiredStateAcknowledged {
    if (_desiredPlan != null) {
      final key = _currentUpsertKey;
      return key != null && _acknowledgedUpsertKey == key;
    }
    if (_desiredCancellation != null) {
      return _acknowledgedCancelKey == _currentCancelKey;
    }
    return false;
  }

  Future<void> applyPlan(WorkoutLiveActivitySchedulePlan plan) {
    if (_disposed) return Future<void>.value();
    switch (plan.disposition) {
      case WorkoutLiveActivityScheduleDisposition.active:
        if (_terminal) return Future<void>.value();
        if (_desiredPlan?.fingerprint != plan.fingerprint ||
            _desiredCancellation != null) {
          _advanceRevision();
          _desiredPlan = plan;
          _desiredCancellation = null;
        }
        return reconcile();
      case WorkoutLiveActivityScheduleDisposition.paused:
        return cancel(
          WorkoutLiveActivityScheduleCancelReason.paused,
          terminal: false,
        );
      case WorkoutLiveActivityScheduleDisposition.finished:
        return cancel(
          WorkoutLiveActivityScheduleCancelReason.finished,
          terminal: true,
        );
      case WorkoutLiveActivityScheduleDisposition.stopped:
        return cancel(
          WorkoutLiveActivityScheduleCancelReason.stopped,
          terminal: true,
        );
    }
  }

  Future<void> attachActivity({
    required String sessionId,
    required String activityId,
  }) {
    if (_disposed || sessionId != this.sessionId || activityId.isEmpty) {
      return Future<void>.value();
    }
    if (_terminal) return reconcile();
    if (_activityId == activityId) return reconcile();
    // The backend binds one immutable ActivityKit identity to a session. A
    // delayed snapshot from another activity must not replace that identity.
    if (_activityId != null) return reconcile();
    _activityId = activityId;
    _pushToken = null;
    _environment = null;
    _tokenVersion = -1;

    final pending = _pendingTokens.remove(activityId);
    if (pending != null) {
      _pushToken = pending.token;
      _tokenVersion = pending.version;
      _environment = pending.environment;
    }
    _pendingTokens.removeWhere((key, _) => key != activityId);
    return reconcile();
  }

  Future<void> updatePushToken({
    required String sessionId,
    required String activityId,
    required String pushToken,
    required int tokenVersion,
    required WorkoutLiveActivityPushEnvironment environment,
  }) {
    if (_disposed ||
        sessionId != this.sessionId ||
        activityId.isEmpty ||
        pushToken.isEmpty ||
        tokenVersion < 0) {
      return Future<void>.value();
    }
    if (_terminal) return reconcile();

    if (_activityId == null) {
      final previous = _pendingTokens[activityId];
      if (previous == null || tokenVersion > previous.version) {
        _pendingTokens[activityId] = _PendingToken(
          token: pushToken,
          version: tokenVersion,
          environment: environment,
        );
      }
      return Future<void>.value();
    }
    if (_activityId != activityId) return Future<void>.value();
    if (tokenVersion < _tokenVersion ||
        (tokenVersion == _tokenVersion && pushToken != _pushToken)) {
      return Future<void>.value();
    }
    if (tokenVersion == _tokenVersion && pushToken == _pushToken) {
      return reconcile();
    }

    _pushToken = pushToken;
    _tokenVersion = tokenVersion;
    _environment = environment;
    return reconcile();
  }

  Future<void> cancel(
    WorkoutLiveActivityScheduleCancelReason reason, {
    required bool terminal,
  }) {
    if (_disposed) return Future<void>.value();
    if (_terminal && terminal) return reconcile();
    if (_desiredCancellation != reason || _desiredPlan != null) {
      _advanceRevision();
      _desiredPlan = null;
      _desiredCancellation = reason;
    }
    _terminal = _terminal || terminal;
    return reconcile();
  }

  /// Retries only the latest desired mutation. Superseded revisions are never
  /// retried, even if an older request failed after the state changed.
  Future<void> reconcile() {
    if (_disposed) return Future<void>.value();
    if (_desiredCancellation != null) return _submitCancellation();
    if (_terminal || _desiredPlan == null) return Future<void>.value();
    if (_activityId == null || _pushToken == null || _environment == null) {
      return Future<void>.value();
    }
    return _submitUpsert();
  }

  void dispose() {
    _disposed = true;
    _pendingTokens.clear();
  }

  Future<void> _submitUpsert() async {
    final plan = _desiredPlan;
    final activityId = _activityId;
    final pushToken = _pushToken;
    final environment = _environment;
    if (plan == null ||
        activityId == null ||
        pushToken == null ||
        environment == null) {
      return;
    }
    if (!plan.remoteRegistrationValidation.isValid) return;

    final revision = _scheduleRevision;
    final tokenVersion = _tokenVersion;
    final key = _upsertKey(
      revision: revision,
      activityId: activityId,
      tokenVersion: tokenVersion,
      environment: environment,
      fingerprint: plan.fingerprint,
    );
    if (_acknowledgedUpsertKey == key || !_inFlightUpserts.add(key)) return;

    final registration = WorkoutLiveActivityScheduleRegistration(
      sessionId: sessionId,
      activityId: activityId,
      pushToken: pushToken,
      tokenVersion: tokenVersion,
      environment: environment,
      scheduleRevision: revision,
      generatedAt: plan.generatedAt,
      expiresAt: plan.endsAt.add(expirationGrace),
      plan: plan,
    );

    try {
      final ack = await _backend.upsertSchedule(registration);
      if (ack.accepted &&
          ack.acceptedRevision == revision &&
          key == _currentUpsertKey) {
        _acknowledgedUpsertKey = key;
        _lastError = null;
      }
    } catch (error) {
      if (key == _currentUpsertKey) _lastError = error;
    } finally {
      _inFlightUpserts.remove(key);
    }
  }

  Future<void> _submitCancellation() async {
    final reason = _desiredCancellation;
    if (reason == null) return;
    final revision = _scheduleRevision;
    final key = _cancelKey(revision: revision, reason: reason);
    if (_acknowledgedCancelKey == key || !_inFlightCancellations.add(key)) {
      return;
    }

    final cancellation = WorkoutLiveActivityScheduleCancellation(
      sessionId: sessionId,
      activityId: _activityId,
      scheduleRevision: revision,
      reason: reason,
      canceledAt: _now(),
    );
    try {
      final ack = await _backend.cancelSchedule(cancellation);
      if (ack.accepted &&
          ack.acceptedRevision == revision &&
          key == _currentCancelKey) {
        _acknowledgedCancelKey = key;
        _lastError = null;
      }
    } catch (error) {
      if (key == _currentCancelKey) _lastError = error;
    } finally {
      _inFlightCancellations.remove(key);
    }
  }

  void _advanceRevision() {
    _scheduleRevision++;
    _acknowledgedUpsertKey = null;
    _acknowledgedCancelKey = null;
    _lastError = null;
  }

  String? get _currentUpsertKey {
    final plan = _desiredPlan;
    final activityId = _activityId;
    final environment = _environment;
    if (plan == null ||
        activityId == null ||
        _pushToken == null ||
        environment == null) {
      return null;
    }
    return _upsertKey(
      revision: _scheduleRevision,
      activityId: activityId,
      tokenVersion: _tokenVersion,
      environment: environment,
      fingerprint: plan.fingerprint,
    );
  }

  String get _currentCancelKey => _cancelKey(
        revision: _scheduleRevision,
        reason: _desiredCancellation!,
      );

  static String _upsertKey({
    required int revision,
    required String activityId,
    required int tokenVersion,
    required WorkoutLiveActivityPushEnvironment environment,
    required String fingerprint,
  }) =>
      '$revision|$activityId|$tokenVersion|${environment.name}|$fingerprint';

  static String _cancelKey({
    required int revision,
    required WorkoutLiveActivityScheduleCancelReason reason,
  }) =>
      '$revision|${reason.name}';
}

class _PendingToken {
  const _PendingToken({
    required this.token,
    required this.version,
    required this.environment,
  });

  final String token;
  final int version;
  final WorkoutLiveActivityPushEnvironment environment;
}
