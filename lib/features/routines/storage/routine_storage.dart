import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/routine.dart';

class RoutineStorage {
  static const String _storageKey = 'routines';

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
        print('[TEST] No routines to test');
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
        print('[TEST FAILED] Idempotency test failed!');
        print('[TEST] Before: $beforeSnapshot');
        print('[TEST] After: $afterSnapshot');
      } else {
        print('[TEST PASSED] Idempotency test passed');
      }

      return isEqual;
    } catch (e) {
      print('[TEST ERROR] Idempotency test exception: $e');
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
      final List<dynamic> jsonList = json.decode(jsonString);
      final routines = jsonList
          .map((json) => Routine.fromJson(json as Map<String, dynamic>))
          .toList();

      // Debug: Verify decimal preservation after load
      for (final routine in routines) {
        for (int i = 0; i < routine.intervals.length; i++) {
          final interval = routine.intervals[i];
          print('[DEBUG LOAD] Routine "${routine.name}" Interval $i: duration=${interval.durationSeconds}s, speedKmh=${interval.speedKmh}, grade=${interval.grade}');
        }
      }

      return routines;
    } catch (e) {
      return [];
    }
  }

  Future<void> saveRoutines(List<Routine> routines) async {
    // DRIFT GUARD: Compute snapshot BEFORE save
    final beforeSnapshot = _computeIntervalJsonSnapshot(routines);

    final prefs = await SharedPreferences.getInstance();
    final jsonList = routines.map((r) => r.toJson()).toList();
    final jsonString = json.encode(jsonList);

    // Debug: Verify decimal preservation
    for (final routine in routines) {
      for (int i = 0; i < routine.intervals.length; i++) {
        final interval = routine.intervals[i];
        print('[DEBUG SAVE] Routine "${routine.name}" Interval $i: duration=${interval.durationSeconds}s, speedKmh=${interval.speedKmh}, grade=${interval.grade}');
      }
    }

    // Idempotency check: encode -> decode -> encode must produce identical JSON
    try {
      final decoded = json.decode(jsonString) as List<dynamic>;
      final reEncoded = json.encode(decoded);
      if (jsonString != reEncoded) {
        print(
            '[ERROR] Idempotency check FAILED: JSON changed after encode->decode->encode');
        print('[ERROR] Original: $jsonString');
        print('[ERROR] Re-encoded: $reEncoded');
        assert(false, 'JSON idempotency check failed - numbers may drift');
      } else {
        print('[DEBUG] Idempotency check PASSED: JSON unchanged');
      }
    } catch (e) {
      print('[ERROR] Idempotency check exception: $e');
      assert(false, 'Idempotency check exception: $e');
    }

    await prefs.setString(_storageKey, jsonString);

    // DRIFT GUARD: After save, reload and compare
    final reloadedRoutines = await loadRoutines();
    final afterSnapshot = _computeIntervalJsonSnapshot(reloadedRoutines);

    if (!_jsonDeepEquals(beforeSnapshot, afterSnapshot)) {
      print('[ERROR] DRIFT DETECTED: Interval values changed after save/load!');
      print('[ERROR] Before save: $beforeSnapshot');
      print('[ERROR] After reload: $afterSnapshot');
      assert(false, 'Drift detected - interval values changed');
    } else {
      print('[DEBUG] Drift guard PASSED: No value changes detected');
    }
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
