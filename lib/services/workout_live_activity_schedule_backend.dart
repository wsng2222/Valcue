import 'workout_live_activity_schedule_models.dart';

/// Provider boundary for a future HTTPS/Firebase/APNs scheduling backend.
///
/// Implementations must compare [scheduleRevision] atomically. A cancellation
/// is a tombstone, and lower revisions must never reactivate a session.
abstract interface class WorkoutLiveActivityScheduleBackend {
  Future<WorkoutLiveActivityScheduleAck> upsertSchedule(
    WorkoutLiveActivityScheduleRegistration registration,
  );

  Future<WorkoutLiveActivityScheduleAck> cancelSchedule(
    WorkoutLiveActivityScheduleCancellation cancellation,
  );
}

/// Safe default until a remote scheduling provider is configured. Returning an
/// unaccepted acknowledgement keeps local notifications as the active fallback
/// and allows a later foreground retry after a real backend is installed.
class NoopWorkoutLiveActivityScheduleBackend
    implements WorkoutLiveActivityScheduleBackend {
  const NoopWorkoutLiveActivityScheduleBackend();

  @override
  Future<WorkoutLiveActivityScheduleAck> upsertSchedule(
    WorkoutLiveActivityScheduleRegistration registration,
  ) async {
    return WorkoutLiveActivityScheduleAck.ignored(
      registration.scheduleRevision,
    );
  }

  @override
  Future<WorkoutLiveActivityScheduleAck> cancelSchedule(
    WorkoutLiveActivityScheduleCancellation cancellation,
  ) async {
    return WorkoutLiveActivityScheduleAck.ignored(
      cancellation.scheduleRevision,
    );
  }
}
