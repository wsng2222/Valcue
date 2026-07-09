import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/routine.dart';
import '../../../utils/debug_log.dart';

class RoutineStorage {
  static const String _storageKey = 'routines';
  static bool diagnosticsEnabled = false;

  /// Drift Guard: Compute JSON snapshot of intervals
  /// Returns a normalized JSON string for comparison
  static String _computeIntervalJsonSnapshot(List<Routine> routines) {
    final intervalsOnly = routines.expand((r) => r.intervals).map((interval) {
      // Extract stored values
      final json = <String, dynamic>{
        'durationSeconds': interval.durationSeconds,
      };
      if (interval.speedKmh != null) json['speedKmh'] = interval.speedKmh;
      if (interval.grade != null) json['grade'] = interval.grade;
      if (interval.rpm != null) json['rpm'] = interval.rpm;
      if (interval.resistance != null) json['resistance'] = interval.resistance;
      if (interval.level != null) json['level'] = interval.level;
      return json;
    }).toList();
    return json.encode(intervalsOnly);
  }

  /// Deep equality check for JSON (ignoring order)
  static bool _jsonDeepEquals(String json1, String json2) {
    try {
      final obj1 = json.decode(json1);
      final obj2 = json.decode(json2);
      return json.encode(obj1) == json.encode(obj2);
    } catch (e) {
      return false;
    }
  }

  /// Test function: encode -> decode -> encode and verify equality
  static Future<bool> testIdempotency() async {
    try {
      final routines = await RoutineStorage().loadRoutines();
      if (routines.isEmpty) {
        return true;
      }

      // Compute snapshot before save
      final beforeSnapshot = _computeIntervalJsonSnapshot(routines);

      // Save and reload
      await RoutineStorage().saveRoutines(routines);
      final reloadedRoutines = await RoutineStorage().loadRoutines();

      // Compute snapshot after reload
      final afterSnapshot = _computeIntervalJsonSnapshot(reloadedRoutines);

      // Compare
      final isEqual = _jsonDeepEquals(beforeSnapshot, afterSnapshot);

      if (!isEqual) {
      } else {}

      return isEqual;
    } catch (e) {
      return false;
    }
  }

  Future<List<Routine>> loadRoutines() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      final decoded = json.decode(jsonString);
      if (decoded is! List) {
        debugLog('[RoutineStorage] Expected a list payload');
        return [];
      }

      final routines = <Routine>[];
      for (final item in decoded) {
        if (item is! Map) {
          debugLog('[RoutineStorage] Skipping malformed routine entry');
          continue;
        }

        try {
          routines.add(Routine.fromJson(Map<String, dynamic>.from(item)));
        } catch (e) {
          debugLog('[RoutineStorage] Failed to parse routine entry: $e');
        }
      }

      return routines;
    } catch (e) {
      debugLog('[RoutineStorage] Failed to load routines: $e');
      return [];
    }
  }

  Future<void> saveRoutines(List<Routine> routines) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = routines.map((r) => r.toJson()).toList();
    final jsonString = json.encode(jsonList);

    if (kDebugMode && diagnosticsEnabled) {
      final beforeSnapshot = _computeIntervalJsonSnapshot(routines);

      // Idempotency check: encode -> decode -> encode must produce identical JSON
      try {
        final decoded = json.decode(jsonString) as List<dynamic>;
        final reEncoded = json.encode(decoded);
        if (jsonString != reEncoded) {
          assert(false, 'JSON idempotency check failed - numbers may drift');
        }
      } catch (e) {
        assert(false, 'Idempotency check exception: $e');
      }

      // DRIFT GUARD: After save, reload and compare
      final reloadedRoutines = await loadRoutines();
      final afterSnapshot = _computeIntervalJsonSnapshot(reloadedRoutines);

      if (!_jsonDeepEquals(beforeSnapshot, afterSnapshot)) {
        assert(false, 'Drift detected - interval values changed');
      }
    }

    await prefs.setString(_storageKey, jsonString);
  }

  Future<void> addRoutine(Routine routine) async {
    final routines = await loadRoutines();
    routines.add(routine);
    await saveRoutines(routines);
  }

  Future<void> updateRoutine(Routine routine) async {
    final routines = await loadRoutines();
    final index = routines.indexWhere((r) => r.id == routine.id);
    if (index != -1) {
      routines[index] = routine;
      await saveRoutines(routines);
    }
  }

  Future<void> deleteRoutine(String id) async {
    final routines = await loadRoutines();
    routines.removeWhere((r) => r.id == id);
    await saveRoutines(routines);
  }
}
