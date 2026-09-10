import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valcue/app_settings/app_settings_model.dart';
import 'package:valcue/app_settings/app_settings_store.dart';

const String _storageKey = 'flutter.app_settings';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('premium gate on load', () {
    test('clears a voice guide left on by a lapsed subscriber', () async {
      await _seed(<String, Object?>{
        ...AppSettings.defaultSettings.toJson(),
        'isPremium': false,
        'voiceGuideEnabled': true,
      });

      final settings = await AppSettingsStore().loadSettings();

      expect(settings.voiceGuideEnabled, isFalse);
    });

    test('rewrites the cleared value so it cannot come back', () async {
      await _seed(<String, Object?>{
        ...AppSettings.defaultSettings.toJson(),
        'isPremium': false,
        'voiceGuideEnabled': true,
      });

      await AppSettingsStore().loadSettings();
      final reloaded = await AppSettingsStore().loadSettings();

      expect(reloaded.voiceGuideEnabled, isFalse);
      final prefs = await SharedPreferences.getInstance();
      final stored = jsonDecode(prefs.getString('app_settings')!) as Map;
      expect(stored['voiceGuideEnabled'], isFalse);
    });

    test('leaves a paying subscriber voice guide alone', () async {
      await _seed(<String, Object?>{
        ...AppSettings.defaultSettings.toJson(),
        'isPremium': true,
        'voiceGuideEnabled': true,
      });

      final settings = await AppSettingsStore().loadSettings();

      expect(settings.voiceGuideEnabled, isTrue);
    });
  });

  group('corrupt or missing data', () {
    test('falls back to defaults instead of throwing', () async {
      SharedPreferences.setMockInitialValues(
        <String, Object>{_storageKey: 'not json'},
      );

      final settings = await AppSettingsStore().loadSettings();

      expect(settings.isPremium, isFalse);
      expect(settings.voiceGuideEnabled, isFalse);
    });

    test('turns sound effects on for settings saved before the flag existed',
        () async {
      final legacy = Map<String, Object?>.from(
        AppSettings.defaultSettings.toJson(),
      )..remove('soundEffectsEnabled');
      await _seed(legacy);

      final settings = await AppSettingsStore().loadSettings();

      expect(settings.soundEffectsEnabled, isTrue);
    });
  });
}

Future<void> _seed(Map<String, Object?> json) async {
  SharedPreferences.setMockInitialValues(
    <String, Object>{_storageKey: jsonEncode(json)},
  );
}
