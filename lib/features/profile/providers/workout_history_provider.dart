import 'package:flutter/foundation.dart';
import '../models/workout_session.dart';
import '../storage/workout_session_storage.dart';
import '../../routines/models/machine_type.dart';

class WorkoutHistoryProvider with ChangeNotifier {
  final WorkoutSessionStorage _storage = WorkoutSessionStorage();
  List<WorkoutSession> _sessions = [];
  bool _isLoading = false;

  List<WorkoutSession> get sessions => _sessions;
  bool get isLoading => _isLoading;

  WorkoutHistoryProvider() {
    loadSessions();
  }

  Future<void> loadSessions() async {
    _isLoading = true;
    notifyListeners();
    _sessions = await _storage.loadSessions();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSession(WorkoutSession session) async {
    await _storage.addSession(session);
    await loadSessions();
  }

  Future<void> deleteSession(String id) async {
    await _storage.deleteSession(id);
    await loadSessions();
  }

  List<WorkoutSession> getSessionsByMachineType(MachineType machineType) {
    return _sessions.where((s) => s.machineType == machineType).toList();
  }

  List<WorkoutSession> getSessionsByDate(DateTime date) {
    return _sessions.where((s) {
      return s.dateTime.year == date.year &&
          s.dateTime.month == date.month &&
          s.dateTime.day == date.day;
    }).toList();
  }

  bool hasWorkoutOnDate(DateTime date) {
    return getSessionsByDate(date).isNotEmpty;
  }
}

