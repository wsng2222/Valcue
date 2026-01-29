import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../routines/models/routine.dart';
import '../../routines/models/interval.dart';
import '../../routines/models/machine_type.dart';
import '../../../services/sound_service.dart';

enum WorkoutStatus {
  running,
  paused,
  resumingCountdown,
  finished,
  stopped,
}

class WorkoutState extends ChangeNotifier {
  final Routine routine;
  final DateTime startTime;

  // Store initial total duration ONCE at workout start
  final int initialTotalSeconds;

  int _currentIntervalIndex = 0;
  int _remainingSeconds = 0;
  int _totalElapsedSeconds = 0;
  WorkoutStatus _status = WorkoutStatus.running;
  bool _stoppedEarly = false;

  Timer? _timer;
  Timer? _countdownTimer;
  int _countdownNumber = 3;

  // Distance tracking for treadmill workouts
  double _distanceMeters = 0.0;
  DateTime? _lastTickTime;
  Timer? _distanceTimer;

  // Flag to prevent double-playing finished sound effect
  bool _finishedSfxPlayed = false;

  WorkoutState({
    required this.routine,
    required this.startTime,
  }) : initialTotalSeconds = routine.totalDurationSeconds {
    _initializeWorkout();
  }

  void _initializeWorkout() {
    // Reset flag on workout start
    _finishedSfxPlayed = false;

    if (routine.intervals.isEmpty) {
      _status = WorkoutStatus.finished;
      _playFinishSfxOnce();
      notifyListeners();
      return;
    }

    _currentIntervalIndex = 0;
    _remainingSeconds = routine.intervals[0].durationSeconds;
    // Start with countdown instead of immediately starting the timer
    startInitialCountdown();
  }

  int get currentIntervalIndex => _currentIntervalIndex;
  int get remainingSeconds => _remainingSeconds;
  int get totalElapsedSeconds => _totalElapsedSeconds;
  WorkoutStatus get status => _status;
  bool get stoppedEarly => _stoppedEarly;
  int get countdownNumber => _countdownNumber;

  Interval get currentInterval => routine.intervals[_currentIntervalIndex];
  int get totalIntervals => routine.intervals.length;

  int get totalRemainingSeconds {
    int remaining = _remainingSeconds;
    for (int i = _currentIntervalIndex + 1; i < routine.intervals.length; i++) {
      remaining += routine.intervals[i].durationSeconds;
    }
    return remaining;
  }

  int get totalDurationSeconds {
    return routine.totalDurationSeconds;
  }

  double get currentIntervalProgress {
    final intervalTotalSeconds = currentInterval.durationSeconds;
    if (intervalTotalSeconds == 0) return 0.0;
    final elapsed = intervalTotalSeconds - _remainingSeconds;
    final progress = elapsed / intervalTotalSeconds;
    // Ensure progress reaches 1.0 when interval is complete
    return progress.clamp(0.0, 1.0);
  }

  double get totalWorkoutProgress {
    final total = totalDurationSeconds;
    if (total == 0) return 0.0;
    return _totalElapsedSeconds / total;
  }

  // Progress for the circular ring: remaining / initial (decreases as time passes)
  double get totalRemainingProgress {
    if (initialTotalSeconds == 0) return 0.0;
    final progress = totalRemainingSeconds / initialTotalSeconds;
    return progress.clamp(0.0, 1.0);
  }

  int get currentIntervalElapsedSeconds {
    final intervalTotalSeconds = currentInterval.durationSeconds;
    return intervalTotalSeconds - _remainingSeconds;
  }

  double get distanceMeters => _distanceMeters;

  bool get isTreadmill => routine.machineType == MachineType.treadmill;

