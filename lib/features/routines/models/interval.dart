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
