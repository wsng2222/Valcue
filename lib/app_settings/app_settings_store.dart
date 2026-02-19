import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_settings_model.dart';

class AppSettingsStore {
  static const String _storageKey = 'app_settings';

  Future<AppSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString == null || jsonString.isEmpty) {
        return AppSettings.defaultSettings;
      }
      final Map<String, dynamic> json = jsonDecode(jsonString);
      var settings = AppSettings.fromJson(json);
      var changed = false;

      // Ensure default ON for sound effects when missing in legacy data.
      if (!json.containsKey('soundEffectsEnabled')) {
        settings = settings.copyWith(soundEffectsEnabled: true);
        changed = true;
      }

      // Enforce premium gate: voice guide cannot be ON without premium.
      if (!settings.isPremium && settings.voiceGuideEnabled) {
        settings = settings.copyWith(voiceGuideEnabled: false);
        changed = true;
      }

      if (changed) {
        final updatedJsonString = jsonEncode(settings.toJson());
        await prefs.setString(_storageKey, updatedJsonString);
      }

      return settings;
    } catch (e) {
      return AppSettings.defaultSettings;
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(settings.toJson());
    await prefs.setString(_storageKey, jsonString);
  }
}
