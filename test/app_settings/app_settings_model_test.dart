import 'package:flutter_test/flutter_test.dart';
import 'package:valcue/app_settings/app_settings_model.dart';

void main() {
  group('AppSettings theme migration', () {
    test('defaults to system theme without user intent', () {
      final settings = AppSettings.defaultSettings;

      expect(settings.themeMode, 'system');
      expect(settings.themeModeUserSet, isFalse);
    });

    test('migrates legacy light default to system', () {
      final settings = AppSettings.fromJson({
        'measurement': 'kmh',
        'isPremium': false,
        'voiceGuideEnabled': false,
        'themeMode': 'light',
      });

      expect(settings.themeMode, 'system');
      expect(settings.themeModeUserSet, isFalse);
    });

    test('preserves explicit light selection', () {
      final settings = AppSettings.fromJson({
        'measurement': 'kmh',
        'isPremium': false,
        'voiceGuideEnabled': false,
        'themeMode': 'light',
        'themeModeUserSet': true,
      });

      expect(settings.themeMode, 'light');
      expect(settings.themeModeUserSet, isTrue);
    });
  });

  group('background interval notification setting', () {
    test('defaults to enabled for new and legacy settings', () {
      expect(
        AppSettings.defaultSettings.backgroundIntervalNotificationsEnabled,
        isTrue,
      );

      final legacy = AppSettings.fromJson({
        'measurement': 'kmh',
        'isPremium': true,
        'voiceGuideEnabled': false,
        'themeMode': 'system',
      });
      expect(legacy.backgroundIntervalNotificationsEnabled, isTrue);
    });

    test('persists an explicit disabled preference', () {
      final disabled = AppSettings.defaultSettings.copyWith(
        backgroundIntervalNotificationsEnabled: false,
      );
      final restored = AppSettings.fromJson(disabled.toJson());

      expect(restored.backgroundIntervalNotificationsEnabled, isFalse);
    });
  });
}
