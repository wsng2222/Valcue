import 'package:intl/intl.dart';

import '../features/routines/models/machine_type.dart';
import '../features/routines/models/routine.dart';

enum WorkoutLiveActivityPhase {
  preparing,
  running,
  paused,
  finished,
}

/// Builds the small, platform-channel-safe state shared with ActivityKit.
///
/// The widget extension receives display-ready localized strings so it never
/// needs to duplicate Flutter's locale, unit, or machine formatting rules.
class WorkoutLiveActivityPayloadBuilder {
  const WorkoutLiveActivityPayloadBuilder._();

  static Map<String, dynamic> build({
    required Routine routine,
    required int intervalIndex,
    required WorkoutLiveActivityPhase phase,
    required Duration intervalRemaining,
    required Duration totalRemaining,
    required Duration countdownRemaining,
    required double progress,
    required String measurement,
    required DateTime now,
    required String machineName,
    required String statusText,
    required String intervalText,
    required String durationText,
    required String speedLabel,
    required String inclineLabel,
    required String resistanceLabel,
    required String levelLabel,
    String? inclineValueTemplate,
    String? rpmValueTemplate,
    String? resistanceValueTemplate,
    String? levelValueTemplate,
    String locale = 'en_US',
  }) {
    if (routine.intervals.isEmpty) {
      throw ArgumentError.value(
        routine.intervals,
        'routine.intervals',
        'A Live Activity requires at least one interval.',
      );
    }

    final safeIndex = intervalIndex.clamp(0, routine.intervals.length - 1);
    final interval = routine.intervals[safeIndex];
    final metrics = _metrics(
      routine: routine,
      intervalIndex: safeIndex,
      measurement: measurement,
      speedLabel: speedLabel,
      inclineLabel: inclineLabel,
      resistanceLabel: resistanceLabel,
      levelLabel: levelLabel,
      inclineValueTemplate: inclineValueTemplate,
      rpmValueTemplate: rpmValueTemplate,
      resistanceValueTemplate: resistanceValueTemplate,
      levelValueTemplate: levelValueTemplate,
      locale: locale,
    );
    final activeTimerRemaining = switch (phase) {
      WorkoutLiveActivityPhase.preparing => countdownRemaining,
      WorkoutLiveActivityPhase.running => intervalRemaining,
      WorkoutLiveActivityPhase.paused ||
      WorkoutLiveActivityPhase.finished =>
        Duration.zero,
    };
    final extraBeforeWorkoutContinues =
        phase == WorkoutLiveActivityPhase.preparing
            ? countdownRemaining
            : Duration.zero;
    final workoutRemaining = totalRemaining + extraBeforeWorkoutContinues;

    return <String, dynamic>{
      'routineId': routine.id,
      'routineName': routine.name,
      'machineType': routine.machineType.toJson(),
      'machineName': machineName,
      'machineSymbol': _machineSymbol(routine.machineType),
      'status': phase.name,
      'statusText': statusText,
      'intervalIndex': safeIndex + 1,
      'totalIntervals': routine.intervals.length,
      'intervalText': intervalText,
      'primaryMetric': metrics.$1,
      'secondaryMetric': metrics.$2,
      'durationText': durationText,
      'intervalDurationSeconds': interval.durationSeconds,
      'timerStartAtMs': now.millisecondsSinceEpoch,
      'timerEndAtMs': activeTimerRemaining > Duration.zero
          ? now.add(activeTimerRemaining).millisecondsSinceEpoch
          : 0,
      'workoutEndAtMs': phase == WorkoutLiveActivityPhase.paused ||
              phase == WorkoutLiveActivityPhase.finished
          ? 0
          : now.add(workoutRemaining).millisecondsSinceEpoch,
      'pausedRemainingSeconds': _ceilSeconds(intervalRemaining),
      'totalRemainingSeconds': _ceilSeconds(totalRemaining),
      'progress': progress.clamp(0.0, 1.0),
    };
  }

  static (String, String) _metrics({
    required Routine routine,
    required int intervalIndex,
    required String measurement,
    required String speedLabel,
    required String inclineLabel,
    required String resistanceLabel,
    required String levelLabel,
    required String? inclineValueTemplate,
    required String? rpmValueTemplate,
    required String? resistanceValueTemplate,
    required String? levelValueTemplate,
    required String locale,
  }) {
    final interval = routine.intervals[intervalIndex];
    switch (routine.machineType) {
      case MachineType.treadmill:
        final useMiles = measurement == 'mph';
        final speed = (interval.speedKmh ?? 0) * (useMiles ? 0.621371 : 1);
        return (
          '$speedLabel ${_formatNumber(speed, locale, decimalDigits: 1)} ${useMiles ? 'mph' : 'km/h'}',
          _metricPhrase(
            template: inclineValueTemplate,
            fallbackLabel: inclineLabel,
            value: _formatMetric(interval.grade ?? 0, locale),
            suffix: NumberFormat.percentPattern(locale).symbols.PERCENT,
          ),
        );
      case MachineType.cycle:
        return (
          _metricPhrase(
            template: resistanceValueTemplate,
            fallbackLabel: resistanceLabel,
            value: _formatNumber(interval.resistance ?? 0, locale),
          ),
          _metricPhrase(
            template: rpmValueTemplate,
            fallbackLabel: '',
            value: _formatNumber(interval.rpm ?? 0, locale),
            suffix: ' RPM',
          ),
        );
      case MachineType.stairmaster:
        return (
          _metricPhrase(
            template: levelValueTemplate,
            fallbackLabel: levelLabel,
            value: _formatNumber(interval.level ?? 0, locale),
          ),
          '',
        );
    }
  }

  static String _machineSymbol(MachineType machineType) {
    switch (machineType) {
      case MachineType.treadmill:
        return 'figure.run';
      case MachineType.cycle:
        return 'bicycle';
      case MachineType.stairmaster:
        return 'figure.stair.stepper';
    }
  }

  static String _formatMetric(double value, String locale) {
    return _formatNumber(
      value,
      locale,
      decimalDigits: value == value.roundToDouble() ? 0 : 1,
    );
  }

  static String _metricPhrase({
    required String? template,
    required String fallbackLabel,
    required String value,
    String suffix = '',
  }) {
    if (template != null) return template.replaceAll('{value}', value);
    final metric = [fallbackLabel, value]
        .where((part) => part.isNotEmpty)
        .join(' ');
    return '$metric$suffix';
  }

  static String _formatNumber(
    num value,
    String locale, {
    int decimalDigits = 0,
  }) {
    final formatter = NumberFormat.decimalPattern(locale)
      ..minimumFractionDigits = decimalDigits
      ..maximumFractionDigits = decimalDigits;
    return formatter.format(value);
  }

  static int _ceilSeconds(Duration duration) {
    if (duration <= Duration.zero) return 0;
    return (duration.inMilliseconds / Duration.millisecondsPerSecond).ceil();
  }
}
