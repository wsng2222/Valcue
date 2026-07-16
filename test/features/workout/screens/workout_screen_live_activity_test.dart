import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:valcue/app_settings/app_settings_provider.dart';
import 'package:valcue/features/routines/models/interval.dart' as workout;
import 'package:valcue/features/routines/models/routine.dart';
import 'package:valcue/features/workout/screens/workout_screen.dart';
import 'package:valcue/features/workout/state/workout_state.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'package:valcue/services/workout_live_activity_schedule_backend.dart';
import 'package:valcue/services/workout_live_activity_schedule_models.dart';

class _TestSettingsProvider extends AppSettingsProvider {
  @override
  Future<void> loadSettings() async {}

  @override
  bool get isPremium => true;

  @override
  bool get backgroundIntervalNotificationsEnabled => true;

  @override
  String get language => 'en';

  @override
  String get measurement => 'kmh';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const liveActivityChannel = MethodChannel('valcue/live_activity');
  const notificationChannel =
      MethodChannel('dexterous.com/flutter/local_notifications');
  const timezoneChannel = MethodChannel('flutter_timezone');
  const wakelockChannel =
      'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle';
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  final routine = Routine(
    id: 'live-activity-routine',
    name: 'Live Activity Test',
    difficulty: 'easy',
    intervals: [
      workout.Interval.treadmill(
        id: 'interval-1',
        durationSeconds: 60,
        speedKmh: 8,
        grade: 1,
      ),
    ],
  );

