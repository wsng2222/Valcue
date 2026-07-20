import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'workout_interval_notification_planner.dart';

class WorkoutReminderService {
  WorkoutReminderService._();

  static final WorkoutReminderService instance = WorkoutReminderService._();

  static const int _notificationIdBase = 7100;
  static const String _channelId = 'valcue_workout_reminder';
  static const int _workoutNotificationIdBase = 7200;

  // iOS keeps 64 pending local notifications for the entire app. Reserve the
  // seven weekly reminder slots plus one spare slot.
  static const int _maxWorkoutNotifications = 56;
  static const String _workoutChannelId = 'valcue_workout_intervals_v1';
  static const Map<
      String,
      ({
        String reminderName,
        String reminderDescription,
        String intervalName,
        String intervalDescription
      })> _channelCopy = {
    'en': (
      reminderName: 'Workout reminders',
      reminderDescription: 'Scheduled workout reminders',
      intervalName: 'Workout interval alerts',
      intervalDescription: 'Alerts when a new workout interval starts',
    ),
    'es': (
      reminderName: 'Recordatorios de entrenamiento',
      reminderDescription: 'Recordatorios de entrenamientos programados',
      intervalName: 'Avisos de intervalos',
      intervalDescription: 'Avisos al comenzar un nuevo intervalo',
    ),
    'fr': (
      reminderName: 'Rappels d’entraînement',
      reminderDescription: 'Rappels des entraînements programmés',
      intervalName: 'Alertes d’intervalle',
      intervalDescription: 'Alertes au début d’un nouvel intervalle',
    ),
    'de': (
      reminderName: 'Trainingserinnerungen',
      reminderDescription: 'Erinnerungen an geplante Trainings',
      intervalName: 'Intervallhinweise',
      intervalDescription: 'Hinweise beim Start eines neuen Intervalls',
    ),
    'it': (
      reminderName: 'Promemoria allenamento',
      reminderDescription: 'Promemoria per gli allenamenti programmati',
      intervalName: 'Avvisi intervallo',
      intervalDescription: 'Avvisi all’inizio di un nuovo intervallo',
    ),
    'nl': (
      reminderName: 'Trainingsherinneringen',
      reminderDescription: 'Herinneringen voor geplande trainingen',
      intervalName: 'Intervalmeldingen',
      intervalDescription: 'Meldingen wanneer een nieuw interval begint',
    ),
    'da': (
      reminderName: 'Træningspåmindelser',
      reminderDescription: 'Påmindelser om planlagte træninger',
      intervalName: 'Intervalbeskeder',
      intervalDescription: 'Beskeder når et nyt interval starter',
    ),
    'nb': (
      reminderName: 'Treningspåminnelser',
      reminderDescription: 'Påminnelser om planlagte treningsøkter',
      intervalName: 'Intervallvarsler',
      intervalDescription: 'Varsler når et nytt intervall starter',
    ),
    'ru': (
      reminderName: 'Напоминания о тренировках',
      reminderDescription: 'Напоминания о запланированных тренировках',
      intervalName: 'Оповещения об интервалах',
      intervalDescription: 'Оповещения о начале нового интервала',
    ),
    'pt': (
      reminderName: 'Lembretes de treino',
      reminderDescription: 'Lembretes de treinos programados',
      intervalName: 'Alertas de intervalo',
      intervalDescription: 'Alertas quando um novo intervalo começa',
    ),
    'ja': (
      reminderName: 'ワークアウトのリマインダー',
      reminderDescription: '設定したワークアウト予定のお知らせ',
      intervalName: 'インターバルのお知らせ',
      intervalDescription: '新しいインターバル開始時のお知らせ',
    ),
    'zh': (
      reminderName: '训练提醒',
      reminderDescription: '按计划提醒训练',
      intervalName: '间歇提醒',
      intervalDescription: '新间歇开始时提醒',
    ),
    'ko': (
      reminderName: '운동 알림',
      reminderDescription: '예정된 운동 시간 알림',
      intervalName: '운동 구간 알림',
      intervalDescription: '새 운동 구간이 시작될 때 알림',
    ),
    'vi': (
      reminderName: 'Nhắc lịch tập',
      reminderDescription: 'Nhắc các buổi tập đã lên lịch',
      intervalName: 'Thông báo quãng tập',
      intervalDescription: 'Thông báo khi bắt đầu quãng mới',
    ),
    'ar': (
      reminderName: 'تذكيرات التمرين',
      reminderDescription: 'تذكيرات بالتمارين المجدولة',
      intervalName: 'تنبيهات فترات التمرين',
      intervalDescription: 'تنبيه عند بدء فترة تمرين جديدة',
    ),
    'th': (
      reminderName: 'แจ้งเตือนออกกำลังกาย',
      reminderDescription: 'แจ้งเตือนการออกกำลังกายที่ตั้งเวลาไว้',
      intervalName: 'แจ้งเตือนช่วงฝึก',
      intervalDescription: 'แจ้งเตือนเมื่อเริ่มช่วงฝึกใหม่',
    ),
  };

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _exactAlarmPermissionRequestedThisSession = false;
  int _workoutScheduleGeneration = 0;
  final Set<int> _activeWorkoutNotificationIds = <int>{};
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
          'Es la hora de entrenamiento programada. Puedes empezar la rutina de hoy a un ritmo cómodo.',
    ),
    'fr': (
      title: 'Rappel de planning d’entraînement',
      body:
          'C’est l’heure prévue pour l’entraînement. Vous pouvez commencer la routine du jour à votre rythme.',
    ),
    'de': (
      title: 'Trainingsplan-Erinnerung',
      body:
          'Es ist Zeit für dein geplantes Training. Starte die heutige Routine in einem angenehmen Tempo.',
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
        debugPrint(
            '[WorkoutReminderService] Failed to set timezone: $e. Falling back to UTC.');
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

    // A cold launch has no restorable active workout yet. Remove only stale
    // workout alerts while preserving the independent weekly reminders.
    await _cancelWorkoutNotificationsForGeneration(
      ++_workoutScheduleGeneration,
    );
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
    // Android 14+ exact alarm access is needed for short workout intervals.
    // If denied, scheduling still falls back to inexact delivery.
    final canScheduleExactly =
        await androidPlugin?.canScheduleExactNotifications();
    if (canScheduleExactly == false &&
        !_exactAlarmPermissionRequestedThisSession) {
      _exactAlarmPermissionRequestedThisSession = true;
      await androidPlugin?.requestExactAlarmsPermission();
    }

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

  /// Replaces the current background-workout schedule without touching weekly
  /// workout reminders. A generation guard prevents a late async schedule from
  /// surviving a fast foreground resume/cancel.
  Future<void> scheduleWorkoutIntervalNotifications({
    required List<PlannedWorkoutNotification> notifications,
    required String routineId,
    required String languageCode,
  }) async {
    await init();
    final scheduleBase = tz.TZDateTime.now(tz.local);
    final generation = ++_workoutScheduleGeneration;
    await _cancelWorkoutNotificationsForGeneration(generation);
    if (generation != _workoutScheduleGeneration) return;

    final selected = notifications.take(_maxWorkoutNotifications).toList();

    // Schedule furthest first so the earliest, most useful alerts are the last
    // inserted if an OS applies its own pending-notification limit.
    for (var index = selected.length - 1; index >= 0; index--) {
      if (generation != _workoutScheduleGeneration) return;

      final notification = selected[index];
      final id = _workoutNotificationIdBase + index;
      final safeDelay = notification.delay < const Duration(milliseconds: 250)
          ? const Duration(milliseconds: 250)
          : notification.delay;
      final requestedDate = scheduleBase.add(safeDelay);
      final minimumDate =
          tz.TZDateTime.now(tz.local).add(const Duration(milliseconds: 250));
      final scheduledDate =
          requestedDate.isAfter(minimumDate) ? requestedDate : minimumDate;
      final payload = jsonEncode({
        'type': notification.intervalIndex == null
            ? 'workout_complete'
            : 'workout_interval',
        'routineId': routineId,
        if (notification.intervalIndex != null)
          'intervalIndex': notification.intervalIndex,
      });

      try {
        await _scheduleWorkoutNotification(
          id: id,
          title: notification.title,
          body: notification.body,
          scheduledDate: scheduledDate,
          payload: payload,
          languageCode: languageCode,
        );
      } catch (error) {
        if (kDebugMode) {
          debugPrint(
            '[WorkoutReminderService] Failed to schedule workout alert: $error',
          );
        }
        continue;
      }

      if (generation != _workoutScheduleGeneration) {
        await _plugin.cancel(id);
        return;
      }
      _activeWorkoutNotificationIds.add(id);
    }
  }

  Future<void> cancelWorkoutIntervalNotifications() async {
    await init();
    final generation = ++_workoutScheduleGeneration;
    await _cancelWorkoutNotificationsForGeneration(generation);
  }

  Future<void> _cancelWorkoutNotificationsForGeneration(
    int generation,
  ) async {
    final ids = <int>{..._activeWorkoutNotificationIds};
    try {
      final pending = await _plugin.pendingNotificationRequests();
      ids.addAll(
        pending.map((request) => request.id).where(_isWorkoutNotificationId),
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[WorkoutReminderService] Failed to inspect pending alerts: $error',
        );
      }
    }

    await Future.wait(
      ids.map((id) async {
        try {
          await _plugin.cancel(id);
        } catch (error) {
          if (kDebugMode) {
            debugPrint(
              '[WorkoutReminderService] Failed to cancel workout alert $id: $error',
            );
          }
        }
      }),
    );
    if (generation == _workoutScheduleGeneration) {
      _activeWorkoutNotificationIds.removeAll(ids);
    }
  }

  bool _isWorkoutNotificationId(int id) {
    return id >= _workoutNotificationIdBase &&
        id < _workoutNotificationIdBase + _maxWorkoutNotifications;
  }

  Future<void> _scheduleWorkoutNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required String payload,
    required String languageCode,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        _workoutNotificationDetails(languageCode),
        payload: payload,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        _workoutNotificationDetails(languageCode),
        payload: payload,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  NotificationDetails _workoutNotificationDetails(String languageCode) {
    final copy = _channelCopyFor(languageCode);
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _workoutChannelId,
        copy.intervalName,
        channelDescription: copy.intervalDescription,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        category: AndroidNotificationCategory.alarm,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
      ),
      macOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentSound: true,
      ),
    );
  }

  Future<void> syncSchedule({
    required bool enabled,
    required List<int> weekdays,
    required int hour,
    required int minute,
    required String languageCode,
  }) async {
    await init();
    _foregroundLanguageCode = languageCode;
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

  NotificationDetails get _defaultNotificationDetails {
    final copy = _channelCopyFor(_foregroundLanguageCode);
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        copy.reminderName,
        channelDescription: copy.reminderDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
    );
  }

  ({
    String reminderName,
    String reminderDescription,
    String intervalName,
    String intervalDescription
  }) _channelCopyFor(String languageCode) {
    final base = languageCode.toLowerCase().split(RegExp('[-_]')).first;
    return _channelCopy[base] ?? _channelCopy['en']!;
  }

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
