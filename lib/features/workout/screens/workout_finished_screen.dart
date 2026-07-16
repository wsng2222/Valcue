import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;
import 'package:valcue/l10n/app_localizations.dart';
import '../../routines/models/routine.dart';
import '../../routines/models/machine_type.dart';
import '../../routines/models/interval.dart';
import '../../../widgets/bidi_safe_text.dart';
import '../../../widgets/bounceable.dart';
import '../../../theme/app_theme.dart';
import '../../../app_settings/app_settings_provider.dart';
import '../../../services/ad_service.dart';
import '../../../utils/debug_log.dart';
import '../../profile/models/workout_session.dart';
import '../../profile/providers/workout_history_provider.dart';

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

  const WorkoutFinishedScreen({
    super.key,
    required this.routine,
    required this.elapsedSeconds,
    this.elapsedMilliseconds,
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
      elapsedMilliseconds: widget.elapsedMilliseconds,
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

  Future<void> _shareWorkout(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final overlay = Overlay.of(context);
    final l10n = AppLocalizations.of(context)!;
    final cardKey = GlobalKey();
    late OverlayEntry entry;

    final machineTypeLabel = switch (widget.routine.machineType) {
      MachineType.treadmill => l10n.treadmill,
      MachineType.cycle => l10n.cycle,
      MachineType.stairmaster => l10n.stairmaster,
    };

    try {
      entry = OverlayEntry(
        builder: (_) => Positioned(
          left: -9999,
          top: -9999,
          child: RepaintBoundary(
            key: cardKey,
            child: _ShareCard(
              routine: widget.routine,
              elapsedSeconds: widget.elapsedSeconds,
              distanceMeters: widget.distanceMeters,
              finishTime: widget.finishTime,
              currentIntervalIndex: widget.currentIntervalIndex,
              elapsedSecondsInCurrentSession:
                  widget.elapsedSecondsInCurrentSession,
              machineTypeLabel: machineTypeLabel,
              totalTimeLabel: l10n.totalTime,
              distanceLabel: l10n.totalDistance,
              avgRpmLabel: l10n.averageRpm,
              avgLevelLabel: l10n.averageLevel,
            ),
          ),
        ),
      );

      overlay.insert(entry);
      // 한 프레임 기다려서 paint 완료
      await Future.delayed(const Duration(milliseconds: 200));

      final renderObject = cardKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        entry.remove();
        return;
      }

      final image = await renderObject.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      entry.remove();
      if (byteData == null) return;

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/workout_result.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      Rect? shareOrigin;
      final box =
          _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        shareOrigin = box.localToGlobal(Offset.zero) & box.size;
      }

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        sharePositionOrigin: shareOrigin,
      );
    } catch (e) {
      debugLog('[WorkoutFinishedScreen] Failed to share workout: $e');
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to share workout')),
      );
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
            // Confetti animation overlay
            _ConfettiAnimation(controller: _confettiController),
            // Main content
            FadeTransition(
              opacity: _fadeController,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
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
                    _WorkoutSummaryCard(
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
                    _WorkoutChart(
                      routine: widget.routine,
                      currentIntervalIndex: widget.currentIntervalIndex,
                      elapsedSecondsInCurrentSession:
                          widget.elapsedSecondsInCurrentSession,
                    ),
                    const Spacer(),
                    // Share button
                    SizedBox(
                      key: _shareButtonKey,
                      width: double.infinity,
                      child: Bounceable(
                        onTap: () => _shareWorkout(context),
                        child: IgnorePointer(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.share_outlined, size: 18),
                            label: Text(
                              AppLocalizations.of(context)!.share,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              side: BorderSide(
                                color: theme.colorScheme.outline
                                    .withValues(alpha: 0.38),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Primary button: End
                    SizedBox(
                      width: double.infinity,
                      child: Bounceable(
                        onTap: () {
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
                        child: IgnorePointer(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
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
  final DateTime finishTime;
  final Routine routine;
  final String machineTypeLabel;
  final int currentIntervalIndex;
  final int elapsedSecondsInCurrentSession;

  const _WorkoutSummaryCard({
    required this.elapsedSeconds,
    this.distanceMeters,
    required this.finishTime,
    required this.routine,
    required this.machineTypeLabel,
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
    final secondaryMetric = distanceMeters != null && distanceMeters! > 0
        ? _formatDistance(context, distanceMeters!)
        : routine.machineType == MachineType.cycle
            ? (() {
                final avgRpm = _calculateAverageRpm();
                return avgRpm == null
                    ? null
                    : '${avgRpm.toStringAsFixed(1)} RPM';
              })()
            : routine.machineType == MachineType.stairmaster
                ? (() {
                    final avgLevel = _calculateAverageLevel();
                    return avgLevel == null
                        ? null
                        : 'Level ${avgLevel.toStringAsFixed(1)}';
                  })()
                : null;
    final summaryParts =
        secondaryMetric != null ? <String>[secondaryMetric] : <String>[];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.totalWorkoutTime,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: appColors.mutedText,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          BidiSafeText(
            _formatTime(elapsedSeconds),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              letterSpacing: -1.4,
              fontFeatures: const [
                ui.FontFeature.tabularFigures()
              ], // Monospaced digits
            ),
            forceLTR: true, // Timers must always be LTR
          ),
          Text(
            summaryParts.join(' · '),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: appColors.mutedText,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${finishTime.year}.${finishTime.month.toString().padLeft(2, '0')}.${finishTime.day.toString().padLeft(2, '0')} · ${finishTime.hour.toString().padLeft(2, '0')}:${finishTime.minute.toString().padLeft(2, '0')}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: appColors.mutedText,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// Advanced physics-based confetti particle animation
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
    if (progress <= 0.0 || progress >= 1.0) return;

    final width = size.width;
    final height = size.height;

    final colors = [
      const Color(0xFFFF1744), // Vibrant Red
      const Color(0xFFFF9100), // Orange
      const Color(0xFFFFEA00), // Yellow
      const Color(0xFF00E676), // Green
      const Color(0xFF2979FF), // Blue
      const Color(0xFFD500F9), // Purple
      const Color(0xFF00E5FF), // Cyan
    ];

    const particleCount = 100;
    
    for (int i = 0; i < particleCount; i++) {
      // Use deterministic random based on particle index so we don't need real-time state updates
      final rand = math.Random(i + 100);

      // Emitter side: true = left bottom, false = right bottom
      final isLeft = i % 2 == 0;
      final startX = isLeft ? width * 0.10 : width * 0.90;
      final startY = height * 0.85;

      // Launch Angle: shoot upwards and towards the center
      // Left side shoots at -30 to -60 degrees, Right side shoots at -120 to -150 degrees
      final angleRange = rand.nextDouble() * (math.pi / 4); // 0 to 45 deg
      final baseAngle = isLeft ? -math.pi / 6 - angleRange : -5 * math.pi / 6 + angleRange;

      // Initial speed (pixels per second)
      final speed = 700 + rand.nextDouble() * 600;
      final vx = math.cos(baseAngle) * speed;
      final vy = math.sin(baseAngle) * speed;

      // Gravity (pixels per second squared)
      final gravity = 700 + rand.nextDouble() * 300;

      // Wind (sinusoidal horizontal drift)
      final windFreq = 2.0 + rand.nextDouble() * 3.0;
      final windAmp = 40.0 + rand.nextDouble() * 50.0;

      // Rotation settings
      final rotationSpeed = (rand.nextDouble() - 0.5) * 8.0;
      final rotationPhase = rand.nextDouble() * math.pi;

      // Size and scale settings
      final sizeScale = 8.0 + rand.nextDouble() * 10.0;
      final shapeType = rand.nextInt(3); // 0: rectangle, 1: circle, 2: triangle

      // Time (t goes from 0.0 to 3.0 seconds based on progress)
      final t = progress * 3.0;

      // Update positions using projectile physics with drag & wind
      final drag = math.exp(-0.25 * t);
      
      // Position equations
      final x = startX + (vx * t) * drag + math.sin(t * windFreq + rotationPhase) * windAmp * t;
      final y = startY + (vy * t) * drag + (0.5 * gravity * t * t);

      // Skip painting if off-screen below bottom
      if (y > height + 20) continue;

      // Fading opacity: stays solid, then fades out in the last 30% of progress
      final double opacity = progress < 0.7 ? 1.0 : (1.0 - (progress - 0.7) / 0.3).clamp(0.0, 1.0);
      if (opacity <= 0.0) continue;

      // Rotation angle
      final angle = rotationPhase + rotationSpeed * t;

      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      
      // 3D scaling simulation
      final scaleX = math.sin(t * 5.0 + rotationPhase).abs().clamp(0.1, 1.0);
      canvas.scale(scaleX, 1.0);

      // Draw different shapes
      switch (shapeType) {
        case 0: // Rectangle ribbon
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: sizeScale, height: sizeScale * 0.5),
            paint,
          );
          break;
        case 1: // Circle dot
          canvas.drawCircle(Offset.zero, sizeScale * 0.35, paint);
          break;
        case 2: // Triangle
          final path = Path();
          final r = sizeScale * 0.5;
          path.moveTo(0, -r);
          path.lineTo(r * 0.86, r * 0.5);
          path.lineTo(-r * 0.86, r * 0.5);
          path.close();
          canvas.drawPath(path, paint);
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _ShareCard extends StatelessWidget {
  final Routine routine;
  final int elapsedSeconds;
  final double? distanceMeters;
  final DateTime finishTime;
  final int currentIntervalIndex;
  final int elapsedSecondsInCurrentSession;
  final String machineTypeLabel;
  final String totalTimeLabel;
  final String distanceLabel;
  final String avgRpmLabel;
  final String avgLevelLabel;

  const _ShareCard({
    required this.routine,
    required this.elapsedSeconds,
    this.distanceMeters,
    required this.finishTime,
    required this.currentIntervalIndex,
    required this.elapsedSecondsInCurrentSession,
    required this.machineTypeLabel,
    required this.totalTimeLabel,
    required this.distanceLabel,
    required this.avgRpmLabel,
    required this.avgLevelLabel,
  });

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';
  }

  String _formatTimeOfDay(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDistance(BuildContext context, double rawDistanceMeters) {
    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);
    final isMetric = settingsProvider.measurement == 'kmh';

    if (isMetric) {
      if (rawDistanceMeters < 1000) {
        return '${rawDistanceMeters.toStringAsFixed(0)} m';
      }
      return '${(rawDistanceMeters / 1000).toStringAsFixed(2)} km';
    }

    const metersPerMile = 1609.344;
    final miles = rawDistanceMeters / metersPerMile;
    return miles < 0.1
        ? '${miles.toStringAsFixed(3)} mi'
        : '${miles.toStringAsFixed(2)} mi';
  }

  String? _secondaryMetricValue(BuildContext context) {
    if (routine.machineType == MachineType.treadmill) {
      final treadmillDistance = distanceMeters;
      if (treadmillDistance != null) {
        return _formatDistance(context, treadmillDistance);
      }
    }
    if (routine.machineType == MachineType.cycle) {
      final rpm = _avgRpm();
      return rpm?.round().toString();
    }
    if (routine.machineType == MachineType.stairmaster) {
      final level = _avgLevel();
      return level?.toStringAsFixed(1);
    }
    return null;
  }

  IconData _secondaryMetricIcon() {
    return switch (routine.machineType) {
      MachineType.treadmill => Icons.route_outlined,
      MachineType.cycle => Icons.speed_outlined,
      MachineType.stairmaster => Icons.stacked_line_chart_outlined,
    };
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color panelColor,
    required Color borderColor,
    required Color titleColor,
    required Color valueColor,
    bool emphasize = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: panelColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: titleColor),
            const SizedBox(height: 12),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: valueColor,
                fontSize: emphasize ? 24 : 20,
                fontWeight: FontWeight.w800,
                letterSpacing: emphasize ? -1.1 : -0.7,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: titleColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.1,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double? _avgRpm() {
    if (routine.machineType != MachineType.cycle) return null;
    double w = 0;
    int t = 0;
    for (int i = 0; i < currentIntervalIndex; i++) {
      final iv = routine.intervals[i];
      if (iv.rpm != null) {
        w += iv.rpm! * iv.durationSeconds;
        t += iv.durationSeconds;
      }
    }
    if (currentIntervalIndex < routine.intervals.length) {
      final iv = routine.intervals[currentIntervalIndex];
      if (iv.rpm != null && elapsedSecondsInCurrentSession > 0) {
        w += iv.rpm! * elapsedSecondsInCurrentSession;
        t += elapsedSecondsInCurrentSession;
      }
    }
    return t == 0 ? null : w / t;
  }

  double? _avgLevel() {
    if (routine.machineType != MachineType.stairmaster) return null;
    double w = 0;
    int t = 0;
    for (int i = 0; i < currentIntervalIndex; i++) {
      final iv = routine.intervals[i];
      if (iv.level != null) {
        w += iv.level! * iv.durationSeconds;
        t += iv.durationSeconds;
      }
    }
    if (currentIntervalIndex < routine.intervals.length) {
      final iv = routine.intervals[currentIntervalIndex];
      if (iv.level != null && elapsedSecondsInCurrentSession > 0) {
        w += iv.level! * elapsedSecondsInCurrentSession;
        t += elapsedSecondsInCurrentSession;
      }
    }
    return t == 0 ? null : w / t;
  }

  @override
  Widget build(BuildContext context) {
    const cardW = 360.0;
    const cardH = 560.0;
    const accent = Color(0xFFFF5A4F);
    const bg1 = Color(0xFF10111A);
    const bg2 = Color(0xFF1B1D2A);
    const stroke = Color(0x22FFFFFF);
    const panel = Color(0x12FFFFFF);
    const primaryText = Colors.white;
    const secondaryText = Color(0x99FFFFFF);
    const tertiaryText = Color(0x70FFFFFF);

    final l10n = AppLocalizations.of(context)!;
    final metricLabel = switch (routine.machineType) {
      MachineType.treadmill => distanceLabel,
      MachineType.cycle => avgRpmLabel,
      MachineType.stairmaster => avgLevelLabel,
    };
    final metricValue = _secondaryMetricValue(context);
    final routineTitle =
        routine.name.trim().isEmpty ? machineTypeLabel : routine.name;
    final dateStr = _formatDate(finishTime);
    final timeStr = _formatTimeOfDay(finishTime);

    return SizedBox(
      width: cardW,
      height: cardH,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bg1, bg2],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Text(
                      'Valcue',
                      style: TextStyle(
                        color: primaryText,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      color: secondaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                machineTypeLabel,
                style: const TextStyle(
                  color: accent,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                routineTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: secondaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                  decoration: BoxDecoration(
                    color: panel,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: stroke),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TIME',
                        style: TextStyle(
                          color: tertiaryText,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 110,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: BidiSafeText(
                            _formatTime(elapsedSeconds),
                            forceLTR: true,
                            style: const TextStyle(
                              color: primaryText,
                              fontSize: 92,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -5,
                              fontFeatures: [ui.FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        totalTimeLabel,
                        style: const TextStyle(
                          color: secondaryText,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildMetricCard(
                    icon: _secondaryMetricIcon(),
                    label: metricLabel,
                    value: metricValue ?? '-',
                    panelColor: panel,
                    borderColor: stroke,
                    titleColor: tertiaryText,
                    valueColor: primaryText,
                    emphasize: true,
                  ),
                  const SizedBox(width: 12),
                  _buildMetricCard(
                    icon: Icons.schedule_outlined,
                    label: l10n.workoutComplete,
                    value: timeStr,
                    panelColor: panel,
                    borderColor: stroke,
                    titleColor: tertiaryText,
                    valueColor: primaryText,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutChart extends StatefulWidget {
  final Routine routine;
  final int currentIntervalIndex;
  final int elapsedSecondsInCurrentSession;

  const _WorkoutChart({
    required this.routine,
    required this.currentIntervalIndex,
    required this.elapsedSecondsInCurrentSession,
  });

  @override
  State<_WorkoutChart> createState() => _WorkoutChartState();
}

class _WorkoutChartState extends State<_WorkoutChart> {
  int? _hoveredIntervalIndex;

  void _updateHoveredIndex(double localX, double totalWidth) {
    if (widget.routine.intervals.isEmpty || totalWidth <= 0) return;

    final totalDuration = widget.routine.intervals.fold<int>(0, (sum, i) => sum + i.durationSeconds);
    if (totalDuration == 0) return;

    final progressPercent = (localX / totalWidth).clamp(0.0, 1.0);
    final elapsedSeconds = (progressPercent * totalDuration).round();

    int calculatedIndex = 0;
    int accumulated = 0;
    for (int i = 0; i < widget.routine.intervals.length; i++) {
      accumulated += widget.routine.intervals[i].durationSeconds;
      if (elapsedSeconds <= accumulated) {
        calculatedIndex = i;
        break;
      }
    }

    if (_hoveredIntervalIndex != calculatedIndex) {
      setState(() {
        _hoveredIntervalIndex = calculatedIndex;
      });
      HapticFeedback.selectionClick();
    }
  }

  void _clearHoveredIndex() {
    if (_hoveredIntervalIndex != null) {
      setState(() {
        _hoveredIntervalIndex = null;
      });
    }
  }

  Widget _buildTooltip(Interval interval, double chartWidth, double chartHeight, int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final totalDuration = widget.routine.intervals.fold<int>(0, (sum, i) => sum + i.durationSeconds);
    if (totalDuration == 0) return const SizedBox.shrink();

    // Calculate center X of this interval
    int durationBefore = 0;
    for (int i = 0; i < index; i++) {
      durationBefore += widget.routine.intervals[i].durationSeconds;
    }
    final intervalDuration = interval.durationSeconds;
    final intervalCenterSeconds = durationBefore + (intervalDuration / 2);
    final pointX = (intervalCenterSeconds / totalDuration) * chartWidth;

    const tooltipWidth = 140.0;
    final leftPos = (pointX - tooltipWidth / 2).clamp(4.0, chartWidth - tooltipWidth - 4.0);

    // Format metrics based on machineType
    String metricText = '';
    switch (widget.routine.machineType) {
      case MachineType.treadmill:
        final speed = interval.speedKmh?.toStringAsFixed(1) ?? '0.0';
        final grade = interval.grade?.toStringAsFixed(1) ?? '0.0';
        metricText = '$speed km/h • $grade%';
        break;
      case MachineType.cycle:
        final rpm = interval.rpm?.toString() ?? '0';
        final res = interval.resistance?.toString() ?? '0';
        metricText = '$rpm RPM • Res $res';
        break;
      case MachineType.stairmaster:
        final lvl = interval.level?.toString() ?? '0';
        metricText = 'Lvl $lvl';
        break;
    }

    // Format session index (e.g. Session 3) and duration (e.g. 02:00)
    final locale = Localizations.localeOf(context).languageCode;
    final sessionWord = switch (locale) {
      'ko' => '세션',
      'es' => 'Sesión',
      'fr' => 'Session',
      'de' => 'Session',
      'ru' => 'Сессия',
      'pt' => 'Sessão',
      'ja' => 'セッション',
      'zh' => '阶段',
      'vi' => 'Phiên',
      'ar' => 'الجلسة',
      _ => 'Session',
    };
    final intervalTitle = '$sessionWord ${index + 1}';
    final durationFormatted = interval.durationFormatted;

    return Positioned(
      left: leftPos,
      top: -56, // Floating above the card
      child: Container(
        width: tooltipWidth,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              metricText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              '$intervalTitle ($durationFormatted)',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final appColors = theme.extension<AppColors>()!;

    if (widget.routine.intervals.isEmpty) return const SizedBox.shrink();

    // Map MachineType display names
    final machineName = switch (widget.routine.machineType) {
      MachineType.treadmill => l10n.treadmill,
      MachineType.cycle => l10n.cycle,
      MachineType.stairmaster => l10n.stairmaster,
    };

    return Container(
      height: 142,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : const Color.fromARGB(245, 245, 245, 245),
        borderRadius: BorderRadius.circular(24),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.routineTab,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: appColors.mutedText,
                  letterSpacing: -0.1,
                ),
              ),
              Text(
                machineName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final chartWidth = constraints.maxWidth;
                final chartHeight = constraints.maxHeight;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onHorizontalDragStart: (details) {
                        _updateHoveredIndex(details.localPosition.dx, chartWidth);
                      },
                      onHorizontalDragUpdate: (details) {
                        _updateHoveredIndex(details.localPosition.dx, chartWidth);
                      },
                      onHorizontalDragEnd: (details) {
                        _clearHoveredIndex();
                      },
                      onHorizontalDragCancel: () {
                        _clearHoveredIndex();
                      },
                      onTapDown: (details) {
                        _updateHoveredIndex(details.localPosition.dx, chartWidth);
                      },
                      onTapUp: (details) {
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) {
                            _clearHoveredIndex();
                          }
                        });
                      },
                      onTapCancel: () {
                        _clearHoveredIndex();
                      },
                      child: Container(
                        color: Colors.transparent, // Ensure gesture detector grabs touches
                        child: CustomPaint(
                          painter: _WorkoutChartPainter(
                            intervals: widget.routine.intervals,
                            currentIntervalIndex: widget.currentIntervalIndex,
                            elapsedSecondsInCurrentSession: widget.elapsedSecondsInCurrentSession,
                            primaryColor: theme.colorScheme.primary,
                            secondaryColor: theme.colorScheme.secondary,
                            isDark: isDark,
                            machineType: widget.routine.machineType,
                            hoveredIntervalIndex: _hoveredIntervalIndex,
                          ),
                          size: Size.infinite,
                        ),
                      ),
                    ),
                    if (_hoveredIntervalIndex != null && _hoveredIntervalIndex! < widget.routine.intervals.length)
                      _buildTooltip(
                        widget.routine.intervals[_hoveredIntervalIndex!],
                        chartWidth,
                        chartHeight,
                        _hoveredIntervalIndex!,
                      ),
                  ],
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutChartPainter extends CustomPainter {
  final List<Interval> intervals;
  final int currentIntervalIndex;
  final int elapsedSecondsInCurrentSession;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDark;
  final MachineType machineType;
  final int? hoveredIntervalIndex;

  _WorkoutChartPainter({
    required this.intervals,
    required this.currentIntervalIndex,
    required this.elapsedSecondsInCurrentSession,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDark,
    required this.machineType,
    this.hoveredIntervalIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (intervals.isEmpty) return;

    final width = size.width;
    final height = size.height;

    // Calculate total seconds and completed seconds
    final totalDuration = intervals.fold<int>(0, (sum, i) => sum + i.durationSeconds);
    if (totalDuration == 0) return;

    int completedSeconds = 0;
    for (int i = 0; i < currentIntervalIndex && i < intervals.length; i++) {
      completedSeconds += intervals[i].durationSeconds;
    }
    if (currentIntervalIndex < intervals.length) {
      completedSeconds += elapsedSecondsInCurrentSession;
    }
    completedSeconds = completedSeconds.clamp(0, totalDuration);

    final progressPercent = completedSeconds / totalDuration;
    final progressX = progressPercent * width;

    // Extract values
    final values = intervals.map((i) {
      switch (machineType) {
        case MachineType.treadmill:
          return i.speedKmh ?? 0.0;
        case MachineType.cycle:
          return (i.rpm ?? 0).toDouble();
        case MachineType.stairmaster:
          return (i.level ?? 0).toDouble();
      }
    }).toList();

    // Max/min limits
    double maxLimit = 10.0;
    double minLimit = 0.0;
    switch (machineType) {
      case MachineType.treadmill:
        maxLimit = 12.0;
        break;
      case MachineType.cycle:
        maxLimit = 100.0;
        break;
      case MachineType.stairmaster:
        maxLimit = 15.0;
        break;
    }

    double maxVal = maxLimit;
    double minVal = minLimit;
    for (final v in values) {
      if (v > maxVal) maxVal = v;
      if (v < minVal) minVal = v;
    }

    final valRange = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    // Grid Lines (Low/Medium/High boundaries)
    final gridPaint = Paint()
      ..color = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw horizontal dividers
    canvas.drawLine(Offset(0, height * 0.25), Offset(width, height * 0.25), gridPaint);
    canvas.drawLine(Offset(0, height * 0.65), Offset(width, height * 0.65), gridPaint);

    // Build the step paths
    final fillPath = Path();
    final strokePath = Path();

    fillPath.moveTo(0, height);

    double currentX = 0;
    double? lastY;

    for (int i = 0; i < intervals.length; i++) {
      final interval = intervals[i];
      final val = values[i];
      final duration = interval.durationSeconds;
      final stepWidth = (duration / totalDuration) * width;
      final y = height - ((val - minVal) / valRange) * height * 0.85 - 2;

      if (i == 0) {
        fillPath.lineTo(0, y);
        strokePath.moveTo(0, y);
      } else {
        if (lastY != null) {
          fillPath.lineTo(currentX, lastY);
          fillPath.lineTo(currentX, y);
          strokePath.lineTo(currentX, y);
        }
      }

      fillPath.lineTo(currentX + stepWidth, y);
      strokePath.lineTo(currentX + stepWidth, y);

      lastY = y;
      currentX += stepWidth;
    }

    fillPath.lineTo(width, height);
    fillPath.close();

    // Shader for completed (active colors) vs skipped (muted gray)
    final gradientColors = [
      primaryColor,
      secondaryColor,
      isDark ? const Color(0xFF333336) : const Color(0xFFD1D1D6),
      isDark ? const Color(0xFF242426) : const Color(0xFFE5E5EA),
    ];
    final gradientStops = [
      0.0,
      progressPercent,
      progressPercent + 0.005,
      1.0,
    ].map((e) => e.clamp(0.0, 1.0)).toList();

    // Handle corner cases where progress is 0% or 100%
    if (progressPercent <= 0.0) {
      gradientColors.removeRange(0, 2);
      gradientStops.clear();
      gradientStops.addAll([0.0, 1.0]);
    } else if (progressPercent >= 1.0) {
      gradientColors.removeRange(2, 4);
      gradientStops.clear();
      gradientStops.addAll([0.0, 1.0]);
    }

    final shader = ui.Gradient.linear(
      Offset.zero,
      Offset(width, 0),
      gradientColors,
      gradientStops,
    );

    // Paint Area Fill
    final fillPaint = Paint()
      ..shader = shader
      ..style = PaintingStyle.fill
      ..color = Colors.grey;
    
    final fillShader = ui.Gradient.linear(
      Offset.zero,
      Offset(width, 0),
      gradientColors.map((c) => c.withValues(alpha: 0.18)).toList(),
      gradientStops,
    );
    fillPaint.shader = fillShader;
    canvas.drawPath(fillPath, fillPaint);

    // Paint Stroke Line
    final strokePaint = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(strokePath, strokePaint);

    // Draw End Indicator vertical line
    if (hoveredIntervalIndex != null && hoveredIntervalIndex! < intervals.length) {
      // Calculate center X of this interval
      int durationBefore = 0;
      for (int i = 0; i < hoveredIntervalIndex!; i++) {
        durationBefore += intervals[i].durationSeconds;
      }
      final intervalDuration = intervals[hoveredIntervalIndex!].durationSeconds;
      final intervalCenterSeconds = durationBefore + (intervalDuration / 2);
      final hoveredX = (intervalCenterSeconds / totalDuration) * width;

      final val = values[hoveredIntervalIndex!];
      final hoveredY = height - ((val - minVal) / valRange) * height * 0.85 - 2;

      final verticalLinePaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;

      // Draw vertical dashed line
      double dashY = 0;
      const dashSpace = 4.0;
      while (dashY < height) {
        canvas.drawLine(Offset(hoveredX, dashY), Offset(hoveredX, dashY + dashSpace), verticalLinePaint);
        dashY += dashSpace * 2;
      }

      // Draw dot and shadow highlight like _WeightSparklinePainter
      final dotPaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.fill;
      final outerCirclePaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;
      final centerCirclePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(hoveredX, hoveredY), 8.0, outerCirclePaint);
      canvas.drawCircle(Offset(hoveredX, hoveredY), 4.5, dotPaint);
      canvas.drawCircle(Offset(hoveredX, hoveredY), 2.2, centerCirclePaint);
    } else if (progressPercent > 0.0 && progressPercent < 1.0) {
      final verticalLinePaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      
      // Draw vertical dashed line
      double dashY = 0;
      const dashSpace = 4.0;
      while (dashY < height) {
        canvas.drawLine(Offset(progressX, dashY), Offset(progressX, dashY + dashSpace), verticalLinePaint);
        dashY += dashSpace * 2;
      }

      // Find current interval y coordinate to draw dot
      double indicatorY = height;
      double indicatorXAcc = 0;
      for (int i = 0; i < intervals.length; i++) {
        final duration = intervals[i].durationSeconds;
        final stepWidth = (duration / totalDuration) * width;
        if (progressX >= indicatorXAcc && progressX <= indicatorXAcc + stepWidth) {
          final val = values[i];
          indicatorY = height - ((val - minVal) / valRange) * height * 0.85 - 2;
          break;
        }
        indicatorXAcc += stepWidth;
      }

      // Draw dot
      final dotPaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.fill;
      final shadowPaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill
        ..imageFilter = ui.ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0);
      
      canvas.drawCircle(Offset(progressX, indicatorY), 8, shadowPaint);
      canvas.drawCircle(Offset(progressX, indicatorY), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_WorkoutChartPainter oldDelegate) {
    return oldDelegate.currentIntervalIndex != currentIntervalIndex ||
        oldDelegate.elapsedSecondsInCurrentSession != elapsedSecondsInCurrentSession ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.isDark != isDark ||
        oldDelegate.hoveredIntervalIndex != hoveredIntervalIndex;
  }
}