  void _startTimer() {
    _status = WorkoutStatus.running;
    _timer?.cancel();

    // Initialize distance tracking for treadmill
    if (isTreadmill) {
      _lastTickTime = DateTime.now();
      _startDistanceTracking();
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_status != WorkoutStatus.running) {
        return;
      }

      _remainingSeconds--;
      _totalElapsedSeconds++;

      // If interval is complete, ensure _remainingSeconds is 0 (not negative)
      // so progress calculation shows exactly 1.0
      if (_remainingSeconds < 0) {
        _remainingSeconds = 0;
      }

      // Notify listeners with progress = 1.0 when interval completes
      notifyListeners();

      // After notifying with progress = 1.0, advance to next interval
      if (_remainingSeconds == 0) {
        _advanceToNextInterval();
        notifyListeners();
      }
    });
  }

  void _startDistanceTracking() {
    _distanceTimer?.cancel();
    _lastTickTime = DateTime.now();

    // Update distance every 500ms for smooth tracking
    _distanceTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_status != WorkoutStatus.running || !isTreadmill) {
        return;
      }

      _updateDistance();
    });
  }

  void _updateDistance() {
    if (_lastTickTime == null || !isTreadmill) return;

    final now = DateTime.now();
    final deltaSeconds = now.difference(_lastTickTime!).inMilliseconds / 1000.0;

    if (deltaSeconds <= 0) return;

    // Get current speed in km/h
    final currentSpeedKmh = currentInterval.speedKmh ?? 0.0;
    if (currentSpeedKmh <= 0) {
      _lastTickTime = now;
      return;
    }

    // Calculate distance: speed (km/h) * time (hours) = distance (km)
    // Convert to meters: km * 1000 = meters
    // speedKmh * 1000 / 3600 = meters per second
    final distanceIncrement =
        (currentSpeedKmh * 1000.0 / 3600.0) * deltaSeconds;
    _distanceMeters += distanceIncrement;

    _lastTickTime = now;
    notifyListeners();
  }

  void _finalizeDistance() {
    // Final distance update before stopping
    if (isTreadmill && _lastTickTime != null) {
      _updateDistance();
    }
  }

  /// Play the finished sound effect exactly once per workout
  void _playFinishSfxOnce() {
    if (!_finishedSfxPlayed) {
      _finishedSfxPlayed = true;
      SoundService().playFinished();
    }
  }

  void _advanceToNextInterval() {
    // Finalize distance up to now before changing speed
    if (isTreadmill) {
      _finalizeDistance();
    }

    if (_currentIntervalIndex < routine.intervals.length - 1) {
      _currentIntervalIndex++;
      _remainingSeconds =
          routine.intervals[_currentIntervalIndex].durationSeconds;
      // Play beep on session transition
      SoundService().playBeep();
    } else {
      _finishWorkout();
    }
  }

  void _finishWorkout() {
    _timer?.cancel();
    if (isTreadmill) {
      _finalizeDistance();
      _distanceTimer?.cancel();
    }
    // Play finished sound before marking as finished
    _playFinishSfxOnce();
    _status = WorkoutStatus.finished;
    notifyListeners();
  }

  void stopWorkout() {
    _timer?.cancel();
    if (isTreadmill) {
      _finalizeDistance();
      _distanceTimer?.cancel();
    }
    // Play finished sound when user confirms stop
    _playFinishSfxOnce();
    _status = WorkoutStatus.stopped;
    _stoppedEarly = true;
    notifyListeners();
  }

  void pauseWorkout() {
    if (_status == WorkoutStatus.running) {
      _status = WorkoutStatus.paused;
      _timer?.cancel();
      if (isTreadmill) {
        // Finalize distance up to pause moment
        _finalizeDistance();
        _distanceTimer?.cancel();
        _lastTickTime = null; // Reset so we don't accumulate during pause
      }
      notifyListeners();
    }
  }

  void startInitialCountdown() {
    // Start countdown when workout first begins
    _status = WorkoutStatus.resumingCountdown;
    _countdownNumber = 3;
    _countdownTimer?.cancel();
    // Play beep for initial countdown number 3
    print('[WorkoutState] startInitialCountdown - playing beep for $_countdownNumber');
    SoundService().playBeep();
    notifyListeners();

    // Start countdown immediately, then tick every 900ms
    _countdownTimer =
        Timer.periodic(const Duration(milliseconds: 900), (timer) {
      _countdownNumber--;
      print('[WorkoutState] Countdown tick - number: $_countdownNumber');
      // Play beep for countdown numbers 3, 2, 1
      if (_countdownNumber >= 1) {
        print('[WorkoutState] Playing beep for $_countdownNumber');
        SoundService().playBeep();
      }
      notifyListeners();

      if (_countdownNumber <= 0) {
        timer.cancel();
        _countdownTimer = null;
        _startTimer(); // Start workout timer after countdown
      }
    });
  }

  void startResumeCountdown() {
    if (_status == WorkoutStatus.paused) {
      _status = WorkoutStatus.resumingCountdown;
      _countdownNumber = 3;
      _countdownTimer?.cancel();
      // Play beep for initial countdown number 3
      print('[WorkoutState] startResumeCountdown - playing beep for $_countdownNumber');
      SoundService().playBeep();
      notifyListeners();

      // Start countdown immediately, then tick every 900ms
      _countdownTimer =
          Timer.periodic(const Duration(milliseconds: 900), (timer) {
        _countdownNumber--;
        print('[WorkoutState] Resume countdown tick - number: $_countdownNumber');
        // Play beep for countdown numbers 3, 2, 1
        if (_countdownNumber >= 1) {
          print('[WorkoutState] Playing beep for $_countdownNumber');
          SoundService().playBeep();
        }
        notifyListeners();

        if (_countdownNumber <= 0) {
          timer.cancel();
          _countdownTimer = null;
          _startTimer(); // Start workout timer after countdown (will restart distance tracking)
        }
      });
    }
  }

  void resumeWorkout() {
    // Legacy method - now starts countdown instead
    startResumeCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    _distanceTimer?.cancel();
    super.dispose();
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String formatTotalTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
