import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_session.dart';
import '../../routines/models/machine_type.dart';
import '../../../utils/debug_log.dart';

class WorkoutSessionStorage {
  static const String _storageKey = 'workout_sessions';

  Future<List<WorkoutSession>> loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      final decoded = jsonDecode(jsonString);
      if (decoded is! List) {
        debugLog('[WorkoutSessionStorage] Expected a list payload');
        return [];
      }

      final sessions = <WorkoutSession>[];
      for (final item in decoded) {
        if (item is! Map) {
          debugLog('[WorkoutSessionStorage] Skipping malformed session entry');
          continue;
        }

        try {
          sessions.add(
            WorkoutSession.fromJson(Map<String, dynamic>.from(item)),
          );
        } catch (e) {
          debugLog('[WorkoutSessionStorage] Failed to parse session entry: $e');
        }
      }

      sessions.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return sessions;
    } catch (e) {
      debugLog('[WorkoutSessionStorage] Failed to load sessions: $e');
      return [];
    }
  }

  Future<void> saveSessions(List<WorkoutSession> sessions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = sessions.map((s) => s.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugLog('[WorkoutSessionStorage] Failed to save sessions: $e');
    }
  }

  Future<void> addSession(WorkoutSession session) async {
    final sessions = await loadSessions();
    sessions.add(session);
    // Sort by date descending (newest first)
    sessions.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    await saveSessions(sessions);
  }

  Future<void> deleteSession(String id) async {
    final sessions = await loadSessions();
    sessions.removeWhere((s) => s.id == id);
    await saveSessions(sessions);
  }

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
