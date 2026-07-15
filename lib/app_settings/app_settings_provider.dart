import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'app_settings_model.dart';
import 'app_settings_store.dart';
import '../services/sound_service.dart';
import '../services/workout_reminder_service.dart';

class AppSettingsProvider with ChangeNotifier {
  final AppSettingsStore _store = AppSettingsStore();
  AppSettings _settings = AppSettings.defaultSettings;
  bool _isLoading = false;

  // Supported languages (same as in LanguageHelper)
  static const List<String> _supportedLanguages = [
    'ko',
    'en',
    'ja',
    'zh',
    'es',
    'fr',
    'de',
    'it',
    'pt',
    'ru',
    'ar',
    'vi',
    'th',
    'nl',
    'nb',
    'da',
  ];

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;

  String get language => _getResolvedLanguage();
  String get measurement => _settings.measurement;
  String get weightUnit => _settings.weightUnit;
  bool get isPremium => _settings.isPremium;
  bool get voiceGuideEnabled =>
      _settings.isPremium ? _settings.voiceGuideEnabled : false;
  bool get backgroundIntervalNotificationsEnabled => _settings.isPremium
      ? _settings.backgroundIntervalNotificationsEnabled
      : false;
  String get themeMode => _settings.themeMode;
  bool get soundEffectsEnabled => _settings.soundEffectsEnabled;
  bool get workoutReminderEnabled => _settings.workoutReminderEnabled;
  List<int> get workoutReminderWeekdays =>
      List<int>.unmodifiable(_settings.workoutReminderWeekdays);
  TimeOfDay get workoutReminderTime => TimeOfDay(
        hour: _settings.workoutReminderHour,
        minute: _settings.workoutReminderMinute,
      );

  /// Resolve language: use device language if supported, otherwise fallback to English
  String _getResolvedLanguage() {
    if (_settings.language != null) {
      return _settings.language!;
    }
    // Get device language
    final deviceLocale = ui.PlatformDispatcher.instance.locale;
    final deviceLang = deviceLocale.languageCode;

    // If device language is supported, use it; otherwise fallback to English
    if (_supportedLanguages.contains(deviceLang)) {
      return deviceLang;
    }
    return 'en'; // Fallback to English
  }

  /// Get current locale
  Locale get locale {
    return Locale(_getResolvedLanguage());
  }

  AppSettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();
    _settings = await _store.loadSettings();
    // Sync sound service with loaded settings
    SoundService().setEnabled(_settings.soundEffectsEnabled);
    await _syncWorkoutReminder();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateLanguage(String language) async {
    _settings = _settings.copyWith(language: language);
    await _store.saveSettings(_settings);
    await _syncWorkoutReminder();
    notifyListeners();
  }

  Future<void> resetLanguageToSystem() async {
    _settings = AppSettings(
      language: null,
      measurement: _settings.measurement,
      weightUnit: _settings.weightUnit,
      isPremium: _settings.isPremium,
      voiceGuideEnabled: _settings.voiceGuideEnabled,
      backgroundIntervalNotificationsEnabled:
          _settings.backgroundIntervalNotificationsEnabled,
      themeMode: _settings.themeMode,
      themeModeUserSet: _settings.themeModeUserSet,
      soundEffectsEnabled: _settings.soundEffectsEnabled,
      workoutReminderEnabled: _settings.workoutReminderEnabled,
      workoutReminderWeekdays:
          List<int>.from(_settings.workoutReminderWeekdays),
      workoutReminderHour: _settings.workoutReminderHour,
      workoutReminderMinute: _settings.workoutReminderMinute,
      workoutReminderMessage: _settings.workoutReminderMessage,
    );
    await _store.saveSettings(_settings);
    await _syncWorkoutReminder();
    notifyListeners();
  }

