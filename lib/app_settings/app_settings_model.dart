enum WorkoutDisplaySize {
  standard(1.0),
  large(1.15),
  extraLarge(1.30);

  const WorkoutDisplaySize(this.scale);

  final double scale;

  static WorkoutDisplaySize fromStorage(Object? value) {
    return WorkoutDisplaySize.values.firstWhere(
      (size) => size.name == value,
      orElse: () => WorkoutDisplaySize.standard,
    );
  }
}

class AppSettings {
  final String? language; // null means System
  final String measurement;
  final String weightUnit; // 'kg' or 'lbs'
  final bool isPremium;
  final bool voiceGuideEnabled;
  final bool backgroundIntervalNotificationsEnabled;
  final String themeMode;
  final bool themeModeUserSet;
  final bool soundEffectsEnabled;
  final bool workoutReminderEnabled;
  final List<int> workoutReminderWeekdays; // DateTime weekday: 1(Mon)-7(Sun)
  final int workoutReminderHour;
  final int workoutReminderMinute;
  final String workoutReminderMessage;
  final WorkoutDisplaySize workoutDisplaySize;

  // Countdown timing setting
  final List<int> voiceGuideCountdownTriggers; // e.g. [10, 20, 30]

  AppSettings({
    this.language,
    required this.measurement,
    this.weightUnit = 'kg',
    required this.isPremium,
    required this.voiceGuideEnabled,
    required this.backgroundIntervalNotificationsEnabled,
    required this.themeMode,
    required this.themeModeUserSet,
    required this.soundEffectsEnabled,
    required this.workoutReminderEnabled,
    required this.workoutReminderWeekdays,
    required this.workoutReminderHour,
    required this.workoutReminderMinute,
    required this.workoutReminderMessage,
    this.workoutDisplaySize = WorkoutDisplaySize.standard,
    this.voiceGuideCountdownTriggers = const [10, 20, 30],
  });

  AppSettings copyWith({
    String? language,
    String? measurement,
    String? weightUnit,
    bool? isPremium,
    bool? voiceGuideEnabled,
    bool? backgroundIntervalNotificationsEnabled,
    String? themeMode,
    bool? themeModeUserSet,
    bool? soundEffectsEnabled,
    bool? workoutReminderEnabled,
    List<int>? workoutReminderWeekdays,
    int? workoutReminderHour,
    int? workoutReminderMinute,
    String? workoutReminderMessage,
    WorkoutDisplaySize? workoutDisplaySize,
    List<int>? voiceGuideCountdownTriggers,
  }) {
    return AppSettings(
      language: language ?? this.language,
      measurement: measurement ?? this.measurement,
      weightUnit: weightUnit ?? this.weightUnit,
      isPremium: isPremium ?? this.isPremium,
      voiceGuideEnabled: voiceGuideEnabled ?? this.voiceGuideEnabled,
      backgroundIntervalNotificationsEnabled:
          backgroundIntervalNotificationsEnabled ??
              this.backgroundIntervalNotificationsEnabled,
      themeMode: themeMode ?? this.themeMode,
      themeModeUserSet: themeModeUserSet ?? this.themeModeUserSet,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      workoutReminderEnabled:
          workoutReminderEnabled ?? this.workoutReminderEnabled,
      workoutReminderWeekdays:
          workoutReminderWeekdays ?? this.workoutReminderWeekdays,
      workoutReminderHour: workoutReminderHour ?? this.workoutReminderHour,
      workoutReminderMinute:
          workoutReminderMinute ?? this.workoutReminderMinute,
      workoutReminderMessage:
          workoutReminderMessage ?? this.workoutReminderMessage,
      workoutDisplaySize: workoutDisplaySize ?? this.workoutDisplaySize,
      voiceGuideCountdownTriggers:
          voiceGuideCountdownTriggers ?? this.voiceGuideCountdownTriggers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'measurement': measurement,
      'weightUnit': weightUnit,
      'isPremium': isPremium,
      'voiceGuideEnabled': voiceGuideEnabled,
      'backgroundIntervalNotificationsEnabled':
          backgroundIntervalNotificationsEnabled,
      'themeMode': themeMode,
      'themeModeUserSet': themeModeUserSet,
      'soundEffectsEnabled': soundEffectsEnabled,
      'workoutReminderEnabled': workoutReminderEnabled,
      'workoutReminderWeekdays': workoutReminderWeekdays,
      'workoutReminderHour': workoutReminderHour,
      'workoutReminderMinute': workoutReminderMinute,
      'workoutReminderMessage': workoutReminderMessage,
      'workoutDisplaySize': workoutDisplaySize.name,
      'voiceGuideCountdownTriggers': voiceGuideCountdownTriggers,
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
    final parsedWeekdays = List<int>.of(
      (json['workoutReminderWeekdays'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .where((day) => day >= 1 && day <= 7)
              .toSet()
              .toList() ??
          const <int>[1, 2, 3, 4, 5],
    );
    parsedWeekdays.sort();

    final parsedCountdownTriggers = List<int>.of(
      (json['voiceGuideCountdownTriggers'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toSet()
              .toList() ??
          const <int>[10, 20, 30],
    );
    parsedCountdownTriggers.sort();

    return AppSettings(
      language: json['language'] as String?,
      measurement: json['measurement'] as String? ?? 'kmh',
      weightUnit: json['weightUnit'] as String? ?? 'kg',
      isPremium: json['isPremium'] as bool? ?? false,
      voiceGuideEnabled: json['voiceGuideEnabled'] as bool? ?? false,
      backgroundIntervalNotificationsEnabled:
          json['backgroundIntervalNotificationsEnabled'] as bool? ?? true,
      themeMode: themeMode,
      themeModeUserSet: themeModeUserSet,
      soundEffectsEnabled: json['soundEffectsEnabled'] as bool? ?? true,
      workoutReminderEnabled: json['workoutReminderEnabled'] as bool? ?? false,
      workoutReminderWeekdays: parsedWeekdays,
      workoutReminderHour: json['workoutReminderHour'] as int? ?? 9,
      workoutReminderMinute: json['workoutReminderMinute'] as int? ?? 0,
      workoutReminderMessage: json['workoutReminderMessage'] as String? ?? '',
      workoutDisplaySize:
          WorkoutDisplaySize.fromStorage(json['workoutDisplaySize']),
      voiceGuideCountdownTriggers: parsedCountdownTriggers,
    );
  }

  static AppSettings get defaultSettings => AppSettings(
        language: null, // System default
        measurement: 'kmh',
        weightUnit: 'kg',
        isPremium: false,
        voiceGuideEnabled: false,
        backgroundIntervalNotificationsEnabled: true,
        themeMode: 'system', // Follow device by default
        themeModeUserSet: false,
        soundEffectsEnabled: true,
        workoutReminderEnabled: false,
        workoutReminderWeekdays: const [1, 2, 3, 4, 5],
        workoutReminderHour: 9,
        workoutReminderMinute: 0,
        workoutReminderMessage: '',
        workoutDisplaySize: WorkoutDisplaySize.standard,
        voiceGuideCountdownTriggers: const [10, 20, 30],
      );
}
