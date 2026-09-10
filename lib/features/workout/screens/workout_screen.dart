import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'package:valcue/l10n/localized_format.dart';
import '../../routines/models/routine.dart';
import '../../routines/models/machine_type.dart';
import '../../../app_settings/app_settings_provider.dart';
import '../state/workout_state.dart';
import 'workout_finished_screen.dart';
import '../../../services/voice_guide_service.dart';
import '../../../services/firebase_workout_live_activity_schedule_backend.dart';
import '../../../services/workout_interval_notification_planner.dart';
import '../../../services/workout_live_activity_payload_builder.dart';
import '../../../services/workout_live_activity_schedule_backend.dart';
import '../../../services/workout_live_activity_schedule_coordinator.dart';
import '../../../services/workout_live_activity_schedule_models.dart';
import '../../../services/workout_live_activity_schedule_planner.dart';
import '../../../services/workout_live_activity_service.dart';
import '../../../services/workout_reminder_service.dart';
import '../../../services/analytics_service.dart';
import '../widgets/bottom_control_bar.dart';
import '../widgets/circular_session_timer.dart';
import '../widgets/countdown_overlay.dart';
import '../widgets/current_value_section.dart';
import '../widgets/interval_pulse_overlay.dart';
import '../widgets/top_pill_progress_bar.dart';
import '../widgets/workout_action_buttons.dart';
import '../widgets/workout_control_sheets.dart';
import '../widgets/workout_hero_panel.dart';
import '../widgets/workout_progress_header.dart';

class WorkoutScreen extends StatefulWidget {
  final Routine routine;
  final bool backgroundNotificationsAuthorized;
  final WorkoutLiveActivityScheduleBackend? liveActivityScheduleBackend;
  final DateTime Function()? nowProvider;
  final Duration? previewElapsed;

  const WorkoutScreen({
    super.key,
    required this.routine,
    this.backgroundNotificationsAuthorized = false,
    this.liveActivityScheduleBackend,
    this.nowProvider,
    this.previewElapsed,
  });

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with WidgetsBindingObserver {
  static const int _maxLiveActivityStartRetries = 1;
  // Refresh token-rotation uploads from the current workout timeline instead
  // of keeping already elapsed boundaries for the full eight-hour window.
  static const Duration _remoteScheduleRefreshAge = Duration(minutes: 4);

  late WorkoutState _workoutState;
  late final DateTime Function() _now;
  bool _pauseSheetOpen = false;
  bool _endConfirmOpen = false;
  bool _hasNavigatedToFinished = false;
  bool _hasLoggedWorkoutCompletion = false;
  bool _hasLoggedWorkoutStop = false;
  bool _isCountdownActive = false;
  bool _isLandscapeMode = false;
  int _lastSpokenIntervalIndex = -1;
  int? _lastSpokenCountdownSecond;
  int _lastSpokenCountdownIntervalIndex = -1;
  bool _suppressIntervalGuidanceOnResume = false;
  bool _isSpeakingIntervalInfo =
      false; // Prevent countdown during interval speech
  late final bool _notificationsAuthorized;
  bool _backgroundLifecycleHandled = false;
  bool _liveActivityStarted = false;
  bool _liveActivityEnded = false;
  bool _liveActivityInitializing = false;
  bool _retryLiveActivityInitialization = false;
  bool _isReconcilingLiveActivityFromBackground = false;
  int _liveActivityStartRetryCount = 0;
  String? _lastLiveActivitySignature;
  String? _finishedLiveActivityStatusText;
  Map<String, dynamic>? _lastLiveActivityPayload;
  Future<void> _liveActivityCommandQueue = Future<void>.value();
  late final String _workoutSessionId;
  late final WorkoutLiveActivityScheduleCoordinator
      _liveActivityScheduleCoordinator;
  StreamSubscription<WorkoutLiveActivityNativeEvent>?
      _liveActivityNativeEventsSubscription;
  AppSettingsProvider? _observedSettingsProvider;
  bool? _lastRemoteScheduleFeatureEnabled;
  String? _lastRemoteScheduleTransition;

  @override
  void initState() {
    super.initState();
    if (widget.previewElapsed == null) {
      WidgetsBinding.instance.addObserver(this);
    }
    _notificationsAuthorized = widget.backgroundNotificationsAuthorized;
    _now = widget.nowProvider ?? DateTime.now;
    _workoutState = WorkoutState(
      routine: widget.routine,
      startTime: _now(),
      nowProvider: _now,
      isPreview: widget.previewElapsed != null,
    );
    if (widget.previewElapsed != null) {
      _workoutState.setPreviewElapsed(widget.previewElapsed!);
    }
    _workoutState.addListener(_onWorkoutStateChanged);
    if (widget.previewElapsed == null) {
      AnalyticsService.instance.logEvent(
        'workout_started',
        {
          'machine_type': widget.routine.machineType.name,
          'duration_seconds': widget.routine.totalDurationSeconds,
          'interval_count': widget.routine.intervals.length,
        },
      );
    }
    _workoutSessionId = generateWorkoutLiveActivitySessionId();
    _liveActivityScheduleCoordinator = WorkoutLiveActivityScheduleCoordinator(
      sessionId: _workoutSessionId,
      backend: widget.liveActivityScheduleBackend ??
          FirebaseWorkoutLiveActivityScheduleBackend(),
      nowProvider: _now,
    );
    if (widget.previewElapsed == null) {
      _liveActivityNativeEventsSubscription =
          WorkoutLiveActivityService.instance.events.listen(
        _handleLiveActivityNativeEvent,
        onError: (Object _, StackTrace __) {},
      );
    }

    // Keep screen awake
    if (widget.previewElapsed == null) {
      WakelockPlus.enable();
    }

    // Lock orientation initially
    if (widget.previewElapsed == null) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }

    if (widget.previewElapsed == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyRemoteScheduleForCurrentState(force: true);
        unawaited(_refreshNativePushRegistrations());
        _requestLiveActivityInitialization();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.previewElapsed != null) return;
    final provider = Provider.of<AppSettingsProvider>(context, listen: false);
    if (identical(provider, _observedSettingsProvider)) return;

    _observedSettingsProvider?.removeListener(_onAppSettingsChanged);
    _observedSettingsProvider = provider;
    _lastRemoteScheduleFeatureEnabled =
        _isRemoteScheduleFeatureEnabled(provider);
    provider.addListener(_onAppSettingsChanged);
  }

