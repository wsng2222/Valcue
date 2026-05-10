import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:interval_cardio/l10n/app_localizations.dart';
import '../../routines/models/routine.dart';
import '../../routines/models/machine_type.dart';
import '../../../widgets/bidi_safe_text.dart';
import '../../../theme/app_theme.dart';
import '../../../app_settings/app_settings_provider.dart';
import '../../../services/ad_service.dart';
import '../../profile/models/workout_session.dart';
import '../../profile/providers/workout_history_provider.dart';

class WorkoutFinishedScreen extends StatefulWidget {
  final Routine routine;
  final int elapsedSeconds;
  final DateTime finishTime;
  final double? distanceMeters; // Distance in meters (null for non-treadmill)
  final int
      currentIntervalIndex; // Index of the interval that was active when workout ended
  final int
      elapsedSecondsInCurrentSession; // Seconds elapsed in the current interval when workout ended

  const WorkoutFinishedScreen({
    super.key,
    required this.routine,
    required this.elapsedSeconds,
    required this.finishTime,
    this.distanceMeters,
    required this.currentIntervalIndex,
    required this.elapsedSecondsInCurrentSession,
  });

  @override
  State<WorkoutFinishedScreen> createState() => _WorkoutFinishedScreenState();
}

class _WorkoutFinishedScreenState extends State<WorkoutFinishedScreen>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _fadeController;
  bool _hasPlayedAnimation = false;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Save workout session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveWorkoutSession();
    });

    // Trigger animation and haptic on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasPlayedAnimation) {
        _hasPlayedAnimation = true;
        HapticFeedback.lightImpact();
        _fadeController.forward();
        _confettiController.forward();
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
      distanceMeters: widget.distanceMeters,
      averageRpm: avgRpm,
      averageLevel: avgLevel,
      routineName: widget.routine.name,
      routineId: widget.routine.id,
    );

    historyProvider.addSession(session);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  String _formatDateTime(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context)!;
    return l10n.dateTimeFormat(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Confetti animation overlay
            if (_confettiController.isAnimating)
              _ConfettiAnimation(controller: _confettiController),
            // Main content
            FadeTransition(
              opacity: _fadeController,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    // Completion icon (red accent)
                    Icon(
                      Icons.check_circle,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 20),
                    // Title: "Workout Completed" (always English)
                    Text(
                      'Workout Completed',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(flex: 2),
                    // Combined time and distance/average card
                    _WorkoutSummaryCard(
                      elapsedSeconds: widget.elapsedSeconds,
                      distanceMeters:
                          widget.routine.machineType == MachineType.treadmill
                              ? widget.distanceMeters
                              : null,
                      routine: widget.routine,
                      currentIntervalIndex: widget.currentIntervalIndex,
                      elapsedSecondsInCurrentSession:
                          widget.elapsedSecondsInCurrentSession,
                    ),
                    const SizedBox(height: 24),
                    // Date/time (secondary text)
                    Text(
                      _formatDateTime(context, widget.finishTime),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: theme.extension<AppColors>()!.mutedText,
                        letterSpacing: -0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(flex: 3),
                    // Primary button: End
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Check if user is premium - premium users don't see ads
                          final settingsProvider =
                              Provider.of<AppSettingsProvider>(context,
                                  listen: false);
                          final isPremium = settingsProvider.isPremium;

                          if (isPremium) {
                            // Premium user: navigate directly without ads
                            Navigator.of(context, rootNavigator: true)
                                .popUntil((route) => route.isFirst);
                            return;
                          }

                          // Show interstitial ad if available, then navigate home
                          final adService = AdService();
                          final navigatorContext =
                              Navigator.of(context, rootNavigator: true);
                          final wasAdShown = adService.showAd(
                            onAdClosed: () {
                              // Navigate back to AppShell (home route) after ad is closed
                              if (mounted) {
                                navigatorContext
                                    .popUntil((route) => route.isFirst);
                              }
                            },
                          );

                          // If ad wasn't shown, navigate immediately
                          if (!wasAdShown) {
                            navigatorContext.popUntil((route) => route.isFirst);
                          }
                        },
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
                          AppLocalizations.of(context)!.end,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Combined workout summary card (time + distance/average)
class _WorkoutSummaryCard extends StatelessWidget {
  final int elapsedSeconds;
  final double? distanceMeters;
  final Routine routine;
  final int currentIntervalIndex;
  final int elapsedSecondsInCurrentSession;

  const _WorkoutSummaryCard({
    required this.elapsedSeconds,
    this.distanceMeters,
    required this.routine,
    required this.currentIntervalIndex,
    required this.elapsedSecondsInCurrentSession,
  });

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatDistance(BuildContext context, double distanceMeters) {
    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);
    final isMetric = settingsProvider.measurement == 'kmh';

    if (isMetric) {
      // Metric: show meters (< 1000m) or km (>= 1000m)
      if (distanceMeters < 1000) {
        return '${distanceMeters.toStringAsFixed(0)} m';
      } else {
        final km = distanceMeters / 1000.0;
        return '${km.toStringAsFixed(2)} km';
      }
    } else {
      // Imperial: convert meters to miles
      const metersPerMile = 1609.344;
      final miles = distanceMeters / metersPerMile;

      if (miles < 0.1) {
        // Very small distances: show 3 decimals
        return '${miles.toStringAsFixed(3)} mi';
      } else {
        // Normal distances: show 2 decimals
        return '${miles.toStringAsFixed(2)} mi';
      }
    }
  }

  /// Calculate time-weighted average RPM for Bike workouts
  /// Returns null if no valid data or workout was stopped immediately
  double? _calculateAverageRpm() {
    if (routine.machineType != MachineType.cycle) return null;

    double totalWeightedRpm = 0.0;
    int totalActualSeconds = 0;

    // Process completed intervals (fully elapsed)
    for (int i = 0; i < currentIntervalIndex; i++) {
      final interval = routine.intervals[i];
      if (interval.rpm != null && interval.durationSeconds > 0) {
        totalWeightedRpm += interval.rpm! * interval.durationSeconds;
        totalActualSeconds += interval.durationSeconds;
      }
    }

    // Process current interval (partially elapsed if stopped mid-session)
    if (currentIntervalIndex < routine.intervals.length) {
      final currentInterval = routine.intervals[currentIntervalIndex];
      if (currentInterval.rpm != null && elapsedSecondsInCurrentSession > 0) {
        totalWeightedRpm +=
            currentInterval.rpm! * elapsedSecondsInCurrentSession;
        totalActualSeconds += elapsedSecondsInCurrentSession;
      }
    }

    if (totalActualSeconds == 0) return null;
    return totalWeightedRpm / totalActualSeconds;
  }

  /// Calculate time-weighted average Level for Stairmaster workouts
  /// Returns null if no valid data or workout was stopped immediately
  double? _calculateAverageLevel() {
    if (routine.machineType != MachineType.stairmaster) return null;

    double totalWeightedLevel = 0.0;
    int totalActualSeconds = 0;

    // Process completed intervals (fully elapsed)
    for (int i = 0; i < currentIntervalIndex; i++) {
      final interval = routine.intervals[i];
      if (interval.level != null && interval.durationSeconds > 0) {
        totalWeightedLevel += interval.level! * interval.durationSeconds;
        totalActualSeconds += interval.durationSeconds;
      }
    }

    // Process current interval (partially elapsed if stopped mid-session)
    if (currentIntervalIndex < routine.intervals.length) {
      final currentInterval = routine.intervals[currentIntervalIndex];
      if (currentInterval.level != null && elapsedSecondsInCurrentSession > 0) {
        totalWeightedLevel +=
            currentInterval.level! * elapsedSecondsInCurrentSession;
        totalActualSeconds += elapsedSecondsInCurrentSession;
      }
    }

    if (totalActualSeconds == 0) return null;
    return totalWeightedLevel / totalActualSeconds;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final appColors = theme.extension<AppColors>()!;

    // Card background color
    final cardColor = isDark
        ? const Color(0xFF1C1C1E) // Dark surface
        : const ui.Color.fromARGB(245, 245, 245, 245);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top: Total time label (small)
          Text(
            l10n.totalWorkoutTime,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: appColors.mutedText,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8), // Small gap: label -> big time
          // Center: Big time text
          BidiSafeText(
            _formatTime(elapsedSeconds),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              letterSpacing: -1.0,
              fontFeatures: const [
                ui.FontFeature.tabularFigures()
              ], // Monospaced digits
            ),
            forceLTR: true, // Timers must always be LTR
          ),
          // Below time: Total distance (Treadmill) or Average RPM/Level (Bike/Stairmaster)
          if (distanceMeters != null && distanceMeters! > 0) ...[
            const SizedBox(height: 16), // Medium gap: big time -> distance
            Text(
              '${(l10n as dynamic).totalDistance ?? 'Total distance'} ${_formatDistance(context, distanceMeters!)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: appColors.mutedText,
                letterSpacing: -0.2,
              ),
            ),
          ] else if (routine.machineType == MachineType.cycle) ...[
            // Bike: Show Average RPM
            Builder(
              builder: (context) {
                final avgRpm = _calculateAverageRpm();
                if (avgRpm == null) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      '${AppLocalizations.of(context)!.averageRpm}: ${avgRpm.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: appColors.mutedText,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                );
              },
            ),
          ] else if (routine.machineType == MachineType.stairmaster) ...[
            // Stairmaster: Show Average Level
            Builder(
              builder: (context) {
                final avgLevel = _calculateAverageLevel();
                if (avgLevel == null) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      '${AppLocalizations.of(context)!.averageLevel}: ${avgLevel.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: appColors.mutedText,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

// Simple confetti animation
class _ConfettiAnimation extends StatelessWidget {
  final AnimationController controller;

  const _ConfettiAnimation({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ConfettiPainter(progress: controller.value),
          size: MediaQuery.of(context).size,
        );
      },
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;

  _ConfettiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
    ];

    const particleCount = 30;
    final centerX = size.width / 2;
    final centerY = size.height / 3;

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * math.pi;
      final distance = progress * 200;
      final x = centerX + math.cos(angle) * distance;
      final y =
          centerY + math.sin(angle) * distance - (progress * progress * 300);

      paint.color = colors[i % colors.length].withValues(alpha: 1.0 - progress);
      canvas.drawCircle(Offset(x, y), 4 * (1.0 - progress), paint);
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
