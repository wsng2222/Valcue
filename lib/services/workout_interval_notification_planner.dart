import 'package:intl/intl.dart';

import '../features/routines/models/machine_type.dart';
import '../features/routines/models/routine.dart';
import '../l10n/supported_app_language.dart';

class WorkoutNotificationLabels {
  const WorkoutNotificationLabels({
    required this.newInterval,
    required this.workoutComplete,
    required this.speed,
    required this.incline,
    required this.resistance,
    required this.level,
    required this.duration,
    this.inclineValueTemplate,
    this.rpmValueTemplate,
    this.resistanceValueTemplate,
    this.levelValueTemplate,
  });

  final String newInterval;
  final String workoutComplete;
  final String speed;
  final String incline;
  final String resistance;
  final String level;
  final String duration;
  final String? inclineValueTemplate;
  final String? rpmValueTemplate;
  final String? resistanceValueTemplate;
  final String? levelValueTemplate;
}

class PlannedWorkoutNotification {
  const PlannedWorkoutNotification({
    required this.delay,
    required this.title,
    required this.body,
    required this.intervalIndex,
  });

  final Duration delay;
  final String title;
  final String body;

  /// Zero-based interval index. Null identifies the workout-complete alert.
  final int? intervalIndex;
}

/// Pure planner for background workout notifications.
///
/// The caller supplies the first interval that has not started yet and its
/// wall-clock delay. The planner emits exactly one alert per new interval plus
/// a final completion alert; it intentionally emits no advance warnings.
class WorkoutIntervalNotificationPlanner {
  const WorkoutIntervalNotificationPlanner._();

  static List<PlannedWorkoutNotification> build({
    required Routine routine,
    required int firstIntervalIndex,
    required Duration delayUntilFirstInterval,
    required String measurement,
    required String languageCode,
    required WorkoutNotificationLabels labels,
  }) {
    if (routine.intervals.isEmpty) return const [];

    final normalizedFirstIndex = firstIntervalIndex.clamp(
      0,
      routine.intervals.length,
    );
    var delay = delayUntilFirstInterval.isNegative
        ? Duration.zero
        : delayUntilFirstInterval;
    final planned = <PlannedWorkoutNotification>[];

    for (var index = normalizedFirstIndex;
        index < routine.intervals.length;
        index++) {
      final interval = routine.intervals[index];
      planned.add(
        PlannedWorkoutNotification(
          delay: delay,
          title: '${labels.newInterval} · '
              '${_formatNumber(index + 1, languageCode)}/'
              '${_formatNumber(routine.intervals.length, languageCode)}',
          body: _buildIntervalBody(
            routine: routine,
            intervalIndex: index,
            measurement: measurement,
            languageCode: languageCode,
            labels: labels,
          ),
          intervalIndex: index,
        ),
      );
      delay += Duration(seconds: interval.durationSeconds);
    }

    planned.add(
      PlannedWorkoutNotification(
        delay: delay,
        title: labels.workoutComplete,
        body:
            '${routine.name} · ${formatDuration(routine.totalDurationSeconds, languageCode)}',
        intervalIndex: null,
      ),
    );
    return planned;
  }

  static String _buildIntervalBody({
    required Routine routine,
    required int intervalIndex,
    required String measurement,
    required String languageCode,
    required WorkoutNotificationLabels labels,
  }) {
    final interval = routine.intervals[intervalIndex];
    final parts = <String>[];

    switch (routine.machineType) {
      case MachineType.treadmill:
        final useMiles = measurement == 'mph';
        final speed = (interval.speedKmh ?? 0) * (useMiles ? 0.621371 : 1);
        parts.add(
          '${labels.speed} ${_formatNumber(speed, languageCode, decimalDigits: 1)} ${useMiles ? 'mph' : 'km/h'}',
        );
        parts.add(
          _metricPhrase(
            template: labels.inclineValueTemplate,
            fallbackLabel: labels.incline,
            value: _formatMetric(interval.grade ?? 0, languageCode),
            suffix: _percentSymbol(languageCode),
          ),
        );
        break;
      case MachineType.cycle:
        parts.add(
          _metricPhrase(
            template: labels.resistanceValueTemplate,
            fallbackLabel: labels.resistance,
            value: _formatNumber(
              interval.resistance ?? 0,
              languageCode,
            ),
          ),
        );
        parts.add(
          _metricPhrase(
            template: labels.rpmValueTemplate,
            fallbackLabel: '',
            value: _formatNumber(interval.rpm ?? 0, languageCode),
            suffix: ' RPM',
          ),
        );
        break;
      case MachineType.stairmaster:
        parts.add(
          _metricPhrase(
            template: labels.levelValueTemplate,
            fallbackLabel: labels.level,
            value: _formatNumber(interval.level ?? 0, languageCode),
          ),
        );
        break;
    }

    final duration = formatDuration(interval.durationSeconds, languageCode);
    parts.add(
      _durationPhrase(
        duration: duration,
        languageCode: languageCode,
        durationLabel: labels.duration,
      ),
    );
    return parts.join(' · ');
  }

