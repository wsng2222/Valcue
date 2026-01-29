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
      return AppSettings.fromJson(json);
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

