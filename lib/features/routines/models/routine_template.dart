import 'interval.dart';
import 'machine_type.dart';
import 'difficulty.dart';

class RoutineTemplate {
  final String id;
  final MachineType machineType;
  final Difficulty difficulty;
  final String titleKey; // Localization key for title
  final String subtitleKey; // Localization key for subtitle
  final List<Interval> intervals;

  RoutineTemplate({
    required this.id,
    required this.machineType,
    required this.difficulty,
    required this.titleKey,
    required this.subtitleKey,
    required this.intervals,
  });

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
}