  Future<void> updateMeasurement(String measurement) async {
    _settings = _settings.copyWith(measurement: measurement);
    await _store.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateWeightUnit(String weightUnit) async {
    _settings = _settings.copyWith(weightUnit: weightUnit);
    await _store.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updatePremium(bool isPremium) async {
    _settings = _settings.copyWith(
      isPremium: isPremium,
      voiceGuideEnabled: isPremium ? _settings.voiceGuideEnabled : false,
    );
    await _store.saveSettings(_settings);
    if (!isPremium) {
      await WorkoutReminderService.instance
          .cancelWorkoutIntervalNotifications();
    }
    notifyListeners();
  }

  Future<void> updateVoiceGuide(bool enabled) async {
    if (!_settings.isPremium && enabled) {
      return; // Cannot enable voice guide without premium
    }
    _settings = _settings.copyWith(voiceGuideEnabled: enabled);
    await _store.saveSettings(_settings);
    notifyListeners();
  }

  Future<bool> updateBackgroundIntervalNotifications(bool enabled) async {
    if (!_settings.isPremium && enabled) return false;

    if (enabled) {
      final granted =
          await WorkoutReminderService.instance.requestPermissions();
      if (!granted) return false;
    } else {
      await WorkoutReminderService.instance
          .cancelWorkoutIntervalNotifications();
    }

    _settings = _settings.copyWith(
      backgroundIntervalNotificationsEnabled: enabled,
    );
    await _store.saveSettings(_settings);
    notifyListeners();
    return true;
  }

  Future<void> updateThemeMode(String themeMode) async {
    _settings = _settings.copyWith(themeMode: themeMode);
    await _store.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateSoundEffects(bool enabled) async {
    _settings = _settings.copyWith(soundEffectsEnabled: enabled);
    await _store.saveSettings(_settings);
    // Sync sound service with updated setting
    SoundService().setEnabled(enabled);
    notifyListeners();
  }

  Future<bool> updateWorkoutReminderEnabled(bool enabled) async {
    if (enabled) {
      final granted =
          await WorkoutReminderService.instance.requestPermissions();
      if (!granted) {
        return false;
      }
    }

    _settings = _settings.copyWith(workoutReminderEnabled: enabled);
    await _store.saveSettings(_settings);
    await _syncWorkoutReminder();
    notifyListeners();
    return true;
  }

  Future<void> updateWorkoutReminderWeekdays(List<int> weekdays) async {
    final normalized = weekdays
        .where((day) => day >= DateTime.monday && day <= DateTime.sunday)
        .toSet()
        .toList()
      ..sort();
    if (normalized.isEmpty) return;

    _settings = _settings.copyWith(workoutReminderWeekdays: normalized);
    await _store.saveSettings(_settings);
    await _syncWorkoutReminder();
    notifyListeners();
  }

  Future<void> updateWorkoutReminderTime(TimeOfDay time) async {
    _settings = _settings.copyWith(
      workoutReminderHour: time.hour,
      workoutReminderMinute: time.minute,
    );
    await _store.saveSettings(_settings);
    await _syncWorkoutReminder();
    notifyListeners();
  }

  /// Get ThemeMode enum from stored string value
  /// Only supports 'light' and 'dark' (system option removed)
  ThemeMode get themeModeEnum {
    switch (_settings.themeMode) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  /// Format speed for DISPLAY ONLY - NEVER save this formatted string back to storage
  /// Storage always uses speedX10 (int) in base units (km/h)
  /// This method converts km/h to mph for display if needed, but does NOT mutate stored values
  String formatSpeed(double speedKmh) {
    if (_settings.measurement == 'mph') {
      // Convert to mph for display ONLY - storage remains in km/h (speedX10)
      final mph = speedKmh * 0.621371;
      return '${mph.toStringAsFixed(1)} mph';
    }
    return '${speedKmh.toStringAsFixed(1)} km/h';
  }

  Future<void> _syncWorkoutReminder() async {
    await WorkoutReminderService.instance.syncSchedule(
      enabled: _settings.workoutReminderEnabled,
      weekdays: _settings.workoutReminderWeekdays,
      hour: _settings.workoutReminderHour,
      minute: _settings.workoutReminderMinute,
      languageCode: _getResolvedLanguage(),
    );
  }
}
