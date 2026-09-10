import 'package:shared_preferences/shared_preferences.dart';
import '../models/weight_entry.dart';
import '../../../utils/debug_log.dart';
import 'record_store.dart';

class WeightStorage {
  /// Kept for one-time migration of entries saved by older versions.
  static const String legacyStorageKey = 'weight_entries';
  static const String keyPrefix = 'weight_entry:';

  /// Where deletions are noted. Kept outside [keyPrefix] so a note
  /// can never be scanned back in as a record.
  static const String deletedKeyPrefix = 'deleted:weight_entry:';
  static const String _goalWeightKey = 'goal_weight_kg';

  final RecordStore<WeightEntry> _records = RecordStore<WeightEntry>(
    label: 'WeightStorage',
    keyPrefix: keyPrefix,
    legacyListKey: legacyStorageKey,
    tombstonePrefix: deletedKeyPrefix,
    idOf: (entry) => entry.id,
    toJson: (entry) => entry.toJson(),
    fromJson: WeightEntry.fromJson,
  );

  /// Newest first.
  Future<List<WeightEntry>> loadEntries() async {
    final entries = await _records.loadAll();
    entries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return entries;
  }

  Future<void> addEntry(WeightEntry entry) => _records.put(entry);

  Future<void> deleteEntry(String id) => _records.remove(id);

  /// Entries deleted on this device, for backup to delete remotely too.
  Future<Map<String, int>> deletedEntryIds() => _records.deletedIds();

  /// Called once a deletion has been applied to the backup.
  Future<void> forgetDeletedEntry(String id) => _records.clearDeletion(id);

  /// Replaces the entry stored under [id]. When the edit also changes the id,
  /// the old record is dropped so an edit never leaves a duplicate behind.
  Future<void> updateEntry(String id, WeightEntry updatedEntry) async {
    await _records.put(updatedEntry);
    if (updatedEntry.id != id) {
      await _records.remove(id);
    }
  }

  Future<double?> getGoalWeight() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_goalWeightKey);
    } catch (e) {
      debugLog('[WeightStorage] Failed to load goal weight: $e');
      return null;
    }
  }

  Future<void> setGoalWeight(double? weightKg) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (weightKg == null) {
        await prefs.remove(_goalWeightKey);
      } else {
        await prefs.setDouble(_goalWeightKey, weightKg);
      }
    } catch (e) {
      debugLog('[WeightStorage] Failed to save goal weight: $e');
    }
  }
}
