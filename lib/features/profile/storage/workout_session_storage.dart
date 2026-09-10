import '../models/workout_session.dart';
import '../../routines/models/machine_type.dart';
import 'record_store.dart';

class WorkoutSessionStorage {
  /// Kept for one-time migration of history saved by older versions.
  static const String legacyStorageKey = 'workout_sessions';
  static const String keyPrefix = 'workout_session:';

  /// Where deletions are noted. Kept outside [keyPrefix] so a note
  /// can never be scanned back in as a record.
  static const String deletedKeyPrefix = 'deleted:workout_session:';

  final RecordStore<WorkoutSession> _records = RecordStore<WorkoutSession>(
    label: 'WorkoutSessionStorage',
    keyPrefix: keyPrefix,
    legacyListKey: legacyStorageKey,
    tombstonePrefix: deletedKeyPrefix,
    idOf: (session) => session.id,
    toJson: (session) => session.toJson(),
    fromJson: WorkoutSession.fromJson,
  );

  /// Newest first.
  Future<List<WorkoutSession>> loadSessions() async {
    final sessions = await _records.loadAll();
    sessions.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return sessions;
  }

  Future<void> addSession(WorkoutSession session) => _records.put(session);

  Future<void> deleteSession(String id) => _records.remove(id);

  /// Sessions deleted on this device, for backup to delete remotely too.
  Future<Map<String, int>> deletedSessionIds() => _records.deletedIds();

  /// Called once a deletion has been applied to the backup.
  Future<void> forgetDeletedSession(String id) => _records.clearDeletion(id);

  Future<List<WorkoutSession>> getSessionsByMachineType(
      MachineType machineType) async {
    final sessions = await loadSessions();
    return sessions.where((s) => s.machineType == machineType).toList();
  }

  Future<List<WorkoutSession>> getSessionsByDateRange(
      DateTime start, DateTime end) async {
    final sessions = await loadSessions();
    return sessions.where((s) {
      return s.dateTime.isAfter(start.subtract(const Duration(days: 1))) &&
          s.dateTime.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }
}