  @override
  void dispose() {
    if (widget.previewElapsed == null) {
      WidgetsBinding.instance.removeObserver(this);
    }
    _observedSettingsProvider?.removeListener(_onAppSettingsChanged);
    unawaited(_liveActivityNativeEventsSubscription?.cancel());
    if (widget.previewElapsed == null &&
        !_liveActivityScheduleCoordinator.isTerminal) {
      unawaited(
        _liveActivityScheduleCoordinator.cancel(
          WorkoutLiveActivityScheduleCancelReason.disposed,
          terminal: true,
        ),
      );
    }
    _liveActivityScheduleCoordinator.dispose();
    if (widget.previewElapsed == null) {
      unawaited(
        WorkoutReminderService.instance.cancelWorkoutIntervalNotifications(),
      );
      _endLiveActivityFromDispose();
    }
    _workoutState.removeListener(_onWorkoutStateChanged);
    _workoutState.dispose();

    // Release wakelock
    if (widget.previewElapsed == null) {
      WakelockPlus.disable();
    }

    // Reset orientation back to the app-wide portrait-only default
    if (widget.previewElapsed == null) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.previewElapsed != null) return;
    switch (state) {
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        if (_backgroundLifecycleHandled) return;
        _backgroundLifecycleHandled = true;
        VoiceGuideService.instance.stop();
        _workoutState.suspendForBackground();
        unawaited(_liveActivityScheduleCoordinator.reconcile());
        unawaited(_scheduleBackgroundWorkoutNotifications());
        break;
      case AppLifecycleState.resumed:
        _liveActivityStartRetryCount = 0;
        unawaited(
          WorkoutReminderService.instance.cancelWorkoutIntervalNotifications(),
        );
        if (!_backgroundLifecycleHandled) {
          _requestLiveActivityInitialization();
          return;
        }
        _backgroundLifecycleHandled = false;
        // Do not replay a voice cue that the background notification already
        // delivered while reconciling possibly several elapsed intervals.
        _suppressIntervalGuidanceOnResume = true;
        _isReconcilingLiveActivityFromBackground = true;
        try {
          _workoutState.resumeFromBackground();
        } finally {
          _isReconcilingLiveActivityFromBackground = false;
          _suppressIntervalGuidanceOnResume = false;
        }
        _lastSpokenIntervalIndex = _workoutState.currentIntervalIndex;
        if (_liveActivityScheduleCoordinator.desiredPlan?.isActive == true &&
            !_liveActivityScheduleCoordinator.isDesiredStateAcknowledged) {
          // An upload may have been waiting for a token/network while interval
          // boundaries elapsed. Rebuild from the reconciled current timeline.
          _applyRemoteScheduleForCurrentState(force: true);
        } else {
          unawaited(_liveActivityScheduleCoordinator.reconcile());
        }
        unawaited(_refreshNativePushRegistrations());
        if (_liveActivityStarted) {
          // State reconciliation callbacks are suppressed above, so this is
          // the single ActivityKit update for the foreground resume.
          _syncLiveActivity(force: true);
        } else {
          // Native start is allowed only while UIApplication is active. Retry
          // if the user left while the initial capability checks were pending.
          _requestLiveActivityInitialization();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _scheduleBackgroundWorkoutNotifications() async {
    if (!mounted) return;

    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);
    final service = WorkoutReminderService.instance;
    if (!settingsProvider.isPremium ||
        !settingsProvider.backgroundIntervalNotificationsEnabled ||
        !_notificationsAuthorized) {
      await service.cancelWorkoutIntervalNotifications();
      return;
    }

    final state = _workoutState;
    late final int firstIntervalIndex;
    late final Duration delayUntilFirstInterval;
    switch (state.status) {
      case WorkoutStatus.running:
        firstIntervalIndex = state.currentIntervalIndex + 1;
        delayUntilFirstInterval = state.currentIntervalRemainingDuration;
        break;
      case WorkoutStatus.resumingCountdown:
        if (state.isInitialCountdown) {
          firstIntervalIndex = state.currentIntervalIndex;
          delayUntilFirstInterval = state.countdownRemainingDuration;
        } else {
          // Resuming the same section is not a new interval, so the first alert
          // remains the next actual boundary after countdown + remaining time.
          firstIntervalIndex = state.currentIntervalIndex + 1;
          delayUntilFirstInterval = state.countdownRemainingDuration +
              state.currentIntervalRemainingDuration;
        }
        break;
      case WorkoutStatus.paused:
      case WorkoutStatus.finished:
      case WorkoutStatus.stopped:
        await service.cancelWorkoutIntervalNotifications();
        return;
    }

    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final notifications = WorkoutIntervalNotificationPlanner.build(
      routine: widget.routine,
      firstIntervalIndex: firstIntervalIndex,
      delayUntilFirstInterval: delayUntilFirstInterval,
      measurement: settingsProvider.measurement,
      languageCode: settingsProvider.language,
      labels: WorkoutNotificationLabels(
        newInterval: l10n.backgroundIntervalNotificationTitle,
        workoutComplete: l10n.workoutComplete,
        speed: l10n.speed,
        incline: l10n.incline,
        resistance: l10n.resistance,
        level: l10n.level,
        duration: l10n.duration,
        inclineValueTemplate: l10n.inclineValue('{value}'),
        rpmValueTemplate: l10n.rpmValue('{value}'),
        resistanceValueTemplate: l10n.resistanceColon('{value}'),
        levelValueTemplate: l10n.levelColon('{value}'),
      ),
    );
    await service.scheduleWorkoutIntervalNotifications(
      notifications: notifications,
      routineId: widget.routine.id,
      languageCode: settingsProvider.language,
    );
  }

  bool _isRemoteScheduleFeatureEnabled(AppSettingsProvider provider) {
    if (widget.routine.intervals.isEmpty ||
        _workoutState.status == WorkoutStatus.finished ||
        _workoutState.status == WorkoutStatus.stopped) {
      return false;
    }
    return provider.isPremium &&
        provider.backgroundIntervalNotificationsEnabled;
  }

  void _onAppSettingsChanged() {
    if (!mounted) return;
    final provider = _observedSettingsProvider;
    if (provider == null) return;

    final enabled = _isRemoteScheduleFeatureEnabled(provider);
    if (_lastRemoteScheduleFeatureEnabled == enabled) return;
    _lastRemoteScheduleFeatureEnabled = enabled;

    if (enabled) {
      _lastRemoteScheduleTransition = null;
      _applyRemoteScheduleForCurrentState(force: true);
      _requestLiveActivityInitialization();
      return;
    }

    final reason = provider.isPremium
        ? WorkoutLiveActivityScheduleCancelReason.featureDisabled
        : WorkoutLiveActivityScheduleCancelReason.premiumRevoked;
    unawaited(
      _liveActivityScheduleCoordinator.cancel(reason, terminal: true),
    );
    unawaited(
      WorkoutReminderService.instance.cancelWorkoutIntervalNotifications(),
    );
    _syncLiveActivity();
  }

  void _handleLiveActivityNativeEvent(
    WorkoutLiveActivityNativeEvent event,
  ) {
    unawaited(_processLiveActivityNativeEvent(event));
  }

  Future<void> _processLiveActivityNativeEvent(
    WorkoutLiveActivityNativeEvent event,
  ) async {
    if (event.workoutSessionId != _workoutSessionId ||
        event.activityId.isEmpty) {
      return;
    }

    switch (event.type) {
      case WorkoutLiveActivityNativeEventType.activityStarted:
        await _liveActivityScheduleCoordinator.attachActivity(
          sessionId: event.workoutSessionId,
          activityId: event.activityId,
        );
        break;
      case WorkoutLiveActivityNativeEventType.activitySnapshot:
        await _liveActivityScheduleCoordinator.attachActivity(
          sessionId: event.workoutSessionId,
          activityId: event.activityId,
        );
        await _applyPushTokenEvent(event);
        break;
      case WorkoutLiveActivityNativeEventType.pushToken:
        // A token can beat the start method result. The coordinator buffers it
        // by activity ID until attachActivity joins the other half.
        await _applyPushTokenEvent(event);
        break;
      case WorkoutLiveActivityNativeEventType.pushTokenInvalidated:
        final attachedActivityId = _liveActivityScheduleCoordinator.activityId;
        if (attachedActivityId == null ||
            attachedActivityId == event.activityId) {
          await _liveActivityScheduleCoordinator.cancel(
            WorkoutLiveActivityScheduleCancelReason.staleSession,
            terminal: true,
          );
        }
        break;
      case WorkoutLiveActivityNativeEventType.activityState:
        if (event.activityState == 'ended' ||
            event.activityState == 'dismissed') {
          final attachedActivityId =
              _liveActivityScheduleCoordinator.activityId;
          if (attachedActivityId != null &&
              attachedActivityId != event.activityId) {
            break;
          }
          await _liveActivityScheduleCoordinator.cancel(
            WorkoutLiveActivityScheduleCancelReason.staleSession,
            terminal: true,
          );
        }
        break;
      case WorkoutLiveActivityNativeEventType.unknown:
        break;
    }
  }

  Future<void> _applyPushTokenEvent(
    WorkoutLiveActivityNativeEvent event,
  ) async {
    final token = event.tokenHex;
    final environment = _remotePushEnvironment(event.environment);
    if (token == null || token.isEmpty || environment == null) return;

    final desiredPlan = _liveActivityScheduleCoordinator.desiredPlan;
    final isNewerToken =
        event.tokenVersion > _liveActivityScheduleCoordinator.tokenVersion;
    final shouldRefreshPlan = mounted &&
        !_liveActivityScheduleCoordinator.isTerminal &&
        isNewerToken &&
        desiredPlan != null &&
        desiredPlan.isActive &&
        _now().difference(desiredPlan.generatedAt) >=
            _remoteScheduleRefreshAge &&
        _isLiveActivityFeatureEnabled;

    // Store and upload the rotated token first. Any subsequent fresh-plan
    // registration then uses only the new bearer token, even if its first
    // network attempt fails or an interval boundary is due concurrently.
    await _liveActivityScheduleCoordinator.updatePushToken(
      sessionId: event.workoutSessionId,
      activityId: event.activityId,
      pushToken: token,
      tokenVersion: event.tokenVersion,
      environment: environment,
    );

    if (shouldRefreshPlan &&
        mounted &&
        !_liveActivityScheduleCoordinator.isTerminal &&
        _isLiveActivityFeatureEnabled) {
      await _liveActivityScheduleCoordinator.applyPlan(
        _buildRemoteSchedulePlan(),
      );
    }
  }

  WorkoutLiveActivityPushEnvironment? _remotePushEnvironment(String value) {
    return switch (value) {
      'sandbox' => WorkoutLiveActivityPushEnvironment.sandbox,
      'production' => WorkoutLiveActivityPushEnvironment.production,
      _ => null,
    };
  }

  Future<void> _refreshNativePushRegistrations() async {
    final registrations =
        await WorkoutLiveActivityService.instance.getPushRegistrations();
    for (final registration in registrations) {
      await _processLiveActivityNativeEvent(registration);
    }
  }

  void _applyRemoteScheduleForCurrentState({bool force = false}) {
    if (!mounted || widget.routine.intervals.isEmpty) return;

    final state = _workoutState;
    final isTerminal = state.status == WorkoutStatus.finished ||
        state.status == WorkoutStatus.stopped;
    if (!isTerminal && !_isLiveActivityFeatureEnabled) return;
    if (isTerminal && _liveActivityScheduleCoordinator.isTerminal) return;

    final transition = '${state.status.name}:${state.isInitialCountdown}';
    if (!force && transition == _lastRemoteScheduleTransition) return;
    _lastRemoteScheduleTransition = transition;

    // The initial/resume plans already contain all later interval boundaries.
    // Foreground ticks and running interval changes must not churn revisions.
    if (!force && state.status == WorkoutStatus.running) return;
    if (!force &&
        state.status == WorkoutStatus.resumingCountdown &&
        state.isInitialCountdown) {
      return;
    }

    unawaited(
      _liveActivityScheduleCoordinator.applyPlan(
        _buildRemoteSchedulePlan(),
      ),
    );
  }

  WorkoutLiveActivitySchedulePlan _buildRemoteSchedulePlan() {
    final state = _workoutState;
    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    final capturedAt = _now();
    final machineName = switch (widget.routine.machineType) {
      MachineType.treadmill => l10n.treadmill,
      MachineType.cycle => l10n.cycle,
      MachineType.stairmaster => l10n.stairmaster,
    };
    final phase = switch (state.status) {
      WorkoutStatus.resumingCountdown => state.isInitialCountdown
          ? WorkoutLiveActivitySchedulePhase.initialCountdown
          : WorkoutLiveActivitySchedulePhase.resumeCountdown,
      WorkoutStatus.running => WorkoutLiveActivitySchedulePhase.running,
      WorkoutStatus.paused => WorkoutLiveActivitySchedulePhase.paused,
      WorkoutStatus.finished => WorkoutLiveActivitySchedulePhase.finished,
      WorkoutStatus.stopped => WorkoutLiveActivitySchedulePhase.stopped,
    };

    return WorkoutLiveActivitySchedulePlanner.build(
      WorkoutLiveActivityScheduleSnapshot(
        routine: widget.routine,
        phase: phase,
        currentIntervalIndex: state.currentIntervalIndex,
        currentIntervalRemaining: state.currentIntervalRemainingDuration,
        totalRemaining: state.totalRemainingDuration,
        countdownRemaining: state.countdownRemainingDuration,
        progress: state.totalWorkoutProgress,
        measurement: settingsProvider.measurement,
        locale: settingsProvider.locale.toLanguageTag(),
        capturedAt: capturedAt,
        labels: WorkoutLiveActivityScheduleLabels(
          machineName: machineName,
          preparingStatusText: l10n.liveActivityPreparing,
          runningStatusText: l10n.liveActivityInProgress,
          finishedStatusText: l10n.workoutComplete,
          intervalText: (current, total) => l10n.liveActivityIntervalFormat(
            LocalizedFormat.decimal(context, current, decimalDigits: 0),
            LocalizedFormat.decimal(context, total, decimalDigits: 0),
          ),
          durationText: (durationSeconds) {
            final formatted = WorkoutIntervalNotificationPlanner.formatDuration(
              durationSeconds,
              settingsProvider.language,
            );
            return l10n.liveActivityDurationFormat(formatted);
          },
          speedLabel: l10n.speed,
          inclineLabel: l10n.incline,
          resistanceLabel: l10n.resistance,
          levelLabel: l10n.level,
          inclineValueTemplate: l10n.inclineValue('{value}'),
          rpmValueTemplate: l10n.rpmValue('{value}'),
          resistanceValueTemplate: l10n.resistanceColon('{value}'),
          levelValueTemplate: l10n.levelColon('{value}'),
        ),
      ),
    );
  }

  void _requestLiveActivityInitialization() {
    if (!mounted ||
        _liveActivityStarted ||
        _liveActivityEnded ||
        widget.routine.intervals.isEmpty) {
      return;
    }

    if (_liveActivityInitializing) {
      _retryLiveActivityInitialization = true;
      return;
    }

    unawaited(_initializeLiveActivity());
  }

  bool get _isApplicationResumed {
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    return lifecycle == null || lifecycle == AppLifecycleState.resumed;
  }

  bool get _isLiveActivityFeatureEnabled {
    if (!mounted || widget.routine.intervals.isEmpty) return false;
    if (_workoutState.status == WorkoutStatus.finished ||
        _workoutState.status == WorkoutStatus.stopped) {
      return false;
    }

    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);
    return settingsProvider.isPremium &&
        settingsProvider.backgroundIntervalNotificationsEnabled;
  }

