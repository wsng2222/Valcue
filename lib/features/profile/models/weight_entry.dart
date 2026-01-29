/// Represents a weight measurement entry
class WeightEntry {
  final String id;
  final DateTime dateTime;
  final double weightKg; // Always stored in kg internally

  WeightEntry({
    String? id,
    required this.dateTime,
    required this.weightKg,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'weightKg': weightKg,
    };
  }

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      id: json['id'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      weightKg: json['weightKg'] as double,
    );
  }

  /// Convert weight to pounds if needed
  double toPounds() {
    return weightKg * 2.20462;
  }

  /// Format weight based on unit preference
  String formatWeight(bool isMetric) {
    if (isMetric) {
      return '${weightKg.toStringAsFixed(1)} kg';
    } else {
      return '${toPounds().toStringAsFixed(1)} lbs';
    }
  }
}

