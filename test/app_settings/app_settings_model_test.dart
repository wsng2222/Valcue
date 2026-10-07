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

  group('workout display size setting', () {
    test('defaults legacy and invalid values to standard', () {
      expect(
        AppSettings.defaultSettings.workoutDisplaySize,
        WorkoutDisplaySize.standard,
      );
      expect(
        AppSettings.fromJson(const {}).workoutDisplaySize,
        WorkoutDisplaySize.standard,
      );
      expect(
        AppSettings.fromJson(
          const {'workoutDisplaySize': 'unsupported'},
        ).workoutDisplaySize,
        WorkoutDisplaySize.standard,
      );
    });

    test('persists every supported preset', () {
      for (final size in WorkoutDisplaySize.values) {
        final restored = AppSettings.fromJson(
          AppSettings.defaultSettings
              .copyWith(workoutDisplaySize: size)
              .toJson(),
        );

        expect(restored.workoutDisplaySize, size);
      }
    });
  });

  group('profile', () {
    test('survives a storage round trip', () {
      final restored = AppSettings.fromJson(
        AppSettings.defaultSettings
            .copyWith(
              profileName: '휘성',
              avatarEmoji: '🦊',
              avatarBg: '#DEE4FB',
            )
            .toJson(),
      );

      expect(restored.profileName, '휘성');
      expect(restored.avatarEmoji, '🦊');
      expect(restored.avatarBg, '#DEE4FB');
    });

    test('falls back to the defaults when absent from stored JSON', () {
      final restored = AppSettings.fromJson(const {});

      expect(restored.profileName, '');
      expect(restored.avatarEmoji, defaultAvatarEmoji);
      expect(restored.avatarBg, defaultAvatarBg);
    });
  });

  group('clearing the language', () {
    test('nulls the language but keeps every other field', () {
      // resetLanguageToSystem used to rebuild AppSettings field by field and
      // silently dropped whatever it forgot to copy - healthSyncEnabled did
      // not survive, and every new field was one more chance to lose data.
      // clearLanguage exists so that rebuild is no longer necessary.
      final before = AppSettings.defaultSettings.copyWith(
        language: 'ko',
        healthSyncEnabled: true,
        profileName: '휘성',
        avatarEmoji: '🦊',
        avatarBg: '#DEE4FB',
        weightUnit: 'lbs',
        isPremium: true,
      );

      final after = before.copyWith(clearLanguage: true);

      expect(after.language, isNull);
      expect(after.healthSyncEnabled, isTrue);
      expect(after.profileName, '휘성');
      expect(after.avatarEmoji, '🦊');
      expect(after.avatarBg, '#DEE4FB');
      expect(after.weightUnit, 'lbs');
      expect(after.isPremium, isTrue);
    });

    test('a plain copyWith cannot clear the language', () {
      final before = AppSettings.defaultSettings.copyWith(language: 'ko');

      expect(before.copyWith(language: null).language, 'ko');
    });
  });
}