  bool get _canInitializeLiveActivity =>
      !_liveActivityStarted &&
      !_liveActivityEnded &&
      _isApplicationResumed &&
      _isLiveActivityFeatureEnabled;

  Future<void> _initializeLiveActivity() async {
    if (_liveActivityInitializing) {
      _retryLiveActivityInitialization = true;
      return;
    }

    _liveActivityInitializing = true;
    try {
      if (!_canInitializeLiveActivity) return;

      final service = WorkoutLiveActivityService.instance;
      final supported = await service.isSupported();
      if (!supported || !_canInitializeLiveActivity) return;

      final enabled = await service.areActivitiesEnabled();
      if (!enabled || !_canInitializeLiveActivity) return;
      if (!mounted) return;

      // Capture both immediately before start. Absolute deadlines stay valid
      // if native startup takes a moment.
      final payload = _buildLiveActivityPayload();
      final signature = _liveActivitySignature;
      final finishedStatusText = AppLocalizations.of(context)!.workoutComplete;
      _finishedLiveActivityStatusText = finishedStatusText;

      // Premium or the feature may have changed while capability calls were in
      // flight. Recheck at the last possible point before creating the native
      // activity.
      if (!_canInitializeLiveActivity) return;
      final startResult = await service.startSession(payload);
      final started = startResult.started &&
          startResult.activityId.isNotEmpty &&
          startResult.workoutSessionId == _workoutSessionId;
      if (!started) {
        if (_isApplicationResumed &&
            _isLiveActivityFeatureEnabled &&
            _liveActivityStartRetryCount < _maxLiveActivityStartRetries) {
          _liveActivityStartRetryCount++;
          _retryLiveActivityInitialization = true;
        }
        return;
      }

      final finishedPayload = _finishedLiveActivityPayload(
        payload,
        statusText: finishedStatusText,
      );
      if (!mounted) {
        await service.end(<String, dynamic>{
          ...finishedPayload,
          'dismissImmediately': true,
        });
        return;
      }

      // cleanup() may have run while native start was pending. Never allow a
      // late result to recreate a disabled or non-premium activity.
      if (!_isLiveActivityFeatureEnabled) {
        await service.end(<String, dynamic>{
          ...finishedPayload,
          'dismissImmediately': true,
        });
        return;
      }

      _liveActivityStarted = true;
      _liveActivityStartRetryCount = 0;
      _lastLiveActivityPayload = payload;
      _lastLiveActivitySignature = signature;
      await _liveActivityScheduleCoordinator.attachActivity(
        sessionId: startResult.workoutSessionId,
        activityId: startResult.activityId,
      );
      unawaited(_refreshNativePushRegistrations());

      // Avoid an unconditional start+update pair. Only catch up if the status
      // or interval actually changed while awaiting ActivityKit.
      if (_liveActivitySignature != signature) {
        _syncLiveActivity();
      }
    } finally {
      _liveActivityInitializing = false;
      final shouldRetry = _retryLiveActivityInitialization;
      _retryLiveActivityInitialization = false;
      if (shouldRetry &&
          mounted &&
          !_liveActivityStarted &&
          !_liveActivityEnded &&
          _isApplicationResumed) {
        scheduleMicrotask(_requestLiveActivityInitialization);
      }
    }
  }

