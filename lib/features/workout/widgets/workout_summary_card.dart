import 'dart:ui' as ui;
import 'package:flutter/material.dart' hide Interval;
import 'package:provider/provider.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'package:valcue/l10n/localized_format.dart';
import '../../routines/models/routine.dart';
import '../../routines/models/machine_type.dart';
import '../../../widgets/bidi_safe_text.dart';
import '../../../theme/app_theme.dart';
import '../../../app_settings/app_settings_provider.dart';

class WorkoutSummaryCard extends StatelessWidget {
  final int elapsedSeconds;
  final double? distanceMeters;
  final DateTime finishTime;
  final Routine routine;
  final String machineTypeLabel;
  final int currentIntervalIndex;
  final int elapsedSecondsInCurrentSession;

  const WorkoutSummaryCard({super.key, 
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
        return '${LocalizedFormat.decimal(context, distanceMeters, decimalDigits: 0)} m';
      } else {
        final km = distanceMeters / 1000.0;
        return '${LocalizedFormat.decimal(context, km, decimalDigits: 2)} km';
      }
    } else {
      // Imperial: convert meters to miles
      const metersPerMile = 1609.344;
      final miles = distanceMeters / metersPerMile;

      if (miles < 0.1) {
        // Very small distances: show 3 decimals
        return '${LocalizedFormat.decimal(context, miles, decimalDigits: 3)} mi';
      } else {
        // Normal distances: show 2 decimals
        return '${LocalizedFormat.decimal(context, miles, decimalDigits: 2)} mi';
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
                    : '${LocalizedFormat.decimal(context, avgRpm)} RPM';
              })()
            : routine.machineType == MachineType.stairmaster
                ? (() {
                    final avgLevel = _calculateAverageLevel();
                    return avgLevel == null
                        ? null
                        : l10n.levelColon(
                            LocalizedFormat.decimal(context, avgLevel),
                          );
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
            LocalizedFormat.dateTime(context, finishTime),
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
