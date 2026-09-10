import 'dart:async';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:valcue/l10n/app_localizations.dart';
import '../../routines/models/routine.dart';
import '../../routines/models/machine_type.dart';
import '../../../widgets/bounceable.dart';
import '../../../widgets/secondary_outlined_button.dart';
import '../../../widgets/app_dialog.dart';
import '../../../widgets/app_message.dart';
import '../../../theme/app_theme.dart';
import '../../../app_settings/app_settings_provider.dart';
import '../../../services/workout_ad_gate.dart';
import '../../../services/review_prompt_service.dart';
import '../../../utils/debug_log.dart';
import '../../profile/models/workout_session.dart';
import '../../profile/providers/workout_history_provider.dart';
import '../../profile/models/achievement.dart';
import '../../profile/providers/achievement_provider.dart';
import '../widgets/confetti_animation.dart';
import '../widgets/share_preview_sheet.dart';
import '../widgets/workout_chart.dart';
import '../widgets/workout_summary_card.dart';

class WorkoutFinishedScreen extends StatefulWidget {
  final Routine routine;
  final int elapsedSeconds;
  final int? elapsedMilliseconds;
  final DateTime finishTime;
  final double? distanceMeters; // Distance in meters (null for non-treadmill)
  final int
      currentIntervalIndex; // Index of the interval that was active when workout ended
  final int
      elapsedSecondsInCurrentSession; // Seconds elapsed in the current interval when workout ended
  final bool previewMode;

  const WorkoutFinishedScreen({
    super.key,
    required this.routine,
    required this.elapsedSeconds,
    this.elapsedMilliseconds,
    required this.finishTime,
    this.distanceMeters,
    required this.currentIntervalIndex,
    required this.elapsedSecondsInCurrentSession,
    this.previewMode = false,
  });

  @override
  State<WorkoutFinishedScreen> createState() => _WorkoutFinishedScreenState();
}