  void _syncLiveActivity({bool force = false}) {
    if (!_liveActivityStarted || _liveActivityEnded || !mounted) return;

    if (!_isLiveActivityFeatureEnabled) {
      _liveActivityStarted = false;
      _liveActivityEnded = true;
      _queueLiveActivityCommand(
        WorkoutLiveActivityService.instance.cleanup,
      );
      return;
    }

    final status = _workoutState.status;
    if (status == WorkoutStatus.finished || status == WorkoutStatus.stopped) {
      _endLiveActivity();
      return;
    }

    final signature = _liveActivitySignature;
    if (!force && signature == _lastLiveActivitySignature) return;

    final payload = _buildLiveActivityPayload();
    _lastLiveActivitySignature = signature;
    _lastLiveActivityPayload = payload;
    _queueLiveActivityCommand(
      () => WorkoutLiveActivityService.instance.update(payload),
    );
  }

  void _endLiveActivity() {
    if (!_liveActivityStarted || _liveActivityEnded) return;
    _liveActivityEnded = true;

    final payload = mounted
        ? _buildLiveActivityPayload(forceFinished: true)
        : _finishedLiveActivityPayload(_lastLiveActivityPayload);
    if (_workoutState.status == WorkoutStatus.stopped) {
      payload['dismissImmediately'] = true;
    } else {
      payload['dismissalDelaySeconds'] = 60;
    }
    _lastLiveActivityPayload = payload;
    _queueLiveActivityCommand(
      () => WorkoutLiveActivityService.instance.end(payload),
    );
  }

  void _endLiveActivityFromDispose() {
    if (!_liveActivityStarted || _liveActivityEnded) return;
    _liveActivityEnded = true;
    final payload = <String, dynamic>{
      ..._finishedLiveActivityPayload(_lastLiveActivityPayload),
      'dismissImmediately': true,
    };
    _lastLiveActivityPayload = payload;
    _queueLiveActivityCommand(
      () => WorkoutLiveActivityService.instance.end(payload),
    );
  }

  void _queueLiveActivityCommand(Future<void> Function() command) {
    _liveActivityCommandQueue = _liveActivityCommandQueue
        .catchError((Object _) {})
        .then((_) => command());
  }

