import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:valcue/app_settings/app_settings_model.dart';
import 'package:valcue/app_settings/app_settings_provider.dart';
import 'package:valcue/app_settings/app_settings_store.dart';

void main() {
  group('real-time workout coaching setting', () {
    test('stays enabled when notifications are denied but Live Activity works',
        () async {
      final store = _FakeAppSettingsStore(_premiumSettings(enabled: false));
      var notificationRequests = 0;
      final provider = _buildProvider(
        store: store,
        requestNotifications: () async {
          notificationRequests++;
          return false;
        },
        liveActivitiesEnabled: () async => true,
      );
      addTearDown(provider.dispose);

      final success =
          await provider.updateBackgroundIntervalNotifications(true);

      expect(success, isTrue);
      expect(provider.backgroundIntervalNotificationsEnabled, isTrue);
      expect(store.persisted.backgroundIntervalNotificationsEnabled, isTrue);
      expect(notificationRequests, 1);
    });

    test('uses notification authorization when Live Activity is unavailable',
        () async {
      final store = _FakeAppSettingsStore(_premiumSettings(enabled: false));
      final provider = _buildProvider(
        store: store,
        requestNotifications: () async => true,
        liveActivitiesEnabled: () async => false,
      );
      addTearDown(provider.dispose);

      final success =
          await provider.updateBackgroundIntervalNotifications(true);

      expect(success, isTrue);
      expect(provider.backgroundIntervalNotificationsEnabled, isTrue);
    });

    test('rejects enable only when both delivery surfaces are unavailable',
        () async {
      final store = _FakeAppSettingsStore(_premiumSettings(enabled: false));
      final provider = _buildProvider(
        store: store,
        requestNotifications: () async => false,
        liveActivitiesEnabled: () async => false,
      );
      addTearDown(provider.dispose);

      final success =
          await provider.updateBackgroundIntervalNotifications(true);

      expect(success, isFalse);
      expect(provider.backgroundIntervalNotificationsEnabled, isFalse);
      expect(store.persisted.backgroundIntervalNotificationsEnabled, isFalse);
    });

    test('OFF supersedes an enable waiting on an async capability check',
        () async {
      final liveActivityResult = Completer<bool>();
      final store = _FakeAppSettingsStore(_premiumSettings(enabled: false));
      var notificationRequests = 0;
      var notificationCancellations = 0;
      var liveActivityCleanups = 0;
      final provider = _buildProvider(
        store: store,
        requestNotifications: () async {
          notificationRequests++;
          return true;
        },
        liveActivitiesEnabled: () => liveActivityResult.future,
        cancelNotifications: () async {
          notificationCancellations++;
        },
        cleanupLiveActivities: () async {
          liveActivityCleanups++;
        },
      );
      addTearDown(provider.dispose);

      final enable = provider.updateBackgroundIntervalNotifications(true);
      await _flushMicrotasks();

      final disable = provider.updateBackgroundIntervalNotifications(false);
      expect(provider.backgroundIntervalNotificationsEnabled, isFalse);

      liveActivityResult.complete(true);
      expect(await enable, isTrue);
      expect(await disable, isTrue);

      expect(provider.backgroundIntervalNotificationsEnabled, isFalse);
      expect(store.persisted.backgroundIntervalNotificationsEnabled, isFalse);
      expect(notificationRequests, 0);
      expect(notificationCancellations, 1);
      expect(liveActivityCleanups, 1);
    });

    test('OFF supersedes an enable waiting on notification permission',
        () async {
      final notificationResult = Completer<bool>();
      final store = _FakeAppSettingsStore(_premiumSettings(enabled: false));
      var notificationCancellations = 0;
      var liveActivityCleanups = 0;
      final provider = _buildProvider(
        store: store,
        requestNotifications: () => notificationResult.future,
        liveActivitiesEnabled: () async => true,
        cancelNotifications: () async {
          notificationCancellations++;
        },
        cleanupLiveActivities: () async {
          liveActivityCleanups++;
        },
      );
      addTearDown(provider.dispose);

      final enable = provider.updateBackgroundIntervalNotifications(true);
      await _flushMicrotasks();

      final disable = provider.updateBackgroundIntervalNotifications(false);
      notificationResult.complete(true);

      expect(await enable, isTrue);
      expect(await disable, isTrue);
      expect(provider.backgroundIntervalNotificationsEnabled, isFalse);
      expect(store.persisted.backgroundIntervalNotificationsEnabled, isFalse);
      expect(notificationCancellations, 1);
      expect(liveActivityCleanups, 1);
    });

    test('premium revocation invalidates an enable that completes late',
        () async {
      final liveActivityResult = Completer<bool>();
      final store = _FakeAppSettingsStore(_premiumSettings(enabled: false));
      var notificationRequests = 0;
      var notificationCancellations = 0;
      var liveActivityCleanups = 0;
      final provider = _buildProvider(
        store: store,
        requestNotifications: () async {
          notificationRequests++;
          return true;
        },
        liveActivitiesEnabled: () => liveActivityResult.future,
        cancelNotifications: () async {
          notificationCancellations++;
        },
        cleanupLiveActivities: () async {
          liveActivityCleanups++;
        },
      );
      addTearDown(provider.dispose);

      final enable = provider.updateBackgroundIntervalNotifications(true);
      await _flushMicrotasks();

      final revoke = provider.updatePremium(false);
      expect(provider.isPremium, isFalse);
      expect(provider.backgroundIntervalNotificationsEnabled, isFalse);

      liveActivityResult.complete(true);
      expect(await enable, isTrue);
      await revoke;

      expect(provider.settings.isPremium, isFalse);
      expect(
        provider.settings.backgroundIntervalNotificationsEnabled,
        isFalse,
      );
      expect(store.persisted.isPremium, isFalse);
      expect(store.persisted.backgroundIntervalNotificationsEnabled, isFalse);
      expect(notificationRequests, 0);
      expect(notificationCancellations, 1);
      expect(liveActivityCleanups, 1);
    });

    test('a newer ON waits for an older OFF cleanup before committing',
        () async {
      final cleanupStarted = Completer<void>();
      final allowCleanupToFinish = Completer<void>();
      final store = _FakeAppSettingsStore(_premiumSettings(enabled: true));
      final provider = _buildProvider(
        store: store,
        requestNotifications: () async => false,
        liveActivitiesEnabled: () async => true,
        cleanupLiveActivities: () async {
          if (!cleanupStarted.isCompleted) cleanupStarted.complete();
          await allowCleanupToFinish.future;
        },
      );
      addTearDown(provider.dispose);

      final disable = provider.updateBackgroundIntervalNotifications(false);
      await cleanupStarted.future;
      final enable = provider.updateBackgroundIntervalNotifications(true);
      await _flushMicrotasks();

      expect(provider.backgroundIntervalNotificationsEnabled, isFalse);

      allowCleanupToFinish.complete();
      expect(await disable, isTrue);
      expect(await enable, isTrue);

      expect(provider.backgroundIntervalNotificationsEnabled, isTrue);
      expect(store.persisted.backgroundIntervalNotificationsEnabled, isTrue);
    });

    test('serializes persistence so a late ON write cannot beat a newer OFF',
        () async {
      final store = _ControlledAppSettingsStore(
        _premiumSettings(enabled: false),
      );
      final provider = _buildProvider(
        store: store,
        requestNotifications: () async => false,
        liveActivitiesEnabled: () async => true,
      );
      addTearDown(provider.dispose);

      final enable = provider.updateBackgroundIntervalNotifications(true);
      await _flushUntil(() => store.writes.length == 1);
      expect(provider.backgroundIntervalNotificationsEnabled, isTrue);

      final disable = provider.updateBackgroundIntervalNotifications(false);
      expect(provider.backgroundIntervalNotificationsEnabled, isFalse);
      expect(store.writes, hasLength(1));

      store.writes.first.complete();
      await _flushUntil(() => store.writes.length == 2);
      store.writes.last.complete();

      expect(await enable, isTrue);
      expect(await disable, isTrue);
      expect(store.persisted.backgroundIntervalNotificationsEnabled, isFalse);
    });

    test('serializes unrelated setting updates behind coaching writes',
        () async {
      final store = _ControlledAppSettingsStore(
        _premiumSettings(enabled: false),
      );
      final provider = _buildProvider(
        store: store,
        requestNotifications: () async => false,
        liveActivitiesEnabled: () async => true,
      );
      addTearDown(provider.dispose);

      final enable = provider.updateBackgroundIntervalNotifications(true);
      await _flushUntil(() => store.writes.length == 1);

      final updateTheme = provider.updateThemeMode('dark');
      expect(store.writes, hasLength(1));

      store.writes.first.complete();
      await _flushUntil(() => store.writes.length == 2);
      store.writes.last.complete();

      expect(await enable, isTrue);
      await updateTheme;
      expect(store.persisted.backgroundIntervalNotificationsEnabled, isTrue);
      expect(store.persisted.themeMode, 'dark');
    });
  });

  group('workout display size setting', () {
    test('updates listeners and persists the selected preset', () async {
      final store = _FakeAppSettingsStore(AppSettings.defaultSettings);
      final provider = _buildProvider(
        store: store,
        requestNotifications: () async => false,
        liveActivitiesEnabled: () async => false,
      );
      addTearDown(provider.dispose);
      var notificationCount = 0;
      provider.addListener(() => notificationCount++);

      await provider.updateWorkoutDisplaySize(WorkoutDisplaySize.extraLarge);

      expect(provider.workoutDisplaySize, WorkoutDisplaySize.extraLarge);
      expect(store.persisted.workoutDisplaySize, WorkoutDisplaySize.extraLarge);
      expect(notificationCount, 1);
    });

    test('does not write or notify when the preset is unchanged', () async {
      final store = _FakeAppSettingsStore(AppSettings.defaultSettings);
      final provider = _buildProvider(
        store: store,
        requestNotifications: () async => false,
        liveActivitiesEnabled: () async => false,
      );
      addTearDown(provider.dispose);
      var notificationCount = 0;
      provider.addListener(() => notificationCount++);

      await provider.updateWorkoutDisplaySize(WorkoutDisplaySize.standard);

      expect(notificationCount, 0);
      expect(store.saveCount, 0);
    });
  });
}

