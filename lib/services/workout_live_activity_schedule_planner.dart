import '../features/routines/models/routine.dart';
import 'workout_live_activity_payload_builder.dart';
import 'workout_live_activity_schedule_models.dart';

typedef WorkoutLiveActivityIntervalTextFormatter = String Function(
  int intervalNumber,
  int totalIntervals,
);
typedef WorkoutLiveActivityDurationTextFormatter = String Function(
  int durationSeconds,
);

class WorkoutLiveActivityScheduleLabels {
  const WorkoutLiveActivityScheduleLabels({
    required this.machineName,
    required this.preparingStatusText,
    required this.runningStatusText,
    required this.finishedStatusText,
    required this.intervalText,
    required this.durationText,
    required this.speedLabel,
    required this.inclineLabel,
    required this.resistanceLabel,
    required this.levelLabel,
  });

  final String machineName;
  final String preparingStatusText;
  final String runningStatusText;
  final String finishedStatusText;
  final WorkoutLiveActivityIntervalTextFormatter intervalText;
  final WorkoutLiveActivityDurationTextFormatter durationText;
  final String speedLabel;
  final String inclineLabel;
  final String resistanceLabel;
  final String levelLabel;
}

class WorkoutLiveActivityScheduleSnapshot {
  const WorkoutLiveActivityScheduleSnapshot({
    required this.routine,
    required this.phase,
    required this.currentIntervalIndex,
    required this.currentIntervalRemaining,
    required this.totalRemaining,
    required this.countdownRemaining,
    required this.progress,
    required this.measurement,
    required this.capturedAt,
    required this.labels,
  });

  final Routine routine;
  final WorkoutLiveActivitySchedulePhase phase;
  final int currentIntervalIndex;
  final Duration currentIntervalRemaining;
  final Duration totalRemaining;
  final Duration countdownRemaining;
  final double progress;
  final String measurement;
  final DateTime capturedAt;
  final WorkoutLiveActivityScheduleLabels labels;
}

/// Builds every remaining interval boundary from one captured wall-clock
/// snapshot. It has no timers, platform channels, or provider dependencies.
class WorkoutLiveActivitySchedulePlanner {
  const WorkoutLiveActivitySchedulePlanner._();

  static WorkoutLiveActivitySchedulePlan build(
    WorkoutLiveActivityScheduleSnapshot snapshot,
  ) {
    final disposition = _dispositionFor(snapshot.phase);
    if (disposition != WorkoutLiveActivityScheduleDisposition.active) {
      return WorkoutLiveActivitySchedulePlan(
        generatedAt: snapshot.capturedAt,
        disposition: disposition,
        events: const <WorkoutLiveActivityScheduledEvent>[],
      );
    }

    final routine = snapshot.routine;
    if (routine.intervals.isEmpty) {
      throw ArgumentError.value(
        routine.intervals,
        'snapshot.routine.intervals',
        'An active Live Activity schedule requires at least one interval.',
      );
    }
    if (snapshot.currentIntervalIndex < 0 ||
        snapshot.currentIntervalIndex >= routine.intervals.length) {
      throw RangeError.range(
        snapshot.currentIntervalIndex,
        0,
        routine.intervals.length - 1,
        'snapshot.currentIntervalIndex',
      );
    }

    final events = <WorkoutLiveActivityScheduledEvent>[];
    var cursor = snapshot.capturedAt;
    var sequence = 0;

    final startsCurrentInterval = switch (snapshot.phase) {
      WorkoutLiveActivitySchedulePhase.initialCountdown ||
      WorkoutLiveActivitySchedulePhase.resumeCountdown =>
        true,
      WorkoutLiveActivitySchedulePhase.running ||
      WorkoutLiveActivitySchedulePhase.paused ||
      WorkoutLiveActivitySchedulePhase.finished ||
      WorkoutLiveActivitySchedulePhase.stopped =>
        false,
    };

    if (startsCurrentInterval) {
      cursor = cursor.add(_nonNegative(snapshot.countdownRemaining));
      final currentRemaining = _nonNegative(
        snapshot.currentIntervalRemaining,
      );
      final totalRemaining = _remainingFrom(
        routine,
        snapshot.currentIntervalIndex,
        currentRemaining,
      );
      events.add(
        _runningEvent(
          snapshot: snapshot,
          intervalIndex: snapshot.currentIntervalIndex,
          deliverAt: cursor,
          intervalRemaining: currentRemaining,
          totalRemaining: totalRemaining,
          sequence: sequence++,
        ),
      );
      cursor = cursor.add(currentRemaining);
    } else {
      cursor = cursor.add(
        _nonNegative(snapshot.currentIntervalRemaining),
      );
    }

    for (var index = snapshot.currentIntervalIndex + 1;
        index < routine.intervals.length;
        index++) {
      final intervalRemaining = Duration(
        seconds: routine.intervals[index].durationSeconds,
      );
      final totalRemaining = _remainingFrom(
        routine,
        index,
        intervalRemaining,
      );
      events.add(
        _runningEvent(
          snapshot: snapshot,
          intervalIndex: index,
          deliverAt: cursor,
          intervalRemaining: intervalRemaining,
          totalRemaining: totalRemaining,
          sequence: sequence++,
        ),
      );
      cursor = cursor.add(intervalRemaining);
    }

    events.add(
      _finishedEvent(
        snapshot: snapshot,
        deliverAt: cursor,
        sequence: sequence,
      ),
    );

    return WorkoutLiveActivitySchedulePlan(
      generatedAt: snapshot.capturedAt,
      disposition: WorkoutLiveActivityScheduleDisposition.active,
      events: events,
    );
  }

