import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routines/models/machine_type.dart';
import '../models/achievement.dart';
import '../models/workout_session.dart';
import 'workout_history_provider.dart';

class AchievementProvider extends ChangeNotifier {
  WorkoutHistoryProvider _historyProvider;
  List<Achievement> _achievements = [];
  final List<Achievement> _newlyUnlocked = [];
  bool _isInitialized = false;

  List<Achievement> get achievements => _achievements;
  List<Achievement> get newlyUnlocked => _newlyUnlocked;

  AchievementProvider(this._historyProvider) {
    _historyProvider.addListener(_updateAchievements);
    _updateAchievements();
  }

  void updateHistoryProvider(WorkoutHistoryProvider historyProvider) {
    _historyProvider.removeListener(_updateAchievements);
    _historyProvider = historyProvider;
    _historyProvider.addListener(_updateAchievements);
    _updateAchievements();
  }

  @override
  void dispose() {
    _historyProvider.removeListener(_updateAchievements);
    super.dispose();
  }

  /// Clears the newly unlocked achievements list after they have been shown to the user
  void clearNewlyUnlocked() {
    _newlyUnlocked.clear();
    notifyListeners();
  }

  Future<void> _updateAchievements() async {
    // We sort the sessions chronologically (oldest first) for correct unlock date calculation
    final sortedSessions = List<WorkoutSession>.from(_historyProvider.sessions)
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    // 1. Calculate achievements state on-the-fly
    final List<Achievement> calculated = _calculate(sortedSessions);

    // 2. Load historically shown unlocked achievement IDs from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final savedUnlockedIds = prefs.getStringList('unlocked_achievement_ids')?.toSet() ?? {};

    // 3. Detect newly unlocked achievements
    bool hasNewUnlocks = false;
    for (final ach in calculated) {
      if (ach.isUnlocked) {
        // If the provider has already completed its first initialization run
        // AND it has not been saved in SharedPreferences, it is a new unlock!
        if (_isInitialized && !savedUnlockedIds.contains(ach.id)) {
          _newlyUnlocked.add(ach);
          hasNewUnlocks = true;
        }
        savedUnlockedIds.add(ach.id);
      }
    }

    if (hasNewUnlocks) {
      await prefs.setStringList('unlocked_achievement_ids', savedUnlockedIds.toList());
    }

    // Mark as initialized on first computation
    if (!_isInitialized) {
      _isInitialized = true;
      // Save startup achievements to SharedPreferences so they are not flagged as newly unlocked
      await prefs.setStringList('unlocked_achievement_ids', savedUnlockedIds.toList());
    }

    _achievements = calculated;
    notifyListeners();
  }

