class AppSettings {
  final String? language; // null means System
  final String measurement;
  final String weightUnit; // 'kg' or 'lbs'
  final bool isPremium;
  final bool voiceGuideEnabled;
  final String themeMode;
  final bool themeModeUserSet;
  final bool soundEffectsEnabled;

  AppSettings({
    this.language,
    required this.measurement,
    this.weightUnit = 'kg',
    required this.isPremium,
    required this.voiceGuideEnabled,
    required this.themeMode,
    required this.themeModeUserSet,
    required this.soundEffectsEnabled,
  });

  AppSettings copyWith({
    String? language,
    String? measurement,
    String? weightUnit,
    bool? isPremium,
    bool? voiceGuideEnabled,
    String? themeMode,
    bool? themeModeUserSet,
    bool? soundEffectsEnabled,
  }) {
    return AppSettings(
      language: language ?? this.language,
      measurement: measurement ?? this.measurement,
      weightUnit: weightUnit ?? this.weightUnit,
      isPremium: isPremium ?? this.isPremium,
      voiceGuideEnabled: voiceGuideEnabled ?? this.voiceGuideEnabled,
      themeMode: themeMode ?? this.themeMode,
      themeModeUserSet: themeModeUserSet ?? this.themeModeUserSet,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'measurement': measurement,
      'weightUnit': weightUnit,
      'isPremium': isPremium,
      'voiceGuideEnabled': voiceGuideEnabled,
      'themeMode': themeMode,
      'themeModeUserSet': themeModeUserSet,
      'soundEffectsEnabled': soundEffectsEnabled,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    String themeMode = json['themeMode'] as String? ?? 'system';
    final bool themeModeUserSet = json['themeModeUserSet'] as bool? ?? false;
    if (themeMode == 'device') {
      themeMode = 'system';
    }
    // Migration: legacy default stored as 'light' without user intent -> follow system
    if (!themeModeUserSet && themeMode == 'light') {
      themeMode = 'system';
    }
    return AppSettings(
      language: json['language'] as String?,
      measurement: json['measurement'] as String? ?? 'kmh',
      weightUnit: json['weightUnit'] as String? ?? 'kg',
      isPremium: json['isPremium'] as bool? ?? false,
      voiceGuideEnabled: json['voiceGuideEnabled'] as bool? ?? false,
      themeMode: themeMode,
      themeModeUserSet: themeModeUserSet,
      soundEffectsEnabled: json['soundEffectsEnabled'] as bool? ?? true,
    );
  }

  static AppSettings get defaultSettings => AppSettings(
        language: null, // System default
        measurement: 'kmh',
        weightUnit: 'kg',
        isPremium: false,
        voiceGuideEnabled: false,
      themeMode: 'system', // Follow device by default
        themeModeUserSet: false,
        soundEffectsEnabled: true,
      );
}

