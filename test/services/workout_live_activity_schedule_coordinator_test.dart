import 'dart:async';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:valcue/services/workout_live_activity_schedule_backend.dart';
import 'package:valcue/services/workout_live_activity_schedule_coordinator.dart';
import 'package:valcue/services/workout_live_activity_schedule_models.dart';

void main() {
  final now = DateTime.fromMillisecondsSinceEpoch(1700000000000);

  WorkoutLiveActivitySchedulePlan activePlan(String marker) {
    return WorkoutLiveActivitySchedulePlan(
      generatedAt: now,
      disposition: WorkoutLiveActivityScheduleDisposition.active,
      events: [
        WorkoutLiveActivityScheduledEvent(
          sequence: 0,
          deliverAt: now.add(const Duration(minutes: 1)),
          action: WorkoutLiveActivityScheduleEventAction.update,
          contentState: <String, dynamic>{'marker': marker},
          staleAt: now.add(const Duration(minutes: 2)),
        ),
        WorkoutLiveActivityScheduledEvent(
          sequence: 1,
          deliverAt: now.add(const Duration(minutes: 2)),
          action: WorkoutLiveActivityScheduleEventAction.end,
          contentState: <String, dynamic>{'marker': 'done'},
          dismissalAt: now.add(const Duration(minutes: 3)),
        ),
      ],
    );
  }

  WorkoutLiveActivitySchedulePlan pausedPlan() {
    return WorkoutLiveActivitySchedulePlan(
      generatedAt: now,
      disposition: WorkoutLiveActivityScheduleDisposition.paused,
      events: const [],
    );
  }

  WorkoutLiveActivityScheduleCoordinator coordinator(
    WorkoutLiveActivityScheduleBackend backend,
  ) {
    return WorkoutLiveActivityScheduleCoordinator(
      sessionId: 'session-1',
      backend: backend,
      nowProvider: () => now,
    );
  }

  test('generates RFC 4122-shaped session IDs from a secure-compatible source',
      () {
    final first = generateWorkoutLiveActivitySessionId(Random(1));
    final second = generateWorkoutLiveActivitySessionId(Random(2));

    expect(
      first,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
    expect(second, isNot(first));
  });

  test('joins a token that arrives before the native start result', () async {
    final backend = _FakeBackend();
    final subject = coordinator(backend);

    await subject.applyPlan(activePlan('initial'));
    await subject.updatePushToken(
      sessionId: 'session-1',
      activityId: 'activity-1',
      pushToken: 'token-1',
      tokenVersion: 1,
      environment: WorkoutLiveActivityPushEnvironment.sandbox,
    );
    expect(backend.registrations, isEmpty);

    await subject.attachActivity(
      sessionId: 'session-1',
      activityId: 'activity-1',
    );

    expect(backend.registrations, hasLength(1));
    final registration = backend.registrations.single;
    expect(registration.scheduleRevision, 1);
    expect(registration.pushToken, 'token-1');
    expect(
      registration.environment,
      WorkoutLiveActivityPushEnvironment.sandbox,
    );
    expect(subject.isDesiredStateAcknowledged, isTrue);
  });

  test('waits for activity, token, and environment before an upsert', () async {
    final backend = _FakeBackend();
    final subject = coordinator(backend);

    await subject.applyPlan(activePlan('initial'));
    await subject.attachActivity(
      sessionId: 'session-1',
      activityId: 'activity-1',
    );
    expect(backend.registrations, isEmpty);
    expect(subject.isDesiredStateAcknowledged, isFalse);

    await subject.updatePushToken(
      sessionId: 'session-1',
      activityId: 'activity-1',
      pushToken: 'token-1',
      tokenVersion: 1,
      environment: WorkoutLiveActivityPushEnvironment.production,
    );

    expect(backend.registrations, hasLength(1));
    expect(
      backend.registrations.single.environment,
      WorkoutLiveActivityPushEnvironment.production,
    );
  });

  test('retains an ineligible plan but skips remote registration', () async {
    final backend = _FakeBackend();
    final subject = coordinator(backend);
    final events = List<WorkoutLiveActivityScheduledEvent>.generate(
      WorkoutLiveActivitySchedulePlan.maximumRemoteEventCount + 1,
      (index) => WorkoutLiveActivityScheduledEvent(
        sequence: index,
        deliverAt: now.add(Duration(seconds: index + 1)),
        action: index == WorkoutLiveActivitySchedulePlan.maximumRemoteEventCount
            ? WorkoutLiveActivityScheduleEventAction.end
            : WorkoutLiveActivityScheduleEventAction.update,
        contentState: <String, dynamic>{'index': index},
      ),
    );
    final ineligiblePlan = WorkoutLiveActivitySchedulePlan(
      generatedAt: now,
      disposition: WorkoutLiveActivityScheduleDisposition.active,
      events: events,
    );

    await subject.applyPlan(ineligiblePlan);
    await subject.attachActivity(
      sessionId: 'session-1',
      activityId: 'activity-1',
    );
    await subject.updatePushToken(
      sessionId: 'session-1',
      activityId: 'activity-1',
      pushToken: 'token-1',
      tokenVersion: 1,
      environment: WorkoutLiveActivityPushEnvironment.sandbox,
    );
    await subject.reconcile();

    expect(backend.registrations, isEmpty);
    expect(subject.desiredPlan, same(ineligiblePlan));
    expect(subject.isDesiredStateAcknowledged, isFalse);
    expect(
      subject.desiredPlanValidation?.issue,
      WorkoutLiveActivityScheduleValidationIssue.tooManyEvents,
    );

    await subject.applyPlan(activePlan('now-eligible'));
    expect(backend.registrations, hasLength(1));
    expect(backend.registrations.single.scheduleRevision, 2);
  });

  test('deduplicates the same plan and duplicate token event', () async {
    final backend = _FakeBackend();
    final subject = coordinator(backend);
    final plan = activePlan('same');

    await subject.applyPlan(plan);
    await subject.attachActivity(
      sessionId: 'session-1',
      activityId: 'activity-1',
    );
    await subject.updatePushToken(
      sessionId: 'session-1',
      activityId: 'activity-1',
      pushToken: 'token-1',
      tokenVersion: 1,
      environment: WorkoutLiveActivityPushEnvironment.sandbox,
    );
    await subject.applyPlan(activePlan('same'));
    await subject.updatePushToken(
      sessionId: 'session-1',
      activityId: 'activity-1',
      pushToken: 'token-1',
      tokenVersion: 1,
      environment: WorkoutLiveActivityPushEnvironment.sandbox,
    );

    expect(subject.scheduleRevision, 1);
    expect(backend.registrations, hasLength(1));
  });

  test('token rotation updates the token without changing schedule revision',
      () async {
    final backend = _FakeBackend();
    final subject = coordinator(backend);
    await subject.applyPlan(activePlan('active'));
    await subject.attachActivity(
      sessionId: 'session-1',
      activityId: 'activity-1',
    );
    await subject.updatePushToken(
      sessionId: 'session-1',
      activityId: 'activity-1',
      pushToken: 'token-1',
      tokenVersion: 1,
      environment: WorkoutLiveActivityPushEnvironment.sandbox,
    );
    await subject.updatePushToken(
      sessionId: 'session-1',
      activityId: 'activity-1',
      pushToken: 'token-2',
      tokenVersion: 2,
      environment: WorkoutLiveActivityPushEnvironment.sandbox,
    );
    await subject.updatePushToken(
      sessionId: 'session-1',
      activityId: 'activity-1',
      pushToken: 'old-token',
      tokenVersion: 1,
      environment: WorkoutLiveActivityPushEnvironment.sandbox,
    );

    expect(subject.scheduleRevision, 1);
    expect(backend.registrations, hasLength(2));
    expect(
      backend.registrations.map((registration) => registration.pushToken),
      ['token-1', 'token-2'],
    );
  });

  test('pause tombstone overtakes an in-flight upsert', () async {
    final upsertCompleter = Completer<WorkoutLiveActivityScheduleAck>();
    final backend = _FakeBackend(
      onUpsert: (_) => upsertCompleter.future,
    );
    final subject = coordinator(backend);

    await subject.applyPlan(activePlan('active'));
    await subject.attachActivity(
      sessionId: 'session-1',
      activityId: 'activity-1',
    );
    final pendingUpsert = subject.updatePushToken(
      sessionId: 'session-1',
      activityId: 'activity-1',
      pushToken: 'token-1',
      tokenVersion: 1,
      environment: WorkoutLiveActivityPushEnvironment.sandbox,
    );
    await Future<void>.delayed(Duration.zero);

    await subject.applyPlan(pausedPlan());

    expect(backend.cancellations, hasLength(1));
    expect(backend.cancellations.single.scheduleRevision, 2);
    expect(
      backend.cancellations.single.reason,
      WorkoutLiveActivityScheduleCancelReason.paused,
    );
    expect(subject.isDesiredStateAcknowledged, isTrue);

    upsertCompleter.complete(
      const WorkoutLiveActivityScheduleAck.accepted(1),
    );
    await pendingUpsert;
    expect(subject.desiredCancellation,
        WorkoutLiveActivityScheduleCancelReason.paused);
    expect(subject.isDesiredStateAcknowledged, isTrue);
  });

  test('resume after pause creates a higher replacement revision', () async {
    final backend = _FakeBackend();
    final subject = coordinator(backend);
    await subject.applyPlan(activePlan('first'));
    await subject.attachActivity(
      sessionId: 'session-1',
      activityId: 'activity-1',
    );
    await subject.updatePushToken(
      sessionId: 'session-1',
      activityId: 'activity-1',
      pushToken: 'token-1',
      tokenVersion: 1,
      environment: WorkoutLiveActivityPushEnvironment.sandbox,
    );

    await subject.applyPlan(pausedPlan());
    await subject.applyPlan(activePlan('resumed'));

    expect(subject.scheduleRevision, 3);
    expect(backend.cancellations.single.scheduleRevision, 2);
    expect(backend.registrations, hasLength(2));
    expect(backend.registrations.last.scheduleRevision, 3);
    expect(subject.isDesiredStateAcknowledged, isTrue);
  });

  test('terminal cancellation cannot be resurrected by a late token', () async {
    final backend = _FakeBackend();
    final subject = coordinator(backend);
    await subject.applyPlan(activePlan('pending'));

    await subject.cancel(
      WorkoutLiveActivityScheduleCancelReason.stopped,
      terminal: true,
    );
    await subject.attachActivity(
      sessionId: 'session-1',
      activityId: 'activity-1',
    );
    await subject.updatePushToken(
      sessionId: 'session-1',
      activityId: 'activity-1',
      pushToken: 'late-token',
      tokenVersion: 1,
      environment: WorkoutLiveActivityPushEnvironment.production,
    );
    await subject.applyPlan(activePlan('must-not-resurrect'));

    expect(subject.scheduleRevision, 2);
    expect(subject.isTerminal, isTrue);
    expect(backend.cancellations, hasLength(1));
    expect(backend.registrations, isEmpty);
  });

  test('ignores token events from another session or activity', () async {
    final backend = _FakeBackend();
    final subject = coordinator(backend);
    await subject.applyPlan(activePlan('active'));
    await subject.attachActivity(
      sessionId: 'session-1',
      activityId: 'activity-1',
    );

    await subject.updatePushToken(
      sessionId: 'another-session',
      activityId: 'activity-1',
      pushToken: 'wrong-session',
      tokenVersion: 1,
      environment: WorkoutLiveActivityPushEnvironment.sandbox,
    );
    await subject.updatePushToken(
      sessionId: 'session-1',
      activityId: 'another-activity',
      pushToken: 'wrong-activity',
      tokenVersion: 1,
      environment: WorkoutLiveActivityPushEnvironment.sandbox,
    );

    expect(backend.registrations, isEmpty);
  });

  test('does not replace the immutable activity identity for a session',
      () async {
    final backend = _FakeBackend();
    final subject = coordinator(backend);
    await subject.applyPlan(activePlan('active'));
    await subject.attachActivity(
      sessionId: 'session-1',
      activityId: 'activity-1',
    );
    await subject.updatePushToken(
      sessionId: 'session-1',
      activityId: 'activity-1',
      pushToken: 'token-1',
      tokenVersion: 1,
      environment: WorkoutLiveActivityPushEnvironment.sandbox,
    );

    await subject.attachActivity(
      sessionId: 'session-1',
      activityId: 'activity-2',
    );
    await subject.updatePushToken(
      sessionId: 'session-1',
      activityId: 'activity-2',
      pushToken: 'token-2',
      tokenVersion: 2,
      environment: WorkoutLiveActivityPushEnvironment.sandbox,
    );

    expect(subject.activityId, 'activity-1');
    expect(subject.scheduleRevision, 1);
    expect(backend.registrations, hasLength(1));
    expect(backend.registrations.single.activityId, 'activity-1');
  });

  test('retries only the latest desired state after a backend failure',
      () async {
    var attempts = 0;
    final backend = _FakeBackend(
      onUpsert: (registration) async {
        attempts++;
        if (attempts == 1) throw StateError('offline');
        return WorkoutLiveActivityScheduleAck.accepted(
          registration.scheduleRevision,
        );
      },
    );
    final subject = coordinator(backend);
    await subject.applyPlan(activePlan('active'));
    await subject.attachActivity(
      sessionId: 'session-1',
      activityId: 'activity-1',
    );
    await subject.updatePushToken(
      sessionId: 'session-1',
      activityId: 'activity-1',
      pushToken: 'token-1',
      tokenVersion: 1,
      environment: WorkoutLiveActivityPushEnvironment.sandbox,
    );

    expect(subject.lastError, isA<StateError>());
    expect(subject.isDesiredStateAcknowledged, isFalse);

    await subject.reconcile();

    expect(attempts, 2);
    expect(subject.lastError, isNull);
    expect(subject.isDesiredStateAcknowledged, isTrue);
  });

  test('retains a failed tombstone for a later retry', () async {
    var attempts = 0;
    final backend = _FakeBackend(
      onCancel: (cancellation) async {
        attempts++;
        if (attempts == 1) throw StateError('offline');
        return WorkoutLiveActivityScheduleAck.accepted(
          cancellation.scheduleRevision,
        );
      },
    );
    final subject = coordinator(backend);
    await subject.applyPlan(activePlan('active'));

    await subject.applyPlan(pausedPlan());
    expect(subject.lastError, isA<StateError>());
    expect(subject.isDesiredStateAcknowledged, isFalse);

    await subject.reconcile();
    expect(attempts, 2);
    expect(subject.isDesiredStateAcknowledged, isTrue);
  });

  test('noop backend leaves the remote state unacknowledged', () async {
    final subject = coordinator(
      const NoopWorkoutLiveActivityScheduleBackend(),
    );
    await subject.applyPlan(activePlan('local-fallback'));
    await subject.attachActivity(
      sessionId: 'session-1',
      activityId: 'activity-1',
    );
    await subject.updatePushToken(
      sessionId: 'session-1',
      activityId: 'activity-1',
      pushToken: 'token-1',
      tokenVersion: 1,
      environment: WorkoutLiveActivityPushEnvironment.sandbox,
    );

    expect(subject.isDesiredStateAcknowledged, isFalse);
  });

  test('registration JSON follows the provider-neutral canonical contract',
      () async {
    final backend = _FakeBackend();
    final subject = coordinator(backend);
    await subject.applyPlan(activePlan('json'));
    await subject.attachActivity(
      sessionId: 'session-1',
      activityId: 'activity-1',
    );
    await subject.updatePushToken(
      sessionId: 'session-1',
      activityId: 'activity-1',
      pushToken: 'token-1',
      tokenVersion: 4,
      environment: WorkoutLiveActivityPushEnvironment.production,
    );

    final json = backend.registrations.single.toJson();
    expect(json.keys, [
      'schemaVersion',
      'sessionId',
      'activityId',
      'token',
      'tokenVersion',
      'environment',
      'scheduleRevision',
      'fingerprint',
      'generatedAtMs',
      'expiresAtMs',
      'events',
    ]);
    expect(json['environment'], 'production');
    expect(json['fingerprint'], matches(RegExp(r'^[0-9a-f]{64}$')));
    final events = json['events'] as List<dynamic>;
    expect((events.first as Map<String, dynamic>).keys, [
      'sequence',
      'deliverAtMs',
      'action',
      'contentState',
      'staleAtMs',
    ]);
    expect((events.last as Map<String, dynamic>)['dismissalAtMs'],
        now.add(const Duration(minutes: 3)).millisecondsSinceEpoch);
  });
}

class _FakeBackend implements WorkoutLiveActivityScheduleBackend {
  _FakeBackend({this.onUpsert, this.onCancel});

  final Future<WorkoutLiveActivityScheduleAck> Function(
    WorkoutLiveActivityScheduleRegistration registration,
  )? onUpsert;
  final Future<WorkoutLiveActivityScheduleAck> Function(
    WorkoutLiveActivityScheduleCancellation cancellation,
  )? onCancel;

  final List<WorkoutLiveActivityScheduleRegistration> registrations = [];
  final List<WorkoutLiveActivityScheduleCancellation> cancellations = [];

  @override
  Future<WorkoutLiveActivityScheduleAck> upsertSchedule(
    WorkoutLiveActivityScheduleRegistration registration,
  ) async {
    registrations.add(registration);
    final handler = onUpsert;
    if (handler != null) return handler(registration);
    return WorkoutLiveActivityScheduleAck.accepted(
      registration.scheduleRevision,
    );
  }

  @override
  Future<WorkoutLiveActivityScheduleAck> cancelSchedule(
    WorkoutLiveActivityScheduleCancellation cancellation,
  ) async {
    cancellations.add(cancellation);
    final handler = onCancel;
    if (handler != null) return handler(cancellation);
    return WorkoutLiveActivityScheduleAck.accepted(
      cancellation.scheduleRevision,
    );
  }
}