  Map<String, dynamic> _buildLiveActivityPayload({
    bool forceFinished = false,
  }) {
    final state = _workoutState;
    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    final phase = forceFinished
        ? WorkoutLiveActivityPhase.finished
        : _liveActivityPhaseFor(state.status);
    final machineName = switch (widget.routine.machineType) {
      MachineType.treadmill => l10n.treadmill,
      MachineType.cycle => l10n.cycle,
      MachineType.stairmaster => l10n.stairmaster,
    };
    final statusText = switch (phase) {
      WorkoutLiveActivityPhase.preparing => l10n.liveActivityPreparing,
      WorkoutLiveActivityPhase.running => l10n.liveActivityInProgress,
      WorkoutLiveActivityPhase.paused => l10n.paused,
      WorkoutLiveActivityPhase.finished => state.status == WorkoutStatus.stopped
          ? l10n.endWorkout
          : l10n.workoutComplete,
    };
    final interval = state.currentInterval;
    final formattedDuration = WorkoutIntervalNotificationPlanner.formatDuration(
      interval.durationSeconds,
      settingsProvider.language,
    );

    return <String, dynamic>{
      ...WorkoutLiveActivityPayloadBuilder.build(
        routine: widget.routine,
        intervalIndex: state.currentIntervalIndex,
        phase: phase,
        intervalRemaining: state.currentIntervalRemainingDuration,
        totalRemaining: state.totalRemainingDuration,
        countdownRemaining: state.countdownRemainingDuration,
        progress: state.totalWorkoutProgress,
        measurement: settingsProvider.measurement,
        locale: settingsProvider.locale.toLanguageTag(),
        now: _now(),
        machineName: machineName,
        statusText: statusText,
        intervalText: l10n.liveActivityIntervalFormat(
          LocalizedFormat.decimal(
            context,
            state.currentIntervalIndex + 1,
            decimalDigits: 0,
          ),
          LocalizedFormat.decimal(
            context,
            state.totalIntervals,
            decimalDigits: 0,
          ),
        ),
        durationText: l10n.liveActivityDurationFormat(formattedDuration),
        speedLabel: l10n.speed,
        inclineLabel: l10n.incline,
        resistanceLabel: l10n.resistance,
        levelLabel: l10n.level,
        inclineValueTemplate: l10n.inclineValue('{value}'),
        rpmValueTemplate: l10n.rpmValue('{value}'),
        resistanceValueTemplate: l10n.resistanceColon('{value}'),
        levelValueTemplate: l10n.levelColon('{value}'),
      ),
      'workoutSessionId': _workoutSessionId,
    };
  }

  Map<String, dynamic> _finishedLiveActivityPayload(
    Map<String, dynamic>? source, {
    String? statusText,
  }) {
    return <String, dynamic>{
      ...?source,
      'status': WorkoutLiveActivityPhase.finished.name,
      'statusText': statusText ??
          _finishedLiveActivityStatusText ??
          source?['statusText'] ??
          '',
      'timerEndAtMs': 0,
      'workoutEndAtMs': 0,
      'progress': _workoutState.status == WorkoutStatus.finished
          ? 1.0
          : (source?['progress'] ?? 0.0),
    };
  }

  WorkoutLiveActivityPhase _liveActivityPhaseFor(WorkoutStatus status) {
    switch (status) {
      case WorkoutStatus.resumingCountdown:
        return WorkoutLiveActivityPhase.preparing;
      case WorkoutStatus.running:
        return WorkoutLiveActivityPhase.running;
      case WorkoutStatus.paused:
        return WorkoutLiveActivityPhase.paused;
      case WorkoutStatus.finished:
      case WorkoutStatus.stopped:
        return WorkoutLiveActivityPhase.finished;
    }
  }

  String get _liveActivitySignature {
    final state = _workoutState;
    final intervalRemainingMs =
        state.currentIntervalRemainingDuration.inMilliseconds;
    final totalRemainingMs = state.totalRemainingDuration.inMilliseconds;
    final progressBucket = (state.totalWorkoutProgress * 1000).round();
    return '${state.status.name}:${state.currentIntervalIndex}:'
        '${state.isInitialCountdown}:$intervalRemainingMs:'
        '$totalRemainingMs:$progressBucket';
  }

  void _onWorkoutStateChanged() {
    final status = _workoutState.status;
    _applyRemoteScheduleForCurrentState();

    if (status == WorkoutStatus.finished && !_hasLoggedWorkoutCompletion) {
      _hasLoggedWorkoutCompletion = true;
      AnalyticsService.instance.logEvent(
        'workout_completed',
        {
          'machine_type': widget.routine.machineType.name,
          'elapsed_seconds': _workoutState.roundedElapsedSeconds,
          'interval_count': widget.routine.intervals.length,
        },
      );
    }

    if (status == WorkoutStatus.stopped && !_hasLoggedWorkoutStop) {
      _hasLoggedWorkoutStop = true;
      AnalyticsService.instance.logEvent(
        'workout_stopped',
        {
          'machine_type': widget.routine.machineType.name,
          'elapsed_seconds': _workoutState.roundedElapsedSeconds,
          'interval_index': _workoutState.currentIntervalIndex,
          'interval_count': widget.routine.intervals.length,
        },
      );
    }

    // Stop immediately when paused/stopped/finished to avoid lingering speech.
    if (status == WorkoutStatus.paused ||
        status == WorkoutStatus.stopped ||
        status == WorkoutStatus.finished) {
      VoiceGuideService.instance.stop();
    }

    if (_workoutState.status == WorkoutStatus.finished ||
        _workoutState.status == WorkoutStatus.stopped) {
      _endLiveActivity();
      unawaited(
        WorkoutReminderService.instance.cancelWorkoutIntervalNotifications(),
      );
      _navigateToFinished();
    } else if (_workoutState.status == WorkoutStatus.running &&
        _isCountdownActive) {
      // Countdown finished, reset flag
      _isCountdownActive = false;
      // If this running transition came from "resume countdown", do NOT
      // re-announce the current session just because user resumed.
      if (_suppressIntervalGuidanceOnResume) {
        _suppressIntervalGuidanceOnResume = false;
      }
    }

    // Voice guide triggers during running only (never during countdown overlay).
    if (status == WorkoutStatus.running) {
      if (!_suppressIntervalGuidanceOnResume) {
        _maybeSpeakIntervalGuidance();
      }
      // Only speak countdown if not currently speaking interval info
      if (!_isSpeakingIntervalInfo) {
        _maybeSpeakCountdownGuidance();
      }
    }

    if (status != WorkoutStatus.finished &&
        status != WorkoutStatus.stopped &&
        !_isReconcilingLiveActivityFromBackground) {
      _syncLiveActivity();
    }

    // Note: Pause sheet is shown in _pauseWorkout(), not here, to avoid duplication
  }

  void _maybeSpeakCountdownGuidance() {
    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);
    final sec = _workoutState.remainingSeconds;
    final targets = settingsProvider.voiceGuideCountdownTriggers;
    if (!targets.contains(sec)) return;

    final idx = _workoutState.currentIntervalIndex;
    if (_lastSpokenCountdownIntervalIndex == idx &&
        _lastSpokenCountdownSecond == sec) {
      return;
    }

    _lastSpokenCountdownIntervalIndex = idx;
    _lastSpokenCountdownSecond = sec;

