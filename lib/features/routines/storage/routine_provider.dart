import 'package:flutter/foundation.dart';
import '../models/routine.dart';
import 'routine_storage.dart';

class RoutineProvider with ChangeNotifier {
  final RoutineStorage _storage = RoutineStorage();
  List<Routine> _routines = [];
  bool _isLoading = false;
  bool _hasLoaded = false;

  List<Routine> get routines => _routines;
  bool get isLoading => _isLoading;

  RoutineProvider() {
    loadRoutines();
  }

  Future<void> _ensureLoaded() async {
    if (_hasLoaded) {
      return;
    }
    _routines = await _storage.loadRoutines();
    _hasLoaded = true;
  }

  Future<void> loadRoutines() async {
    _isLoading = true;
    notifyListeners();
    _routines = await _storage.loadRoutines();
    _isLoading = false;
    _hasLoaded = true;
    notifyListeners();
  }

  Future<void> addRoutine(Routine routine) async {
    await _ensureLoaded();
    _routines = [..._routines, routine];
    notifyListeners();
    await _storage.saveRoutines(_routines);
  }

  Future<void> updateRoutine(Routine routine) async {
    await _ensureLoaded();
    final index = _routines.indexWhere((r) => r.id == routine.id);
    if (index == -1) {
      return;
    }
    final updated = [..._routines];
    updated[index] = routine;
    _routines = updated;
    notifyListeners();
    await _storage.saveRoutines(_routines);
  }

  Future<void> deleteRoutine(String id) async {
    await _ensureLoaded();
    _routines = _routines.where((r) => r.id != id).toList();
    notifyListeners();
    await _storage.saveRoutines(_routines);
  }
}
