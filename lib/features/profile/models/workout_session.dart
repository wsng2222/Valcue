import '../../routines/models/machine_type.dart';

/// Represents a completed workout session
class WorkoutSession {
  final String id;
  final MachineType machineType;
  final DateTime dateTime;
  final int durationSeconds;
  final int? elapsedMilliseconds;

  // Machine-specific metrics
  final double? distanceMeters; // Treadmill
  final double? averageRpm; // Bike
  final double? averageLevel; // Stairmaster

  // Routine info
  final String routineName;
  final String routineId;

  WorkoutSession({
    String? id,
    required this.machineType,
    required this.dateTime,
    required this.durationSeconds,
    this.elapsedMilliseconds,
    this.distanceMeters,
    this.averageRpm,
    this.averageLevel,
    required this.routineName,
    required this.routineId,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'machineType': machineType.toJson(),
      'dateTime': dateTime.toIso8601String(),
      'durationSeconds': durationSeconds,
      'elapsedMilliseconds': elapsedMilliseconds,
      'distanceMeters': distanceMeters,
      'averageRpm': averageRpm,
      'averageLevel': averageLevel,
      'routineName': routineName,
      'routineId': routineId,
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as String,
      machineType: MachineType.fromJson(json['machineType'] as String),
      dateTime: DateTime.parse(json['dateTime'] as String),
      durationSeconds: (json['durationSeconds'] as num).toInt(),
      elapsedMilliseconds: (json['elapsedMilliseconds'] as num?)?.toInt(),
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
      averageRpm: (json['averageRpm'] as num?)?.toDouble(),
      averageLevel: (json['averageLevel'] as num?)?.toDouble(),
      routineName: json['routineName'] as String,
      routineId: json['routineId'] as String,
    );
  }

  /// Get the key metric for this machine type
  String? getKeyMetric() {
    switch (machineType) {
      case MachineType.treadmill:
        return distanceMeters != null
            ? '${distanceMeters!.toStringAsFixed(2)} m'
            : null;
      case MachineType.cycle:
        return averageRpm != null
            ? '${averageRpm!.toStringAsFixed(1)} RPM'
            : null;
      case MachineType.stairmaster:
        return averageLevel != null
            ? 'Level ${averageLevel!.toStringAsFixed(1)}'
            : null;
    }
  }
}