AppSettings _premiumSettings({required bool enabled}) {
  return AppSettings.defaultSettings.copyWith(
    isPremium: true,
    backgroundIntervalNotificationsEnabled: enabled,
  );
}

AppSettingsProvider _buildProvider({
  required AppSettingsStore store,
  required Future<bool> Function() requestNotifications,
  required Future<bool> Function() liveActivitiesEnabled,
  Future<void> Function()? cancelNotifications,
  Future<void> Function()? cleanupLiveActivities,
}) {
  final initialSettings = switch (store) {
    _FakeAppSettingsStore fake => fake.persisted,
    _ControlledAppSettingsStore controlled => controlled.persisted,
    _ => AppSettings.defaultSettings,
  };
  return AppSettingsProvider(
    store: store,
    initialSettings: initialSettings,
    loadSettingsOnCreate: false,
    requestWorkoutNotificationPermissions: requestNotifications,
    areLiveActivitiesEnabled: liveActivitiesEnabled,
    cancelWorkoutIntervalNotifications: cancelNotifications ?? () async {},
    cleanupLiveActivities: cleanupLiveActivities ?? () async {},
  );
}

Future<void> _flushMicrotasks() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

Future<void> _flushUntil(bool Function() condition) async {
  for (var i = 0; i < 20 && !condition(); i++) {
    await Future<void>.delayed(Duration.zero);
  }
  expect(condition(), isTrue, reason: 'Async operation did not make progress');
}

class _FakeAppSettingsStore extends AppSettingsStore {
  _FakeAppSettingsStore(this.persisted);

  AppSettings persisted;
  int saveCount = 0;

  @override
  Future<AppSettings> loadSettings() async => persisted;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    saveCount++;
    persisted = AppSettings.fromJson(settings.toJson());
  }
}

class _ControlledAppSettingsStore extends AppSettingsStore {
  _ControlledAppSettingsStore(this.persisted);

  AppSettings persisted;
  final List<_PendingSettingsWrite> writes = <_PendingSettingsWrite>[];

  @override
  Future<AppSettings> loadSettings() async => persisted;

  @override
  Future<void> saveSettings(AppSettings settings) async {
    final write = _PendingSettingsWrite(
      AppSettings.fromJson(settings.toJson()),
    );
    writes.add(write);
    await write.completer.future;
    persisted = write.settings;
  }
}

class _PendingSettingsWrite {
  _PendingSettingsWrite(this.settings);

  final AppSettings settings;
  final Completer<void> completer = Completer<void>();

  void complete() => completer.complete();
}