  static String _formatMetric(double value, String languageCode) {
    return _formatNumber(
      value,
      languageCode,
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

  static String _percentSymbol(String languageCode) {
    final locale = _localeName(languageCode);
    return NumberFormat.percentPattern(locale).symbols.PERCENT;
  }

  static String _formatNumber(
    num value,
    String languageCode, {
    int decimalDigits = 0,
  }) {
    final formatter = NumberFormat.decimalPattern(_localeName(languageCode))
      ..minimumFractionDigits = decimalDigits
      ..maximumFractionDigits = decimalDigits;
    return formatter.format(value);
  }

  static String _localeName(String languageCode) {
    return SupportedAppLanguage.fromCode(
      _baseLanguage(languageCode),
    ).locale.toLanguageTag();
  }

  static String _durationPhrase({
    required String duration,
    required String languageCode,
    required String durationLabel,
  }) {
    switch (_baseLanguage(languageCode)) {
      case 'ko':
        return '$duration 동안';
      case 'en':
        return 'for $duration';
      case 'ja':
        return '$duration間';
      default:
        return '$durationLabel $duration';
    }
  }

  static String formatDuration(int totalSeconds, String languageCode) {
    final safeSeconds = totalSeconds < 0 ? 0 : totalSeconds;
    final hours = safeSeconds ~/ 3600;
    final minutes = (safeSeconds % 3600) ~/ 60;
    final seconds = safeSeconds % 60;
    final units =
        _durationUnits[_baseLanguage(languageCode)] ?? _durationUnits['en']!;
    final parts = <String>[];

    if (hours > 0) {
      parts.add('${_formatNumber(hours, languageCode)}${units.hour}');
    }
    if (minutes > 0) {
      parts.add('${_formatNumber(minutes, languageCode)}${units.minute}');
    }
    if (seconds > 0 || parts.isEmpty) {
      parts.add('${_formatNumber(seconds, languageCode)}${units.second}');
    }
    return parts.join(units.separator);
  }

  static String _baseLanguage(String languageCode) {
    return languageCode.toLowerCase().split(RegExp('[-_]')).first;
  }

  static const Map<String, _DurationUnits> _durationUnits = {
    'en': _DurationUnits(hour: ' hr', minute: ' min', second: ' sec'),
    'ko': _DurationUnits(hour: '시간', minute: '분', second: '초'),
    'ja': _DurationUnits(
      hour: '時間',
      minute: '分',
      second: '秒',
      separator: '',
    ),
    'zh': _DurationUnits(
      hour: '小时',
      minute: '分钟',
      second: '秒',
      separator: '',
    ),
    'es': _DurationUnits(hour: ' h', minute: ' min', second: ' s'),
    'fr': _DurationUnits(hour: ' h', minute: ' min', second: ' s'),
    'de': _DurationUnits(hour: ' Std.', minute: ' Min.', second: ' Sek.'),
    'it': _DurationUnits(hour: ' h', minute: ' min', second: ' s'),
    'pt': _DurationUnits(hour: ' h', minute: ' min', second: ' s'),
    'ru': _DurationUnits(hour: ' ч', minute: ' мин', second: ' с'),
    'ar': _DurationUnits(hour: ' س', minute: ' د', second: ' ث'),
    'vi': _DurationUnits(hour: ' giờ', minute: ' phút', second: ' giây'),
    'th': _DurationUnits(hour: ' ชม.', minute: ' นาที', second: ' วินาที'),
    'nl': _DurationUnits(hour: ' u', minute: ' min', second: ' sec'),
    'nb': _DurationUnits(hour: ' t', minute: ' min', second: ' sek'),
    'da': _DurationUnits(hour: ' t', minute: ' min', second: ' sek'),
  };
}

class _DurationUnits {
  const _DurationUnits({
    required this.hour,
    required this.minute,
    required this.second,
    this.separator = ' ',
  });

  final String hour;
  final String minute;
  final String second;
  final String separator;
}