class _WorkoutFinishedScreenState extends State<WorkoutFinishedScreen>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _fadeController;
  bool _hasPlayedAnimation = false;
  final GlobalKey _shareButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Save workout session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.previewMode) {
        _saveWorkoutSession();
      }
    });

    // Trigger animation and haptic on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasPlayedAnimation) {
        _hasPlayedAnimation = true;
        _fadeController.forward();
        if (!widget.previewMode) {
          HapticFeedback.lightImpact();
          _confettiController.forward();
        }
      }
    });
  }

  void _saveWorkoutSession() {
    if (!mounted) return;

    final historyProvider =
        Provider.of<WorkoutHistoryProvider>(context, listen: false);

    // Calculate averages
    double? avgRpm;
    double? avgLevel;

    if (widget.routine.machineType == MachineType.cycle) {
      double totalWeightedRpm = 0.0;
      int totalActualSeconds = 0;

      for (int i = 0; i < widget.currentIntervalIndex; i++) {
        final interval = widget.routine.intervals[i];
        if (interval.rpm != null && interval.durationSeconds > 0) {
          totalWeightedRpm += interval.rpm! * interval.durationSeconds;
          totalActualSeconds += interval.durationSeconds;
        }
      }

      if (widget.currentIntervalIndex < widget.routine.intervals.length) {
        final currentInterval =
            widget.routine.intervals[widget.currentIntervalIndex];
        if (currentInterval.rpm != null &&
            widget.elapsedSecondsInCurrentSession > 0) {
          totalWeightedRpm +=
              currentInterval.rpm! * widget.elapsedSecondsInCurrentSession;
          totalActualSeconds += widget.elapsedSecondsInCurrentSession;
        }
      }

      if (totalActualSeconds > 0) {
        avgRpm = totalWeightedRpm / totalActualSeconds;
      }
    } else if (widget.routine.machineType == MachineType.stairmaster) {
      double totalWeightedLevel = 0.0;
      int totalActualSeconds = 0;

      for (int i = 0; i < widget.currentIntervalIndex; i++) {
        final interval = widget.routine.intervals[i];
        if (interval.level != null && interval.durationSeconds > 0) {
          totalWeightedLevel += interval.level! * interval.durationSeconds;
          totalActualSeconds += interval.durationSeconds;
        }
      }

      if (widget.currentIntervalIndex < widget.routine.intervals.length) {
        final currentInterval =
            widget.routine.intervals[widget.currentIntervalIndex];
        if (currentInterval.level != null &&
            widget.elapsedSecondsInCurrentSession > 0) {
          totalWeightedLevel +=
              currentInterval.level! * widget.elapsedSecondsInCurrentSession;
          totalActualSeconds += widget.elapsedSecondsInCurrentSession;
        }
      }

      if (totalActualSeconds > 0) {
        avgLevel = totalWeightedLevel / totalActualSeconds;
      }
    }

    final session = WorkoutSession(
      machineType: widget.routine.machineType,
      dateTime: widget.finishTime,
      durationSeconds: widget.elapsedSeconds,
      elapsedMilliseconds: widget.elapsedMilliseconds,
      distanceMeters: widget.distanceMeters,
      averageRpm: avgRpm,
      averageLevel: avgLevel,
      routineName: widget.routine.name,
      routineId: widget.routine.id,
    );

    historyProvider.addSession(session);

    final completedWorkoutCount = historyProvider.sessions.length;

    // Check if there are newly unlocked achievements to celebrate
    final achievementProvider =
        Provider.of<AchievementProvider>(context, listen: false);
    if (achievementProvider.newlyUnlocked.isNotEmpty) {
      _showCongratsDialog(
        achievementProvider.newlyUnlocked,
        completedWorkoutCount,
      );
    } else {
      unawaited(
        ReviewPromptService.instance.maybeRequestReview(completedWorkoutCount),
      );
    }
  }

  void _showCongratsDialog(
    List<Achievement> achievements,
    int completedWorkoutCount,
  ) {
    if (!mounted) return;

    final langCode = Localizations.localeOf(context).languageCode;
    final l10n = AppLocalizations.of(context)!;

    // Play a premium vibration
    HapticFeedback.heavyImpact();

    showAppDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AppDialog(
          icon: Icons.emoji_events_rounded,
          title: l10n.achievementUnlocked,
          message: l10n.achievementCongratulations,
          content: Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: achievements.map((ach) {
              final title = ach.getTitle(langCode);
              final desc = ach.getDescription(langCode);
              return SizedBox(
                width: 120,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: ach.gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: ach.gradientColors[0].withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(ach.icon, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(dialogContext)
                            .extension<AppColors>()!
                            .mutedText,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          actions: [
            AppDialogAction(
              label: l10n.awesome,
              onPressed: () {
                final provider = Provider.of<AchievementProvider>(
                  dialogContext,
                  listen: false,
                );
                provider.clearNewlyUnlocked();
                Navigator.of(dialogContext).pop();
                HapticFeedback.lightImpact();
                unawaited(
                  ReviewPromptService.instance
                      .maybeRequestReview(completedWorkoutCount),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _shareWorkout(BuildContext context) async {
    final picker = ImagePicker();

    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (!context.mounted || pickedFile == null) {
        // Closing the camera is an intentional cancellation. Keep the user on
        // the workout completion screen instead of showing an empty card.
        return;
      }

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => SharePreviewSheet(
          routine: widget.routine,
          elapsedSeconds: widget.elapsedSeconds,
          distanceMeters: widget.distanceMeters,
          finishTime: widget.finishTime,
          currentIntervalIndex: widget.currentIntervalIndex,
          elapsedSecondsInCurrentSession: widget.elapsedSecondsInCurrentSession,
          imagePath: pickedFile.path,
        ),
      );
    } catch (e) {
      debugLog('[WorkoutFinishedScreen] Error picking image: $e');
      if (context.mounted) {
        showAppMessage(
          context,
          AppLocalizations.of(context)!.unableToShareWorkout,
          type: AppMessageType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final machineTypeLabel = switch (widget.routine.machineType) {
      MachineType.treadmill => l10n.treadmill,
      MachineType.cycle => l10n.cycle,
      MachineType.stairmaster => l10n.stairmaster,
    };

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            if (!widget.previewMode)
              ConfettiAnimation(controller: _confettiController),
            // Main content
            FadeTransition(
              opacity: _fadeController,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 56,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                    const Spacer(),
                    Icon(
                      Icons.check_circle,
                      size: 60,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      l10n.workoutComplete,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.routine.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: theme.extension<AppColors>()!.mutedText,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    WorkoutSummaryCard(
                      elapsedSeconds: widget.elapsedSeconds,
                      distanceMeters:
                          widget.routine.machineType == MachineType.treadmill
                              ? widget.distanceMeters
                              : null,
                      finishTime: widget.finishTime,
                      routine: widget.routine,
                      machineTypeLabel: machineTypeLabel,
                      currentIntervalIndex: widget.currentIntervalIndex,
                      elapsedSecondsInCurrentSession:
                          widget.elapsedSecondsInCurrentSession,
                    ),
                    const SizedBox(height: 12),
                    WorkoutChart(
                      routine: widget.routine,
                      currentIntervalIndex: widget.currentIntervalIndex,
                      elapsedSecondsInCurrentSession:
                          widget.elapsedSecondsInCurrentSession,
                    ),
                    const Spacer(),
                    // Share button
                    SecondaryOutlinedButton(
                      key: _shareButtonKey,
                      onPressed: () => _shareWorkout(context),
                      borderRadius: AppTheme.buttonRadius,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      borderColor:
                          theme.colorScheme.outline.withValues(alpha: 0.38),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.share_outlined, size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              AppLocalizations.of(context)!.share,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Primary button: End
                    SizedBox(
                      width: double.infinity,
                      child: Bounceable(
                        onTap: () async {
                          final settingsProvider =
                              Provider.of<AppSettingsProvider>(context,
                                  listen: false);
                          final navigatorContext =
                              Navigator.of(context, rootNavigator: true);

                          await WorkoutAdGate.instance.run(
                            isPremium: settingsProvider.isPremium,
                            placement: WorkoutAdPlacement.afterWorkout,
                            onContinue: () {
                              // Back to the home route in AppShell.
                              navigatorContext
                                  .popUntil((route) => route.isFirst);
                            },
                          );
                        },
                        child: IgnorePointer(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.end,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
