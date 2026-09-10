import '../models/routine.dart';
import '../../profile/storage/record_store.dart';

class RoutineStorage {
  /// Kept for one-time migration of routines saved by older versions.
  static const String legacyStorageKey = 'routines';
  static const String keyPrefix = 'routine:';

  /// Where deletions are noted. Kept outside [keyPrefix] so a note can never
  /// be scanned back in as a routine.
  static const String deletedKeyPrefix = 'deleted:routine:';

  final RecordStore<Routine> _records = RecordStore<Routine>(
    label: 'RoutineStorage',
    keyPrefix: keyPrefix,
    legacyListKey: legacyStorageKey,
    tombstonePrefix: deletedKeyPrefix,
    idOf: (routine) => routine.id,
    toJson: (routine) => routine.toJson(),
    fromJson: Routine.fromJson,
  );

  /// Oldest first, which is the order routines were created in and the order
  /// the list has always shown them in.
  Future<List<Routine>> loadRoutines() async {
    final routines = await _records.loadAll();
    routines.sort(_byCreationOrder);
    return routines;
  }

  Future<void> addRoutine(Routine routine) => _records.put(routine);

  /// Saving an existing id replaces just that routine.
  Future<void> updateRoutine(Routine routine) => _records.put(routine);

  Future<void> deleteRoutine(String id) => _records.remove(id);

  /// Routines deleted on this device, for backup to delete remotely too.
  Future<Map<String, int>> deletedRoutineIds() => _records.deletedIds();

  /// Called once a deletion has been applied to the backup.
  Future<void> forgetDeletedRoutine(String id) => _records.clearDeletion(id);

  /// Ids carry the creation time - either `<millis>` or `imported_<millis>` -
  /// so ordering by that number restores the original list order. Anything
  /// unparseable sorts last, by id, so the order is at least stable.
  static int _byCreationOrder(Routine a, Routine b) {
    final aTime = createdAtFromId(a.id);
    final bTime = createdAtFromId(b.id);
    if (aTime != null && bTime != null) return aTime.compareTo(bTime);
    if (aTime != null) return -1;
    if (bTime != null) return 1;
    return a.id.compareTo(b.id);
  }

  /// The creation timestamp encoded in a routine id, or null.
  static int? createdAtFromId(String id) {
    final digits = RegExp(r'(\d+)$').firstMatch(id)?.group(1);
    if (digits == null) return null;
    return int.tryParse(digits);
  }
}