  List<Achievement> _calculate(List<WorkoutSession> sorted) {
    // Pre-calculate sub-lists
    final treadmillList = sorted.where((s) => s.machineType == MachineType.treadmill).toList();
    final cycleList = sorted.where((s) => s.machineType == MachineType.cycle).toList();
    final stairmasterList = sorted.where((s) => s.machineType == MachineType.stairmaster).toList();

    final totalWorkouts = sorted.length;

    // Calculate Streaks
    final streakResults = _calculateStreakData(sorted);
    final maxStreak = streakResults.maxStreak;
    final streakUnlockDates = streakResults.streakUnlockDates;

    // Cumulative stats
    double totalTreadmillDistanceMeters = 0;
    double maxTreadmillDistance = 0;
    final Map<String, DateTime> treadmillDistanceUnlocks = {};
    for (final s in treadmillList) {
      final dist = s.distanceMeters ?? 0;
      if (dist > maxTreadmillDistance) {
        maxTreadmillDistance = dist;
      }
      totalTreadmillDistanceMeters += dist;
      if (!treadmillDistanceUnlocks.containsKey('10k') && totalTreadmillDistanceMeters >= 10000) {
        treadmillDistanceUnlocks['10k'] = s.dateTime;
      }
      if (!treadmillDistanceUnlocks.containsKey('marathon') && totalTreadmillDistanceMeters >= 42195) {
        treadmillDistanceUnlocks['marathon'] = s.dateTime;
      }
      if (!treadmillDistanceUnlocks.containsKey('100k') && totalTreadmillDistanceMeters >= 100000) {
        treadmillDistanceUnlocks['100k'] = s.dateTime;
      }
      if (!treadmillDistanceUnlocks.containsKey('500k') && totalTreadmillDistanceMeters >= 500000) {
        treadmillDistanceUnlocks['500k'] = s.dateTime;
      }
      if (!treadmillDistanceUnlocks.containsKey('1000k') && totalTreadmillDistanceMeters >= 1000000) {
        treadmillDistanceUnlocks['1000k'] = s.dateTime;
      }
    }

    double totalCycleDistanceMeters = 0;
    final Map<String, DateTime> cycleDistanceUnlocks = {};
    for (final s in cycleList) {
      totalCycleDistanceMeters += s.distanceMeters ?? 0;
      if (!cycleDistanceUnlocks.containsKey('50k') && totalCycleDistanceMeters >= 50000) {
        cycleDistanceUnlocks['50k'] = s.dateTime;
      }
      if (!cycleDistanceUnlocks.containsKey('200k') && totalCycleDistanceMeters >= 200000) {
        cycleDistanceUnlocks['200k'] = s.dateTime;
      }
      if (!cycleDistanceUnlocks.containsKey('500k') && totalCycleDistanceMeters >= 500000) {
        cycleDistanceUnlocks['500k'] = s.dateTime;
      }
      if (!cycleDistanceUnlocks.containsKey('1000k') && totalCycleDistanceMeters >= 1000000) {
        cycleDistanceUnlocks['1000k'] = s.dateTime;
      }
    }

    // Cumulative workout time (all machines combined)
    int totalDurationSeconds = 0;
    final Map<String, DateTime> totalDurationUnlocks = {};
    for (final s in sorted) {
      totalDurationSeconds += s.durationSeconds;
      if (!totalDurationUnlocks.containsKey('10h') && totalDurationSeconds >= 36000) {
        totalDurationUnlocks['10h'] = s.dateTime;
      }
      if (!totalDurationUnlocks.containsKey('50h') && totalDurationSeconds >= 180000) {
        totalDurationUnlocks['50h'] = s.dateTime;
      }
      if (!totalDurationUnlocks.containsKey('100h') && totalDurationSeconds >= 360000) {
        totalDurationUnlocks['100h'] = s.dateTime;
      }
      if (!totalDurationUnlocks.containsKey('500h') && totalDurationSeconds >= 1800000) {
        totalDurationUnlocks['500h'] = s.dateTime;
      }
    }

    // Stairmaster cumulative duration
    int stairmasterDurationSeconds = 0;
    DateTime? stairmaster10hUnlockDate;
    for (final s in stairmasterList) {
      stairmasterDurationSeconds += s.durationSeconds;
      if (stairmaster10hUnlockDate == null && stairmasterDurationSeconds >= 36000) {
        stairmaster10hUnlockDate = s.dateTime;
      }
    }

    // Single session metrics
    DateTime? treadmill5kUnlockDate;
    DateTime? treadmill10kUnlockDate;
    DateTime? treadmillHalfMarathonUnlockDate;
    for (final s in treadmillList) {
      final dist = s.distanceMeters ?? 0;
      if (treadmill5kUnlockDate == null && dist >= 5000) {
        treadmill5kUnlockDate = s.dateTime;
      }
      if (treadmill10kUnlockDate == null && dist >= 10000) {
        treadmill10kUnlockDate = s.dateTime;
      }
      if (treadmillHalfMarathonUnlockDate == null && dist >= 21097.5) {
        treadmillHalfMarathonUnlockDate = s.dateTime;
      }
    }

    // Speed checks (average speed of the session = dist / hours)
    double maxSpeedKmh = 0;
    DateTime? speed12UnlockDate;
    DateTime? speed16UnlockDate;
    DateTime? speed20UnlockDate;
    for (final s in treadmillList) {
      if (s.durationSeconds > 0 && s.distanceMeters != null) {
        final speed = (s.distanceMeters! / 1000.0) / (s.durationSeconds / 3600.0);
        if (speed > maxSpeedKmh) {
          maxSpeedKmh = speed;
        }
        if (speed12UnlockDate == null && speed >= 12.0) {
          speed12UnlockDate = s.dateTime;
        }
        if (speed16UnlockDate == null && speed >= 16.0) {
          speed16UnlockDate = s.dateTime;
        }
        if (speed20UnlockDate == null && speed >= 20.0) {
          speed20UnlockDate = s.dateTime;
        }
      }
    }

    // Cycle RPM check
    double maxAvgRpm = 0;
    DateTime? rpm90UnlockDate;
    DateTime? rpm100UnlockDate;
    DateTime? rpm110UnlockDate;
    for (final s in cycleList) {
      final rpm = s.averageRpm ?? 0;
      if (rpm > maxAvgRpm) {
        maxAvgRpm = rpm;
      }
      if (rpm90UnlockDate == null && rpm >= 90) {
        rpm90UnlockDate = s.dateTime;
      }
      if (rpm100UnlockDate == null && rpm >= 100) {
        rpm100UnlockDate = s.dateTime;
      }
      if (rpm110UnlockDate == null && rpm >= 110) {
        rpm110UnlockDate = s.dateTime;
      }
    }

    // Stairmaster Level check
    double maxAvgLevel = 0;
    DateTime? lvl10UnlockDate;
    DateTime? lvl12UnlockDate;
    DateTime? lvl15UnlockDate;
    for (final s in stairmasterList) {
      final lvl = s.averageLevel ?? 0;
      if (lvl > maxAvgLevel) {
        maxAvgLevel = lvl;
      }
      if (lvl10UnlockDate == null && lvl >= 10) {
        lvl10UnlockDate = s.dateTime;
      }
      if (lvl12UnlockDate == null && lvl >= 12) {
        lvl12UnlockDate = s.dateTime;
      }
      if (lvl15UnlockDate == null && lvl >= 15) {
        lvl15UnlockDate = s.dateTime;
      }
    }

    // Single workout duration limits (in minutes)
    int maxSingleDurationMinutes = 0;
    DateTime? duration30UnlockDate;
    DateTime? duration60UnlockDate;
    DateTime? duration90UnlockDate;
    for (final s in sorted) {
      final mins = (s.durationSeconds / 60.0).round();
      if (mins > maxSingleDurationMinutes) {
        maxSingleDurationMinutes = mins;
      }
      if (duration30UnlockDate == null && s.durationSeconds >= 1800) {
        duration30UnlockDate = s.dateTime;
      }
      if (duration60UnlockDate == null && s.durationSeconds >= 3600) {
        duration60UnlockDate = s.dateTime;
      }
      if (duration90UnlockDate == null && s.durationSeconds >= 5400) {
        duration90UnlockDate = s.dateTime;
      }
    }

    return [
      // === 1. General Workouts ===
      Achievement(
        id: 'first_workout',
        titleKo: '첫 걸음마',
        titleEn: 'First Steps',
        descriptionKo: '첫 번째 운동 세션을 완료했습니다.',
        descriptionEn: 'Completed your first workout session.',
        icon: Icons.emoji_events,
        gradientColors: [Colors.orange, Colors.amber],
        isUnlocked: totalWorkouts >= 1,
        unlockedAt: totalWorkouts >= 1 ? sorted[0].dateTime : null,
        progress: (totalWorkouts / 1).clamp(0.0, 1.0),
        currentValue: totalWorkouts,
        targetValue: 1,
      ),
      Achievement(
        id: 'workouts_5',
        titleKo: '꾸준한 습관',
        titleEn: 'Regular Habit',
        descriptionKo: '운동 세션을 5회 완료했습니다.',
        descriptionEn: 'Completed 5 workout sessions.',
        icon: Icons.emoji_events,
        gradientColors: [Colors.orange.shade300, Colors.amber.shade400],
        isUnlocked: totalWorkouts >= 5,
        unlockedAt: totalWorkouts >= 5 ? sorted[4].dateTime : null,
        progress: (totalWorkouts / 5).clamp(0.0, 1.0),
        currentValue: totalWorkouts,
        targetValue: 5,
      ),
      Achievement(
        id: 'workouts_10',
        titleKo: '러닝 브론즈',
        titleEn: 'Workout Bronze',
        descriptionKo: '운동 세션을 10회 완료했습니다.',
        descriptionEn: 'Completed 10 workout sessions.',
        icon: Icons.emoji_events,
        gradientColors: [Colors.orange.shade700, Colors.deepOrange],
        isUnlocked: totalWorkouts >= 10,
        unlockedAt: totalWorkouts >= 10 ? sorted[9].dateTime : null,
        progress: (totalWorkouts / 10).clamp(0.0, 1.0),
        currentValue: totalWorkouts,
        targetValue: 10,
      ),
      Achievement(
        id: 'workouts_25',
        titleKo: '헬스 주니어',
        titleEn: 'Workout Silver',
        descriptionKo: '운동 세션을 25회 완료했습니다.',
        descriptionEn: 'Completed 25 workout sessions.',
        icon: Icons.emoji_events,
        gradientColors: [Colors.grey.shade400, Colors.blueGrey.shade300],
        isUnlocked: totalWorkouts >= 25,
        unlockedAt: totalWorkouts >= 25 ? sorted[24].dateTime : null,
        progress: (totalWorkouts / 25).clamp(0.0, 1.0),
        currentValue: totalWorkouts,
        targetValue: 25,
      ),
      Achievement(
        id: 'workouts_50',
        titleKo: '운동 애호가',
        titleEn: 'Active Enthusiast',
        descriptionKo: '운동 세션을 50회 완료했습니다.',
        descriptionEn: 'Completed 50 workout sessions.',
        icon: Icons.emoji_events,
        gradientColors: [Colors.grey.shade600, Colors.grey.shade400],
        isUnlocked: totalWorkouts >= 50,
        unlockedAt: totalWorkouts >= 50 ? sorted[49].dateTime : null,
        progress: (totalWorkouts / 50).clamp(0.0, 1.0),
        currentValue: totalWorkouts,
        targetValue: 50,
      ),
      Achievement(
        id: 'workouts_100',
        titleKo: '센추리 클럽',
        titleEn: 'Century Club',
        descriptionKo: '운동 세션을 100회 완료했습니다.',
        descriptionEn: 'Completed 100 workout sessions.',
        icon: Icons.emoji_events,
        gradientColors: [Colors.amber.shade700, Colors.yellow.shade600],
        isUnlocked: totalWorkouts >= 100,
        unlockedAt: totalWorkouts >= 100 ? sorted[99].dateTime : null,
        progress: (totalWorkouts / 100).clamp(0.0, 1.0),
        currentValue: totalWorkouts,
        targetValue: 100,
      ),
      Achievement(
        id: 'workouts_250',
        titleKo: '피트니스 장인',
        titleEn: 'Fitness Craftsman',
        descriptionKo: '운동 세션을 250회 완료했습니다.',
        descriptionEn: 'Completed 250 workout sessions.',
        icon: Icons.emoji_events,
        gradientColors: [Colors.cyan.shade600, Colors.blue.shade500],
        isUnlocked: totalWorkouts >= 250,
        unlockedAt: totalWorkouts >= 250 ? sorted[249].dateTime : null,
        progress: (totalWorkouts / 250).clamp(0.0, 1.0),
        currentValue: totalWorkouts,
        targetValue: 250,
      ),
      Achievement(
        id: 'workouts_500',
        titleKo: '스포츠 레전드',
        titleEn: 'Sports Legend',
        descriptionKo: '운동 세션을 500회 완료했습니다.',
        descriptionEn: 'Completed 500 workout sessions.',
        icon: Icons.emoji_events,
        gradientColors: [Colors.purple.shade600, Colors.indigo.shade500],
        isUnlocked: totalWorkouts >= 500,
        unlockedAt: totalWorkouts >= 500 ? sorted[499].dateTime : null,
        progress: (totalWorkouts / 500).clamp(0.0, 1.0),
        currentValue: totalWorkouts,
        targetValue: 500,
      ),
      Achievement(
        id: 'workouts_1000',
        titleKo: '명예의 전당',
        titleEn: 'Hall of Fame',
        descriptionKo: '운동 세션을 1000회 완료했습니다.',
        descriptionEn: 'Completed 1000 workout sessions.',
        icon: Icons.military_tech,
        gradientColors: [Colors.red.shade700, Colors.orange.shade600],
        isUnlocked: totalWorkouts >= 1000,
        unlockedAt: totalWorkouts >= 1000 ? sorted[999].dateTime : null,
        progress: (totalWorkouts / 1000).clamp(0.0, 1.0),
        currentValue: totalWorkouts,
        targetValue: 1000,
      ),

      // === 2. Daily Streaks ===
      Achievement(
        id: 'streak_3',
        titleKo: '꾸준함의 시작',
        titleEn: '3-Day Streak',
        descriptionKo: '3일 연속으로 운동을 완료했습니다.',
        descriptionEn: 'Completed workouts 3 days in a row.',
        icon: Icons.local_fire_department,
        gradientColors: [Colors.orange, Colors.red],
        isUnlocked: maxStreak >= 3,
        unlockedAt: streakUnlockDates[3],
        progress: (maxStreak / 3).clamp(0.0, 1.0),
        currentValue: maxStreak,
        targetValue: 3,
      ),
      Achievement(
        id: 'streak_7',
        titleKo: '한 주 정복',
        titleEn: '7-Day Streak',
        descriptionKo: '7일 연속으로 운동을 완료했습니다.',
        descriptionEn: 'Completed workouts 7 days in a row.',
        icon: Icons.flash_on,
        gradientColors: [Colors.amber, Colors.yellow.shade700],
        isUnlocked: maxStreak >= 7,
        unlockedAt: streakUnlockDates[7],
        progress: (maxStreak / 7).clamp(0.0, 1.0),
        currentValue: maxStreak,
        targetValue: 7,
      ),
      Achievement(
        id: 'streak_14',
        titleKo: '강철 같은 의지',
        titleEn: '14-Day Streak',
        descriptionKo: '14일 연속으로 운동을 완료했습니다.',
        descriptionEn: 'Completed workouts 14 days in a row.',
        icon: Icons.bolt,
        gradientColors: [Colors.teal, Colors.green],
        isUnlocked: maxStreak >= 14,
        unlockedAt: streakUnlockDates[14],
        progress: (maxStreak / 14).clamp(0.0, 1.0),
        currentValue: maxStreak,
        targetValue: 14,
      ),
      Achievement(
        id: 'streak_30',
        titleKo: '습관의 기적',
        titleEn: '30-Day Streak',
        descriptionKo: '30일 연속으로 운동을 완료했습니다.',
        descriptionEn: 'Completed workouts 30 days in a row.',
        icon: Icons.workspace_premium,
        gradientColors: [Colors.blue, Colors.indigo],
        isUnlocked: maxStreak >= 30,
        unlockedAt: streakUnlockDates[30],
        progress: (maxStreak / 30).clamp(0.0, 1.0),
        currentValue: maxStreak,
        targetValue: 30,
      ),
      Achievement(
        id: 'streak_60',
        titleKo: '라이프스타일',
        titleEn: '60-Day Streak',
        descriptionKo: '60일 연속으로 운동을 완료했습니다.',
        descriptionEn: 'Completed workouts 60 days in a row.',
        icon: Icons.stars,
        gradientColors: [Colors.purple, Colors.pink],
        isUnlocked: maxStreak >= 60,
        unlockedAt: streakUnlockDates[60],
        progress: (maxStreak / 60).clamp(0.0, 1.0),
        currentValue: maxStreak,
        targetValue: 60,
      ),
      Achievement(
        id: 'streak_90',
        titleKo: '득도의 경지',
        titleEn: '90-Day Streak',
        descriptionKo: '90일 연속으로 운동을 완료했습니다.',
        descriptionEn: 'Completed workouts 90 days in a row.',
        icon: Icons.emoji_events,
        gradientColors: [Colors.yellow.shade800, Colors.orange.shade700],
        isUnlocked: maxStreak >= 90,
        unlockedAt: streakUnlockDates[90],
        progress: (maxStreak / 90).clamp(0.0, 1.0),
        currentValue: maxStreak,
        targetValue: 90,
      ),

      // === 3. Single Workout Endurance ===
      Achievement(
        id: 'duration_30',
        titleKo: '지구력 초급',
        titleEn: '30m Finisher',
        descriptionKo: '한 번에 30분 이상 운동을 진행했습니다.',
        descriptionEn: 'Completed a workout of at least 30 minutes.',
        icon: Icons.timer,
        gradientColors: [Colors.teal, Colors.cyan],
        isUnlocked: duration30UnlockDate != null,
        unlockedAt: duration30UnlockDate,
        progress: maxSingleDurationMinutes >= 30 ? 1.0 : (maxSingleDurationMinutes / 30).clamp(0.0, 1.0),
        currentValue: maxSingleDurationMinutes,
        targetValue: 30,
      ),
      Achievement(
        id: 'duration_60',
        titleKo: '버닝 머신',
        titleEn: '60m Finisher',
        descriptionKo: '한 번에 60분 이상 운동을 진행했습니다.',
        descriptionEn: 'Completed a workout of at least 60 minutes.',
        icon: Icons.fitness_center,
        gradientColors: [Colors.blueGrey.shade700, Colors.black],
        isUnlocked: duration60UnlockDate != null,
        unlockedAt: duration60UnlockDate,
        progress: maxSingleDurationMinutes >= 60 ? 1.0 : (maxSingleDurationMinutes / 60).clamp(0.0, 1.0),
        currentValue: maxSingleDurationMinutes,
        targetValue: 60,
      ),
      Achievement(
        id: 'duration_90',
        titleKo: '끝없는 갈망',
        titleEn: '90m Finisher',
        descriptionKo: '한 번에 90분 이상 운동을 진행했습니다.',
        descriptionEn: 'Completed a workout of at least 90 minutes.',
        icon: Icons.speed,
        gradientColors: [Colors.red.shade900, Colors.black],
        isUnlocked: duration90UnlockDate != null,
        unlockedAt: duration90UnlockDate,
        progress: maxSingleDurationMinutes >= 90 ? 1.0 : (maxSingleDurationMinutes / 90).clamp(0.0, 1.0),
        currentValue: maxSingleDurationMinutes,
        targetValue: 90,
      ),

      // === 4. Cumulative Endurance (All Machines Combined) ===
      Achievement(
        id: 'total_duration_10h',
        titleKo: '시간 축적가',
        titleEn: 'Time Accumulator',
        descriptionKo: '총 누적 운동 시간 10시간을 달성했습니다.',
        descriptionEn: 'Reached 10 hours of cumulative workout duration.',
        icon: Icons.query_builder,
        gradientColors: [Colors.green.shade400, Colors.teal.shade500],
        isUnlocked: totalDurationSeconds >= 36000,
        unlockedAt: totalDurationUnlocks['10h'],
        progress: (totalDurationSeconds / 36000).clamp(0.0, 1.0),
        currentValue: totalDurationSeconds / 3600.0,
        targetValue: 10,
      ),
      Achievement(
        id: 'total_duration_50h',
        titleKo: '강철의 누적',
        titleEn: 'Iron Accumulation',
        descriptionKo: '총 누적 운동 시간 50시간을 달성했습니다.',
        descriptionEn: 'Reached 50 hours of cumulative workout duration.',
        icon: Icons.query_builder,
        gradientColors: [Colors.blue.shade600, Colors.blueGrey.shade600],
        isUnlocked: totalDurationSeconds >= 180000,
        unlockedAt: totalDurationUnlocks['50h'],
        progress: (totalDurationSeconds / 180000).clamp(0.0, 1.0),
        currentValue: totalDurationSeconds / 3600.0,
        targetValue: 50,
      ),
      Achievement(
        id: 'total_duration_100h',
        titleKo: '센추리 아워',
        titleEn: 'Century Hour',
        descriptionKo: '총 누적 운동 시간 100시간을 달성했습니다.',
        descriptionEn: 'Reached 100 hours of cumulative workout duration.',
        icon: Icons.hourglass_full,
        gradientColors: [Colors.purple.shade600, Colors.pink.shade500],
        isUnlocked: totalDurationSeconds >= 360000,
        unlockedAt: totalDurationUnlocks['100h'],
        progress: (totalDurationSeconds / 360000).clamp(0.0, 1.0),
        currentValue: totalDurationSeconds / 3600.0,
        targetValue: 100,
      ),
      Achievement(
        id: 'total_duration_500h',
        titleKo: '시간의 지배자',
        titleEn: 'Master of Time',
        descriptionKo: '총 누적 운동 시간 500시간을 달성했습니다.',
        descriptionEn: 'Reached 500 hours of cumulative workout duration.',
        icon: Icons.watch,
        gradientColors: [Colors.red.shade700, Colors.black],
        isUnlocked: totalDurationSeconds >= 1800000,
        unlockedAt: totalDurationUnlocks['500h'],
        progress: (totalDurationSeconds / 1800000).clamp(0.0, 1.0),
        currentValue: totalDurationSeconds / 3600.0,
        targetValue: 500,
      ),

      // === 5. Treadmill ===
      Achievement(
        id: 'treadmill_first',
        titleKo: '러너의 탄생',
        titleEn: 'First Run',
        descriptionKo: '트레드밀에서 러닝 세션을 완료했습니다.',
        descriptionEn: 'Completed a treadmill running session.',
        icon: Icons.directions_run,
        gradientColors: [Colors.blue, Colors.cyan],
        isUnlocked: treadmillList.isNotEmpty,
        unlockedAt: treadmillList.isNotEmpty ? treadmillList.first.dateTime : null,
        progress: treadmillList.isNotEmpty ? 1.0 : 0.0,
        currentValue: treadmillList.length,
        targetValue: 1,
      ),
      Achievement(
        id: 'treadmill_runs_10',
        titleKo: '트레드밀 마니아',
        titleEn: 'Treadmill Fan',
        descriptionKo: '트레드밀 세션을 10회 완료했습니다.',
        descriptionEn: 'Completed 10 treadmill running sessions.',
        icon: Icons.directions_run,
        gradientColors: [Colors.blue.shade400, Colors.teal.shade300],
        isUnlocked: treadmillList.length >= 10,
        unlockedAt: treadmillList.length >= 10 ? treadmillList[9].dateTime : null,
        progress: (treadmillList.length / 10).clamp(0.0, 1.0),
        currentValue: treadmillList.length,
        targetValue: 10,
      ),
      Achievement(
        id: 'treadmill_runs_50',
        titleKo: '길들여진 벨트',
        titleEn: 'Belt Tamer',
        descriptionKo: '트레드밀 세션을 50회 완료했습니다.',
        descriptionEn: 'Completed 50 treadmill running sessions.',
        icon: Icons.directions_run,
        gradientColors: [Colors.indigo, Colors.blue],
        isUnlocked: treadmillList.length >= 50,
        unlockedAt: treadmillList.length >= 50 ? treadmillList[49].dateTime : null,
        progress: (treadmillList.length / 50).clamp(0.0, 1.0),
        currentValue: treadmillList.length,
        targetValue: 50,
      ),
      Achievement(
        id: 'treadmill_runs_100',
        titleKo: '벨트 위의 마에스트로',
        titleEn: 'Treadmill Maestro',
        descriptionKo: '트레드밀 세션을 100회 완료했습니다.',
        descriptionEn: 'Completed 100 treadmill running sessions.',
        icon: Icons.directions_run,
        gradientColors: [Colors.purple, Colors.pink],
        isUnlocked: treadmillList.length >= 100,
        unlockedAt: treadmillList.length >= 100 ? treadmillList[99].dateTime : null,
        progress: (treadmillList.length / 100).clamp(0.0, 1.0),
        currentValue: treadmillList.length,
        targetValue: 100,
      ),
      Achievement(
        id: 'treadmill_dist_10k',
        titleKo: '첫 번째 관문',
        titleEn: 'Treadmill 10k',
        descriptionKo: '트레드밀 누적 거리 10km를 달성했습니다.',
        descriptionEn: 'Cumulative treadmill distance reached 10 km.',
        icon: Icons.map,
        gradientColors: [Colors.orange.shade300, Colors.red.shade300],
        isUnlocked: totalTreadmillDistanceMeters >= 10000,
        unlockedAt: treadmillDistanceUnlocks['10k'],
        progress: (totalTreadmillDistanceMeters / 10000).clamp(0.0, 1.0),
        currentValue: totalTreadmillDistanceMeters / 1000.0,
        targetValue: 10,
      ),
      Achievement(
        id: 'treadmill_marathon',
        titleKo: '방구석 마라토너',
        titleEn: 'Marathoner',
        descriptionKo: '트레드밀 누적 거리 42.195km를 달성했습니다.',
        descriptionEn: 'Cumulative treadmill distance reached 42.195 km.',
        icon: Icons.explore,
        gradientColors: [Colors.purple, Colors.pink],
        isUnlocked: totalTreadmillDistanceMeters >= 42195,
        unlockedAt: treadmillDistanceUnlocks['marathon'],
        progress: (totalTreadmillDistanceMeters / 42195).clamp(0.0, 1.0),
        currentValue: totalTreadmillDistanceMeters / 1000.0,
        targetValue: 42.195,
      ),
      Achievement(
        id: 'treadmill_dist_100k',
        titleKo: '국토 대장정',
        titleEn: 'Treadmill 100k',
        descriptionKo: '트레드밀 누적 거리 100km를 달성했습니다.',
        descriptionEn: 'Cumulative treadmill distance reached 100 km.',
        icon: Icons.terrain,
        gradientColors: [Colors.cyan.shade600, Colors.teal.shade500],
        isUnlocked: totalTreadmillDistanceMeters >= 100000,
        unlockedAt: treadmillDistanceUnlocks['100k'],
        progress: (totalTreadmillDistanceMeters / 100000).clamp(0.0, 1.0),
        currentValue: totalTreadmillDistanceMeters / 1000.0,
        targetValue: 100,
      ),
      Achievement(
        id: 'treadmill_dist_500k',
        titleKo: '울트라 러너',
        titleEn: 'Ultra Runner',
        descriptionKo: '트레드밀 누적 거리 500km를 달성했습니다.',
        descriptionEn: 'Cumulative treadmill distance reached 500 km.',
        icon: Icons.hiking,
        gradientColors: [Colors.purple.shade700, Colors.indigo.shade600],
        isUnlocked: totalTreadmillDistanceMeters >= 500000,
        unlockedAt: treadmillDistanceUnlocks['500k'],
        progress: (totalTreadmillDistanceMeters / 500000).clamp(0.0, 1.0),
        currentValue: totalTreadmillDistanceMeters / 1000.0,
        targetValue: 500,
      ),
      Achievement(
        id: 'treadmill_dist_1000k',
        titleKo: '지구 한 바퀴',
        titleEn: 'Globe Trotter',
        descriptionKo: '트레드밀 누적 거리 1000km를 달성했습니다.',
        descriptionEn: 'Cumulative treadmill distance reached 1000 km.',
        icon: Icons.public,
        gradientColors: [Colors.red.shade600, Colors.yellow.shade700],
        isUnlocked: totalTreadmillDistanceMeters >= 1000000,
        unlockedAt: treadmillDistanceUnlocks['1000k'],
        progress: (totalTreadmillDistanceMeters / 1000000).clamp(0.0, 1.0),
        currentValue: totalTreadmillDistanceMeters / 1000.0,
        targetValue: 1000,
      ),
      Achievement(
        id: 'treadmill_5k',
        titleKo: '5K 질주',
        titleEn: '5K Run',
        descriptionKo: '단일 세션에서 5km 이상 달렸습니다.',
        descriptionEn: 'Completed a single run of at least 5 km.',
        icon: Icons.run_circle,
        gradientColors: [Colors.amber.shade600, Colors.orange.shade500],
        isUnlocked: treadmill5kUnlockDate != null,
        unlockedAt: treadmill5kUnlockDate,
        progress: maxTreadmillDistance >= 5000 ? 1.0 : (maxTreadmillDistance / 5000).clamp(0.0, 1.0),
        currentValue: maxTreadmillDistance / 1000.0,
        targetValue: 5,
      ),
      Achievement(
        id: 'treadmill_10k',
        titleKo: '10K 정복',
        titleEn: '10K Run',
        descriptionKo: '단일 세션에서 10km 이상 달렸습니다.',
        descriptionEn: 'Completed a single run of at least 10 km.',
        icon: Icons.run_circle,
        gradientColors: [Colors.purple.shade500, Colors.deepPurple.shade600],
        isUnlocked: treadmill10kUnlockDate != null,
        unlockedAt: treadmill10kUnlockDate,
        progress: maxTreadmillDistance >= 10000 ? 1.0 : (maxTreadmillDistance / 10000).clamp(0.0, 1.0),
        currentValue: maxTreadmillDistance / 1000.0,
        targetValue: 10,
      ),
      Achievement(
        id: 'treadmill_half_marathon',
        titleKo: '하프 메달리스트',
        titleEn: 'Half Marathon',
        descriptionKo: '단일 세션에서 하프 마라톤 거리(21.0975km) 이상을 완료했습니다.',
        descriptionEn: 'Completed a single run of at least 21.0975 km.',
        icon: Icons.emoji_events,
        gradientColors: [Colors.red.shade600, Colors.pink.shade500],
        isUnlocked: treadmillHalfMarathonUnlockDate != null,
        unlockedAt: treadmillHalfMarathonUnlockDate,
        progress: maxTreadmillDistance >= 21097.5 ? 1.0 : (maxTreadmillDistance / 21097.5).clamp(0.0, 1.0),
        currentValue: maxTreadmillDistance / 1000.0,
        targetValue: 21.0975,
      ),
      Achievement(
        id: 'treadmill_speed_12',
        titleKo: '페이스 러너',
        titleEn: 'Pace Runner',
        descriptionKo: '트레드밀에서 평균 속도 12 km/h 이상을 기록했습니다.',
        descriptionEn: 'Recorded an average speed of 12 km/h or more.',
        icon: Icons.speed,
        gradientColors: [Colors.cyan, Colors.blue],
        isUnlocked: speed12UnlockDate != null,
        unlockedAt: speed12UnlockDate,
        progress: maxSpeedKmh >= 12.0 ? 1.0 : (maxSpeedKmh / 12.0).clamp(0.0, 1.0),
        currentValue: maxSpeedKmh,
        targetValue: 12,
      ),
      Achievement(
        id: 'treadmill_speed_16',
        titleKo: '바람의 인도자',
        titleEn: 'Wind Rider',
        descriptionKo: '트레드밀에서 평균 속도 16 km/h 이상을 기록했습니다.',
        descriptionEn: 'Recorded an average speed of 16 km/h or more.',
        icon: Icons.speed,
        gradientColors: [Colors.orange, Colors.red],
        isUnlocked: speed16UnlockDate != null,
        unlockedAt: speed16UnlockDate,
        progress: maxSpeedKmh >= 16.0 ? 1.0 : (maxSpeedKmh / 16.0).clamp(0.0, 1.0),
        currentValue: maxSpeedKmh,
        targetValue: 16,
      ),
      Achievement(
        id: 'treadmill_speed_20',
        titleKo: '음속의 벽',
        titleEn: 'Sonic Boom',
        descriptionKo: '트레드밀에서 평균 속도 20 km/h 이상을 기록했습니다.',
        descriptionEn: 'Recorded an average speed of 20 km/h or more.',
        icon: Icons.speed,
        gradientColors: [Colors.indigo, Colors.black],
        isUnlocked: speed20UnlockDate != null,
        unlockedAt: speed20UnlockDate,
        progress: maxSpeedKmh >= 20.0 ? 1.0 : (maxSpeedKmh / 20.0).clamp(0.0, 1.0),
        currentValue: maxSpeedKmh,
        targetValue: 20,
      ),

      // === 6. Cycling ===
      Achievement(
        id: 'cycle_first',
        titleKo: '페달의 시작',
        titleEn: 'First Ride',
        descriptionKo: '사이클에서 라이딩 세션을 완료했습니다.',
        descriptionEn: 'Completed a cycling session.',
        icon: Icons.directions_bike,
        gradientColors: [Colors.green, Colors.teal],
        isUnlocked: cycleList.isNotEmpty,
        unlockedAt: cycleList.isNotEmpty ? cycleList.first.dateTime : null,
        progress: cycleList.isNotEmpty ? 1.0 : 0.0,
        currentValue: cycleList.length,
        targetValue: 1,
      ),
      Achievement(
        id: 'cycle_rides_10',
        titleKo: '사이클 매니아',
        titleEn: 'Cycle Enthusiast',
        descriptionKo: '사이클 세션을 10회 완료했습니다.',
        descriptionEn: 'Completed 10 cycling sessions.',
        icon: Icons.directions_bike,
        gradientColors: [Colors.teal.shade300, Colors.green.shade400],
        isUnlocked: cycleList.length >= 10,
        unlockedAt: cycleList.length >= 10 ? cycleList[9].dateTime : null,
        progress: (cycleList.length / 10).clamp(0.0, 1.0),
        currentValue: cycleList.length,
        targetValue: 10,
      ),
      Achievement(
        id: 'cycle_rides_50',
        titleKo: '도로의 지배자',
        titleEn: 'Road Conqueror',
        descriptionKo: '사이클 세션을 50회 완료했습니다.',
        descriptionEn: 'Completed 50 cycling sessions.',
        icon: Icons.directions_bike,
        gradientColors: [Colors.blue.shade600, Colors.teal.shade500],
        isUnlocked: cycleList.length >= 50,
        unlockedAt: cycleList.length >= 50 ? cycleList[49].dateTime : null,
        progress: (cycleList.length / 50).clamp(0.0, 1.0),
        currentValue: cycleList.length,
        targetValue: 50,
      ),
      Achievement(
        id: 'cycle_rides_100',
        titleKo: '강철 허벅지',
        titleEn: 'Golden Pedalist',
        descriptionKo: '사이클 세션을 100회 완료했습니다.',
        descriptionEn: 'Completed 100 cycling sessions.',
        icon: Icons.directions_bike,
        gradientColors: [Colors.amber.shade700, Colors.orange.shade600],
        isUnlocked: cycleList.length >= 100,
        unlockedAt: cycleList.length >= 100 ? cycleList[99].dateTime : null,
        progress: (cycleList.length / 100).clamp(0.0, 1.0),
        currentValue: cycleList.length,
        targetValue: 100,
      ),
      Achievement(
        id: 'cycle_rpm',
        titleKo: '페달 마스터',
        titleEn: 'RPM Master',
        descriptionKo: '사이클 세션에서 평균 90 RPM 이상을 기록했습니다.',
        descriptionEn: 'Completed a cycling session with an average RPM of 90+.',
        icon: Icons.rotate_right,
        gradientColors: [Colors.lightGreen, Colors.teal],
        isUnlocked: rpm90UnlockDate != null,
        unlockedAt: rpm90UnlockDate,
        progress: maxAvgRpm >= 90 ? 1.0 : (maxAvgRpm / 90).clamp(0.0, 1.0),
        currentValue: maxAvgRpm,
        targetValue: 90,
      ),
      Achievement(
        id: 'cycle_rpm_100',
        titleKo: '케이드 엔진',
        titleEn: 'Cadence Engine',
        descriptionKo: '사이클 세션에서 평균 100 RPM 이상을 기록했습니다.',
        descriptionEn: 'Completed a cycling session with an average RPM of 100+.',
        icon: Icons.loop,
        gradientColors: [Colors.orange, Colors.amber],
        isUnlocked: rpm100UnlockDate != null,
        unlockedAt: rpm100UnlockDate,
        progress: maxAvgRpm >= 100 ? 1.0 : (maxAvgRpm / 100).clamp(0.0, 1.0),
        currentValue: maxAvgRpm,
        targetValue: 100,
      ),
      Achievement(
        id: 'cycle_rpm_110',
        titleKo: '하이퍼 로테이터',
        titleEn: 'Hyper Rotator',
        descriptionKo: '사이클 세션에서 평균 110 RPM 이상을 기록했습니다.',
        descriptionEn: 'Completed a cycling session with an average RPM of 110+.',
        icon: Icons.bolt,
        gradientColors: [Colors.red, Colors.pink],
        isUnlocked: rpm110UnlockDate != null,
        unlockedAt: rpm110UnlockDate,
        progress: maxAvgRpm >= 110 ? 1.0 : (maxAvgRpm / 110).clamp(0.0, 1.0),
        currentValue: maxAvgRpm,
        targetValue: 110,
      ),
      Achievement(
        id: 'cycle_dist_50k',
        titleKo: '첫 교외 라이딩',
        titleEn: 'Cycling 50k',
        descriptionKo: '사이클 누적 거리 50km를 달성했습니다.',
        descriptionEn: 'Cumulative cycling distance reached 50 km.',
        icon: Icons.map,
        gradientColors: [Colors.teal.shade300, Colors.blue.shade300],
        isUnlocked: totalCycleDistanceMeters >= 50000,
        unlockedAt: cycleDistanceUnlocks['50k'],
        progress: (totalCycleDistanceMeters / 50000).clamp(0.0, 1.0),
        currentValue: totalCycleDistanceMeters / 1000.0,
        targetValue: 50,
      ),
      Achievement(
        id: 'cycle_dist_200k',
        titleKo: '국토 순례',
        titleEn: 'Cycling 200k',
        descriptionKo: '사이클 누적 거리 200km를 달성했습니다.',
        descriptionEn: 'Cumulative cycling distance reached 200 km.',
        icon: Icons.terrain,
        gradientColors: [Colors.indigo.shade400, Colors.purple.shade400],
        isUnlocked: totalCycleDistanceMeters >= 200000,
        unlockedAt: cycleDistanceUnlocks['200k'],
        progress: (totalCycleDistanceMeters / 200000).clamp(0.0, 1.0),
        currentValue: totalCycleDistanceMeters / 1000.0,
        targetValue: 200,
      ),
      Achievement(
        id: 'cycle_dist_500k',
        titleKo: '장거리 투어러',
        titleEn: 'Long Tourer',
        descriptionKo: '사이클 누적 거리 500km를 달성했습니다.',
        descriptionEn: 'Cumulative cycling distance reached 500 km.',
        icon: Icons.hiking,
        gradientColors: [Colors.amber.shade700, Colors.red.shade600],
        isUnlocked: totalCycleDistanceMeters >= 500000,
        unlockedAt: cycleDistanceUnlocks['500k'],
        progress: (totalCycleDistanceMeters / 500000).clamp(0.0, 1.0),
        currentValue: totalCycleDistanceMeters / 1000.0,
        targetValue: 500,
      ),
      Achievement(
        id: 'cycle_dist_1000k',
        titleKo: '백만 미터 라이더',
        titleEn: 'Million Meter Rider',
        descriptionKo: '사이클 누적 거리 1000km를 달성했습니다.',
        descriptionEn: 'Cumulative cycling distance reached 1000 km.',
        icon: Icons.public,
        gradientColors: [Colors.purple.shade700, Colors.black],
        isUnlocked: totalCycleDistanceMeters >= 1000000,
        unlockedAt: cycleDistanceUnlocks['1000k'],
        progress: (totalCycleDistanceMeters / 1000000).clamp(0.0, 1.0),
        currentValue: totalCycleDistanceMeters / 1000.0,
        targetValue: 1000,
      ),

      // === 7. Stairmaster ===
      Achievement(
        id: 'stairmaster_first',
        titleKo: '천국의 첫 계단',
        titleEn: 'First Step',
        descriptionKo: 'Stairmaster에서 운동 세션을 완료했습니다.',
        descriptionEn: 'Completed a Stairmaster stepmill session.',
        icon: Icons.filter_hdr,
        gradientColors: [Colors.pink, Colors.red],
        isUnlocked: stairmasterList.isNotEmpty,
        unlockedAt: stairmasterList.isNotEmpty ? stairmasterList.first.dateTime : null,
        progress: stairmasterList.isNotEmpty ? 1.0 : 0.0,
        currentValue: stairmasterList.length,
        targetValue: 1,
      ),
      Achievement(
        id: 'stairmaster_climbs_10',
        titleKo: '등반 유망주',
        titleEn: 'Climber Apprentice',
        descriptionKo: 'Stairmaster 세션을 10회 완료했습니다.',
        descriptionEn: 'Completed 10 Stairmaster sessions.',
        icon: Icons.filter_hdr,
        gradientColors: [Colors.pink.shade400, Colors.orange.shade400],
        isUnlocked: stairmasterList.length >= 10,
        unlockedAt: stairmasterList.length >= 10 ? stairmasterList[9].dateTime : null,
        progress: (stairmasterList.length / 10).clamp(0.0, 1.0),
        currentValue: stairmasterList.length,
        targetValue: 10,
      ),
      Achievement(
        id: 'stairmaster_climbs_50',
        titleKo: '에베레스트 원정대',
        titleEn: 'Everest Expedition',
        descriptionKo: 'Stairmaster 세션을 50회 완료했습니다.',
        descriptionEn: 'Completed 50 Stairmaster sessions.',
        icon: Icons.filter_hdr,
        gradientColors: [Colors.purple.shade600, Colors.pink.shade500],
        isUnlocked: stairmasterList.length >= 50,
        unlockedAt: stairmasterList.length >= 50 ? stairmasterList[49].dateTime : null,
        progress: (stairmasterList.length / 50).clamp(0.0, 1.0),
        currentValue: stairmasterList.length,
        targetValue: 50,
      ),
      Achievement(
        id: 'stairmaster_climbs_100',
        titleKo: '천국의 지배자',
        titleEn: 'Master of Stairs',
        descriptionKo: 'Stairmaster 세션을 100회 완료했습니다.',
        descriptionEn: 'Completed 100 Stairmaster sessions.',
        icon: Icons.military_tech,
        gradientColors: [Colors.amber.shade700, Colors.red.shade600],
        isUnlocked: stairmasterList.length >= 100,
        unlockedAt: stairmasterList.length >= 100 ? stairmasterList[99].dateTime : null,
        progress: (stairmasterList.length / 100).clamp(0.0, 1.0),
        currentValue: stairmasterList.length,
        targetValue: 100,
      ),
      Achievement(
        id: 'stairmaster_level',
        titleKo: '중력 거스르기',
        titleEn: 'Everest Level',
        descriptionKo: 'Stairmaster 세션에서 평균 레벨 10 이상을 완료했습니다.',
        descriptionEn: 'Completed a Stairmaster session with an average level of 10+.',
        icon: Icons.arrow_upward,
        gradientColors: [Colors.indigo, Colors.purple],
        isUnlocked: lvl10UnlockDate != null,
        unlockedAt: lvl10UnlockDate,
        progress: maxAvgLevel >= 10 ? 1.0 : (maxAvgLevel / 10).clamp(0.0, 1.0),
        currentValue: maxAvgLevel,
        targetValue: 10,
      ),
      Achievement(
        id: 'stairmaster_level_12',
        titleKo: '고산 지대',
        titleEn: 'High Altitude',
        descriptionKo: 'Stairmaster 세션에서 평균 레벨 12 이상을 완료했습니다.',
        descriptionEn: 'Completed a Stairmaster session with an average level of 12+.',
        icon: Icons.arrow_upward,
        gradientColors: [Colors.red, Colors.deepOrange],
        isUnlocked: lvl12UnlockDate != null,
        unlockedAt: lvl12UnlockDate,
        progress: maxAvgLevel >= 12 ? 1.0 : (maxAvgLevel / 12).clamp(0.0, 1.0),
        currentValue: maxAvgLevel,
        targetValue: 12,
      ),
      Achievement(
        id: 'stairmaster_level_15',
        titleKo: '구름 위의 등반가',
        titleEn: 'Cloud Climber',
        descriptionKo: 'Stairmaster 세션에서 평균 레벨 15 이상을 완료했습니다.',
        descriptionEn: 'Completed a Stairmaster session with an average level of 15+.',
        icon: Icons.arrow_upward,
        gradientColors: [Colors.purple.shade900, Colors.black],
        isUnlocked: lvl15UnlockDate != null,
        unlockedAt: lvl15UnlockDate,
        progress: maxAvgLevel >= 15 ? 1.0 : (maxAvgLevel / 15).clamp(0.0, 1.0),
        currentValue: maxAvgLevel,
        targetValue: 15,
      ),
      Achievement(
        id: 'stairmaster_time_10h',
        titleKo: '천국의 시간 계단',
        titleEn: '10h Stairmaster',
        descriptionKo: 'Stairmaster 누적 운동 시간 10시간을 달성했습니다.',
        descriptionEn: 'Cumulative Stairmaster duration reached 10 hours.',
        icon: Icons.hourglass_bottom,
        gradientColors: [Colors.orange.shade700, Colors.red.shade800],
        isUnlocked: stairmasterDurationSeconds >= 36000,
        unlockedAt: stairmaster10hUnlockDate,
        progress: (stairmasterDurationSeconds / 36000).clamp(0.0, 1.0),
        currentValue: stairmasterDurationSeconds / 3600.0,
        targetValue: 10,
      ),
    ];
  }

