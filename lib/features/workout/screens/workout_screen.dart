import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
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
  bool _isSpeakingIntervalInfo =
      false; // Prevent countdown during interval speech

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
          VoiceGuideService.instance
              .speakSpeedAndIncline(speed, incline)
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
      builder: (context) => PopScope(
        canPop: false,
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
      builder: (context) => PopScope(
        canPop: false,
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
    return PopScope(
      canPop: false,
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
    final portraitMainFontSize =
        (MediaQuery.sizeOf(context).width * 0.14).clamp(58.0, 78.0);

    return Column(
      children: [
        // Top section: Total routine remaining time and progress bar
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 28, 24, 12),
            child: Column(
              children: [
                // Total remaining time text (above bar) with tabular digits
                BidiSafeText(
                  state.formatTime(state.totalRemainingSeconds),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.7,
                    fontFeatures: const [
                      ui.FontFeature.tabularFigures()
                    ], // Tabular/monospaced digits
                  ),
                  forceLTR: true, // Timers must always be LTR
                ),
                const SizedBox(height: 10),
                // Total routine remaining progress bar
                _TopPillProgressBar(
                  progress: state.totalRemainingProgress,
                  height: 12,
                ),
              ],
            ),
          ),
        ),
        // Main content: Current session info and circular timer
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 20),
            child: Align(
              alignment: const Alignment(0, -0.08),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: _WorkoutHeroPanel(
                  isPortrait: true,
                  scaleFactor: 1.0,
                  mainSection: _CurrentValueSection(
                    metricLabel: primaryMetricLabel,
                    mainValueText:
                        _getMainValueText(context, state, settingsProvider),
                    detailChips: detailChips,
                    mainFontSize: portraitMainFontSize,
                    currentIntervalIndex: state.currentIntervalIndex,
                    scaleFactor: 1.0,
                    alignCenter: true,
                  ),
                  timerSection: SizedBox(
                    width: double.infinity,
                    child: _TimerSurface(
                      isPortrait: true,
                      scaleFactor: 1.0,
                      child: _CircularSessionTimer(
                        timeText: countdownLabel,
                        progress: 1.0 - state.currentIntervalProgress,
                        isPaused: state.status == WorkoutStatus.paused,
                        size: 154,
                        currentIntervalIndex: state.currentIntervalIndex,
                        scaleFactor: 1.0,
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
          padding: const EdgeInsetsDirectional.fromSTEB(
            20,
            0,
            20,
            32,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PrimaryButton(
                  width: 200,
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

    // Clamp text scaling to prevent UI breaking
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(
            MediaQuery.of(context).textScaler.scale(1.0).clamp(1.0, 1.15)),
      ),
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

            // Helper function to scale values
            double scaled(double base) => base * scaleFactor;

            // Calculate responsive sizes
            final circleSize = math
                .min(
                  scaled(availableHeight * 0.52),
                  scaled(availableWidth * 0.26),
                )
                .clamp(scaled(112.0), scaled(170.0));

            final mainFontSize = (availableHeight * 0.17 * scaleFactor)
                .clamp(scaled(46.0), scaled(88.0));
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
                    _TopRoutineProgressHeader(
                      totalRemainingTimeFormatted:
                          state.formatTime(state.totalRemainingSeconds),
                      progress: state.totalRemainingProgress,
                      scaleFactor: scaleFactor,
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
                            child: _WorkoutHeroPanel(
                              isPortrait: false,
                              scaleFactor: scaleFactor,
                              mainSection: _CurrentValueSection(
                                metricLabel: primaryMetricLabel,
                                mainValueText: _getMainValueText(
                                    context, state, settingsProvider),
                                detailChips: detailChips,
                                mainFontSize: mainFontSize,
                                currentIntervalIndex:
                                    state.currentIntervalIndex,
                                scaleFactor: scaleFactor,
                                alignCenter: false,
                              ),
                              timerSection: SizedBox(
                                width: math.max(
                                  circleSize + scaled(28),
                                  scaled(198),
                                ),
                                child: _TimerSurface(
                                  isPortrait: false,
                                  scaleFactor: scaleFactor,
                                  child: _CircularSessionTimer(
                                    timeText: countdownLabel,
                                    progress:
                                        1.0 - state.currentIntervalProgress,
                                    isPaused:
                                        state.status == WorkoutStatus.paused,
                                    size: circleSize,
                                    currentIntervalIndex:
                                        state.currentIntervalIndex,
                                    scaleFactor: scaleFactor,
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
                  child: _BottomControlBar(
                    isPaused: state.status == WorkoutStatus.paused,
                    isResumingCountdown:
                        state.status == WorkoutStatus.resumingCountdown,
                    onPauseResume: state.status ==
                            WorkoutStatus.resumingCountdown
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

  List<_WorkoutDetailChipData> _getDetailChips(
    BuildContext context,
    WorkoutState state,
    AppSettingsProvider settingsProvider,
  ) {
    final chips = <_WorkoutDetailChipData>[];
    final nextValueText = _getNextValueText(context, state, settingsProvider);
    final nextRpmText = _getNextRpmText(context, state);
    final secondaryValueText = _getSecondaryValueText(context, state);

    if (nextValueText.isNotEmpty) {
      chips.add(
        _WorkoutDetailChipData(
          icon: Icons.arrow_outward_rounded,
          text: nextValueText,
          isAccent: true,
        ),
      );
    }

    if (nextRpmText.isNotEmpty) {
      chips.add(
        _WorkoutDetailChipData(
          icon: Icons.speed_rounded,
          text: nextRpmText,
        ),
      );
    }

    if (nextRpmText.isEmpty && secondaryValueText.isNotEmpty) {
      chips.add(
        _WorkoutDetailChipData(
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
    final isDark = theme.brightness == Brightness.dark;
    final trackColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : theme.colorScheme.onSurface.withValues(alpha: 0.06);
    return Container(
      height: widget.height ?? 12,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.08),
            blurRadius: 14,
            spreadRadius: 0,
            offset: const Offset(0, 4),
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
                color: trackColor,
              ),
              // Primary fill bar with smooth animation (always left to right)
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return FractionallySizedBox(
                    widthFactor: _animation.value.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            Color.lerp(
                                  theme.colorScheme.primary,
                                  Colors.white,
                                  isDark ? 0.08 : 0.18,
                                ) ??
                                theme.colorScheme.primary,
                          ],
                        ),
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

// Painter for progress ring: gray background + primary arc
class _ProgressRingPainter extends CustomPainter {
  final double strokeWidth;
  final double progress; // 0.0 to 1.0
  final Color trackColor;
  final Color progressColor;

  final Paint _trackPaint;
  final Paint _progressPaint;

  _ProgressRingPainter({
    required this.strokeWidth,
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  })  : _trackPaint = Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
        _progressPaint = Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background ring (full circle)
    canvas.drawCircle(center, radius, _trackPaint);

    // Draw progress arc (clockwise from top)
    if (progress > 0) {
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
        _progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}

// Primary button (red) - for Pause/Resume
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double width;

  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.width = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
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
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFD0D0D0);

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

class _WorkoutHeroPanel extends StatelessWidget {
  final bool isPortrait;
  final double scaleFactor;
  final Widget mainSection;
  final Widget timerSection;

  const _WorkoutHeroPanel({
    required this.isPortrait,
    required this.scaleFactor,
    required this.mainSection,
    required this.timerSection,
  });

  double _scaled(double base) => base * scaleFactor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _scaled(isPortrait ? 4 : 8),
        vertical: _scaled(isPortrait ? 12 : 6),
      ),
      child: isPortrait
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                mainSection,
                SizedBox(height: _scaled(34)),
                timerSection,
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: _scaled(560)),
                  child: mainSection,
                ),
                SizedBox(width: _scaled(18)),
                timerSection,
              ],
            ),
    );
  }
}

class _TimerSurface extends StatelessWidget {
  final bool isPortrait;
  final double scaleFactor;
  final Widget child;

  const _TimerSurface({
    required this.isPortrait,
    required this.scaleFactor,
    required this.child,
  });

  double _scaled(double base) => base * scaleFactor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: _scaled(isPortrait ? 0 : 8)),
      child: child,
    );
  }
}

class _WorkoutDetailChipData {
  final IconData icon;
  final String text;
  final bool isAccent;

  const _WorkoutDetailChipData({
    required this.icon,
    required this.text,
    this.isAccent = false,
  });
}

class _WorkoutDetailChip extends StatelessWidget {
  final _WorkoutDetailChipData chip;
  final double scaleFactor;

  const _WorkoutDetailChip({
    required this.chip,
    required this.scaleFactor,
  });

  double _scaled(double base) => base * scaleFactor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chipColor = chip.isAccent
        ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.08 : 0.04)
        : isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02);
    final borderColor = chip.isAccent
        ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.55 : 0.28)
        : isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.10);

    return Container(
      constraints: BoxConstraints(minHeight: _scaled(40)),
      padding: EdgeInsets.symmetric(
        horizontal: _scaled(14),
        vertical: _scaled(9),
      ),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(_scaled(999)),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            chip.icon,
            size: _scaled(15),
            color: chip.isAccent
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.56),
          ),
          SizedBox(width: _scaled(10)),
          Flexible(
            child: Text(
              chip.text,
              style: TextStyle(
                fontSize: _scaled(15),
                fontWeight: FontWeight.w600,
                color: chip.isAccent
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.84),
                letterSpacing: -0.1,
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
        top: _scaled(4),
        bottom: 0,
        start: _scaled(32),
        end: _scaled(32),
      ),
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: _scaled(320)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Center: Primary pause/resume button (pill shape)
              Container(
                height: _scaled(48),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      _scaled(24)), // >= 20 for premium look
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
            ],
          ),
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
              // Total remaining time text (compact) with tabular digits
              BidiSafeText(
                totalRemainingTimeFormatted,
                style: TextStyle(
                  fontSize: _scaled(28),
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.7,
                  height: 1.0,
                  fontFeatures: const [
                    ui.FontFeature.tabularFigures()
                  ], // Tabular/monospaced digits
                ),
                forceLTR: true, // Timers must always be LTR
              ),
              SizedBox(height: _scaled(10)),
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
  final String metricLabel;
  final String mainValueText;
  final List<_WorkoutDetailChipData> detailChips;
  final double mainFontSize;
  final int currentIntervalIndex;
  final double scaleFactor;
  final bool alignCenter;

  const _CurrentValueSection({
    required this.metricLabel,
    required this.mainValueText,
    required this.detailChips,
    required this.mainFontSize,
    required this.currentIntervalIndex,
    required this.scaleFactor,
    required this.alignCenter,
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
      crossAxisAlignment: widget.alignCenter
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          widget.metricLabel,
          style: TextStyle(
            fontSize: widget._scaled(13),
            fontWeight: FontWeight.w700,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.42),
            letterSpacing: 1.3,
          ),
          textAlign: widget.alignCenter ? TextAlign.center : TextAlign.start,
        ),
        SizedBox(height: widget._scaled(12)),
        // Current session value (large primary text) with pulse animation
        Align(
          alignment: widget.alignCenter
              ? Alignment.center
              : AlignmentDirectional.centerStart,
          widthFactor: widget.alignCenter ? null : 1,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = 1.0 + (_pulseController.value * 0.1);
              return Transform.scale(
                scale: scale,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: widget.alignCenter
                      ? Alignment.center
                      : AlignmentDirectional.centerStart,
                  child: FlashingMetricText(
                    text: widget.mainValueText,
                    style: TextStyle(
                      fontSize: widget.mainFontSize,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: -1.8,
                    ),
                    defaultColor: Theme.of(context).colorScheme.onSurface,
                    flashColor: Theme.of(context).colorScheme.primary,
                    triggerKey: widget.currentIntervalIndex,
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.detailChips.isNotEmpty) ...[
          SizedBox(height: widget._scaled(16)),
          Align(
            alignment: widget.alignCenter
                ? Alignment.center
                : AlignmentDirectional.centerStart,
            widthFactor: widget.alignCenter ? null : 1,
            child: Wrap(
              alignment: widget.alignCenter
                  ? WrapAlignment.center
                  : WrapAlignment.start,
              spacing: widget._scaled(10),
              runSpacing: widget._scaled(10),
              children: [
                for (final chip in widget.detailChips)
                  _WorkoutDetailChip(
                    chip: chip,
                    scaleFactor: widget.scaleFactor,
                  ),
              ],
            ),
          ),
        ],
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
    final trackColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
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
                          Colors.black.withValues(alpha: isDark ? 0.28 : 0.1),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 3),
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
                          trackColor: trackColor,
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
