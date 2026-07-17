// Valcue Local Database Migration Skeleton & Guide (Hive / Isar)
//
// This file serves as a blueprint and skeleton code for migrating
// local storage from SharedPreferences JSON serialization to Hive (or Isar).
//
// To implement this database migration, follow these steps:
//
// 1. Add packages to pubspec.yaml:
//    dependencies:
//      hive: ^2.2.3
//      hive_flutter: ^1.1.0
//    dev_dependencies:
//      hive_generator: ^2.0.1
//      build_runner: ^2.4.8
//
// 2. Run build_runner to generate type adapters:
//    flutter pub run build_runner build --delete-conflicting-outputs
//
// 3. Register adapters and initialize Hive in main.dart:
//    await Hive.initFlutter();
//    Hive.registerAdapter(RoutineAdapter());
//    Hive.registerAdapter(IntervalAdapter());
//    Hive.registerAdapter(WorkoutSessionAdapter());
//    Hive.registerAdapter(WeightEntryAdapter());
//
// 4. Run the migration script at startup to move existing SharedPreferences JSON data to Hive.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/routines/models/routine.dart';
import '../features/profile/models/workout_session.dart';
import '../features/profile/models/weight_entry.dart';
import '../utils/debug_log.dart';

// ==========================================
// 1. Proposed Hive Annotated Models (Reference)
// ==========================================

/*
import 'package:hive/hive.dart';
part 'local_db_models.g.dart';

@HiveType(typeId: 0)
class HiveRoutine extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String machineType; // stored as string e.g., 'treadmill'

  @HiveField(3)
  late String difficulty;

  @HiveField(4)
  late List<HiveInterval> intervals;
}

@HiveType(typeId: 1)
class HiveInterval extends HiveObject {
  @HiveField(0)
  late int durationSeconds;

  @HiveField(1)
  double? speedKmh;

  @HiveField(2)
  double? grade;

  @HiveField(3)
  int? rpm;

  @HiveField(4)
  int? resistance;

  @HiveField(5)
  int? level;
}

@HiveType(typeId: 2)
class HiveWorkoutSession extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String routineId;

  @HiveField(2)
  late String routineName;

  @HiveField(3)
  late String machineType;

  @HiveField(4)
  late DateTime dateTime;

  @HiveField(5)
  late int elapsedSeconds;

  @HiveField(6)
  double? distanceMeters;
}

@HiveType(typeId: 3)
class HiveWeightEntry extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late double weightKg;

  @HiveField(2)
  late DateTime dateTime;
}
*/

// ==========================================
// 2. Migration Orchestration Service
// ==========================================

class LocalDbMigrationService {
  static const String _migratedKey = 'db_migrated_v1';
  
  /// Performs one-time migration of SharedPreferences data to Hive boxes.
  static Future<void> performMigration() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if already migrated
    final isMigrated = prefs.getBool(_migratedKey) ?? false;
    if (isMigrated) {
      debugLog('[DB Migration] Already migrated to Hive. Skipping.');
      return;
    }

    debugLog('[DB Migration] Starting migration from SharedPreferences to Hive...');

    try {
      // 1. Migrate Routines
      await _migrateRoutines(prefs);

      // 2. Migrate Workout History
      await _migrateWorkoutSessions(prefs);

      // 3. Migrate Weight Entries
      await _migrateWeightEntries(prefs);

      // Mark migration as successfully complete
      await prefs.setBool(_migratedKey, true);
      debugLog('[DB Migration] Migration successfully completed.');
    } catch (e, stack) {
      debugLog('[DB Migration] CRITICAL: Migration failed: $e\n$stack');
    }
  }

  static Future<void> _migrateRoutines(SharedPreferences prefs) async {
    final jsonString = prefs.getString('routines');
    if (jsonString == null || jsonString.isEmpty) return;

    try {
      final decoded = json.decode(jsonString) as List<dynamic>;
      debugLog('[DB Migration] Found ${decoded.length} routines in SharedPreferences.');

      // In real Hive implementation:
      // final box = await Hive.openBox<HiveRoutine>('routines_box');
      // for (final item in decoded) {
      //   final routine = Routine.fromJson(Map<String, dynamic>.from(item));
      //   final hiveRoutine = HiveRoutine()
      //     ..id = routine.id
      //     ..name = routine.name
      //     ..machineType = routine.machineType.name
      //     ..difficulty = routine.difficulty
      //     ..intervals = routine.intervals.map((i) => HiveInterval()...).toList();
      //   await box.put(hiveRoutine.id, hiveRoutine);
      // }
      
      debugLog('[DB Migration] Routines mock-migrated.');
    } catch (e) {
      debugLog('[DB Migration] Failed to migrate routines: $e');
    }
  }

  static Future<void> _migrateWorkoutSessions(SharedPreferences prefs) async {
    final jsonString = prefs.getString('workout_sessions');
    if (jsonString == null || jsonString.isEmpty) return;

    try {
      final decoded = json.decode(jsonString) as List<dynamic>;
      debugLog('[DB Migration] Found ${decoded.length} workout sessions in SharedPreferences.');

      // In real Hive implementation:
      // final box = await Hive.openBox<HiveWorkoutSession>('workout_sessions_box');
      // for (final item in decoded) {
      //   final session = WorkoutSession.fromJson(Map<String, dynamic>.from(item));
      //   // map and put in box
      // }
      
      debugLog('[DB Migration] Workout sessions mock-migrated.');
    } catch (e) {
      debugLog('[DB Migration] Failed to migrate workout sessions: $e');
    }
  }

  static Future<void> _migrateWeightEntries(SharedPreferences prefs) async {
    final jsonString = prefs.getString('weight_entries');
    if (jsonString == null || jsonString.isEmpty) return;

    try {
      final decoded = json.decode(jsonString) as List<dynamic>;
      debugLog('[DB Migration] Found ${decoded.length} weight entries in SharedPreferences.');

      // In real Hive implementation:
      // final box = await Hive.openBox<HiveWeightEntry>('weight_entries_box');
      // for (final item in decoded) {
      //   final entry = WeightEntry.fromJson(Map<String, dynamic>.from(item));
      //   // map and put in box
      // }
      
      debugLog('[DB Migration] Weight entries mock-migrated.');
    } catch (e) {
      debugLog('[DB Migration] Failed to migrate weight entries: $e');
    }
  }
}
