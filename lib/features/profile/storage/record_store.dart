import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/debug_log.dart';

/// Keeps a collection of records as one SharedPreferences key per record.
///
/// The app used to hold every workout or weight entry inside a single JSON
/// string, so saving one record meant reading, re-encoding and rewriting all
/// of them. That grew with history length, and two overlapping edits could
/// silently drop a record: both read the old list, and the slower write won.
///
/// Here each record owns its own key, so [put] and [remove] touch exactly one
/// record and cannot clobber another. Data written by the old format is
/// migrated on the first read.
class RecordStore<T> {
  RecordStore({
    required this.label,
    required this.keyPrefix,
    required this.legacyListKey,
    required this.idOf,
    required this.toJson,
    required this.fromJson,
    String? tombstonePrefix,
  })  :
        // Must not start with keyPrefix, or the record scan would read
        // tombstones back as records.
        assert(
          tombstonePrefix == null || !tombstonePrefix.startsWith(keyPrefix),
          'A tombstone prefix inside keyPrefix would be scanned as a record',
        ),
        tombstonePrefix = tombstonePrefix ?? 'deleted:$keyPrefix';

  /// Name used in debug logs.
  final String label;

  /// Every record key starts with this.
  final String keyPrefix;

  /// Where deletions are noted. Deliberately not a [keyPrefix] key, so a
  /// tombstone can never be read back as a record.
  final String tombstonePrefix;

  /// The old single-blob key, read once and then deleted.
  final String legacyListKey;

  final String Function(T record) idOf;
  final Map<String, dynamic> Function(T record) toJson;
  final T Function(Map<String, dynamic> json) fromJson;

  String _keyFor(String id) => '$keyPrefix$id';
  String _tombstoneKeyFor(String id) => '$tombstonePrefix$id';

  /// Every stored record. Malformed records are skipped rather than failing
  /// the whole read, so one bad entry can never hide a person's history.
  Future<List<T>> loadAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _migrateLegacyList(prefs);

      final records = <T>[];
      for (final key in prefs.getKeys()) {
        if (!key.startsWith(keyPrefix)) continue;
        // Read per key: a value of the wrong type throws, and letting that
        // escape would return an empty history for one bad entry.
        String? raw;
        try {
          raw = prefs.getString(key);
        } catch (e) {
          debugLog('[$label] Skipping unreadable key $key: $e');
          continue;
        }
        final record = _decode(raw);
        if (record != null) records.add(record);
      }
      return records;
    } catch (e) {
      debugLog('[$label] Failed to load records: $e');
      return <T>[];
    }
  }

  /// Writes one record, leaving every other record untouched. Also used for
  /// updates - a record with an existing id replaces just that entry.
  ///
  /// Writing an id clears any deletion noted for it: a deliberate write is a
  /// later decision than the delete it replaces.
  Future<void> put(T record) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _migrateLegacyList(prefs);
      final id = idOf(record);
      await prefs.setString(_keyFor(id), jsonEncode(toJson(record)));
      await prefs.remove(_tombstoneKeyFor(id));
    } catch (e) {
      debugLog('[$label] Failed to save record: $e');
    }
  }

  /// Deletes one record and notes that it was deleted.
  ///
  /// The note is what stops a backup from handing the record straight back on
  /// the next sync. Deleting something already gone is not an error.
  Future<void> remove(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _migrateLegacyList(prefs);
      await prefs.remove(_keyFor(id));
      await prefs.setInt(
        _tombstoneKeyFor(id),
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugLog('[$label] Failed to delete record: $e');
    }
  }

  /// Ids deleted on this device, mapped to when. Backup uses these to delete
  /// the same records remotely, and to ignore them when pulling.
  Future<Map<String, int>> deletedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deleted = <String, int>{};
      for (final key in prefs.getKeys()) {
        if (!key.startsWith(tombstonePrefix)) continue;
        final id = key.substring(tombstonePrefix.length);
        if (id.isEmpty) continue;
        deleted[id] = prefs.getInt(key) ?? 0;
      }
      return deleted;
    } catch (e) {
      debugLog('[$label] Failed to read deletions: $e');
      return <String, int>{};
    }
  }

  /// Forgets a deletion, once it has been applied to the backup.
  Future<void> clearDeletion(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tombstoneKeyFor(id));
    } catch (e) {
      debugLog('[$label] Failed to clear a deletion: $e');
    }
  }

  T? _decode(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map) {
        debugLog('[$label] Skipping malformed record payload');
        return null;
      }
      return fromJson(Map<String, dynamic>.from(decoded));
    } catch (e) {
      debugLog('[$label] Failed to parse record: $e');
      return null;
    }
  }

  /// Rewrites the old single-blob value as individual records.
  ///
  /// Records are written before the old key is dropped, so an interrupted
  /// migration just runs again on the next launch and lands on the same keys.
  Future<void> _migrateLegacyList(SharedPreferences prefs) async {
    final jsonString = prefs.getString(legacyListKey);
    if (jsonString == null) return;

    try {
      if (jsonString.isNotEmpty) {
        final decoded = jsonDecode(jsonString);
        if (decoded is List) {
          for (final item in decoded) {
            if (item is! Map) {
              debugLog('[$label] Skipping malformed legacy entry');
              continue;
            }
            try {
              final record = fromJson(Map<String, dynamic>.from(item));
              await prefs.setString(
                _keyFor(idOf(record)),
                jsonEncode(toJson(record)),
              );
            } catch (e) {
              debugLog('[$label] Failed to migrate legacy entry: $e');
            }
          }
        } else {
          debugLog('[$label] Expected a list payload in legacy storage');
        }
      }
      await prefs.remove(legacyListKey);
    } catch (e) {
      // Leave the old value in place so the next launch can retry it.
      debugLog('[$label] Failed to migrate legacy storage: $e');
    }
  }
}