  _StreakData _calculateStreakData(List<WorkoutSession> sorted) {
    if (sorted.isEmpty) {
      return _StreakData(0, {});
    }

    final uniqueDates = sorted.map((s) {
      final d = s.dateTime;
      return DateTime(d.year, d.month, d.day);
    }).toSet().toList()..sort();

    int maxStreak = 1;
    int currentStreak = 1;
    final Map<int, DateTime> streakUnlockDates = {};

    // Helper to record unlock dates for any streak threshold
    void recordStreakUnlock(int streak, DateTime date) {
      if (!streakUnlockDates.containsKey(streak)) {
        // Find corresponding session on this day
        final session = sorted.firstWhere((s) {
          final sd = s.dateTime;
          return sd.year == date.year && sd.month == date.month && sd.day == date.day;
        });
        streakUnlockDates[streak] = session.dateTime;
      }
    }

    if (uniqueDates.isNotEmpty) {
      recordStreakUnlock(1, uniqueDates[0]);
    }

    for (int i = 1; i < uniqueDates.length; i++) {
      final diff = uniqueDates[i].difference(uniqueDates[i - 1]).inDays;
      if (diff == 1) {
        currentStreak++;
        if (currentStreak > maxStreak) {
          maxStreak = currentStreak;
        }
        recordStreakUnlock(currentStreak, uniqueDates[i]);
      } else if (diff > 1) {
        currentStreak = 1;
        recordStreakUnlock(currentStreak, uniqueDates[i]);
      }
    }

    return _StreakData(maxStreak, streakUnlockDates);
  }
}

class _StreakData {
  final int maxStreak;
  final Map<int, DateTime> streakUnlockDates;

  _StreakData(this.maxStreak, this.streakUnlockDates);
}
