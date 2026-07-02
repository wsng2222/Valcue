import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class WorkoutReminderService {
  WorkoutReminderService._();

  static final WorkoutReminderService instance = WorkoutReminderService._();

  static const int _notificationIdBase = 7100;
  static const String _channelId = 'interval_cardio_workout_reminder';
  static const String _channelName = 'Workout reminders';
  static const String _channelDescription =
      'Scheduled workout reminder notifications';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  Timer? _foregroundTicker;
  Set<int> _foregroundWeekdays = <int>{};
  int _foregroundHour = 0;
  int _foregroundMinute = 0;
  String _foregroundLanguageCode = 'en';
  String? _lastForegroundTriggerKey;

  static const Map<String, ({String title, String body})> _defaultMessages = {
    'ko': (
      title: '운동 일정 알림',
      body: '설정된 운동 시간입니다. 오늘 계획한 루틴을 편한 속도로 시작해 보세요.',
    ),
    'en': (
      title: 'Workout Schedule Reminder',
      body:
          'It is your scheduled workout time. You can begin today\'s planned routine at a comfortable pace.',
    ),
    'ja': (
      title: 'ワークアウト予定のお知らせ',
      body: '設定した運動時間です。今日は計画したルーティンを無理のないペースで進めてみましょう。',
    ),
    'zh': (
      title: '训练日程提醒',
      body: '现在是你设定的训练时间。可以按舒适的节奏开始今天计划的训练。',
    ),
    'es': (
      title: 'Recordatorio de horario de entrenamiento',
      body:
          'Es la hora de entrenamiento programada. Puede iniciar la rutina de hoy a un ritmo cómodo.',
    ),
    'fr': (
      title: 'Rappel de planning d’entraînement',
      body:
          'C’est l’heure prévue pour l’entraînement. Vous pouvez commencer la routine du jour à votre rythme.',
    ),
    'de': (
      title: 'Trainingsplan-Erinnerung',
      body:
          'Es ist Ihre geplante Trainingszeit. Sie können die heutige Routine in einem angenehmen Tempo beginnen.',
    ),
    'it': (
      title: 'Promemoria programma di allenamento',
      body:
          'È l’orario di allenamento previsto. Puoi iniziare la routine di oggi con un ritmo confortevole.',
    ),
    'pt': (
      title: 'Lembrete de agenda de treino',
      body:
          'Este é o horário de treino programado. Você pode iniciar a rotina de hoje em um ritmo confortável.',
    ),
    'ru': (
      title: 'Напоминание о расписании тренировки',
      body:
          'Сейчас запланированное время тренировки. Можно начать сегодняшнюю программу в комфортном темпе.',
    ),
    'ar': (
      title: 'تذكير بجدول التمرين',
      body: 'هذا هو وقت التمرين المحدد. يمكنك بدء روتين اليوم بوتيرة مريحة.',
    ),
    'vi': (
      title: 'Nhắc lịch tập luyện',
      body:
          'Đã đến giờ tập theo lịch. Bạn có thể bắt đầu bài tập hôm nay với nhịp độ thoải mái.',
    ),
    'th': (
      title: 'แจ้งเตือนตารางการออกกำลังกาย',
      body:
          'ถึงเวลาออกกำลังกายตามที่ตั้งไว้ คุณสามารถเริ่มตามแผนวันนี้ด้วยจังหวะที่สบาย',
    ),
    'nl': (
      title: 'Herinnering trainingsschema',
      body:
          'Dit is je geplande trainingstijd. Je kunt de routine van vandaag in een comfortabel tempo starten.',
    ),
    'nb': (
      title: 'Påminnelse om treningsplan',
      body:
          'Det er tiden du har satt av til trening. Du kan starte dagens økt i et behagelig tempo.',
    ),
    'da': (
      title: 'Påmindelse om træningsplan',
      body:
          'Det er din planlagte træningstid. Du kan starte dagens træning i et behageligt tempo.',
    ),
  };

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[WorkoutReminderService] Failed to set timezone: $e. Falling back to UTC.');
      }
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {
        // Fail-safe: if UTC is somehow missing, it will default to UTC in timezone package or throw
      }
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    await init();

    var granted = true;

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final androidPermission =
        await androidPlugin?.requestNotificationsPermission();
    if (androidPermission == false) {
      granted = false;
    }
    // Android 14+ exact alarm permission. If denied, we still fallback to
    // inexact scheduling in _scheduleWeeklyReminder.
    await androidPlugin?.requestExactAlarmsPermission();

    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosPermission = await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    if (iosPermission == false) {
      granted = false;
    }

    final macPlugin = _plugin.resolvePlatformSpecificImplementation<
        MacOSFlutterLocalNotificationsPlugin>();
    final macPermission = await macPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    if (macPermission == false) {
      granted = false;
    }

    return granted;
  }

  Future<void> syncSchedule({
    required bool enabled,
    required List<int> weekdays,
    required int hour,
    required int minute,
    required String languageCode,
  }) async {
    await init();
    await _cancelAllReminderNotifications();

    if (!enabled) {
      _stopForegroundTicker();
      return;
    }
    if (weekdays.isEmpty) {
      _stopForegroundTicker();
      return;
    }

    final normalizedWeekdays = weekdays
        .where((day) => day >= DateTime.monday && day <= DateTime.sunday)
        .toSet()
        .toList()
      ..sort();

    if (normalizedWeekdays.isEmpty) {
      _stopForegroundTicker();
      return;
    }

    final copy = _copyForLanguage(languageCode);

    for (final weekday in normalizedWeekdays) {
      final scheduledDate = _nextInstanceOfWeekdayAtTime(
        weekday,
        hour,
        minute,
      );
      await _scheduleWeeklyReminder(
        id: _notificationIdBase + weekday,
        title: copy.title,
        body: copy.body,
        scheduledDate: scheduledDate,
      );
    }

    _startForegroundTicker(
      weekdays: normalizedWeekdays.toSet(),
      hour: hour,
      minute: minute,
      languageCode: languageCode,
    );
  }

  String defaultBodyForLanguage(String languageCode) {
    return _copyForLanguage(languageCode).body;
  }

  ({String title, String body}) _copyForLanguage(String languageCode) {
    final lang = languageCode.toLowerCase();
    if (_defaultMessages.containsKey(lang)) {
      return _defaultMessages[lang]!;
    }

    final base = lang.split('-').first;
    return _defaultMessages[base] ?? _defaultMessages['en']!;
  }

  Future<void> _cancelAllReminderNotifications() async {
    for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++) {
      await _plugin.cancel(_notificationIdBase + weekday);
    }
  }

  NotificationDetails get _defaultNotificationDetails =>
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      );

  void _startForegroundTicker({
    required Set<int> weekdays,
    required int hour,
    required int minute,
    required String languageCode,
  }) {
    _foregroundWeekdays = weekdays;
    _foregroundHour = hour;
    _foregroundMinute = minute;
    _foregroundLanguageCode = languageCode;

    _foregroundTicker ??= Timer.periodic(
      const Duration(seconds: 15),
      (_) => _checkAndFireForegroundReminder(),
    );
  }

  void _stopForegroundTicker() {
    _foregroundTicker?.cancel();
    _foregroundTicker = null;
    _foregroundWeekdays = <int>{};
    _lastForegroundTriggerKey = null;
  }

  Future<void> _checkAndFireForegroundReminder() async {
    if (_foregroundWeekdays.isEmpty) return;
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (lifecycle != null && lifecycle != AppLifecycleState.resumed) return;

    final now = DateTime.now();
    if (!_foregroundWeekdays.contains(now.weekday)) return;
    if (now.hour != _foregroundHour || now.minute != _foregroundMinute) return;

    final triggerKey =
        '${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}';
    if (_lastForegroundTriggerKey == triggerKey) return;
    _lastForegroundTriggerKey = triggerKey;

    final copy = _copyForLanguage(_foregroundLanguageCode);
    await _plugin.show(
      _notificationIdBase + now.weekday,
      copy.title,
      copy.body,
      _defaultNotificationDetails,
    );
  }

  Future<void> _scheduleWeeklyReminder({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        _defaultNotificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (_) {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        _defaultNotificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  tz.TZDateTime _nextInstanceOfWeekdayAtTime(
    int weekday,
    int hour,
    int minute,
  ) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    while (scheduledDate.weekday != weekday || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
