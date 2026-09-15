import 'dart:async';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:valcue/l10n/app_localizations.dart';
import '../../routines/models/routine.dart';
import '../../routines/models/machine_type.dart';
import '../../../widgets/bounceable.dart';
import '../../../widgets/valcue_ui.dart';
import '../../../widgets/app_dialog.dart';
import '../../../widgets/app_message.dart';
import '../../../theme/app_theme.dart';
import '../../../app_settings/app_settings_provider.dart';
import '../../../services/workout_ad_gate.dart';
import '../../../services/health_sync_service.dart';
import '../../../services/review_prompt_service.dart';
import '../../../utils/debug_log.dart';
import '../../profile/models/workout_session.dart';
import '../../profile/providers/workout_history_provider.dart';
import '../../profile/providers/weight_tracker_provider.dart';
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
    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);

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

    // Best effort: a health store that is missing or denied must never get in
    // the way of the workout being saved here. The latest recorded weight
    // makes the energy estimate personal; without one it falls back to an
    // assumed weight rather than skipping the rings entirely.
    unawaited(
      HealthSyncService.instance.writeWorkout(
        session,
        enabled: settingsProvider.healthSyncEnabled,
        bodyWeightKg: Provider.of<WeightTrackerProvider>(context, listen: false)
            .currentWeight
            ?.weightKg,
      ),
    );

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
                    padding: const EdgeInsets.fromLTRB(22, 28, 22, 34),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 56,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                    const Spacer(),
                    Center(
                      child: Container(
                        width: 78,
                        height: 78,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 44,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      l10n.workoutComplete,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -1.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.routine.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
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
                    const SizedBox(height: 14),
                    WorkoutChart(
                      routine: widget.routine,
                      currentIntervalIndex: widget.currentIntervalIndex,
                      elapsedSecondsInCurrentSession:
                          widget.elapsedSecondsInCurrentSession,
                    ),
                    const Spacer(),
                    // Share button
                    OutlinePillButton(
                      key: _shareButtonKey,
                      onPressed: () => _shareWorkout(context),
                      height: 54,
                      label: AppLocalizations.of(context)!.share,
                      leading: const Icon(
                        Icons.ios_share,
                        size: 19,
                        color: Color(0xFF007AFF),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                              minimumSize: const Size.fromHeight(58),
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.end,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
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
