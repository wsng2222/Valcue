import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:interval_cardio/l10n/app_localizations.dart';
import '../../routines/models/routine.dart';
import '../../routines/models/machine_type.dart';
import '../../../app_settings/app_settings_provider.dart';
import '../../../utils/app_shadows.dart';
import '../../../widgets/bidi_safe_text.dart';
import '../../../theme/app_theme.dart';
import '../state/workout_state.dart';
import '../widgets/flashing_metric_text.dart';
import 'workout_finished_screen.dart';
import '../../../widgets/secondary_outlined_button.dart';
import '../../../services/voice_guide_service.dart';

class WorkoutScreen extends StatefulWidget {
  final Routine routine;

  const WorkoutScreen({
    super.key,
    required this.routine,
  });

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late WorkoutState _workoutState;
  bool _pauseSheetOpen = false;
  bool _endConfirmOpen = false;
  bool _isCountdownActive = false;
  bool _isLandscapeMode = false;
  int _lastSpokenIntervalIndex = -1;
  int? _lastSpokenCountdownSecond;
  int _lastSpokenCountdownIntervalIndex = -1;
  bool _suppressIntervalGuidanceOnResume = false;
  bool _isSpeakingIntervalInfo = false;  // Prevent countdown during interval speech

  @override
  void initState() {
    super.initState();
    _workoutState = WorkoutState(
      routine: widget.routine,
      startTime: DateTime.now(),
    );
    _workoutState.addListener(_onWorkoutStateChanged);

    // Keep screen awake
    WakelockPlus.enable();

    // Lock orientation initially
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    _workoutState.removeListener(_onWorkoutStateChanged);
    _workoutState.dispose();

    // Release wakelock
    WakelockPlus.disable();

    // Reset orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  void _onWorkoutStateChanged() {
    final status = _workoutState.status;

    // Stop immediately when paused/stopped/finished to avoid lingering speech.
    if (status == WorkoutStatus.paused ||
        status == WorkoutStatus.stopped ||
        status == WorkoutStatus.finished) {
      VoiceGuideService.instance.stop();
    }

    if (_workoutState.status == WorkoutStatus.finished ||
        _workoutState.status == WorkoutStatus.stopped) {
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

    // Note: Pause sheet is shown in _pauseWorkout(), not here, to avoid duplication
  }

  void _maybeSpeakCountdownGuidance() {
    // Speak: 30 / 20 / 10 seconds left.
    final sec = _workoutState.remainingSeconds;
    const targets = {30, 20, 10};
    if (!targets.contains(sec)) return;

    final idx = _workoutState.currentIntervalIndex;
    if (_lastSpokenCountdownIntervalIndex == idx &&
        _lastSpokenCountdownSecond == sec) {
      return;
    }

    _lastSpokenCountdownIntervalIndex = idx;
    _lastSpokenCountdownSecond = sec;

    VoiceGuideService.instance.speakCountdown(sec);
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
          VoiceGuideService.instance.speakSpeedAndIncline(speed, incline).then((_) {
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
          VoiceGuideService.instance.speakLevelAndRpm(resistance, rpm).then((_) {
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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => WorkoutFinishedScreen(
          routine: widget.routine,
          elapsedSeconds: _workoutState.totalElapsedSeconds,
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
      builder: (context) => WillPopScope(
        onWillPop: () async => false, // Prevent back button dismissal
        child: _PauseBottomSheet(
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
      builder: (context) => WillPopScope(
        onWillPop: () async => false, // Prevent back button dismissal
        child: _EndWorkoutConfirmationBottomSheet(
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
    return WillPopScope(
      onWillPop: () async => false, // Prevent accidental back navigation
      child: ChangeNotifierProvider.value(
        value: _workoutState,
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: OrientationBuilder(
              builder: (context, orientation) {
                return Consumer2<WorkoutState, AppSettingsProvider>(
                  builder: (context, state, settingsProvider, child) {
                    return Stack(
                      children: [
                        orientation == Orientation.portrait
                            ? _buildPortraitLayout(state, settingsProvider)
                            : _buildLandscapeLayout(state, settingsProvider),
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

    return Column(
      children: [
        // Top section: Total routine remaining time and progress bar
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 64, 24, 20),
            child: Column(
              children: [
                // Label for total remaining time
                Text(
                  'Total remaining',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).extension<AppColors>()!.mutedText,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                // Total remaining time text (above bar) with tabular digits
                BidiSafeText(
                  state.formatTime(state.totalRemainingSeconds),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.5,
                    fontFeatures: const [
                      ui.FontFeature.tabularFigures()
                    ], // Tabular/monospaced digits
                  ),
                  forceLTR: true, // Timers must always be LTR
                ),
                const SizedBox(height: 10),
                // Total routine remaining progress bar
                _TopPillProgressBar(progress: state.totalRemainingProgress),
              ],
            ),
          ),
        ),
        // Main content: Current session info and circular timer
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 1),
                // Current session value (large primary text)
                FlashingMetricText(
                  text: _getMainValueText(context, state, settingsProvider),
                  style: TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -2.0,
                  ),
                  defaultColor: Theme.of(context).colorScheme.onSurface,
                  flashColor: Theme.of(context).colorScheme.primary,
                  triggerKey: state.currentIntervalIndex,
                ),
                const SizedBox(height: 12),
                // Next session value and secondary value as chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_getNextValueText(context, state, settingsProvider)
                        .isNotEmpty)
                      _InfoChip(
                        text:
                            _getNextValueText(context, state, settingsProvider),
                      ),
                    if (_getNextValueText(context, state, settingsProvider)
                            .isNotEmpty &&
                        _getNextRpmText(context, state).isNotEmpty)
                      const SizedBox(width: 8),
                    if (_getNextRpmText(context, state).isNotEmpty)
                      _InfoChip(
                        text: _getNextRpmText(context, state),
                      ),
                    if (_getNextValueText(context, state, settingsProvider)
                            .isNotEmpty &&
                        _getNextRpmText(context, state).isEmpty &&
                        _getSecondaryValueText(context, state).isNotEmpty)
                      const SizedBox(width: 8),
                    if (_getNextValueText(context, state, settingsProvider)
                            .isNotEmpty &&
                        _getNextRpmText(context, state).isEmpty &&
                        _getSecondaryValueText(context, state).isNotEmpty)
                      _InfoChip(
                        text: _getSecondaryValueText(context, state),
                      ),
                    if (_getNextValueText(context, state, settingsProvider)
                            .isEmpty &&
                        _getSecondaryValueText(context, state).isNotEmpty)
                      _InfoChip(
                        text: _getSecondaryValueText(context, state),
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                // Circular timer for current session
                _CircularTimerBadge(
                  timeText: countdownLabel,
                  progress: 1.0 - state.currentIntervalProgress,
                  isPaused: state.status == WorkoutStatus.paused,
                  isLandscape: _isLandscapeMode,
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
        // Bottom buttons
        Padding(
          padding: const EdgeInsetsDirectional.only(
            bottom: 32,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PrimaryButton(
                label: state.status == WorkoutStatus.paused
                    ? AppLocalizations.of(context)!.resume
                    : AppLocalizations.of(context)!.pause,
                onPressed: state.status == WorkoutStatus.resumingCountdown
                    ? () {} // Disabled during countdown
                    : (state.status == WorkoutStatus.paused
                        ? () {
                            Navigator.of(context, rootNavigator: true)
                                .popUntil((route) => route.isFirst);
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
              ),
              const SizedBox(width: 12),
              _SecondaryButton(
                onPressed: state.status == WorkoutStatus.resumingCountdown
                    ? () {} // Disabled during countdown
                    : _toggleOrientation,
              ),
            ],
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

    // Clamp text scaling to prevent UI breaking
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(
            MediaQuery.of(context).textScaler.scale(1.0).clamp(1.0, 1.15)),
      ),
      child: SafeArea(
        left: false,  // No left padding in landscape
        right: false, // No right padding in landscape
        minimum: const EdgeInsets.only(top: 16, bottom: 16), // Add padding to center vertically
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

            // Helper function to scale values
            double scaled(double base) => base * scaleFactor;

            // Calculate responsive sizes
            final circleSize = math
                .min(
                  scaled(availableHeight * 0.65),
                  scaled(availableWidth * 0.33),
                )
                .clamp(scaled(100.0), scaled(180.0));

            final mainFontSize = (availableHeight * 0.20 * scaleFactor)
                .clamp(scaled(48.0), scaled(100.0));

            return Column(
              children: [
                // Top section: Total routine remaining time and progress bar (full width)
                _TopRoutineProgressHeader(
                  totalRemainingTimeFormatted:
                      state.formatTime(state.totalRemainingSeconds),
                  progress: state.totalRemainingProgress,
                  scaleFactor: scaleFactor,
                ),
                // Main content: Two columns layout - Centered vertically
                Expanded(
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      scaled(20),
                      scaled(8),
                      scaled(48),
                      scaled(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left column: Current speed + chips
                        Expanded(
                          flex: 1,
                          child: _CurrentValueSection(
                            mainValueText: _getMainValueText(
                                context, state, settingsProvider),
                            nextValueText: _getNextValueText(
                                context, state, settingsProvider),
                            nextRpmText: _getNextRpmText(context, state),
                            secondaryValueText:
                                _getSecondaryValueText(context, state),
                            mainFontSize: mainFontSize,
                            currentIntervalIndex: state.currentIntervalIndex,
                            scaleFactor: scaleFactor,
                          ),
                        ),
                        SizedBox(width: scaled(24)),
                        // Right column: Circular session timer
                        SizedBox(
                          width: circleSize +
                              scaled(12), // Bring timer closer to center
                          child: _CircularSessionTimer(
                            timeText: countdownLabel,
                            progress: 1.0 - state.currentIntervalProgress,
                            isPaused: state.status == WorkoutStatus.paused,
                            size: circleSize,
                            currentIntervalIndex: state.currentIntervalIndex,
                            scaleFactor: scaleFactor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottom control bar with bottom padding
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    bottom: scaled(1),
                  ),
                  child: _BottomControlBar(
                    isPaused: state.status == WorkoutStatus.paused,
                    isResumingCountdown:
                        state.status == WorkoutStatus.resumingCountdown,
                    onPauseResume: state.status == WorkoutStatus.resumingCountdown
                        ? () {}
                        : (state.status == WorkoutStatus.paused
                            ? () {
                                Navigator.of(context, rootNavigator: true)
                                    .popUntil((route) => route.isFirst);
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
    switch (widget.routine.machineType) {
      case MachineType.treadmill:
        return settingsProvider
            .formatSpeed(state.currentInterval.speedKmh ?? 0.0);
      case MachineType.cycle:
        return 'Level ${state.currentInterval.resistance ?? 0}';
      case MachineType.stairmaster:
        return 'Level ${state.currentInterval.level ?? 0}';
    }
  }

  String _getSecondaryValueText(BuildContext context, WorkoutState state) {
    switch (widget.routine.machineType) {
      case MachineType.treadmill:
        final l10n = AppLocalizations.of(context)!;
        final grade = state.currentInterval.grade ?? 0.0;
        return '${grade.toStringAsFixed(1)}% ${l10n.incline}';
      case MachineType.cycle:
        // Show current session RPM when there's no next session, or show current RPM in secondary area
        final l10n = AppLocalizations.of(context)!;
        final currentRpm = state.currentInterval.rpm ?? 0;
        return '${l10n.rpm} $currentRpm';
      case MachineType.stairmaster:
        return ''; // No secondary value for stairmaster
    }
  }

  String _getNextValueText(BuildContext context, WorkoutState state,
      AppSettingsProvider settingsProvider) {
    // Get next interval if available
    if (state.currentIntervalIndex < widget.routine.intervals.length - 1) {
      final nextInterval =
          widget.routine.intervals[state.currentIntervalIndex + 1];
      switch (widget.routine.machineType) {
        case MachineType.treadmill:
          return 'Next ${settingsProvider.formatSpeed(nextInterval.speedKmh ?? 0.0)}';
        case MachineType.cycle:
          return 'Next Level ${nextInterval.resistance ?? 0}';
        case MachineType.stairmaster:
          return 'Next Level ${nextInterval.level ?? 0}';
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
      return '${l10n.rpm} $currentRpm';
    }
    // Get next interval if available
    if (state.currentIntervalIndex < widget.routine.intervals.length - 1) {
      final nextInterval =
          widget.routine.intervals[state.currentIntervalIndex + 1];
      return '${l10n.rpm} ${nextInterval.rpm ?? 0}';
    }
    return ''; // No next interval
  }

  Widget _buildCountdownOverlay(WorkoutState state) {
    return _CountdownOverlay(countdownNumber: state.countdownNumber);
  }
}

// Top pill progress bar with white container and red fill
class _TopPillProgressBar extends StatefulWidget {
  final double progress;
  final double? height;

  const _TopPillProgressBar({
    required this.progress,
    this.height,
  });

  @override
  State<_TopPillProgressBar> createState() => _TopPillProgressBarState();
}

class _TopPillProgressBarState extends State<_TopPillProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _previousProgress = widget.progress;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: widget.progress,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
    _controller.value = 1.0; // Start at the end
  }

  @override
  void didUpdateWidget(_TopPillProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _previousProgress = _animation.value;

      // If progress decreased (session ended, resetting to 0), skip animation and reset immediately
      if (widget.progress < _previousProgress) {
        _animation = Tween<double>(
          begin: widget.progress,
          end: widget.progress,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.linear,
        ));
        _controller.value = 1.0; // Set immediately without animation
      } else {
        // Progress increased (new session starting), animate normally
        _animation = Tween<double>(
          begin: _previousProgress,
          end: widget.progress,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.linear,
        ));
        _controller.reset();
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: widget.height ?? 22,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 20,
            spreadRadius: 0.5,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        // Force LTR direction so progress bar always goes left to right, even in RTL mode
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              // Background
              Container(
                width: double.infinity,
                color: theme.colorScheme.surface,
              ),
              // Primary fill bar with smooth animation (always left to right)
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return FractionallySizedBox(
                    widthFactor: _animation.value.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Small circular timer badge with full red ring
class _CircularTimerBadge extends StatefulWidget {
  final String timeText;
  final double progress; // 0.0 to 1.0, where 1.0 = full ring, 0.0 = empty
  final bool isPaused;
  final bool isLandscape;

  const _CircularTimerBadge({
    required this.timeText,
    required this.progress,
    required this.isPaused,
    required this.isLandscape,
  });

  @override
  State<_CircularTimerBadge> createState() => _CircularTimerBadgeState();
}

class _CircularTimerBadgeState extends State<_CircularTimerBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _previousProgress = widget.progress;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: widget.progress,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
    _controller.value = 1.0; // Start at the end
  }

  @override
  void didUpdateWidget(_CircularTimerBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _previousProgress = _animation.value;
      _animation = Tween<double>(
        begin: _previousProgress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ));
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Larger size in landscape mode
    final double size = widget.isLandscape ? 200.0 : 130.0;
    final double strokeWidth = widget.isLandscape ? 14.0 : 10.0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Dark mode: use near-black/charcoal surface, light mode: white
    final backgroundColor = isDark
        ? const Color(0xFF1C1C1E) // Dark surface (charcoal)
        : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          // Background circle with shadow
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          // Progress ring (background gray + foreground red arc) with smooth animation
          SizedBox(
            width: size,
            height: size,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ProgressRingPainter(
                    strokeWidth: strokeWidth,
                    progress: _animation.value,
                    backgroundColor: backgroundColor,
                    progressColor: theme.colorScheme.primary,
                  ),
                );
              },
            ),
          ),
          // Time text (always LTR for timers) with tabular digits
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BidiSafeText(
                widget.timeText,
                style: TextStyle(
                  fontSize: widget.isLandscape ? 36.0 : 24.0,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: -0.5,
                  fontFeatures: const [
                    ui.FontFeature.tabularFigures()
                  ], // Tabular/monospaced digits
                ),
                forceLTR: true, // Timers must always be LTR
              ),
              if (widget.isPaused) ...[
                SizedBox(height: widget.isLandscape ? 6 : 4),
                Text(
                  AppLocalizations.of(context)!.paused,
                  style: TextStyle(
                    fontSize: widget.isLandscape ? 12.0 : 10.0,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).extension<AppColors>()!.mutedText,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// Painter for progress ring: gray background + primary arc
class _ProgressRingPainter extends CustomPainter {
  final double strokeWidth;
  final double progress; // 0.0 to 1.0
  final Color backgroundColor;
  final Color progressColor;

  _ProgressRingPainter({
    required this.strokeWidth,
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background ring (full circle)
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc (clockwise from top)
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Start from top (-90 degrees) and draw clockwise
      // Progress arc: sweepAngle = progress * 360 degrees (2π radians)
      // Positive sweepAngle = clockwise direction in Flutter
      final sweepAngle = progress * 2 * math.pi;
      const startAngle = -math.pi / 2; // Start from top (-90 degrees)

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle, // Positive = clockwise, negative = counterclockwise
        false, // Don't use center
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor;
  }
}

// Primary button (red) - for Pause/Resume
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.elevatedSoft,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}

// Secondary button (neutral/gray) - for Rotate
class _SecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _SecondaryButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Default colors
    final bgColor = isDark
        ? const Color(0xFF2C2C2E).withValues(alpha: 0.5)
        : Colors.grey.shade50;
    const borderColor = Color(0xFFD0D0D0);

    return Opacity(
      opacity: onPressed == null ? 0.5 : 1.0,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: bgColor,
          border: Border.all(
            color: borderColor,
            width: 1.0,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            splashColor: Colors.black.withValues(alpha: 0.08),
            highlightColor: Colors.black.withValues(alpha: 0.05),
            child: Icon(
              Icons.rotate_right,
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

// Premium info chip with icon (landscape mode)
class _PremiumInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final double scaleFactor;

  const _PremiumInfoChip({
    required this.icon,
    required this.text,
    required this.scaleFactor,
  });

  double _scaled(double base) => base * scaleFactor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // Very light tint (near white), not flat gray
    final chipColor = isDark
        ? const Color(0xFF2C2C2E) // Dark surface
        : Colors.grey.shade50;

    return Container(
      height: _scaled(42),
      padding: EdgeInsets.symmetric(horizontal: _scaled(16), vertical: 0),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius:
            BorderRadius.circular(_scaled(24)), // >= 18 for premium look
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: _scaled(16),
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          SizedBox(width: _scaled(10)),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: _scaled(18),
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                letterSpacing: -0.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// Bottom control bar widget (landscape mode)
class _BottomControlBar extends StatelessWidget {
  final bool isPaused;
  final bool isResumingCountdown;
  final VoidCallback onPauseResume;
  final VoidCallback onRotate;
  final double scaleFactor;

  const _BottomControlBar({
    required this.isPaused,
    required this.isResumingCountdown,
    required this.onPauseResume,
    required this.onRotate,
    required this.scaleFactor,
  });

  double _scaled(double base) => base * scaleFactor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: _scaled(16),
        bottom: _scaled(16),
        start: _scaled(32),
        end: _scaled(32),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Left spacer
          const Spacer(),
          // Center: Primary pause/resume button (pill shape)
          Container(
            height: _scaled(48),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(_scaled(24)), // >= 20 for premium look
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                  blurRadius: _scaled(8),
                  spreadRadius: 0,
                  offset: Offset(0, _scaled(2)),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isResumingCountdown ? () {} : onPauseResume,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(
                  horizontal: _scaled(32),
                  vertical: _scaled(12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_scaled(24)),
                ),
                elevation: 0,
              ),
              child: Text(
                isPaused ? l10n.resume : l10n.pause,
                style: TextStyle(
                  fontSize: _scaled(17),
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
          SizedBox(width: _scaled(10)),
          // Right: Rotate button (right of pause button)
          SecondaryOutlinedIconButton(
            onPressed: isResumingCountdown
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    onRotate();
                  },
            size: _scaled(44),
            iconColor: theme.colorScheme.onSurface,
            icon: Icon(
              Icons.rotate_right,
              size: _scaled(20),
            ),
          ),
          // Right spacer
          const Spacer(),
        ],
      ),
    );
  }
}

// Info chip for next speed/incline
class _InfoChip extends StatelessWidget {
  final String text;

  const _InfoChip({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chipColor = isDark
        ? const Color(0xFF2C2C2E) // Dark surface
        : Colors.grey.shade100;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(8),
        border: isDark
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              )
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

// Countdown overlay widget with persistent background
class _CountdownOverlay extends StatefulWidget {
  final int countdownNumber;

  const _CountdownOverlay({
    required this.countdownNumber,
  });

  @override
  State<_CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<_CountdownOverlay> {
  @override
  Widget build(BuildContext context) {
    // Persistent background that never flickers - stays mounted for entire countdown
    return Container(
      color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.35),
      child: Stack(
        children: [
          // Animated number in center - only this part changes
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              child: Text(
                '${widget.countdownNumber}',
                key: ValueKey(widget.countdownNumber),
                style: const TextStyle(
                  fontSize: 120,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -3.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Top routine progress header widget (reusable for landscape)
class _TopRoutineProgressHeader extends StatelessWidget {
  final String totalRemainingTimeFormatted;
  final double progress;
  final double scaleFactor;

  const _TopRoutineProgressHeader({
    required this.totalRemainingTimeFormatted,
    required this.progress,
    required this.scaleFactor,
  });

  double _scaled(double base) => base * scaleFactor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            _scaled(32),
            _scaled(8),
            _scaled(32),
            _scaled(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label for total remaining time (compact style)
              Text(
                'Total remaining',
                style: TextStyle(
                  fontSize: _scaled(11),
                  fontWeight: FontWeight.w500,
                  color: theme.extension<AppColors>()!.mutedText,
                  letterSpacing: 0.2,
                  height: 1.0, // Compact line height
                ),
              ),
              SizedBox(height: _scaled(4)), // Reduced spacing
              // Total remaining time text (compact) with tabular digits
              BidiSafeText(
                totalRemainingTimeFormatted,
                style: TextStyle(
                  fontSize: _scaled(28), // Slightly smaller
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.5,
                  height: 1.0, // Compact line height
                  fontFeatures: const [
                    ui.FontFeature.tabularFigures()
                  ], // Tabular/monospaced digits
                ),
                forceLTR: true, // Timers must always be LTR
              ),
              SizedBox(height: _scaled(8)), // Reduced spacing
              // Total routine remaining progress bar (thinner)
              Padding(
                padding:
                    EdgeInsetsDirectional.symmetric(horizontal: _scaled(8)),
                child: _TopPillProgressBar(
                  progress: progress,
                  height: _scaled(10), // Reduced from 22 to 10 (10~12px range)
                ),
              ),
            ],
          ),
        ),
        // Subtle divider line under header
        Divider(
          height: 1,
          thickness: 1,
          color: theme.dividerColor.withValues(alpha: 0.3),
          indent: _scaled(32),
          endIndent: _scaled(32),
        ),
      ],
    );
  }
}

// Current value section widget (left column in landscape)
class _CurrentValueSection extends StatefulWidget {
  final String mainValueText;
  final String nextValueText;
  final String nextRpmText;
  final String secondaryValueText;
  final double mainFontSize;
  final int currentIntervalIndex;
  final double scaleFactor;

  const _CurrentValueSection({
    required this.mainValueText,
    required this.nextValueText,
    required this.nextRpmText,
    required this.secondaryValueText,
    required this.mainFontSize,
    required this.currentIntervalIndex,
    required this.scaleFactor,
  });

  double _scaled(double base) => base * scaleFactor;

  @override
  State<_CurrentValueSection> createState() => _CurrentValueSectionState();
}

class _CurrentValueSectionState extends State<_CurrentValueSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int _previousIntervalIndex = -1;

  @override
  void initState() {
    super.initState();
    _previousIntervalIndex = widget.currentIntervalIndex;
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(_CurrentValueSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Pulse animation when interval changes
    if (oldWidget.currentIntervalIndex != widget.currentIntervalIndex &&
        _previousIntervalIndex != widget.currentIntervalIndex) {
      _previousIntervalIndex = widget.currentIntervalIndex;
      _pulseController.reset();
      _pulseController.forward();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Current session value (large primary text) with pulse animation
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = 1.0 + (_pulseController.value * 0.1);
            return Transform.scale(
              scale: scale,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: FlashingMetricText(
                  text: widget.mainValueText,
                  style: TextStyle(
                    fontSize: widget.mainFontSize,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -2.0,
                  ),
                  defaultColor: Theme.of(context).colorScheme.onSurface,
                  flashColor: Theme.of(context).colorScheme.primary,
                  triggerKey: widget.currentIntervalIndex,
                ),
              ),
            );
          },
        ),
        SizedBox(height: widget._scaled(20)),
        // Next session value and secondary value as premium chips (wrap if needed)
        Wrap(
          alignment: WrapAlignment.center,
          spacing: widget._scaled(8),
          runSpacing: widget._scaled(8),
          children: [
            if (widget.nextValueText.isNotEmpty)
              _PremiumInfoChip(
                icon: Icons.arrow_forward_ios,
                text: widget.nextValueText,
                scaleFactor: widget.scaleFactor,
              ),
            if (widget.nextRpmText.isNotEmpty)
              _PremiumInfoChip(
                icon: Icons.speed,
                text: widget.nextRpmText,
                scaleFactor: widget.scaleFactor,
              ),
            if (widget.nextValueText.isNotEmpty &&
                widget.nextRpmText.isEmpty &&
                widget.secondaryValueText.isNotEmpty)
              _PremiumInfoChip(
                icon: Icons.terrain,
                text: widget.secondaryValueText,
                scaleFactor: widget.scaleFactor,
              ),
            if (widget.nextValueText.isEmpty &&
                widget.nextRpmText.isEmpty &&
                widget.secondaryValueText.isNotEmpty)
              _PremiumInfoChip(
                icon: Icons.terrain,
                text: widget.secondaryValueText,
                scaleFactor: widget.scaleFactor,
              ),
          ],
        ),
      ],
    );
  }
}

// Circular session timer widget (right column in landscape)
class _CircularSessionTimer extends StatefulWidget {
  final String timeText;
  final double progress; // 0.0 to 1.0, where 1.0 = full ring, 0.0 = empty
  final bool isPaused;
  final double size;
  final int currentIntervalIndex;
  final double scaleFactor;

  const _CircularSessionTimer({
    required this.timeText,
    required this.progress,
    required this.isPaused,
    required this.size,
    required this.currentIntervalIndex,
    required this.scaleFactor,
  });

  double _scaled(double base) => base * scaleFactor;

  @override
  State<_CircularSessionTimer> createState() => _CircularSessionTimerState();
}

class _CircularSessionTimerState extends State<_CircularSessionTimer>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _animation;
  late Animation<double> _pulseAnimation;
  double _previousProgress = 0.0;
  int _previousIntervalIndex = -1;

  @override
  void initState() {
    super.initState();
    _previousProgress = widget.progress;
    _previousIntervalIndex = widget.currentIntervalIndex;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: widget.progress,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _controller.value = 1.0; // Start at the end
  }

  @override
  void didUpdateWidget(_CircularSessionTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _previousProgress = _animation.value;
      _animation = Tween<double>(
        begin: _previousProgress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ));
      _controller.reset();
      _controller.forward();
    }
    // Pulse animation when interval changes
    if (oldWidget.currentIntervalIndex != widget.currentIntervalIndex &&
        _previousIntervalIndex != widget.currentIntervalIndex) {
      _previousIntervalIndex = widget.currentIntervalIndex;
      _pulseController.reset();
      _pulseController.forward().then((_) {
        // Ensure animation returns to original state after completion
        if (mounted) {
          _pulseController.reset();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF1C1C1E) // Dark surface (charcoal)
        : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final strokeWidth =
        (widget.size * 0.07).clamp(widget._scaled(10.0), widget._scaled(14.0));
    final fontSize =
        (widget.size * 0.18).clamp(widget._scaled(24.0), widget._scaled(36.0));

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Circular timer
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              // Background circle with shadow (always rendered, outside AnimatedBuilder)
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: backgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                      blurRadius: 12,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              // Progress ring with smooth animation and pulse effect
              AnimatedBuilder(
                animation: Listenable.merge([_animation, _pulseAnimation]),
                builder: (context, child) {
                  final pulseScale = _pulseAnimation.value;
                  return Transform.scale(
                    scale: pulseScale,
                    child: SizedBox(
                      width: widget.size,
                      height: widget.size,
                      child: CustomPaint(
                        painter: _ProgressRingPainter(
                          strokeWidth: strokeWidth,
                          progress: _animation.value,
                          backgroundColor: backgroundColor,
                          progressColor: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Time text (always LTR for timers) with tabular digits
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BidiSafeText(
                    widget.timeText,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      letterSpacing: -0.5,
                      fontFeatures: const [
                        ui.FontFeature.tabularFigures()
                      ], // Tabular/monospaced digits
                    ),
                    forceLTR: true, // Timers must always be LTR
                  ),
                  if (widget.isPaused) ...[
                    SizedBox(height: widget.size * 0.03),
                    Text(
                      AppLocalizations.of(context)!.paused,
                      style: TextStyle(
                        fontSize: fontSize * 0.33,
                        fontWeight: FontWeight.w600,
                        color: textColor.withValues(alpha: 0.6),
                        letterSpacing: widget._scaled(0.2),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Premium pause bottom sheet widget
class _PauseBottomSheet extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onEndWorkout;

  const _PauseBottomSheet({
    required this.onResume,
    required this.onEndWorkout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      top: false,
      bottom: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pause icon in circular background
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.pause_rounded,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  Text(
                    l10n.pausedTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  Text(
                    l10n.pausedSubtitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: appColors.mutedText,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Primary button: Continue
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onResume,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.resume,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Secondary button: End workout
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onEndWorkout,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        l10n.endWorkout,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Premium end workout confirmation bottom sheet
class _EndWorkoutConfirmationBottomSheet extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _EndWorkoutConfirmationBottomSheet({
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      top: false,
      bottom: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Warning/Stop icon in circular background
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.stop_circle_outlined,
                      size: 32,
                      color: theme.colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  Text(
                    l10n.endWorkoutQuestion,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Body text
                  Text(
                    l10n.endWorkoutConfirmationMessage,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: appColors.mutedText,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Buttons row
                  Row(
                    children: [
                      // Cancel button (secondary)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onCancel,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ).copyWith(
                            backgroundColor:
                                WidgetStateProperty.all(Colors.transparent),
                          ),
                          child: Text(
                            l10n.cancel,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // End button (destructive primary)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onConfirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.error,
                            foregroundColor: theme.colorScheme.onError,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            l10n.end,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
