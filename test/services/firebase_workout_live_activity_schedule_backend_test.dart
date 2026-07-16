import 'package:flutter_test/flutter_test.dart';
import 'package:valcue/services/firebase_workout_live_activity_schedule_backend.dart';
import 'package:valcue/services/workout_live_activity_schedule_models.dart';

void main() {
  WorkoutLiveActivityScheduleRegistration registration() {
    final now = DateTime.fromMillisecondsSinceEpoch(1000000);
    final plan = WorkoutLiveActivitySchedulePlan(
      generatedAt: now,
      disposition: WorkoutLiveActivityScheduleDisposition.active,
      events: <WorkoutLiveActivityScheduledEvent>[
        WorkoutLiveActivityScheduledEvent(
          sequence: 0,
          deliverAt: now.add(const Duration(seconds: 30)),
          action: WorkoutLiveActivityScheduleEventAction.end,
          contentState: const <String, dynamic>{'status': 'finished'},
        ),
      ],
    );
    return WorkoutLiveActivityScheduleRegistration(
      sessionId: 'session-1',
      activityId: 'activity-1',
      pushToken: 'aabbcc',
      tokenVersion: 1,
      environment: WorkoutLiveActivityPushEnvironment.sandbox,
      scheduleRevision: 3,
      generatedAt: now,
      expiresAt: now.add(const Duration(minutes: 2)),
      plan: plan,
    );
  }

  test('calls upsert callable with the serialized schedule', () async {
    String? calledName;
    Map<String, dynamic>? calledPayload;
    final backend = FirebaseWorkoutLiveActivityScheduleBackend(
      callableInvoker: (name, payload) async {
        calledName = name;
        calledPayload = payload;
        return <String, dynamic>{
          'accepted': true,
          'acceptedRevision': 3,
        };
      },
    );

    final ack = await backend.upsertSchedule(registration());

    expect(calledName, 'upsertLiveActivitySchedule');
    expect(calledPayload?['sessionId'], 'session-1');
    expect(calledPayload?['events'], hasLength(1));
    expect(ack.accepted, isTrue);
    expect(ack.acceptedRevision, 3);
  });

  test('calls cancel callable and preserves an ignored newer revision',
      () async {
    final backend = FirebaseWorkoutLiveActivityScheduleBackend(
      callableInvoker: (name, payload) async {
        expect(name, 'cancelLiveActivitySchedule');
        expect(payload['reason'], 'paused');
        return <String, dynamic>{
          'accepted': false,
          'acceptedRevision': 8,
        };
      },
    );
    final cancellation = WorkoutLiveActivityScheduleCancellation(
      sessionId: 'session-1',
      activityId: 'activity-1',
      scheduleRevision: 7,
      reason: WorkoutLiveActivityScheduleCancelReason.paused,
      canceledAt: DateTime.fromMillisecondsSinceEpoch(2000000),
    );

    final ack = await backend.cancelSchedule(cancellation);

    expect(ack.accepted, isFalse);
    expect(ack.acceptedRevision, 8);
  });

  test('rejects malformed callable acknowledgements', () async {
    final backend = FirebaseWorkoutLiveActivityScheduleBackend(
      callableInvoker: (_, __) async => <String, dynamic>{'ok': true},
    );

    expect(
      () => backend.upsertSchedule(registration()),
      throwsA(isA<FormatException>()),
    );
  });
}
