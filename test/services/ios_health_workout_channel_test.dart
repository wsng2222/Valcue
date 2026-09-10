import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valcue/features/profile/models/workout_session.dart';
import 'package:valcue/features/routines/models/machine_type.dart';
import 'package:valcue/services/health_sync_service.dart';
import 'package:valcue/services/ios_health_workout_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('what gets sent to HealthKit', () {
    test('carries the times, distance and energy the workout had', () async {
      final fake = _FakeChannel(returns: true);

      await fake.wrapper.writeWorkout(
        start: DateTime(2026, 5, 1, 7, 0),
        end: DateTime(2026, 5, 1, 7, 30),
        machineType: MachineType.treadmill,
        title: 'Intervals',
        distanceMeters: 5000,
        activeEnergyKcal: 350,
      );

      final args = fake.lastArguments!;
      expect(args['activityType'], 'running');
      expect(
        args['startMs'],
        DateTime(2026, 5, 1, 7, 0).millisecondsSinceEpoch,
      );
      expect(
        args['endMs'],
        DateTime(2026, 5, 1, 7, 30).millisecondsSinceEpoch,
      );
      expect(args['distanceMeters'], 5000);
      expect(args['activeEnergyKcal'], 350);
      expect(args['title'], 'Intervals');
    });

    test('omits distance and energy when there are none', () async {
      final fake = _FakeChannel(returns: true);

      await fake.wrapper.writeWorkout(
        start: DateTime(2026, 5, 1, 7, 0),
        end: DateTime(2026, 5, 1, 7, 30),
        machineType: MachineType.treadmill,
      );

      expect(fake.lastArguments!['distanceMeters'], isNull);
      expect(fake.lastArguments!['activeEnergyKcal'], isNull);
    });

    test('names an activity HealthKit accepts for every machine', () {
      expect(
        IosHealthWorkoutChannel.activityNameFor(MachineType.treadmill),
        'running',
      );
      expect(
        IosHealthWorkoutChannel.activityNameFor(MachineType.cycle),
        'cycling',
      );
      expect(
        IosHealthWorkoutChannel.activityNameFor(MachineType.stairmaster),
        'stairClimbing',
      );
    });
  });

  group('when the native side cannot help', () {
    test('a refused write is reported, not thrown', () async {
      final fake = _FakeChannel(returns: false);

      expect(await fake.wrapper.writeWorkout(
          start: DateTime(2026, 5, 1, 7, 0),
          end: DateTime(2026, 5, 1, 7, 30),
          machineType: MachineType.treadmill,
        ), isFalse);
    });

    test('a throwing bridge is reported, not thrown', () async {
      final fake = _FakeChannel(throws: PlatformException(code: 'nope'));

      expect(await fake.wrapper.writeWorkout(
          start: DateTime(2026, 5, 1, 7, 0),
          end: DateTime(2026, 5, 1, 7, 30),
          machineType: MachineType.treadmill,
        ), isFalse);
      expect(await fake.wrapper.isAvailable(), isFalse);
    });

    test('a missing bridge is reported, not thrown', () async {
      final fake = _FakeChannel(throws: MissingPluginException());

      expect(await fake.wrapper.writeWorkout(
          start: DateTime(2026, 5, 1, 7, 0),
          end: DateTime(2026, 5, 1, 7, 30),
          machineType: MachineType.treadmill,
        ), isFalse);
      expect(await fake.wrapper.isAvailable(), isFalse);
    });
  });

  group('platform routing', () {
    test('iOS writes through the native bridge, not the plugin', () async {
      final fake = _FakeChannel(returns: true);
      final service = HealthSyncService(
        iosChannel: fake.wrapper,
        isIOS: () => true,
        isAndroid: () => false,
      );

      final outcome = await service.writeWorkout(
        _session(distanceMeters: 5000),
        enabled: true,
        bodyWeightKg: 70,
      );

      expect(outcome, HealthSyncOutcome.written);
      expect(fake.callCount, 1);
      // The energy estimate must actually reach HealthKit, or the rings
      // stay empty - which is the whole point of the native bridge.
      expect(fake.lastArguments!['activeEnergyKcal'], greaterThan(0));
    });

    test('sends the span the workout really occupied', () async {
      final fake = _FakeChannel(returns: true);
      final service = HealthSyncService(
        iosChannel: fake.wrapper,
        isIOS: () => true,
        isAndroid: () => false,
      );

      // The session below finished at 07:30 after 30 minutes.
      await service.writeWorkout(_session(), enabled: true, bodyWeightKg: 70);

      expect(
        fake.lastArguments!['startMs'],
        DateTime(2026, 5, 1, 7, 0).millisecondsSinceEpoch,
      );
      expect(
        fake.lastArguments!['endMs'],
        DateTime(2026, 5, 1, 7, 30).millisecondsSinceEpoch,
      );
    });

    test('a switched-off setting never reaches the bridge', () async {
      final fake = _FakeChannel(returns: true);
      final service = HealthSyncService(
        iosChannel: fake.wrapper,
        isIOS: () => true,
        isAndroid: () => false,
      );

      await service.writeWorkout(_session(), enabled: false);

      expect(fake.callCount, 0);
    });
  });
}

WorkoutSession _session({double? distanceMeters}) {
  return WorkoutSession(
    id: 'session-1',
    machineType: MachineType.treadmill,
    dateTime: DateTime(2026, 5, 1, 7, 30), // when it finished
    durationSeconds: 1800,
    distanceMeters: distanceMeters,
    routineName: 'Intervals',
    routineId: 'routine-1',
  );
}

class _FakeChannel {
  _FakeChannel({this.returns = false, this.throws}) {
    const channel = MethodChannel(IosHealthWorkoutChannel.channelName);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      callCount++;
      lastArguments = (call.arguments as Map?)?.cast<String, dynamic>();
      if (throws != null) throw throws!;
      return returns;
    });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    wrapper = IosHealthWorkoutChannel(channel: channel);
  }

  final bool returns;
  final Object? throws;
  late final IosHealthWorkoutChannel wrapper;
  int callCount = 0;
  Map<String, dynamic>? lastArguments;
}
