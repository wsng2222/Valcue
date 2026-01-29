import 'interval.dart';
import 'machine_type.dart';

class Routine {
  final String id;
  String name;
  String difficulty;
  final List<Interval> intervals;
  MachineType machineType;
  // Metadata for recommended routines
  final String? source; // 'recommended' if from template, null if user-created
  final String? templateId; // ID of the template if from recommended

  Routine({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.intervals,
    this.machineType = MachineType.treadmill,
    this.source,
    this.templateId,
  }) {
    // Enforce storage limit (40 chars) - truncate if longer
    if (name.length > 40) {
      name = name.substring(0, 40);
      assert(() {
        print('[DEBUG] Routine name truncated in constructor: "$name"');
        return true;
      }());
    }
  }

  int get totalDurationSeconds {
    return intervals.fold(0, (sum, interval) => sum + interval.durationSeconds);
  }

  String get totalDurationFormatted {
    final total = totalDurationSeconds;
    final hours = total ~/ 3600;
    final minutes = (total % 3600) ~/ 60;
    final seconds = total % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'name': name,
      'difficulty': difficulty,
      'machineType': machineType.toJson(),
      'intervals': intervals.map((i) => i.toJson()).toList(),
    };
    if (source != null) json['source'] = source!;
    if (templateId != null) json['templateId'] = templateId!;
    return json;
  }

  factory Routine.fromJson(Map<String, dynamic> json) {
    String name = json['name'] as String;
    // Enforce storage limit (40 chars) - truncate if longer (backward compatibility)
    if (name.length > 40) {
      name = name.substring(0, 40);
      assert(() {
        print('[DEBUG] Routine name truncated from JSON: "$name"');
        return true;
      }());
    }

    return Routine(
      id: json['id'] as String,
      name: name,
      difficulty: json['difficulty'] as String,
      machineType: json['machineType'] != null
          ? MachineType.fromJson(json['machineType'] as String)
          : MachineType.treadmill, // Default for migration
      intervals: (json['intervals'] as List)
          .map((i) => Interval.fromJson(i as Map<String, dynamic>))
          .toList(),
      source: json['source'] as String?,
      templateId: json['templateId'] as String?,
    );
  }

  Routine copyWith({
    String? id,
    String? name,
    String? difficulty,
    List<Interval>? intervals,
    MachineType? machineType,
    String? source,
    String? templateId,
  }) {
    // Validation happens in constructor
    return Routine(
      id: id ?? this.id,
      name: name ?? this.name,
      difficulty: difficulty ?? this.difficulty,
      intervals: intervals ?? this.intervals,
      machineType: machineType ?? this.machineType,
      source: source ?? this.source,
      templateId: templateId ?? this.templateId,
    );
  }

  /// Deep copy routine with all intervals copied (for draft editing)
  Routine deepCopy() {
    return Routine(
      id: id,
      name: name,
      difficulty: difficulty,
      intervals: intervals
          .map((i) => Interval(
                id: i.id,
                durationSeconds: i.durationSeconds,
                speedKmh: i.speedKmh,
                grade: i.grade,
                rpm: i.rpm,
                resistance: i.resistance,
                level: i.level,
              ))
          .toList(),
      machineType: machineType,
      source: source,
      templateId: templateId,
    );
  }
}
