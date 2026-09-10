import 'package:flutter_test/flutter_test.dart';
import 'package:valcue/app_settings/app_settings_model.dart';
import 'package:valcue/app_settings/app_settings_provider.dart';
import 'package:valcue/app_settings/app_settings_store.dart';

/// The health toggle must never claim to be syncing when the health store has
/// not actually granted access.
void main() {
  test('stays off when the health store refuses access', () async {
    final store = _FakeStore(AppSettings.defaultSettings);
    final provider = _build(store, permissionGranted: false);
    addTearDown(provider.dispose);

    final enabled = await provider.updateHealthSync(true);

    expect(enabled, isFalse);
    expect(provider.healthSyncEnabled, isFalse);
    expect(store.saveCount, 0);
  });

  test('turns on and persists once access is granted', () async {
    final store = _FakeStore(AppSettings.defaultSettings);
    final provider = _build(store, permissionGranted: true);
    addTearDown(provider.dispose);

    final enabled = await provider.updateHealthSync(true);

    expect(enabled, isTrue);
    expect(provider.healthSyncEnabled, isTrue);
    expect(store.persisted.healthSyncEnabled, isTrue);
  });

  test('turning off never asks for permission', () async {
    final store = _FakeStore(
      AppSettings.defaultSettings.copyWith(healthSyncEnabled: true),
    );
    var permissionRequests = 0;
    final provider = AppSettingsProvider(
      store: store,
      initialSettings: store.persisted,
      loadSettingsOnCreate: false,
      requestWorkoutNotificationPermissions: () async => true,
      areLiveActivitiesEnabled: () async => true,
      cancelWorkoutIntervalNotifications: () async {},
      cleanupLiveActivities: () async {},
      requestHealthPermission: () async {
        permissionRequests++;
        return true;
      },
    );
    addTearDown(provider.dispose);

    await provider.updateHealthSync(false);

    expect(provider.healthSyncEnabled, isFalse);
    expect(permissionRequests, 0);
  });

  test('re-enabling an already-on setting writes nothing new', () async {
    final store = _FakeStore(
      AppSettings.defaultSettings.copyWith(healthSyncEnabled: true),
    );
    final provider = _build(store, permissionGranted: true);
    addTearDown(provider.dispose);

    await provider.updateHealthSync(true);

    expect(store.saveCount, 0);
  });

  test('the setting is off for someone who never turned it on', () {
    expect(AppSettings.defaultSettings.healthSyncEnabled, isFalse);
  });

  test('survives a save and load round trip', () {
    final settings =
        AppSettings.defaultSettings.copyWith(healthSyncEnabled: true);

    final reloaded = AppSettings.fromJson(settings.toJson());

    expect(reloaded.healthSyncEnabled, isTrue);
  });
}

AppSettingsProvider _build(
  _FakeStore store, {
  required bool permissionGranted,
}) {
  return AppSettingsProvider(
    store: store,
    initialSettings: store.persisted,
    loadSettingsOnCreate: false,
    requestWorkoutNotificationPermissions: () async => true,
    areLiveActivitiesEnabled: () async => true,
    cancelWorkoutIntervalNotifications: () async {},
    cleanupLiveActivities: () async {},
    requestHealthPermission: () async => permissionGranted,
  );
}

class _FakeStore extends AppSettingsStore {
  _FakeStore(this.persisted);

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
