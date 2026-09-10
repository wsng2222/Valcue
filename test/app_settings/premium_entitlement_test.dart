import 'package:flutter_test/flutter_test.dart';
import 'package:valcue/app_settings/app_settings_model.dart';
import 'package:valcue/app_settings/app_settings_provider.dart';
import 'package:valcue/app_settings/app_settings_store.dart';
import 'package:valcue/services/purchase_service.dart';

/// Covers the money-sensitive path: how a RevenueCat entitlement becomes the
/// local `isPremium` flag, and what that flag unlocks or takes away.
void main() {
  setUp(() => PurchaseService.instance.isPremiumListenable.value = null);
  tearDown(() => PurchaseService.instance.isPremiumListenable.value = null);

  group('entitlement to settings sync', () {
    test('an unresolved entitlement leaves a paying user premium', () async {
      // Null means "the SDK hasn't answered yet" - offline launch, slow
      // network. Reading it as "not premium" would lock a subscriber out.
      final store = _FakeAppSettingsStore(_settings(isPremium: true));
      final provider = _buildProvider(store);
      addTearDown(provider.dispose);

      expect(provider.isPremium, isTrue);
      expect(store.saveCount, 0);
    });

    test('an activated entitlement upgrades and persists the settings',
        () async {
      final store = _FakeAppSettingsStore(_settings(isPremium: false));
      final provider = _buildProvider(store);
      addTearDown(provider.dispose);

      PurchaseService.instance.isPremiumListenable.value = true;
      await _flushMicrotasks();

      expect(provider.isPremium, isTrue);
      expect(store.persisted.isPremium, isTrue);
    });

    test('a revoked entitlement downgrades and turns voice guide off',
        () async {
      final store = _FakeAppSettingsStore(
        _settings(isPremium: true, voiceGuide: true),
      );
      final provider = _buildProvider(store);
      addTearDown(provider.dispose);

      PurchaseService.instance.isPremiumListenable.value = false;
      await _flushMicrotasks();

      expect(provider.isPremium, isFalse);
      expect(provider.voiceGuideEnabled, isFalse);
      expect(store.persisted.isPremium, isFalse);
      expect(store.persisted.voiceGuideEnabled, isFalse);
    });

    test('an unchanged entitlement writes nothing', () async {
      final store = _FakeAppSettingsStore(_settings(isPremium: true));
      final provider = _buildProvider(store);
      addTearDown(provider.dispose);

      PurchaseService.instance.isPremiumListenable.value = true;
      await _flushMicrotasks();

      expect(store.saveCount, 0);
    });

    test('a disposed provider stops following entitlement changes', () async {
      final store = _FakeAppSettingsStore(_settings(isPremium: true));
      final provider = _buildProvider(store);

      provider.dispose();
      PurchaseService.instance.isPremiumListenable.value = false;
      await _flushMicrotasks();

      expect(store.saveCount, 0);
    });
  });

  group('what premium gates', () {
    test('voice guide cannot be switched on without premium', () async {
      final store = _FakeAppSettingsStore(_settings(isPremium: false));
      final provider = _buildProvider(store);
      addTearDown(provider.dispose);

      await provider.updateVoiceGuide(true);

      expect(provider.voiceGuideEnabled, isFalse);
      expect(store.saveCount, 0);
    });

    test('voice guide can be switched on with premium', () async {
      final store = _FakeAppSettingsStore(_settings(isPremium: true));
      final provider = _buildProvider(store);
      addTearDown(provider.dispose);

      await provider.updateVoiceGuide(true);

      expect(provider.voiceGuideEnabled, isTrue);
      expect(store.persisted.voiceGuideEnabled, isTrue);
    });

    test('background coaching is refused without premium', () async {
      final store = _FakeAppSettingsStore(_settings(isPremium: false));
      final provider = _buildProvider(store);
      addTearDown(provider.dispose);

      final accepted =
          await provider.updateBackgroundIntervalNotifications(true);

      expect(accepted, isFalse);
      expect(provider.backgroundIntervalNotificationsEnabled, isFalse);
    });

    test('a stored voice-guide preference stays off after a downgrade',
        () async {
      // The setting is reported off even if a stale `true` survives on disk,
      // so a lapsed subscriber never keeps a paid feature.
      final store = _FakeAppSettingsStore(
        _settings(isPremium: false, voiceGuide: true),
      );
      final provider = _buildProvider(store);
      addTearDown(provider.dispose);

      expect(provider.voiceGuideEnabled, isFalse);
    });
  });
}

AppSettings _settings({required bool isPremium, bool voiceGuide = false}) {
  return AppSettings.defaultSettings.copyWith(
    isPremium: isPremium,
    voiceGuideEnabled: voiceGuide,
  );
}

AppSettingsProvider _buildProvider(_FakeAppSettingsStore store) {
  return AppSettingsProvider(
    store: store,
    initialSettings: store.persisted,
    loadSettingsOnCreate: false,
    requestWorkoutNotificationPermissions: () async => true,
    areLiveActivitiesEnabled: () async => true,
    cancelWorkoutIntervalNotifications: () async {},
    cleanupLiveActivities: () async {},
  );
}

Future<void> _flushMicrotasks() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
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
