import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart' hide Interval;
import 'package:provider/provider.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'package:valcue/l10n/localized_format.dart';
import '../../routines/models/routine.dart';
import '../../routines/models/machine_type.dart';
import '../../routines/models/interval.dart';
import '../../../widgets/bidi_safe_text.dart';
import '../../../app_settings/app_settings_provider.dart';

class WorkoutShareCard extends StatelessWidget {
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
  final String? imagePath;
  final double cardW;
  final double cardH;

  const WorkoutShareCard({super.key, 
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
    this.imagePath,
    required this.cardW,
    required this.cardH,
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

  String _formatDate(BuildContext context, DateTime dateTime) {
    return LocalizedFormat.date(context, dateTime);
  }

  String _formatTimeOfDay(BuildContext context, DateTime dateTime) {
    return LocalizedFormat.time(context, dateTime);
  }

  String _formatDistance(BuildContext context, double rawDistanceMeters) {
    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);
    final isMetric = settingsProvider.measurement == 'kmh';

    if (isMetric) {
      if (rawDistanceMeters < 1000) {
        return '${LocalizedFormat.decimal(context, rawDistanceMeters, decimalDigits: 0)} m';
      }
      return '${LocalizedFormat.decimal(context, rawDistanceMeters / 1000, decimalDigits: 2)} km';
    }

    const metersPerMile = 1609.344;
    final miles = rawDistanceMeters / metersPerMile;
    return miles < 0.1
        ? '${LocalizedFormat.decimal(context, miles, decimalDigits: 3)} mi'
        : '${LocalizedFormat.decimal(context, miles, decimalDigits: 2)} mi';
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
      return level == null ? null : LocalizedFormat.decimal(context, level);
    }
    return null;
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
    final theme = Theme.of(context);
    final isSquare = cardH == cardW;

    final brandFontSize = isSquare ? 18.0 : 22.0;
    final dateFontSize = isSquare ? 10.0 : 12.0;
    final timeFontSize = isSquare ? 26.0 : 32.0;
    final labelFontSize = isSquare ? 9.0 : 10.0;
    final metricValFontSize = isSquare ? 16.0 : 20.0;
    final metricLabelFontSize = isSquare ? 9.0 : 10.0;
    final graphHeight = isSquare ? 30.0 : 44.0;
    final contentPadding = isSquare
        ? const EdgeInsets.symmetric(horizontal: 18, vertical: 18)
        : const EdgeInsets.symmetric(horizontal: 24, vertical: 26);
    final bottomSpacerHeight = isSquare ? 8.0 : 12.0;
    final graphSpacerHeight = isSquare ? 12.0 : 18.0;

    const textShadows = [
      Shadow(
        offset: Offset(0, 1.5),
        blurRadius: 4.0,
        color: Colors.black87,
      ),
      Shadow(
        offset: Offset(0, 3.0),
        blurRadius: 8.0,
        color: Colors.black54,
      ),
    ];

    final l10n = AppLocalizations.of(context)!;
    final metricLabel = switch (routine.machineType) {
      MachineType.treadmill => distanceLabel,
      MachineType.cycle => avgRpmLabel,
      MachineType.stairmaster => avgLevelLabel,
    };
    final metricValue = _secondaryMetricValue(context);
    final dateStr = _formatDate(context, finishTime);
    final timeStr = _formatTimeOfDay(context, finishTime);

    Widget backgroundWidget;
    if (imagePath != null && File(imagePath!).existsSync()) {
      backgroundWidget = Image.file(
        File(imagePath!),
        width: cardW,
        height: cardH,
        fit: BoxFit.cover,
      );
    } else {
      backgroundWidget = Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F1016), Color(0xFF1B1D2A)],
          ),
        ),
      );
    }

    return SizedBox(
      width: cardW,
      height: cardH,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: Stack(
          children: [
            Positioned.fill(child: backgroundWidget),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.55),
                    ],
                    stops: const [0.0, 0.25, 0.65, 1.0],
                  ),
                ),
              ),
            ),
            Padding(
              padding: contentPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/app_icon.png',
                            width: brandFontSize * 1.45,
                            height: brandFontSize * 1.45,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.directions_run,
                                color: theme.colorScheme.primary,
                                size: brandFontSize * 1.45,
                              );
                            },
                          ),
                          Transform.translate(
                            offset: Offset(isSquare ? -1.0 : -2.0, 0),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: brandFontSize,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.2,
                                  fontStyle: FontStyle.italic,
                                  fontFamily:
                                      theme.textTheme.titleMedium?.fontFamily,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Val',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  TextSpan(
                                    text: 'cue',
                                    style: TextStyle(
                                        color: theme.colorScheme.primary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$dateStr  $timeStr',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: dateFontSize,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BidiSafeText(
                        _formatTime(elapsedSeconds),
                        forceLTR: true,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: timeFontSize,
                          fontWeight: FontWeight.w900,
                          letterSpacing: isSquare ? -1.5 : -3.0,
                          height: 1.0,
                          fontFeatures: const [ui.FontFeature.tabularFigures()],
                          shadows: textShadows,
                        ),
                      ),
                      Text(
                        totalTimeLabel.toUpperCase(),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: labelFontSize,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          shadows: textShadows,
                        ),
                      ),
                      SizedBox(height: bottomSpacerHeight),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  metricValue ?? '-',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: metricValFontSize,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.8,
                                    height: 1.1,
                                    shadows: textShadows,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  metricLabel.toUpperCase(),
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontSize: metricLabelFontSize,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.4,
                                    shadows: textShadows,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  machineTypeLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: metricValFontSize,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.8,
                                    height: 1.1,
                                    shadows: textShadows,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.workout.toUpperCase(),
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontSize: metricLabelFontSize,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.4,
                                    shadows: textShadows,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: graphSpacerHeight),
                      if (routine.intervals.isNotEmpty) ...[
                        SizedBox(
                          width: double.infinity,
                          height: graphHeight,
                          child: CustomPaint(
                            painter: _ShareIntervalGraphPainter(
                              intervals: routine.intervals,
                              machineType: routine.machineType,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareIntervalGraphPainter extends CustomPainter {
  final List<Interval> intervals;
  final MachineType machineType;

  _ShareIntervalGraphPainter({
    required this.intervals,
    required this.machineType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (intervals.isEmpty) return;

    final totalDuration =
        intervals.fold<double>(0.0, (sum, i) => sum + i.durationSeconds);
    if (totalDuration <= 0) return;

    double maxVal = 1.0;
    for (final iv in intervals) {
      double val = 0;
      if (machineType == MachineType.treadmill) {
        val = iv.speedKmh ?? 0.0;
      } else if (machineType == MachineType.cycle) {
        val = (iv.rpm ?? 0).toDouble();
        if (val == 0) val = (iv.resistance ?? 0).toDouble();
      } else if (machineType == MachineType.stairmaster) {
        val = (iv.level ?? 0).toDouble();
      }
      if (val > maxVal) maxVal = val;
    }

    final path = Path();
    final fillPath = Path();

    double currentX = 0.0;
    fillPath.moveTo(0, size.height);

    for (int i = 0; i < intervals.length; i++) {
      final iv = intervals[i];
      double val = 0;
      if (machineType == MachineType.treadmill) {
        val = iv.speedKmh ?? 0.0;
      } else if (machineType == MachineType.cycle) {
        val = (iv.rpm ?? 0).toDouble();
        if (val == 0) val = (iv.resistance ?? 0).toDouble();
      } else if (machineType == MachineType.stairmaster) {
        val = (iv.level ?? 0).toDouble();
      }

      final segmentWidth = (iv.durationSeconds / totalDuration) * size.width;
      final y = size.height - (val / maxVal) * (size.height * 0.85);

      if (i == 0) {
        path.moveTo(0, y);
        fillPath.lineTo(0, y);
      } else {
        path.lineTo(currentX, y);
        fillPath.lineTo(currentX, y);
      }

      currentX += segmentWidth;
      path.lineTo(currentX, y);
      fillPath.lineTo(currentX, y);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _ShareIntervalGraphPainter oldDelegate) {
    return oldDelegate.intervals != intervals ||
        oldDelegate.machineType != machineType;
  }
}
