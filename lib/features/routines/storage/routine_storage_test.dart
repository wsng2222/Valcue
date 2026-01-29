import 'dart:convert';
import 'routine_storage.dart';
import '../models/routine.dart';
import '../models/interval.dart';
import '../models/machine_type.dart';

/// Test function to verify idempotency: encode -> decode -> encode
/// Returns true if no drift detected, false otherwise
Future<bool> testRoutineIdempotency() async {
  try {
    final storage = RoutineStorage();
    final routines = await storage.loadRoutines();
    
    if (routines.isEmpty) {
      print('[TEST] No routines found - creating test routine');
      // Create a test routine with decimal values
      final testRoutine = Routine(
        id: 'test-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Routine',
        difficulty: '쉬움',
        intervals: [
          Interval.treadmill(
            durationSeconds: 34,
            speedKmh: 3.6,
            grade: 2.5,
          ),
          Interval.treadmill(
            durationSeconds: 34,
            speedKmh: 5.7,
            grade: 0.0,
          ),
        ],
        machineType: MachineType.treadmill,
      );
      await storage.addRoutine(testRoutine);
      return await testRoutineIdempotency(); // Retry with the test routine
    }
    
    print('[TEST] Testing ${routines.length} routine(s)');
    
    // Test each routine
    for (final routine in routines) {
      print('[TEST] Testing routine: ${routine.name}');
      
      // Create snapshot of interval values
      final beforeSnapshot = routine.intervals.map((i) {
        final json = <String, dynamic>{'durationSeconds': i.durationSeconds};
        if (i.speedKmh != null) json['speedKmh'] = i.speedKmh;
        if (i.grade != null) json['grade'] = i.grade;
        if (i.rpm != null) json['rpm'] = i.rpm;
        if (i.resistance != null) json['resistance'] = i.resistance;
        if (i.level != null) json['level'] = i.level;
        return json;
      }).toList();
      final beforeJson = json.encode(beforeSnapshot);
      
      // Save and reload
      await storage.updateRoutine(routine);
      final reloadedRoutines = await storage.loadRoutines();
      final reloadedRoutine = reloadedRoutines.firstWhere(
        (r) => r.id == routine.id,
        orElse: () => routine,
      );
      
      // Create snapshot after reload
      final afterSnapshot = reloadedRoutine.intervals.map((i) {
        final json = <String, dynamic>{'durationSeconds': i.durationSeconds};
        if (i.speedKmh != null) json['speedKmh'] = i.speedKmh;
        if (i.grade != null) json['grade'] = i.grade;
        if (i.rpm != null) json['rpm'] = i.rpm;
        if (i.resistance != null) json['resistance'] = i.resistance;
        if (i.level != null) json['level'] = i.level;
        return json;
      }).toList();
      final afterJson = json.encode(afterSnapshot);
      
      // Compare
      if (beforeJson != afterJson) {
        print('[TEST FAILED] Routine "${routine.name}" - values changed!');
        print('[TEST] Before: $beforeJson');
        print('[TEST] After: $afterJson');
        
        // Show diff
        for (int i = 0; i < beforeSnapshot.length && i < afterSnapshot.length; i++) {
          if (json.encode(beforeSnapshot[i]) != json.encode(afterSnapshot[i])) {
            print('[TEST] Interval $i changed:');
            print('[TEST]   Before: ${beforeSnapshot[i]}');
            print('[TEST]   After: ${afterSnapshot[i]}');
          }
        }
        
        return false;
      } else {
        print('[TEST PASSED] Routine "${routine.name}" - no drift detected');
      }
    }
    
    print('[TEST] All routines passed idempotency test');
    return true;
  } catch (e, stackTrace) {
    print('[TEST ERROR] Exception: $e');
    print('[TEST ERROR] Stack: $stackTrace');
    return false;
  }
}

