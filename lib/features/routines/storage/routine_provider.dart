import 'package:flutter/foundation.dart';
import '../models/routine.dart';
import 'routine_storage.dart';

class RoutineProvider with ChangeNotifier {
  final RoutineStorage _storage = RoutineStorage();
  List<Routine> _routines = [];
  bool _isLoading = false;

  List<Routine> get routines => _routines;
  bool get isLoading => _isLoading;

  RoutineProvider() {
    loadRoutines();
  }

  Future<void> loadRoutines() async {
    _isLoading = true;
    notifyListeners();
    _routines = await _storage.loadRoutines();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addRoutine(Routine routine) async {
    await _storage.addRoutine(routine);
    await loadRoutines();
  }

  Future<void> updateRoutine(Routine routine) async {
    await _storage.updateRoutine(routine);
    await loadRoutines();
  }

  Future<void> deleteRoutine(String id) async {
    await _storage.deleteRoutine(id);
    await loadRoutines();
  }
}

