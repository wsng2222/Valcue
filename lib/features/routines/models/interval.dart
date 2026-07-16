import 'package:flutter/material.dart';
import 'machine_type.dart';

class Interval {
  // Stable ID for tracking intervals across edits (single source of truth)
  final String id;
  final int durationSeconds;
  
  // Treadmill fields - stored as doubles (preserve 1 decimal precision)
  final double? speedKmh;
  final double? grade;
  
  // Cycle fields
  final int? rpm;
  final int? resistance;
  
  // Stairmaster fields
  final int? level;

  // Constructor: accepts doubles for speed/grade, ints for others
  Interval({
    String? id,
    required this.durationSeconds,
    this.speedKmh,
    this.grade,
    this.rpm,
    this.resistance,
    this.level,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  // Factory constructors for each machine type
  factory Interval.treadmill({
    String? id,
    required int durationSeconds,
    required double speedKmh,
    required double grade,
  }) {
    return Interval(
      id: id,
      durationSeconds: durationSeconds,
      speedKmh: speedKmh,
      grade: grade,
    );
  }

  factory Interval.cycle({
    String? id,
    required int durationSeconds,
    required int rpm,
    required int resistance,
  }) {
    return Interval(
      id: id,
      durationSeconds: durationSeconds,
      rpm: rpm,
      resistance: resistance,
    );
  }

  factory Interval.stairmaster({
    String? id,
    required int durationSeconds,
    required int level,
  }) {
    return Interval(
      id: id,
      durationSeconds: durationSeconds,
      level: level,
    );
  }

  // Format duration as mm:ss
  String get durationFormatted {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'durationSeconds': durationSeconds,
    };
    // Always include speedKmh and grade if they exist (even if 0.0)
    if (speedKmh != null) {
      json['speedKmh'] = speedKmh;
    }
    if (grade != null) {
      json['grade'] = grade;
    }
    if (rpm != null) json['rpm'] = rpm;
    if (resistance != null) json['resistance'] = resistance;
    if (level != null) json['level'] = level;
    return json;
  }

  factory Interval.fromJson(Map<String, dynamic> json) {
    // Migration: support old durationMinutes field
    int durationSeconds;
    if (json.containsKey('durationSeconds')) {
      durationSeconds = json['durationSeconds'] as int;
    } else if (json.containsKey('durationMinutes')) {
      // Convert old minutes to seconds
      durationSeconds = (json['durationMinutes'] as int) * 60;
    } else {
      durationSeconds = 300; // Default 5 minutes
    }
    
    // Read doubles from JSON (support both new and legacy formats)
    double? speedKmh;
    double? grade;
    
    if (json.containsKey('speedKmh')) {
      speedKmh = (json['speedKmh'] as num).toDouble();
    } else if (json.containsKey('speedX10')) {
      // Legacy scaled integer format - convert to double
      final speedX10 = json['speedX10'] as int;
      speedKmh = speedX10 / 10.0;
    }
    
    if (json.containsKey('grade')) {
      grade = (json['grade'] as num).toDouble();
    } else if (json.containsKey('gradeX10')) {
      // Legacy scaled integer format - convert to double
      final gradeX10 = json['gradeX10'] as int;
      grade = gradeX10 / 10.0;
    }
    
    return Interval(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      durationSeconds: durationSeconds,
      speedKmh: speedKmh,
      grade: grade,
      rpm: json['rpm'] != null ? json['rpm'] as int : null,
      resistance: json['resistance'] != null ? json['resistance'] as int : null,
      level: json['level'] != null ? json['level'] as int : null,
    );
  }

  Interval copyWith({
    String? id,
    int? durationSeconds,
    double? speedKmh,
    double? grade,
    int? rpm,
    int? resistance,
    int? level,
  }) {
    return Interval(
      id: id ?? this.id,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      speedKmh: speedKmh ?? this.speedKmh,
      grade: grade ?? this.grade,
      rpm: rpm ?? this.rpm,
      resistance: resistance ?? this.resistance,
      level: level ?? this.level,
    );
  }
}

enum IntensityLevel { low, moderate, high }

extension IntervalIntensity on Interval {
  IntensityLevel getIntensity(MachineType machineType) {
    switch (machineType) {
      case MachineType.treadmill:
        final speed = speedKmh ?? 0.0;
        if (speed <= 5.5) return IntensityLevel.low;
        if (speed <= 9.0) return IntensityLevel.moderate;
        return IntensityLevel.high;
      case MachineType.cycle:
        final r = rpm ?? 0;
        if (r <= 65) return IntensityLevel.low;
        if (r <= 85) return IntensityLevel.moderate;
        return IntensityLevel.high;
      case MachineType.stairmaster:
        final l = level ?? 0;
        if (l <= 5) return IntensityLevel.low;
        if (l <= 10) return IntensityLevel.moderate;
        return IntensityLevel.high;
    }
  }

  Color getIntensityColor(BuildContext context, MachineType machineType) {
    final theme = Theme.of(context);
    final intensity = getIntensity(machineType);
    switch (intensity) {
      case IntensityLevel.low:
        return theme.brightness == Brightness.dark
            ? const Color(0xFF0F261C) // Deep dark emerald green
            : const Color(0xFFE8F5E9); // Soft light green
      case IntensityLevel.moderate:
        return theme.brightness == Brightness.dark
            ? const Color(0xFF2E1C0A) // Deep dark amber/orange
            : const Color(0xFFFFF3E0); // Soft light orange
      case IntensityLevel.high:
        return theme.brightness == Brightness.dark
            ? const Color(0xFF2D0F0F) // Deep dark red
            : const Color(0xFFFFEBEE); // Soft light red
    }
  }

  Color getIntensityActiveColor(BuildContext context, MachineType machineType) {
    final intensity = getIntensity(machineType);
    switch (intensity) {
      case IntensityLevel.low:
        return const Color(0xFF00C853); // Vibrant green
      case IntensityLevel.moderate:
        return const Color(0xFFFFAB00); // Vibrant amber/orange
      case IntensityLevel.high:
        return const Color(0xFFFF1744); // Vibrant red/crimson
    }
  }
}

