import 'package:flutter/foundation.dart';
import '../models/weight_entry.dart';
import '../storage/weight_storage.dart';

class WeightTrackerProvider with ChangeNotifier {
  final WeightStorage _storage = WeightStorage();
  List<WeightEntry> _entries = [];
  double? _goalWeight;
  bool _isLoading = false;

  List<WeightEntry> get entries => _entries;
  double? get goalWeight => _goalWeight;
  bool get isLoading => _isLoading;

  WeightEntry? get currentWeight => _entries.isNotEmpty ? _entries.first : null;

  WeightTrackerProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    _entries = await _storage.loadEntries();
    _goalWeight = await _storage.getGoalWeight();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addEntry(WeightEntry entry) async {
    await _storage.addEntry(entry);
    await loadData();
  }

  Future<void> deleteEntry(String id) async {
    await _storage.deleteEntry(id);
    await loadData();
  }

  Future<void> updateEntry(String id, WeightEntry entry) async {
    await _storage.updateEntry(id, entry);
    await loadData();
  }

  Future<void> setGoalWeight(double? weightKg) async {
    await _storage.setGoalWeight(weightKg);
    _goalWeight = weightKg;
    notifyListeners();
  }

  /// Get weight change from previous entry
  double? getWeightChange() {
    if (_entries.length < 2) return null;
    return _entries[0].weightKg - _entries[1].weightKg;
  }

  /// Get weight change from N days ago
  double? getWeightChangeFromDaysAgo(int days) {
    if (_entries.isEmpty) return null;
    final targetDate = DateTime.now().subtract(Duration(days: days));
    final targetEntry = _entries.firstWhere(
      (e) => e.dateTime.isBefore(targetDate) || e.dateTime.isAtSameMomentAs(targetDate),
      orElse: () => _entries.last,
    );
    return _entries.first.weightKg - targetEntry.weightKg;
  }

  /// Get average weight over last N entries
  double? getAverageWeight(int count) {
    if (_entries.isEmpty) return null;
    final entriesToUse = _entries.take(count).toList();
    final sum = entriesToUse.fold<double>(0.0, (sum, e) => sum + e.weightKg);
    return sum / entriesToUse.length;
  }

  /// Get weight to goal
  double? getWeightToGoal() {
    if (_entries.isEmpty || _goalWeight == null) return null;
    return _goalWeight! - _entries.first.weightKg;
  }

  /// Get entries for chart (last N entries, sorted by date ascending)
  List<WeightEntry> getChartEntries({int count = 30}) {
    return _entries.take(count).toList().reversed.toList();
  }
}

