import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valcue/features/profile/models/workout_session.dart';
import 'package:valcue/features/profile/providers/workout_history_provider.dart';
import 'package:valcue/features/profile/providers/achievement_provider.dart';
import 'package:valcue/features/routines/models/machine_type.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('AchievementProvider starts with all achievements locked when history is empty', () async {
    final historyProvider = WorkoutHistoryProvider();
    await historyProvider.loadSessions();
    final achievementProvider = AchievementProvider(historyProvider);

    // Allow async updates to run
    await Future.delayed(const Duration(milliseconds: 50));

    final achievements = achievementProvider.achievements;
    expect(achievements.length, 56);
    for (final ach in achievements) {
      expect(ach.isUnlocked, false);
      expect(ach.unlockedAt, null);
      if (ach.id == 'first_workout') {
        expect(ach.progress, 0.0);
      }
    }
  });

  test('AchievementProvider unlocks first_workout when a session is added', () async {
    final historyProvider = WorkoutHistoryProvider();
    await historyProvider.loadSessions();
    final achievementProvider = AchievementProvider(historyProvider);

    // Allow initial async updates to run
    await Future.delayed(const Duration(milliseconds: 50));

    final session = WorkoutSession(
      id: 'session-1',
      machineType: MachineType.treadmill,
      dateTime: DateTime(2026, 7, 18, 10, 0),
      durationSeconds: 600,
      distanceMeters: 1000,
      routineName: 'Quick Run',
      routineId: 'routine-1',
    );

    await historyProvider.addSession(session);
    // Allow post-add async updates to run
    await Future.delayed(const Duration(milliseconds: 50));

    final firstWorkout = achievementProvider.achievements.firstWhere((a) => a.id == 'first_workout');
    expect(firstWorkout.isUnlocked, true);
    expect(firstWorkout.progress, 1.0);
    expect(firstWorkout.unlockedAt, session.dateTime);
  });

  test('AchievementProvider calculates streak and unlocks streak_3', () async {
    final historyProvider = WorkoutHistoryProvider();
    await historyProvider.loadSessions();
    final achievementProvider = AchievementProvider(historyProvider);

    // Allow initial async updates to run
    await Future.delayed(const Duration(milliseconds: 50));

    // Create 3 workouts on 3 consecutive days
    final session1 = WorkoutSession(
      id: 'session-1',
      machineType: MachineType.treadmill,
      dateTime: DateTime(2026, 7, 16, 10, 0),
      durationSeconds: 600,
      routineName: 'Day 1',
      routineId: 'routine-1',
    );
    final session2 = WorkoutSession(
      id: 'session-2',
      machineType: MachineType.treadmill,
      dateTime: DateTime(2026, 7, 17, 10, 0),
      durationSeconds: 600,
      routineName: 'Day 2',
      routineId: 'routine-1',
    );
    final session3 = WorkoutSession(
      id: 'session-3',
      machineType: MachineType.treadmill,
      dateTime: DateTime(2026, 7, 18, 10, 0),
      durationSeconds: 600,
      routineName: 'Day 3',
      routineId: 'routine-1',
    );

    await historyProvider.addSession(session1);
    await historyProvider.addSession(session2);
    await historyProvider.addSession(session3);
    // Allow post-add async updates to run
    await Future.delayed(const Duration(milliseconds: 50));

    final streak3 = achievementProvider.achievements.firstWhere((a) => a.id == 'streak_3');
    expect(streak3.isUnlocked, true);
    expect(streak3.unlockedAt, session3.dateTime);

    final streak7 = achievementProvider.achievements.firstWhere((a) => a.id == 'streak_7');
    expect(streak7.isUnlocked, false);
    expect(streak7.progress, closeTo(3 / 7, 0.01));
  });

  test('AchievementProvider unlocks cumulative treadmill distance (marathoner)', () async {
    final historyProvider = WorkoutHistoryProvider();
    await historyProvider.loadSessions();
    final achievementProvider = AchievementProvider(historyProvider);

    // Allow initial async updates to run
    await Future.delayed(const Duration(milliseconds: 50));

    // Marathoner target is 42.195km (42,195m)
    final session1 = WorkoutSession(
      id: 'session-1',
      machineType: MachineType.treadmill,
      dateTime: DateTime(2026, 7, 17, 10, 0),
      durationSeconds: 1800,
      distanceMeters: 25000, // 25km
      routineName: 'Long Run 1',
      routineId: 'routine-1',
    );

    final session2 = WorkoutSession(
      id: 'session-2',
      machineType: MachineType.treadmill,
      dateTime: DateTime(2026, 7, 18, 10, 0),
      durationSeconds: 1800,
      distanceMeters: 20000, // 20km (Total = 45km)
      routineName: 'Long Run 2',
      routineId: 'routine-1',
    );

    await historyProvider.addSession(session1);
    await historyProvider.addSession(session2);
    // Allow post-add async updates to run
    await Future.delayed(const Duration(milliseconds: 50));

    final marathoner = achievementProvider.achievements.firstWhere((a) => a.id == 'treadmill_marathon');
    expect(marathoner.isUnlocked, true);
    expect(marathoner.unlockedAt, session2.dateTime);
    expect(marathoner.progress, 1.0);
  });

  test('AchievementProvider unlocks total cumulative duration (total_duration_10h)', () async {
    final historyProvider = WorkoutHistoryProvider();
    await historyProvider.loadSessions();
    final achievementProvider = AchievementProvider(historyProvider);

    // Allow initial async updates to run
    await Future.delayed(const Duration(milliseconds: 50));

    // Add 10 sessions of 1 hour each to reach 10 hours (36000 seconds)
    for (int i = 0; i < 10; i++) {
      final session = WorkoutSession(
        id: 'session-$i',
        machineType: MachineType.cycle,
        dateTime: DateTime(2026, 7, i + 1, 10, 0),
        durationSeconds: 3600, // 1 hour
        routineName: 'Cycle hour',
        routineId: 'routine-1',
      );
      await historyProvider.addSession(session);
    }

    // Allow post-add async updates to run
    await Future.delayed(const Duration(milliseconds: 50));

    final total10h = achievementProvider.achievements.firstWhere((a) => a.id == 'total_duration_10h');
    expect(total10h.isUnlocked, true);
    expect(total10h.progress, 1.0);
  });

  test('AchievementProvider detects newly unlocked achievements and clears them', () async {
    final historyProvider = WorkoutHistoryProvider();
    await historyProvider.loadSessions();
    final achievementProvider = AchievementProvider(historyProvider);

    // Prime the achievements in memory first
    await Future.delayed(const Duration(milliseconds: 50));
    expect(achievementProvider.newlyUnlocked.isEmpty, true);

    final session = WorkoutSession(
      id: 'session-1',
      machineType: MachineType.treadmill,
      dateTime: DateTime(2026, 7, 18, 10, 0),
      durationSeconds: 600,
      distanceMeters: 1000,
      routineName: 'Quick Run',
      routineId: 'routine-1',
    );

    await historyProvider.addSession(session);
    // Allow post-add async updates to run
    await Future.delayed(const Duration(milliseconds: 50));

    // Newly unlocked list should contain 'first_workout' and 'treadmill_first'
    expect(achievementProvider.newlyUnlocked.length, 2);
    expect(achievementProvider.newlyUnlocked.any((a) => a.id == 'first_workout'), true);
    expect(achievementProvider.newlyUnlocked.any((a) => a.id == 'treadmill_first'), true);

    achievementProvider.clearNewlyUnlocked();
    expect(achievementProvider.newlyUnlocked.isEmpty, true);
  });
}
