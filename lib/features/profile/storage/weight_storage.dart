import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weight_entry.dart';
import '../../../utils/debug_log.dart';

class WeightStorage {
  static const String _storageKey = 'weight_entries';
  static const String _goalWeightKey = 'goal_weight_kg';

  Future<List<WeightEntry>> loadEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      final decoded = jsonDecode(jsonString);
      if (decoded is! List) {
        debugLog('[WeightStorage] Expected a list payload');
        return [];
      }

      final entries = <WeightEntry>[];
      for (final item in decoded) {
        if (item is! Map) {
          debugLog('[WeightStorage] Skipping malformed weight entry');
          continue;
        }

        try {
          entries.add(WeightEntry.fromJson(Map<String, dynamic>.from(item)));
        } catch (e) {
          debugLog('[WeightStorage] Failed to parse weight entry: $e');
        }
      }

      entries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return entries;
    } catch (e) {
      debugLog('[WeightStorage] Failed to load entries: $e');
      return [];
    }
  }

  Future<void> saveEntries(List<WeightEntry> entries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = entries.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      debugLog('[WeightStorage] Failed to save entries: $e');
    }
  }

  Future<void> addEntry(WeightEntry entry) async {
    final entries = await loadEntries();
    entries.add(entry);
    entries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    await saveEntries(entries);
  }

  Future<void> deleteEntry(String id) async {
    final entries = await loadEntries();
    entries.removeWhere((e) => e.id == id);
    await saveEntries(entries);
  }

  Future<void> updateEntry(String id, WeightEntry updatedEntry) async {
    final entries = await loadEntries();
    final index = entries.indexWhere((e) => e.id == id);
    if (index != -1) {
      entries[index] = updatedEntry;
      entries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      await saveEntries(entries);
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
