import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valcue/services/workout_live_activity_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('valcue/live_activity');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final service = WorkoutLiveActivityService.instance;

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  test('queries iOS support and activity authorization through the channel',
      () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return switch (call.method) {
        'isSupported' => true,
        'areActivitiesEnabled' => false,
        _ => null,
      };
    });

    expect(await service.isSupported(), isTrue);
    expect(await service.areActivitiesEnabled(), isFalse);
    expect(
      calls.map((call) => call.method),
      ['isSupported', 'areActivitiesEnabled'],
    );
    expect(calls.every((call) => call.arguments == null), isTrue);
  });

  test('forwards generic payloads to start, update, and end', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return call.method == 'start' ? true : null;
    });

    final startPayload = <String, dynamic>{
      'routineId': 'routine-1',
      'intervalIndex': 0,
      'metrics': <String, dynamic>{'speedKmh': 8.5, 'grade': 2.0},
    };
    final updatePayload = <String, dynamic>{
      'intervalIndex': 1,
      'remainingSeconds': 90,
    };
    final endPayload = <String, dynamic>{
      'completed': true,
      'elapsedSeconds': 600,
    };

    expect(await service.start(startPayload), isTrue);
    await service.update(updatePayload);
    await service.end(endPayload);
    await service.cleanup();

    expect(calls.map((call) => call.method), [
      'start',
      'update',
      'end',
      'cleanup',
    ]);
    expect(calls[0].arguments, startPayload);
    expect(calls[1].arguments, updatePayload);
    expect(calls[2].arguments, endPayload);
    expect(calls[3].arguments, isNull);
  });

  test('starts a push-enabled session and restores token snapshots', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method == 'startSession') {
        return <String, dynamic>{
          'started': true,
          'activityId': 'activity-1',
          'workoutSessionId': 'session-1',
          'remotePushEnabled': true,
          'environment': 'sandbox',
        };
      }
      if (call.method == 'getPushRegistrations') {
        return <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'activitySnapshot',
            'schemaVersion': 1,
            'activityId': 'activity-1',
            'routineId': 'routine-1',
            'workoutSessionId': 'session-1',
            'environment': 'sandbox',
            'timestampMs': 1234,
            'tokenHex': 'aabbcc',
            'version': 2,
            'state': 'active',
          },
        ];
      }
      return null;
    });

    final started = await service.startSession(<String, dynamic>{
      'workoutSessionId': 'session-1',
    });
    final registrations = await service.getPushRegistrations();

    expect(started.started, isTrue);
    expect(started.activityId, 'activity-1');
    expect(started.workoutSessionId, 'session-1');
    expect(started.environment, 'sandbox');
    expect(registrations, hasLength(1));
    expect(registrations.single.hasPushToken, isTrue);
    expect(registrations.single.tokenHex, 'aabbcc');
    expect(registrations.single.tokenVersion, 2);
    expect(registrations.single.activityState, 'active');
    expect(
      calls.map((call) => call.method),
      ['startSession', 'getPushRegistrations'],
    );
  });

  test('parses token invalidation lifecycle events defensively', () {
    final event = WorkoutLiveActivityNativeEvent.fromMap(
      <String, Object?>{
        'type': 'pushTokenInvalidated',
        'schemaVersion': 1,
        'activityId': 'activity-1',
        'workoutSessionId': 'session-1',
        'environment': 'production',
        'timestampMs': 5678,
        'tokenHex': 'deadbeef',
        'version': 4,
        'reason': 'activityState.ended',
      },
    );

    expect(
      event.type,
      WorkoutLiveActivityNativeEventType.pushTokenInvalidated,
    );
    expect(event.environment, 'production');
    expect(event.tokenVersion, 4);
    expect(event.reason, 'activityState.ended');
  });

  test('returns safe fallbacks when the iOS channel throws', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(code: 'live_activity_failure');
    });

    expect(await service.isSupported(), isFalse);
    expect(await service.areActivitiesEnabled(), isFalse);
    expect(await service.start(<String, dynamic>{}), isFalse);
    expect(
      (await service.startSession(<String, dynamic>{})).started,
      isFalse,
    );
    expect(await service.getPushRegistrations(), isEmpty);
    await expectLater(service.update(<String, dynamic>{}), completes);
    await expectLater(service.end(<String, dynamic>{}), completes);
    await expectLater(service.cleanup(), completes);
  });

  test('is a false/no-op bridge outside iOS', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return true;
    });

    expect(await service.isSupported(), isFalse);
    expect(await service.areActivitiesEnabled(), isFalse);
    expect(
      await service.start(<String, dynamic>{'value': 1}),
      isFalse,
    );
    expect(
      (await service.startSession(<String, dynamic>{
        'workoutSessionId': 'session-1',
      }))
          .started,
      isFalse,
    );
    expect(await service.getPushRegistrations(), isEmpty);
    await service.update(<String, dynamic>{'value': 2});
    await service.end(<String, dynamic>{'value': 3});
    await service.cleanup();

    expect(calls, isEmpty);
  });
}