  setUp(() async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    messenger.setMockMethodCallHandler(notificationChannel, (call) async {
      return switch (call.method) {
        'initialize' => true,
        'pendingNotificationRequests' => <Map<String, dynamic>>[],
        _ => null,
      };
    });
    messenger.setMockMethodCallHandler(timezoneChannel, (call) async => 'UTC');
    messenger.setMockMessageHandler(
      wakelockChannel,
      (message) async =>
          const StandardMessageCodec().encodeMessage(<Object?>[null]),
    );
    TestWidgetsFlutterBinding.instance
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });

  tearDown(() async {
    messenger.setMockMethodCallHandler(liveActivityChannel, null);
    messenger.setMockMethodCallHandler(notificationChannel, null);
    messenger.setMockMethodCallHandler(timezoneChannel, null);
    messenger.setMockMessageHandler(wakelockChannel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  Future<void> pumpWorkout(
    WidgetTester tester, {
    WorkoutLiveActivityScheduleBackend? scheduleBackend,
    DateTime Function()? nowProvider,
    Routine? workoutRoutine,
    bool backgroundNotificationsAuthorized = false,
  }) async {
    tester.view.physicalSize = const Size(1400, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(
      ChangeNotifierProvider<AppSettingsProvider>.value(
        value: _TestSettingsProvider(),
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: WorkoutScreen(
            routine: workoutRoutine ?? routine,
            backgroundNotificationsAuthorized:
                backgroundNotificationsAuthorized,
            liveActivityScheduleBackend: scheduleBackend,
            nowProvider: nowProvider,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> pumpUntil(
    WidgetTester tester,
    bool Function() condition,
  ) async {
    for (var attempt = 0; attempt < 20 && !condition(); attempt++) {
      await tester.pump();
    }
    expect(condition(), isTrue);
  }

  testWidgets('retries one in-flight start after a quick lifecycle resume',
      (tester) async {
    final firstStart = Completer<Object?>();
    final calls = <MethodCall>[];
    var startCalls = 0;
    messenger.setMockMethodCallHandler(liveActivityChannel, (call) async {
      calls.add(call);
      switch (call.method) {
        case 'isSupported':
        case 'areActivitiesEnabled':
          return true;
        case 'startSession':
          startCalls++;
          if (startCalls == 1) return firstStart.future;
          final payload = call.arguments as Map<Object?, Object?>;
          return <String, Object?>{
            'started': true,
            'activityId': 'activity-$startCalls',
            'workoutSessionId': payload['workoutSessionId'],
            'remotePushEnabled': true,
            'environment': 'sandbox',
          };
        case 'getPushRegistrations':
          return <Object?>[];
        default:
          return null;
      }
    });

    await pumpWorkout(tester);
    await pumpUntil(tester, () => startCalls == 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    // Resume requests a retry, but it must not overlap the pending start.
    expect(startCalls, 1);
    firstStart.complete(<String, Object?>{'started': false});
    await pumpUntil(tester, () => startCalls == 2);

    expect(startCalls, 2);
    expect(calls.where((call) => call.method == 'update'), isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('bounds foreground start failures to one retry', (tester) async {
    var startCalls = 0;
    messenger.setMockMethodCallHandler(liveActivityChannel, (call) async {
      switch (call.method) {
        case 'isSupported':
        case 'areActivitiesEnabled':
          return true;
        case 'startSession':
          startCalls++;
          return <String, Object?>{'started': false};
        case 'getPushRegistrations':
          return <Object?>[];
        default:
          return null;
      }
    });

    await pumpWorkout(tester);
    await pumpUntil(tester, () => startCalls == 2);
    for (var index = 0; index < 10; index++) {
      await tester.pump();
    }

    expect(startCalls, 2);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('late start after dispose ends with consistent finished copy',
      (tester) async {
    final pendingStart = Completer<Object?>();
    final endPayloads = <Map<Object?, Object?>>[];
    var startCalls = 0;
    String? workoutSessionId;
    messenger.setMockMethodCallHandler(liveActivityChannel, (call) async {
      switch (call.method) {
        case 'isSupported':
        case 'areActivitiesEnabled':
          return true;
        case 'startSession':
          startCalls++;
          final payload = call.arguments as Map<Object?, Object?>;
          workoutSessionId = payload['workoutSessionId'] as String?;
          return pendingStart.future;
        case 'getPushRegistrations':
          return <Object?>[];
        case 'end':
          endPayloads.add(call.arguments as Map<Object?, Object?>);
          return null;
        default:
          return null;
      }
    });

    await pumpWorkout(tester);
    await pumpUntil(tester, () => startCalls == 1);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    pendingStart.complete(<String, Object?>{
      'started': true,
      'activityId': 'activity-1',
      'workoutSessionId': workoutSessionId,
      'remotePushEnabled': true,
      'environment': 'sandbox',
    });
    await pumpUntil(tester, () => endPayloads.isNotEmpty);

    expect(endPayloads.single['status'], 'finished');
    expect(endPayloads.single['statusText'], 'Workout Complete');
    expect(endPayloads.single['dismissImmediately'], isTrue);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('joins the native snapshot and uploads one initial schedule',
      (tester) async {
    final backend = _RecordingScheduleBackend();
    String? workoutSessionId;
    var activityStarted = false;
    messenger.setMockMethodCallHandler(liveActivityChannel, (call) async {
      switch (call.method) {
        case 'isSupported':
        case 'areActivitiesEnabled':
          return true;
        case 'startSession':
          final payload = call.arguments as Map<Object?, Object?>;
          workoutSessionId = payload['workoutSessionId'] as String?;
          activityStarted = true;
          return <String, Object?>{
            'started': true,
            'activityId': 'activity-1',
            'workoutSessionId': workoutSessionId,
            'remotePushEnabled': true,
            'environment': 'sandbox',
          };
        case 'getPushRegistrations':
          if (!activityStarted) return <Object?>[];
          return <Object?>[
            <String, Object?>{
              'type': 'activitySnapshot',
              'schemaVersion': 1,
              'activityId': 'activity-1',
              'routineId': routine.id,
              'workoutSessionId': workoutSessionId,
              'environment': 'sandbox',
              'timestampMs': 1700000000000,
              'version': 1,
              'tokenHex': 'aabbcc',
              'state': 'active',
            },
          ];
        default:
          return null;
      }
    });

    await pumpWorkout(tester, scheduleBackend: backend);
    await pumpUntil(tester, () => backend.registrations.isNotEmpty);

    expect(backend.registrations, hasLength(1));
    final registration = backend.registrations.single;
    expect(registration.sessionId, workoutSessionId);
    expect(registration.activityId, 'activity-1');
    expect(registration.pushToken, 'aabbcc');
    expect(registration.scheduleRevision, 1);
    expect(registration.plan.events.first.contentState['intervalIndex'], 1);
    expect(
      registration.plan.events.first.contentState['primaryMetric'],
      'Speed 8.0 km/h',
    );

    for (var index = 0; index < 10; index++) {
      await tester.pump();
    }
    expect(backend.registrations, hasLength(1));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(backend.cancellations, hasLength(1));
    expect(
      backend.cancellations.single.reason,
      WorkoutLiveActivityScheduleCancelReason.disposed,
    );
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('resume rebuilds an unacknowledged schedule from current time',
      (tester) async {
    final backend = _RecordingScheduleBackend(acceptUpserts: false);
    var now = DateTime.fromMillisecondsSinceEpoch(1700000000000);
    final longRoutine = Routine(
      id: 'long-unacknowledged-routine',
      name: 'Long workout',
      difficulty: 'easy',
      intervals: [
        workout.Interval.treadmill(
          id: 'long-interval',
          durationSeconds: 30 * 60,
          speedKmh: 8,
          grade: 1,
        ),
      ],
    );
    String? workoutSessionId;
    var activityStarted = false;
    messenger.setMockMethodCallHandler(liveActivityChannel, (call) async {
      switch (call.method) {
        case 'isSupported':
        case 'areActivitiesEnabled':
          return true;
        case 'startSession':
          final payload = call.arguments as Map<Object?, Object?>;
          workoutSessionId = payload['workoutSessionId'] as String?;
          activityStarted = true;
          return <String, Object?>{
            'started': true,
            'activityId': 'activity-1',
            'workoutSessionId': workoutSessionId,
            'remotePushEnabled': true,
            'environment': 'sandbox',
          };
        case 'getPushRegistrations':
          if (!activityStarted) return <Object?>[];
          return <Object?>[
            <String, Object?>{
              'type': 'activitySnapshot',
              'schemaVersion': 1,
              'activityId': 'activity-1',
              'routineId': longRoutine.id,
              'workoutSessionId': workoutSessionId,
              'environment': 'sandbox',
              'timestampMs': now.millisecondsSinceEpoch,
              'version': 1,
              'tokenHex': 'aa' * 32,
              'state': 'active',
            },
          ];
        default:
          return null;
      }
    });

    await pumpWorkout(
      tester,
      scheduleBackend: backend,
      nowProvider: () => now,
      workoutRoutine: longRoutine,
    );
    await pumpUntil(tester, () => backend.registrations.isNotEmpty);
    expect(backend.registrations.first.scheduleRevision, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    now = now.add(const Duration(minutes: 10));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await pumpUntil(
      tester,
      () => backend.registrations.any(
        (registration) => registration.scheduleRevision == 2,
      ),
    );

    final fresh = backend.registrations.firstWhere(
      (registration) => registration.scheduleRevision == 2,
    );
    expect(fresh.generatedAt, now);
    expect(fresh.plan.generatedAt, now);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('token rotation refreshes an acknowledged stale schedule',
      (tester) async {
    final backend = _RecordingScheduleBackend();
    var now = DateTime.fromMillisecondsSinceEpoch(1700000000000);
    final longRoutine = Routine(
      id: 'long-token-routine',
      name: 'Long workout',
      difficulty: 'easy',
      intervals: [
        workout.Interval.treadmill(
          id: 'long-interval',
          durationSeconds: 30 * 60,
          speedKmh: 8,
          grade: 1,
        ),
      ],
    );
    String? workoutSessionId;
    var activityStarted = false;
    var tokenVersion = 1;
    var tokenHex = 'aa' * 32;
    messenger.setMockMethodCallHandler(liveActivityChannel, (call) async {
      switch (call.method) {
        case 'isSupported':
        case 'areActivitiesEnabled':
          return true;
        case 'startSession':
          final payload = call.arguments as Map<Object?, Object?>;
          workoutSessionId = payload['workoutSessionId'] as String?;
          activityStarted = true;
          return <String, Object?>{
            'started': true,
            'activityId': 'activity-1',
            'workoutSessionId': workoutSessionId,
            'remotePushEnabled': true,
            'environment': 'sandbox',
          };
        case 'getPushRegistrations':
          if (!activityStarted) return <Object?>[];
          return <Object?>[
            <String, Object?>{
              'type': 'activitySnapshot',
              'schemaVersion': 1,
              'activityId': 'activity-1',
              'routineId': longRoutine.id,
              'workoutSessionId': workoutSessionId,
              'environment': 'sandbox',
              'timestampMs': now.millisecondsSinceEpoch,
              'version': tokenVersion,
              'tokenHex': tokenHex,
              'state': 'active',
            },
          ];
        default:
          return null;
      }
    });

    await pumpWorkout(
      tester,
      scheduleBackend: backend,
      nowProvider: () => now,
      workoutRoutine: longRoutine,
    );
    await pumpUntil(tester, () => backend.registrations.isNotEmpty);
    expect(backend.registrations, hasLength(1));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    now = now.add(const Duration(minutes: 10));
    tokenVersion = 2;
    tokenHex = 'bb' * 32;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await pumpUntil(
      tester,
      () => backend.registrations.any(
        (registration) => registration.pushToken == tokenHex,
      ),
    );

    final rotated = backend.registrations.lastWhere(
      (registration) => registration.pushToken == tokenHex,
    );
    expect(rotated.scheduleRevision, 2);
    expect(rotated.tokenVersion, 2);
    expect(rotated.generatedAt, now);
    expect(
      backend.registrations
          .where((registration) => registration.scheduleRevision == 2)
          .every((registration) => registration.pushToken == tokenHex),
      isTrue,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('pause tombstones and resume replaces without tick churn',
      (tester) async {
    final backend = _RecordingScheduleBackend();
    var now = DateTime.fromMillisecondsSinceEpoch(1700000000000);
    String? workoutSessionId;
    var activityStarted = false;
    messenger.setMockMethodCallHandler(liveActivityChannel, (call) async {
      switch (call.method) {
        case 'isSupported':
        case 'areActivitiesEnabled':
          return true;
        case 'startSession':
          final payload = call.arguments as Map<Object?, Object?>;
          workoutSessionId = payload['workoutSessionId'] as String?;
          activityStarted = true;
          return <String, Object?>{
            'started': true,
            'activityId': 'activity-1',
            'workoutSessionId': workoutSessionId,
            'remotePushEnabled': true,
            'environment': 'sandbox',
          };
        case 'getPushRegistrations':
          if (!activityStarted) return <Object?>[];
          return <Object?>[
            <String, Object?>{
              'type': 'activitySnapshot',
              'schemaVersion': 1,
              'activityId': 'activity-1',
              'routineId': routine.id,
              'workoutSessionId': workoutSessionId,
              'environment': 'sandbox',
              'timestampMs': 1700000000000,
              'version': 1,
              'tokenHex': 'aabbcc',
              'state': 'active',
            },
          ];
        default:
          return null;
      }
    });

    await pumpWorkout(
      tester,
      scheduleBackend: backend,
      nowProvider: () => now,
    );
    await pumpUntil(tester, () => backend.registrations.isNotEmpty);

    final scaffoldContext = tester.element(find.byType(Scaffold));
    final state = Provider.of<WorkoutState>(
      scaffoldContext,
      listen: false,
    );
    now = now.add(const Duration(seconds: 3));
    state.synchronizeWithClock();
    await tester.pump();
    expect(state.status, WorkoutStatus.running);
    expect(backend.registrations, hasLength(1));

    state.pauseWorkout();
    await tester.pump();
    expect(backend.cancellations, hasLength(1));
    expect(
      backend.cancellations.single.reason,
      WorkoutLiveActivityScheduleCancelReason.paused,
    );
    expect(backend.cancellations.single.scheduleRevision, 2);

    state.startResumeCountdown();
    await tester.pump();
    expect(backend.registrations, hasLength(2));
    expect(backend.registrations.last.scheduleRevision, 3);
    expect(
      backend
          .registrations.last.plan.events.first.contentState['intervalIndex'],
      1,
    );

    await tester.pump(const Duration(milliseconds: 500));
    expect(backend.registrations, hasLength(2));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    debugDefaultTargetPlatformOverride = null;
  });
}

class _RecordingScheduleBackend implements WorkoutLiveActivityScheduleBackend {
  _RecordingScheduleBackend({this.acceptUpserts = true});

  final bool acceptUpserts;
  final List<WorkoutLiveActivityScheduleRegistration> registrations = [];
  final List<WorkoutLiveActivityScheduleCancellation> cancellations = [];

  @override
  Future<WorkoutLiveActivityScheduleAck> upsertSchedule(
    WorkoutLiveActivityScheduleRegistration registration,
  ) async {
    registrations.add(registration);
    return acceptUpserts
        ? WorkoutLiveActivityScheduleAck.accepted(
            registration.scheduleRevision,
          )
        : WorkoutLiveActivityScheduleAck.ignored(
            registration.scheduleRevision,
          );
  }

  @override
  Future<WorkoutLiveActivityScheduleAck> cancelSchedule(
    WorkoutLiveActivityScheduleCancellation cancellation,
  ) async {
    cancellations.add(cancellation);
    return WorkoutLiveActivityScheduleAck.accepted(
      cancellation.scheduleRevision,
    );
  }
}