    VoiceGuideService.instance.speakCountdown(sec);
    HapticFeedback.lightImpact();
  }

  void _maybeSpeakIntervalGuidance() {
    final idx = _workoutState.currentIntervalIndex;
    if (_lastSpokenIntervalIndex == idx) return;
    _lastSpokenIntervalIndex = idx;

    // Reset countdown counter when new interval starts
    _lastSpokenCountdownIntervalIndex = -1;
    _lastSpokenCountdownSecond = null;

    final interval = _workoutState.currentInterval;

    // Delay to let beep sound play first (beep happens in WorkoutState when interval changes)
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted || _workoutState.currentIntervalIndex != idx) return;
      if (_workoutState.status != WorkoutStatus.running) return;

      switch (widget.routine.machineType) {
        case MachineType.treadmill:
          final settingsProvider =
              Provider.of<AppSettingsProvider>(context, listen: false);

          final speedKmh = interval.speedKmh ?? 0.0;
          // Match the UI unit setting: speak mph if measurement is mph.
          final speed = settingsProvider.measurement == 'mph'
              ? (speedKmh * 0.621371)
              : speedKmh;
          final incline = interval.grade ?? 0.0;

          // Speak speed and incline together in one sentence
          _isSpeakingIntervalInfo = true;
          VoiceGuideService.instance
              .speakSpeedAndIncline(
            speed,
            incline,
            measurement: settingsProvider.measurement,
          )
              .then((_) {
            Future.delayed(const Duration(milliseconds: 300), () {
              _isSpeakingIntervalInfo = false;
            });
          });
          break;

        case MachineType.cycle:
          // Cycle has both resistance (treated as level) and RPM.
          final resistance = interval.resistance ?? 0;
          final rpm = interval.rpm ?? 0;

          // Speak level and RPM together in one sentence
          _isSpeakingIntervalInfo = true;
          VoiceGuideService.instance
              .speakLevelAndRpm(resistance, rpm)
              .then((_) {
            Future.delayed(const Duration(milliseconds: 300), () {
              _isSpeakingIntervalInfo = false;
            });
          });
          break;

        case MachineType.stairmaster:
          final level = interval.level ?? 0;
          _isSpeakingIntervalInfo = true;
          VoiceGuideService.instance.speakLevel(level).then((_) {
            Future.delayed(const Duration(milliseconds: 300), () {
              _isSpeakingIntervalInfo = false;
            });
          });
          break;
      }
    });
  }

  void _navigateToFinished() {
    if (_hasNavigatedToFinished || !mounted) {
      return;
    }
    _hasNavigatedToFinished = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => WorkoutFinishedScreen(
          routine: widget.routine,
          elapsedSeconds: _workoutState.roundedElapsedSeconds,
          elapsedMilliseconds: _workoutState.totalElapsedMilliseconds,
          finishTime: DateTime.now(),
          distanceMeters:
              _workoutState.isTreadmill ? _workoutState.distanceMeters : null,
          currentIntervalIndex: _workoutState.currentIntervalIndex,
          elapsedSecondsInCurrentSession:
              _workoutState.currentIntervalElapsedSeconds,
        ),
      ),
    );
  }

  void _toggleOrientation() {
    // Toggle between portrait and landscape mode
    if (_isLandscapeMode) {
      // Switch back to portrait mode
      _isLandscapeMode = false;
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    } else {
      // Switch to landscape mode
      _isLandscapeMode = true;
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  void _pauseWorkout(WorkoutState state) {
    // Guard: prevent duplicate sheets
    if (_pauseSheetOpen) {
      return;
    }

    state.pauseWorkout();
    unawaited(
      WorkoutReminderService.instance.cancelWorkoutIntervalNotifications(),
    );
    _showPauseSheet(state);
  }

  void _showPauseSheet(WorkoutState state) {
    // Guard: prevent duplicate sheets
    if (_pauseSheetOpen || !mounted) {
      return;
    }

    _pauseSheetOpen = true;

    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true, // Can dismiss by tapping outside
      enableDrag: false, // Cannot drag to dismiss
      backgroundColor: Colors.transparent,
      barrierColor: theme.colorScheme.shadow.withValues(alpha: 0.4),
      builder: (context) => PopScope(
        canPop: false,
        child: PauseBottomSheet(
          onResume: () {
            // Close bottom sheet immediately
            if (mounted) {
              _pauseSheetOpen = false;
            }
            Navigator.pop(context);
            // Start countdown after bottom sheet is closed
            if (mounted && !_isCountdownActive) {
              _isCountdownActive = true;
              _suppressIntervalGuidanceOnResume = true;
              state.startResumeCountdown();
            }
          },
          onEndWorkout: () {
            // Reset flag before opening confirmation (will reopen pause sheet if cancelled)
            if (mounted) {
              _pauseSheetOpen = false;
            }
            Navigator.pop(context);
            // Open confirmation bottom sheet - will reopen pause sheet if cancelled
            _showEndWorkoutConfirmation(state);
          },
        ),
      ),
    ).then((_) {
      // Only reset flag if it wasn't already reset by explicit actions
      // This is a safety net, but actions should handle their own flag management
      if (mounted && _pauseSheetOpen) {
        _pauseSheetOpen = false;
      }
    });
  }

  void _showEndWorkoutConfirmation(WorkoutState state) {
    // Guard: prevent duplicate bottom sheets
    if (_endConfirmOpen || !mounted) {
      return;
    }

    _endConfirmOpen = true;

    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true, // Can dismiss by tapping outside
      enableDrag: false, // Cannot drag to dismiss
      backgroundColor: Colors.transparent,
      barrierColor: theme.colorScheme.shadow.withValues(alpha: 0.4),
      builder: (context) => PopScope(
        canPop: false,
        child: EndWorkoutConfirmationBottomSheet(
          onCancel: () {
            // Cancel: close bottom sheet and reopen pause sheet
            Navigator.pop(context);
            if (mounted) {
              _endConfirmOpen = false;
              // Reopen pause sheet after confirmation bottom sheet is dismissed
              Future.microtask(() {
                if (mounted &&
                    state.status == WorkoutStatus.paused &&
                    !_pauseSheetOpen) {
                  _showPauseSheet(state);
                }
              });
            }
          },
          onConfirm: () {
            // End workout: ONLY action that calls stopWorkout()
            Navigator.pop(context);
            if (mounted) {
              _endConfirmOpen = false;
              _pauseSheetOpen = false; // Reset flag since we're ending
            }
            // Explicitly end workout - this is the ONLY place stopWorkout() is called
            state.stopWorkout();
          },
        ),
      ),
    ).then((_) {
      // Safety net: ensure flag is reset if bottom sheet is dismissed unexpectedly
      if (mounted) {
        _endConfirmOpen = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.previewElapsed != null,
      child: ChangeNotifierProvider.value(
        value: _workoutState,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            bottom: false,
            child: OrientationBuilder(
              builder: (context, orientation) {
                return Consumer2<WorkoutState, AppSettingsProvider>(
                  builder: (context, state, settingsProvider, child) {
                    return Stack(
                      children: [
                        orientation == Orientation.portrait
                            ? _buildPortraitLayout(state, settingsProvider)
                            : _buildLandscapeLayout(state, settingsProvider),
                        IntervalPulseOverlay(
                          triggerKey: state.currentIntervalIndex,
                          enabled: state.status == WorkoutStatus.running,
                        ),
                        // Countdown overlay
                        if (state.status == WorkoutStatus.resumingCountdown)
                          _buildCountdownOverlay(state),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(
      WorkoutState state, AppSettingsProvider settingsProvider) {
    // Format remaining seconds as mm:ss
    final remainingSeconds = state.remainingSeconds;
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final countdownLabel =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final detailChips = _getDetailChips(context, state, settingsProvider);
    final primaryMetricLabel = _getPrimaryMetricLabel(context);

    // Calculate dynamic scaleFactor for portrait based on baseline iPhone 14 Pro (393 x 852)
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    const double basePortraitWidth = 393.0;
    const double basePortraitHeight = 852.0;

    final double widthScale =
        screenWidth > 0 ? screenWidth / basePortraitWidth : 1.0;
    final double heightScale =
        screenHeight > 0 ? screenHeight / basePortraitHeight : 1.0;
    final double scaleFactor =
        math.min(widthScale, heightScale).clamp(0.75, 1.15);
    final displayScale = settingsProvider.workoutDisplaySize.scale;
    final contentScaleFactor = scaleFactor * displayScale;
    final headerScaleFactor = scaleFactor * math.min(displayScale, 1.15);

    final portraitMainFontSize =
        (screenWidth * 0.14 * scaleFactor * displayScale)
            .clamp(48.0, 102.0)
            .toDouble();
    final portraitTimerSize = math
        .min(
          154 * contentScaleFactor,
          screenWidth - (48 * scaleFactor),
        )
        .clamp(112 * scaleFactor, 214 * scaleFactor)
        .toDouble();

    return Column(
      children: [
        // Top section: Total routine remaining time and progress bar
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              24 * scaleFactor,
              28 * scaleFactor,
              24 * scaleFactor,
              12 * scaleFactor,
            ),
            child: Column(
              children: [
                HeaderTimeSummary(
                  totalRemainingTimeFormatted:
                      state.formatTime(state.totalRemainingSeconds),
                  currentIntervalIndex: state.currentIntervalIndex,
                  totalIntervals: widget.routine.intervals.length,
                  scaleFactor: headerScaleFactor,
                ),
                SizedBox(height: 10 * scaleFactor),
                // Total routine remaining progress bar
                TopPillProgressBar(
                  progress: state.totalRemainingProgress,
                  height: 12 * scaleFactor,
                ),
              ],
            ),
          ),
        ),
        // Main content: Current session info and circular timer
        Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              20 * scaleFactor,
              8 * scaleFactor,
              20 * scaleFactor,
              20 * scaleFactor,
            ),
            child: Align(
              alignment: const Alignment(0, -0.08),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 560 * scaleFactor),
                child: WorkoutHeroPanel(
                  isPortrait: true,
                  scaleFactor: scaleFactor,
                  mainSection: CurrentValueSection(
                    metricLabel: primaryMetricLabel,
                    mainValueText:
                        _getMainValueText(context, state, settingsProvider),
                    detailChips: detailChips,
                    mainFontSize: portraitMainFontSize,
                    currentIntervalIndex: state.currentIntervalIndex,
                    scaleFactor: contentScaleFactor,
                    alignCenter: true,
                  ),
                  timerSection: SizedBox(
                    width: double.infinity,
                    child: TimerSurface(
                      isPortrait: true,
                      scaleFactor: scaleFactor,
                      child: CircularSessionTimer(
                        timeText: countdownLabel,
                        progress: 1.0 - state.currentIntervalProgress,
                        isPaused: state.status == WorkoutStatus.paused,
                        size: portraitTimerSize,
                        currentIntervalIndex: state.currentIntervalIndex,
                        scaleFactor: contentScaleFactor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // Bottom buttons
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            20 * scaleFactor,
            0,
            20 * scaleFactor,
            32 * scaleFactor,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 360 * scaleFactor),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WorkoutPrimaryButton(
                  width: 200 * scaleFactor,
                  label: state.status == WorkoutStatus.paused
                      ? AppLocalizations.of(context)!.resume
                      : AppLocalizations.of(context)!.pause,
                  onPressed: state.status == WorkoutStatus.resumingCountdown
                      ? () {} // Disabled during countdown
                      : (state.status == WorkoutStatus.paused
                          ? () {
                              if (mounted) {
                                _pauseSheetOpen = false;
                                if (!_isCountdownActive) {
                                  _isCountdownActive = true;
                                  _suppressIntervalGuidanceOnResume = true;
                                  state.startResumeCountdown();
                                }
                              }
                            }
                          : () => _pauseWorkout(state)),
                  scaleFactor: scaleFactor,
                ),
                SizedBox(width: 12 * scaleFactor),
                WorkoutSecondaryButton(
                  onPressed: state.status == WorkoutStatus.resumingCountdown
                      ? () {} // Disabled during countdown
                      : _toggleOrientation,
                  scaleFactor: scaleFactor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout(
      WorkoutState state, AppSettingsProvider settingsProvider) {
    // Format remaining seconds as mm:ss
    final remainingSeconds = state.remainingSeconds;
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final countdownLabel =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final detailChips = _getDetailChips(context, state, settingsProvider);
    final primaryMetricLabel = _getPrimaryMetricLabel(context);

    return MediaQuery(
      data: MediaQuery.of(context),
      child: SafeArea(
        left: false, // No left padding in landscape
        right: false, // No right padding in landscape
        minimum: const EdgeInsets.only(
            top: 12,
            bottom:
                16), // Keep top breathing room and ensure bottom space on devices with 0 bottom padding (like Android)
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Get available dimensions after SafeArea
            final availableWidth = constraints.maxWidth;
            final availableHeight = constraints.maxHeight;
            final shortestSide = math.min(availableWidth, availableHeight);

            // Calculate scaleFactor based on shortest side
            // Base reference: iPhone 14 Pro landscape (926x428) -> shortestSide = 428
            // Scale factor: shortestSide / 428, clamped to safe range
            const baseShortestSide = 428.0;
            double scaleFactor =
                (shortestSide / baseShortestSide).clamp(0.85, 1.25);

            // Breakpoint adjustments for very small screens
            if (availableWidth < 700 || availableHeight < 320) {
              // Reduce scale more aggressively for small screens
              scaleFactor = (shortestSide / baseShortestSide).clamp(0.75, 1.0);
            }
            final displayScale = settingsProvider.workoutDisplaySize.scale;
            final contentScaleFactor = scaleFactor * displayScale;
            final headerScaleFactor =
                scaleFactor * math.min(displayScale, 1.15);

            // Helper function to scale values
            double scaled(double base) => base * scaleFactor;

            // Calculate responsive sizes
            final baseCircleSize = math
                .min(
                  scaled(availableHeight * 0.52),
                  scaled(availableWidth * 0.26),
                )
                .clamp(scaled(112.0), scaled(170.0));
            final circleSize = math
                .min(baseCircleSize * displayScale, availableHeight * 0.68)
                .toDouble();

            final mainFontSize = (availableHeight * 0.17 * scaleFactor)
                    .clamp(scaled(46.0), scaled(88.0)) *
                displayScale;
            final panelMaxWidth = math.max(
              scaled(600),
              math.min(availableWidth - scaled(56), scaled(940)),
            );

            return Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  children: [
                    // Top section: Total routine remaining time and progress bar (full width)
                    TopRoutineProgressHeader(
                      totalRemainingTimeFormatted:
                          state.formatTime(state.totalRemainingSeconds),
                      progress: state.totalRemainingProgress,
                      currentIntervalIndex: state.currentIntervalIndex,
                      totalIntervals: widget.routine.intervals.length,
                      scaleFactor: headerScaleFactor,
                    ),
                    // Main content: Two columns layout
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                            scaled(20),
                            scaled(12),
                            scaled(20),
                            scaled(42),
                          ),
                          child: ConstrainedBox(
                            constraints:
                                BoxConstraints(maxWidth: panelMaxWidth),
                            child: WorkoutHeroPanel(
                              isPortrait: false,
                              scaleFactor: scaleFactor,
                              mainSection: CurrentValueSection(
                                metricLabel: primaryMetricLabel,
                                mainValueText: _getMainValueText(
                                    context, state, settingsProvider),
                                detailChips: detailChips,
                                mainFontSize: mainFontSize,
                                currentIntervalIndex:
                                    state.currentIntervalIndex,
                                scaleFactor: contentScaleFactor,
                                alignCenter: false,
                              ),
                              timerSection: SizedBox(
                                width: math.max(
                                  circleSize + scaled(28),
                                  scaled(198),
                                ),
                                child: TimerSurface(
                                  isPortrait: false,
                                  scaleFactor: scaleFactor,
                                  child: CircularSessionTimer(
                                    timeText: countdownLabel,
                                    progress:
                                        1.0 - state.currentIntervalProgress,
                                    isPaused:
                                        state.status == WorkoutStatus.paused,
                                    size: circleSize,
                                    currentIntervalIndex:
                                        state.currentIntervalIndex,
                                    scaleFactor: contentScaleFactor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: BottomControlBar(
                    isPaused: state.status == WorkoutStatus.paused,
                    isResumingCountdown:
                        state.status == WorkoutStatus.resumingCountdown,
                    onPauseResume: state.status ==
                            WorkoutStatus.resumingCountdown
                        ? () {}
                        : (state.status == WorkoutStatus.paused
                            ? () {
                                if (mounted) {
                                  _pauseSheetOpen = false;
                                  if (!_isCountdownActive) {
                                    _isCountdownActive = true;
                                    _suppressIntervalGuidanceOnResume = true;
                                    state.startResumeCountdown();
                                  }
                                }
                              }
                            : () => _pauseWorkout(state)),
                    onRotate: state.status == WorkoutStatus.resumingCountdown
                        ? () {}
                        : _toggleOrientation,
                    scaleFactor: scaleFactor,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _getMainValueText(BuildContext context, WorkoutState state,
      AppSettingsProvider settingsProvider) {
    final l10n = AppLocalizations.of(context)!;
    switch (widget.routine.machineType) {
      case MachineType.treadmill:
        return settingsProvider
            .formatSpeed(state.currentInterval.speedKmh ?? 0.0);
      case MachineType.cycle:
        return l10n.resistanceColon(
          LocalizedFormat.decimal(
            context,
            state.currentInterval.resistance ?? 0,
            decimalDigits: 0,
          ),
        );
      case MachineType.stairmaster:
        return l10n.levelColon(
          LocalizedFormat.decimal(
            context,
            state.currentInterval.level ?? 0,
            decimalDigits: 0,
          ),
        );
    }
  }

  String _getPrimaryMetricLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = switch (widget.routine.machineType) {
      MachineType.treadmill => l10n.speed,
      MachineType.cycle => l10n.level,
      MachineType.stairmaster => l10n.level,
    };
    return '${l10n.current} $label';
  }

  String _getSecondaryValueText(BuildContext context, WorkoutState state) {
    switch (widget.routine.machineType) {
      case MachineType.treadmill:
        final l10n = AppLocalizations.of(context)!;
        final grade = state.currentInterval.grade ?? 0.0;
        return l10n.inclineValue(
          LocalizedFormat.decimal(context, grade),
        );
      case MachineType.cycle:
        // Show current session RPM when there's no next session, or show current RPM in secondary area
        final l10n = AppLocalizations.of(context)!;
        final currentRpm = state.currentInterval.rpm ?? 0;
        return l10n.rpmValue(
          LocalizedFormat.decimal(context, currentRpm, decimalDigits: 0),
        );
      case MachineType.stairmaster:
        return ''; // No secondary value for stairmaster
    }
  }

  String _getNextValueText(BuildContext context, WorkoutState state,
      AppSettingsProvider settingsProvider) {
    final l10n = AppLocalizations.of(context)!;
    // Get next interval if available
    if (state.currentIntervalIndex < widget.routine.intervals.length - 1) {
      final nextInterval =
          widget.routine.intervals[state.currentIntervalIndex + 1];
      switch (widget.routine.machineType) {
        case MachineType.treadmill:
          return l10n.nextMetric(
            settingsProvider.formatSpeed(nextInterval.speedKmh ?? 0.0),
          );
        case MachineType.cycle:
          return l10n.nextMetric(
            l10n.resistanceColon(
              LocalizedFormat.decimal(
                context,
                nextInterval.resistance ?? 0,
                decimalDigits: 0,
              ),
            ),
          );
        case MachineType.stairmaster:
          return l10n.nextMetric(
            l10n.levelColon(
              LocalizedFormat.decimal(
                context,
                nextInterval.level ?? 0,
                decimalDigits: 0,
              ),
            ),
          );
      }
    }
    return ''; // No next interval
  }

  String _getNextRpmText(BuildContext context, WorkoutState state) {
    final l10n = AppLocalizations.of(context)!;
    // Only show RPM for cycle workouts in next session area
    if (widget.routine.machineType != MachineType.cycle) {
      return '';
    }
    // For first session (index 0), show current session RPM instead of next
    if (state.currentIntervalIndex == 0) {
      final currentRpm = state.currentInterval.rpm ?? 0;
      return l10n.rpmValue(
        LocalizedFormat.decimal(context, currentRpm, decimalDigits: 0),
      );
    }
    // Get next interval if available
    if (state.currentIntervalIndex < widget.routine.intervals.length - 1) {
      final nextInterval =
          widget.routine.intervals[state.currentIntervalIndex + 1];
      return l10n.rpmValue(
        LocalizedFormat.decimal(
          context,
          nextInterval.rpm ?? 0,
          decimalDigits: 0,
        ),
      );
    }
    return ''; // No next interval
  }

  List<WorkoutDetailChipData> _getDetailChips(
    BuildContext context,
    WorkoutState state,
    AppSettingsProvider settingsProvider,
  ) {
    final chips = <WorkoutDetailChipData>[];
    final nextValueText = _getNextValueText(context, state, settingsProvider);
    final nextRpmText = _getNextRpmText(context, state);
    final secondaryValueText = _getSecondaryValueText(context, state);

    if (nextValueText.isNotEmpty) {
      chips.add(
        WorkoutDetailChipData(
          icon: Icons.arrow_outward_rounded,
          text: nextValueText,
          isAccent: true,
        ),
      );
    }

    if (nextRpmText.isNotEmpty) {
      chips.add(
        WorkoutDetailChipData(
          icon: Icons.speed_rounded,
          text: nextRpmText,
        ),
      );
    }

    if (nextRpmText.isEmpty && secondaryValueText.isNotEmpty) {
      chips.add(
        WorkoutDetailChipData(
          icon: _secondaryMetricIcon(),
          text: secondaryValueText,
        ),
      );
    }

    return chips;
  }

  IconData _secondaryMetricIcon() {
    switch (widget.routine.machineType) {
      case MachineType.treadmill:
        return Icons.terrain_rounded;
      case MachineType.cycle:
        return Icons.speed_rounded;
      case MachineType.stairmaster:
        return Icons.stairs_rounded;
    }
  }

  Widget _buildCountdownOverlay(WorkoutState state) {
    return CountdownOverlay(countdownNumber: state.countdownNumber);
  }
}

// Top pill progress bar with white container and red fill
