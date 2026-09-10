import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'package:valcue/l10n/localized_format.dart';
import '../../routines/models/routine.dart';
import '../../routines/models/machine_type.dart';
import '../../routines/models/interval.dart';
import '../../../theme/app_theme.dart';
import '../../../app_settings/app_settings_provider.dart';

class WorkoutChart extends StatefulWidget {
  final Routine routine;
  final int currentIntervalIndex;
  final int elapsedSecondsInCurrentSession;

  const WorkoutChart({super.key, 
    required this.routine,
    required this.currentIntervalIndex,
    required this.elapsedSecondsInCurrentSession,
  });

  @override
  State<WorkoutChart> createState() => _WorkoutChartState();
}

class _WorkoutChartState extends State<WorkoutChart> {
  int? _hoveredIntervalIndex;

  void _updateHoveredIndex(double localX, double totalWidth) {
    if (widget.routine.intervals.isEmpty || totalWidth <= 0) return;

    final totalDuration = widget.routine.intervals
        .fold<int>(0, (sum, i) => sum + i.durationSeconds);
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

  Widget _buildTooltip(
      Interval interval, double chartWidth, double chartHeight, int index) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final totalDuration = widget.routine.intervals
        .fold<int>(0, (sum, i) => sum + i.durationSeconds);
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
    final leftPos =
        (pointX - tooltipWidth / 2).clamp(4.0, chartWidth - tooltipWidth - 4.0);

    // Format metrics based on machineType
    String metricText = '';
    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);
    switch (widget.routine.machineType) {
      case MachineType.treadmill:
        final speed = settingsProvider.formatSpeed(interval.speedKmh ?? 0);
        final grade = LocalizedFormat.decimal(context, interval.grade ?? 0);
        metricText = '$speed • $grade%';
        break;
      case MachineType.cycle:
        final rpm = LocalizedFormat.decimal(
          context,
          interval.rpm ?? 0,
          decimalDigits: 0,
        );
        final res = LocalizedFormat.decimal(
          context,
          interval.resistance ?? 0,
          decimalDigits: 0,
        );
        metricText = '$rpm RPM • ${l10n.resistanceColon(res)}';
        break;
      case MachineType.stairmaster:
        final lvl = LocalizedFormat.decimal(
          context,
          interval.level ?? 0,
          decimalDigits: 0,
        );
        metricText = l10n.levelColon(lvl);
        break;
    }

    final intervalTitle = l10n.liveActivityIntervalFormat(
      LocalizedFormat.decimal(context, index + 1, decimalDigits: 0),
      LocalizedFormat.decimal(
        context,
        widget.routine.intervals.length,
        decimalDigits: 0,
      ),
    );
    final durationFormatted = interval.durationFormatted;

    return Positioned(
      left: leftPos,
      top: -56, // Floating above the card
      child: Container(
        width: tooltipWidth,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: context.appColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.grey.shade300,
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
        color: isDark
            ? const Color(0xFF1C1C1E)
            : const Color.fromARGB(245, 245, 245, 245),
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
              Flexible(
                child: Text(
                  l10n.routineTab,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: appColors.mutedText,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  machineName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
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
                      color: Colors
                          .transparent, // Ensure gesture detector grabs touches
                      child: CustomPaint(
                        painter: _WorkoutChartPainter(
                          intervals: widget.routine.intervals,
                          currentIntervalIndex: widget.currentIntervalIndex,
                          elapsedSecondsInCurrentSession:
                              widget.elapsedSecondsInCurrentSession,
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
                  if (_hoveredIntervalIndex != null &&
                      _hoveredIntervalIndex! < widget.routine.intervals.length)
                    _buildTooltip(
                      widget.routine.intervals[_hoveredIntervalIndex!],
                      chartWidth,
                      chartHeight,
                      _hoveredIntervalIndex!,
                    ),
                ],
              );
            }),
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
    final totalDuration =
        intervals.fold<int>(0, (sum, i) => sum + i.durationSeconds);
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
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw horizontal dividers
    canvas.drawLine(
        Offset(0, height * 0.25), Offset(width, height * 0.25), gridPaint);
    canvas.drawLine(
        Offset(0, height * 0.65), Offset(width, height * 0.65), gridPaint);

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
    if (hoveredIntervalIndex != null &&
        hoveredIntervalIndex! < intervals.length) {
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
        canvas.drawLine(Offset(hoveredX, dashY),
            Offset(hoveredX, dashY + dashSpace), verticalLinePaint);
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
        canvas.drawLine(Offset(progressX, dashY),
            Offset(progressX, dashY + dashSpace), verticalLinePaint);
        dashY += dashSpace * 2;
      }

      // Find current interval y coordinate to draw dot
      double indicatorY = height;
      double indicatorXAcc = 0;
      for (int i = 0; i < intervals.length; i++) {
        final duration = intervals[i].durationSeconds;
        final stepWidth = (duration / totalDuration) * width;
        if (progressX >= indicatorXAcc &&
            progressX <= indicatorXAcc + stepWidth) {
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
        oldDelegate.elapsedSecondsInCurrentSession !=
            elapsedSecondsInCurrentSession ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.isDark != isDark ||
        oldDelegate.hoveredIntervalIndex != hoveredIntervalIndex;
  }
}