  static WorkoutLiveActivityScheduledEvent _runningEvent({
    required WorkoutLiveActivityScheduleSnapshot snapshot,
    required int intervalIndex,
    required DateTime deliverAt,
    required Duration intervalRemaining,
    required Duration totalRemaining,
    required int sequence,
  }) {
    final contentState = _payload(
      snapshot: snapshot,
      intervalIndex: intervalIndex,
      phase: WorkoutLiveActivityPhase.running,
      intervalRemaining: intervalRemaining,
      totalRemaining: totalRemaining,
      countdownRemaining: Duration.zero,
      progress: _progressFor(snapshot.routine, totalRemaining),
      at: deliverAt,
    );
    return WorkoutLiveActivityScheduledEvent(
      sequence: sequence,
      deliverAt: deliverAt,
      action: WorkoutLiveActivityScheduleEventAction.update,
      contentState: contentState,
      staleAt: deliverAt.add(intervalRemaining),
    );
  }

  static WorkoutLiveActivityScheduledEvent _finishedEvent({
    required WorkoutLiveActivityScheduleSnapshot snapshot,
    required DateTime deliverAt,
    required int sequence,
  }) {
    final lastIndex = snapshot.routine.intervals.length - 1;
    return WorkoutLiveActivityScheduledEvent(
      sequence: sequence,
      deliverAt: deliverAt,
      action: WorkoutLiveActivityScheduleEventAction.end,
      contentState: _payload(
        snapshot: snapshot,
        intervalIndex: lastIndex,
        phase: WorkoutLiveActivityPhase.finished,
        intervalRemaining: Duration.zero,
        totalRemaining: Duration.zero,
        countdownRemaining: Duration.zero,
        progress: 1,
        at: deliverAt,
      ),
      dismissalAt: deliverAt.add(const Duration(seconds: 60)),
    );
  }

  static Map<String, dynamic> _payload({
    required WorkoutLiveActivityScheduleSnapshot snapshot,
    required int intervalIndex,
    required WorkoutLiveActivityPhase phase,
    required Duration intervalRemaining,
    required Duration totalRemaining,
    required Duration countdownRemaining,
    required double progress,
    required DateTime at,
  }) {
    final routine = snapshot.routine;
    final labels = snapshot.labels;
    final interval = routine.intervals[intervalIndex];
    final statusText = switch (phase) {
      WorkoutLiveActivityPhase.preparing => labels.preparingStatusText,
      WorkoutLiveActivityPhase.running => labels.runningStatusText,
      WorkoutLiveActivityPhase.paused => labels.preparingStatusText,
      WorkoutLiveActivityPhase.finished => labels.finishedStatusText,
    };

    return WorkoutLiveActivityPayloadBuilder.build(
      routine: routine,
      intervalIndex: intervalIndex,
      phase: phase,
      intervalRemaining: intervalRemaining,
      totalRemaining: totalRemaining,
      countdownRemaining: countdownRemaining,
      progress: progress,
      measurement: snapshot.measurement,
      now: at,
      machineName: labels.machineName,
      statusText: statusText,
      intervalText: labels.intervalText(
        intervalIndex + 1,
        routine.intervals.length,
      ),
      durationText: labels.durationText(interval.durationSeconds),
      speedLabel: labels.speedLabel,
      inclineLabel: labels.inclineLabel,
      resistanceLabel: labels.resistanceLabel,
      levelLabel: labels.levelLabel,
    );
  }

  static Duration _remainingFrom(
    Routine routine,
    int intervalIndex,
    Duration firstRemaining,
  ) {
    var milliseconds = _nonNegative(firstRemaining).inMilliseconds;
    for (var index = intervalIndex + 1;
        index < routine.intervals.length;
        index++) {
      milliseconds += routine.intervals[index].durationSeconds * 1000;
    }
    return Duration(milliseconds: milliseconds);
  }

  static double _progressFor(Routine routine, Duration totalRemaining) {
    final totalMilliseconds = routine.totalDurationSeconds * 1000;
    if (totalMilliseconds <= 0) return 1;
    return (1 - totalRemaining.inMilliseconds / totalMilliseconds)
        .clamp(0.0, 1.0);
  }

  static Duration _nonNegative(Duration value) =>
      value.isNegative ? Duration.zero : value;

  static WorkoutLiveActivityScheduleDisposition _dispositionFor(
    WorkoutLiveActivitySchedulePhase phase,
  ) {
    return switch (phase) {
      WorkoutLiveActivitySchedulePhase.initialCountdown ||
      WorkoutLiveActivitySchedulePhase.running ||
      WorkoutLiveActivitySchedulePhase.resumeCountdown =>
        WorkoutLiveActivityScheduleDisposition.active,
      WorkoutLiveActivitySchedulePhase.paused =>
        WorkoutLiveActivityScheduleDisposition.paused,
      WorkoutLiveActivitySchedulePhase.finished =>
        WorkoutLiveActivityScheduleDisposition.finished,
      WorkoutLiveActivitySchedulePhase.stopped =>
        WorkoutLiveActivityScheduleDisposition.stopped,
    };
  }
}
