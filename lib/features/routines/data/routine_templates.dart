import '../models/routine_template.dart';
import '../models/interval.dart';
import '../models/machine_type.dart';
import '../models/difficulty.dart';

class RoutineTemplates {
  static List<RoutineTemplate> getAllTemplates() {
    return [
      // TREADMILL
      _createTreadmillBeginner1(),
      _createTreadmillBeginner2(),
      _createTreadmillIntermediate1(),
      _createTreadmillIntermediate2(),
      _createTreadmillAdvanced1(),
      _createTreadmillAdvanced2(),
      // CYCLE
      _createCycleBeginner1(),
      _createCycleBeginner2(),
      _createCycleIntermediate1(),
      _createCycleIntermediate2(),
      _createCycleAdvanced1(),
      _createCycleAdvanced2(),
      // STAIRMASTER
      _createStairmasterBeginner1(),
      _createStairmasterBeginner2(),
      _createStairmasterIntermediate1(),
      _createStairmasterIntermediate2(),
      _createStairmasterAdvanced1(),
      _createStairmasterAdvanced2(),
    ];
  }

  static List<RoutineTemplate> getTemplatesByMachine(MachineType machineType) {
    return getAllTemplates()
        .where((t) => t.machineType == machineType)
        .toList();
  }

  static RoutineTemplate? getTemplateById(String id) {
    return getAllTemplates().firstWhere(
      (t) => t.id == id,
      orElse: () => throw StateError('Template not found: $id'),
    );
  }

  // TREADMILL TEMPLATES

  static RoutineTemplate _createTreadmillBeginner1() {
    return RoutineTemplate(
      id: 'treadmill_beginner_1',
      machineType: MachineType.treadmill,
      difficulty: Difficulty.beginner,
      titleKey: 'template_treadmill_beginner_1_title',
      subtitleKey: 'template_treadmill_beginner_1_subtitle',
      intervals: [
        // Easy Start 20 (20:00)
        Interval.treadmill(durationSeconds: 180, speedKmh: 5.5, grade: 0.5),
        // 7 sets (1:00 on / 1:00 off) = 14:00
        Interval.treadmill(durationSeconds: 60, speedKmh: 8.5, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 8.5, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 8.5, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 8.5, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 8.5, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 8.5, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 8.5, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 180, speedKmh: 5.5, grade: 0.5),
      ],
    );
  }

  static RoutineTemplate _createTreadmillBeginner2() {
    return RoutineTemplate(
      id: 'treadmill_beginner_2',
      machineType: MachineType.treadmill,
      difficulty: Difficulty.beginner,
      titleKey: 'template_treadmill_beginner_2_title',
      subtitleKey: 'template_treadmill_beginner_2_subtitle',
      intervals: [
        // Incline Walk 25 (25:00)
        Interval.treadmill(durationSeconds: 300, speedKmh: 5.5, grade: 1.0),
        Interval.treadmill(durationSeconds: 180, speedKmh: 6.0, grade: 6.0),
        Interval.treadmill(durationSeconds: 120, speedKmh: 5.5, grade: 2.0),
        Interval.treadmill(durationSeconds: 180, speedKmh: 6.0, grade: 6.0),
        Interval.treadmill(durationSeconds: 120, speedKmh: 5.5, grade: 2.0),
        Interval.treadmill(durationSeconds: 180, speedKmh: 6.0, grade: 6.0),
        Interval.treadmill(durationSeconds: 120, speedKmh: 5.5, grade: 2.0),
        Interval.treadmill(durationSeconds: 180, speedKmh: 6.0, grade: 6.0),
        Interval.treadmill(durationSeconds: 120, speedKmh: 5.5, grade: 2.0),
      ],
    );
  }

  static RoutineTemplate _createTreadmillIntermediate1() {
    return RoutineTemplate(
      id: 'treadmill_intermediate_1',
      machineType: MachineType.treadmill,
      difficulty: Difficulty.intermediate,
      titleKey: 'template_treadmill_intermediate_1_title',
      subtitleKey: 'template_treadmill_intermediate_1_subtitle',
      intervals: [
        // Classic 1:1 24 (24:00)
        Interval.treadmill(durationSeconds: 240, speedKmh: 6.0, grade: 1.0),
        // 8 sets (1:00 on / 1:00 off) = 16:00
        Interval.treadmill(durationSeconds: 60, speedKmh: 10.5, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 10.5, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 10.5, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 10.5, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 10.5, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 10.5, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 10.5, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 10.5, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 240, speedKmh: 5.5, grade: 0.5),
      ],
    );
  }

  static RoutineTemplate _createTreadmillIntermediate2() {
    return RoutineTemplate(
      id: 'treadmill_intermediate_2',
      machineType: MachineType.treadmill,
      difficulty: Difficulty.intermediate,
      titleKey: 'template_treadmill_intermediate_2_title',
      subtitleKey: 'template_treadmill_intermediate_2_subtitle',
      intervals: [
        // Speed Ladder 20 (20:00)
        Interval.treadmill(durationSeconds: 180, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 9.5, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 10.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 10.5, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 11.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 11.5, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 12.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 300, speedKmh: 5.5, grade: 0.5),
      ],
    );
  }

  static RoutineTemplate _createTreadmillAdvanced1() {
    return RoutineTemplate(
      id: 'treadmill_advanced_1',
      machineType: MachineType.treadmill,
      difficulty: Difficulty.advanced,
      titleKey: 'template_treadmill_advanced_1_title',
      subtitleKey: 'template_treadmill_advanced_1_subtitle',
      intervals: [
        // 2:1 Burner 21 (21:00)
        Interval.treadmill(durationSeconds: 240, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 120, speedKmh: 12.0, grade: 1.5),
        Interval.treadmill(durationSeconds: 60, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 120, speedKmh: 12.0, grade: 1.5),
        Interval.treadmill(durationSeconds: 60, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 120, speedKmh: 12.0, grade: 1.5),
        Interval.treadmill(durationSeconds: 60, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 120, speedKmh: 12.0, grade: 1.5),
        Interval.treadmill(durationSeconds: 60, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 120, speedKmh: 12.0, grade: 1.5),
        Interval.treadmill(durationSeconds: 60, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 120, speedKmh: 5.5, grade: 0.5),
      ],
    );
  }

  static RoutineTemplate _createTreadmillAdvanced2() {
    return RoutineTemplate(
      id: 'treadmill_advanced_2',
      machineType: MachineType.treadmill,
      difficulty: Difficulty.advanced,
      titleKey: 'template_treadmill_advanced_2_title',
      subtitleKey: 'template_treadmill_advanced_2_subtitle',
      intervals: [
        // Sprint Pop 18 (18:00)
        Interval.treadmill(durationSeconds: 120, speedKmh: 6.0, grade: 1.0),
        // 10 rounds: 0:20 sprint + 1:10 easy = 15:00
        Interval.treadmill(durationSeconds: 20, speedKmh: 15.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 70, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 20, speedKmh: 15.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 70, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 20, speedKmh: 15.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 70, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 20, speedKmh: 15.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 70, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 20, speedKmh: 15.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 70, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 20, speedKmh: 15.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 70, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 20, speedKmh: 15.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 70, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 20, speedKmh: 15.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 70, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 20, speedKmh: 15.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 70, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 20, speedKmh: 15.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 70, speedKmh: 6.0, grade: 1.0),
        Interval.treadmill(durationSeconds: 60, speedKmh: 5.5, grade: 0.5),
      ],
    );
  }

  // CYCLE TEMPLATES

  static RoutineTemplate _createCycleBeginner1() {
    return RoutineTemplate(
      id: 'cycle_beginner_1',
      machineType: MachineType.cycle,
      difficulty: Difficulty.beginner,
      titleKey: 'template_cycle_beginner_1_title',
      subtitleKey: 'template_cycle_beginner_1_subtitle',
      intervals: [
        // Cadence Builder 20 (20:00)
        Interval.cycle(durationSeconds: 240, resistance: 4, rpm: 75),
        // 7 sets (1:00 on / 1:00 off) = 14:00
        Interval.cycle(durationSeconds: 60, resistance: 6, rpm: 90),
        Interval.cycle(durationSeconds: 60, resistance: 4, rpm: 75),
        Interval.cycle(durationSeconds: 60, resistance: 6, rpm: 90),
        Interval.cycle(durationSeconds: 60, resistance: 4, rpm: 75),
        Interval.cycle(durationSeconds: 60, resistance: 6, rpm: 90),
        Interval.cycle(durationSeconds: 60, resistance: 4, rpm: 75),
        Interval.cycle(durationSeconds: 60, resistance: 6, rpm: 90),
        Interval.cycle(durationSeconds: 60, resistance: 4, rpm: 75),
        Interval.cycle(durationSeconds: 60, resistance: 6, rpm: 90),
        Interval.cycle(durationSeconds: 60, resistance: 4, rpm: 75),
        Interval.cycle(durationSeconds: 60, resistance: 6, rpm: 90),
        Interval.cycle(durationSeconds: 60, resistance: 4, rpm: 75),
        Interval.cycle(durationSeconds: 60, resistance: 6, rpm: 90),
        Interval.cycle(durationSeconds: 60, resistance: 4, rpm: 75),
        Interval.cycle(durationSeconds: 120, resistance: 3, rpm: 70),
      ],
    );
  }

  static RoutineTemplate _createCycleBeginner2() {
    return RoutineTemplate(
      id: 'cycle_beginner_2',
      machineType: MachineType.cycle,
      difficulty: Difficulty.beginner,
      titleKey: 'template_cycle_beginner_2_title',
      subtitleKey: 'template_cycle_beginner_2_subtitle',
      intervals: [
        // Steady Ride 25 (25:00)
        Interval.cycle(durationSeconds: 300, resistance: 4, rpm: 75),
        Interval.cycle(durationSeconds: 900, resistance: 5, rpm: 85),
        Interval.cycle(durationSeconds: 300, resistance: 3, rpm: 70),
      ],
    );
  }

  static RoutineTemplate _createCycleIntermediate1() {
    return RoutineTemplate(
      id: 'cycle_intermediate_1',
      machineType: MachineType.cycle,
      difficulty: Difficulty.intermediate,
      titleKey: 'template_cycle_intermediate_1_title',
      subtitleKey: 'template_cycle_intermediate_1_subtitle',
      intervals: [
        // Spin 1:1 24 (24:00)
        Interval.cycle(durationSeconds: 240, resistance: 5, rpm: 80),
        // 8 sets (1:00 on / 1:00 off) = 16:00
        Interval.cycle(durationSeconds: 60, resistance: 8, rpm: 100),
        Interval.cycle(durationSeconds: 60, resistance: 5, rpm: 80),
        Interval.cycle(durationSeconds: 60, resistance: 8, rpm: 100),
        Interval.cycle(durationSeconds: 60, resistance: 5, rpm: 80),
        Interval.cycle(durationSeconds: 60, resistance: 8, rpm: 100),
        Interval.cycle(durationSeconds: 60, resistance: 5, rpm: 80),
        Interval.cycle(durationSeconds: 60, resistance: 8, rpm: 100),
        Interval.cycle(durationSeconds: 60, resistance: 5, rpm: 80),
        Interval.cycle(durationSeconds: 60, resistance: 8, rpm: 100),
        Interval.cycle(durationSeconds: 60, resistance: 5, rpm: 80),
        Interval.cycle(durationSeconds: 60, resistance: 8, rpm: 100),
        Interval.cycle(durationSeconds: 60, resistance: 5, rpm: 80),
        Interval.cycle(durationSeconds: 60, resistance: 8, rpm: 100),
        Interval.cycle(durationSeconds: 60, resistance: 5, rpm: 80),
        Interval.cycle(durationSeconds: 60, resistance: 8, rpm: 100),
        Interval.cycle(durationSeconds: 60, resistance: 5, rpm: 80),
        Interval.cycle(durationSeconds: 240, resistance: 4, rpm: 75),
      ],
    );
  }

  static RoutineTemplate _createCycleIntermediate2() {
    return RoutineTemplate(
      id: 'cycle_intermediate_2',
      machineType: MachineType.cycle,
      difficulty: Difficulty.intermediate,
      titleKey: 'template_cycle_intermediate_2_title',
      subtitleKey: 'template_cycle_intermediate_2_subtitle',
      intervals: [
        // Hill Simulation 22 (22:00)
        Interval.cycle(durationSeconds: 240, resistance: 5, rpm: 80),
        // 5 blocks: (2:00 climb + 1:00 cadence) = 15:00
        Interval.cycle(durationSeconds: 120, resistance: 10, rpm: 75),
        Interval.cycle(durationSeconds: 60, resistance: 6, rpm: 90),
        Interval.cycle(durationSeconds: 120, resistance: 10, rpm: 75),
        Interval.cycle(durationSeconds: 60, resistance: 6, rpm: 90),
        Interval.cycle(durationSeconds: 120, resistance: 10, rpm: 75),
        Interval.cycle(durationSeconds: 60, resistance: 6, rpm: 90),
        Interval.cycle(durationSeconds: 120, resistance: 10, rpm: 75),
        Interval.cycle(durationSeconds: 60, resistance: 6, rpm: 90),
        Interval.cycle(durationSeconds: 120, resistance: 10, rpm: 75),
        Interval.cycle(durationSeconds: 60, resistance: 6, rpm: 90),
        Interval.cycle(durationSeconds: 180, resistance: 4, rpm: 75),
      ],
    );
  }

  static RoutineTemplate _createCycleAdvanced1() {
    return RoutineTemplate(
      id: 'cycle_advanced_1',
      machineType: MachineType.cycle,
      difficulty: Difficulty.advanced,
      titleKey: 'template_cycle_advanced_1_title',
      subtitleKey: 'template_cycle_advanced_1_subtitle',
      intervals: [
        // Power Intervals 20 (20:00)
        Interval.cycle(durationSeconds: 180, resistance: 6, rpm: 85),
        // 8 rounds: (0:30 power + 1:30 easy) = 16:00
        Interval.cycle(durationSeconds: 30, resistance: 12, rpm: 110),
        Interval.cycle(durationSeconds: 90, resistance: 6, rpm: 80),
        Interval.cycle(durationSeconds: 30, resistance: 12, rpm: 110),
        Interval.cycle(durationSeconds: 90, resistance: 6, rpm: 80),
        Interval.cycle(durationSeconds: 30, resistance: 12, rpm: 110),
        Interval.cycle(durationSeconds: 90, resistance: 6, rpm: 80),
        Interval.cycle(durationSeconds: 30, resistance: 12, rpm: 110),
        Interval.cycle(durationSeconds: 90, resistance: 6, rpm: 80),
        Interval.cycle(durationSeconds: 30, resistance: 12, rpm: 110),
        Interval.cycle(durationSeconds: 90, resistance: 6, rpm: 80),
        Interval.cycle(durationSeconds: 30, resistance: 12, rpm: 110),
        Interval.cycle(durationSeconds: 90, resistance: 6, rpm: 80),
        Interval.cycle(durationSeconds: 30, resistance: 12, rpm: 110),
        Interval.cycle(durationSeconds: 90, resistance: 6, rpm: 80),
        Interval.cycle(durationSeconds: 30, resistance: 12, rpm: 110),
        Interval.cycle(durationSeconds: 90, resistance: 6, rpm: 80),
        Interval.cycle(durationSeconds: 60, resistance: 4, rpm: 70),
      ],
    );
  }

  static RoutineTemplate _createCycleAdvanced2() {
    return RoutineTemplate(
      id: 'cycle_advanced_2',
      machineType: MachineType.cycle,
      difficulty: Difficulty.advanced,
      titleKey: 'template_cycle_advanced_2_title',
      subtitleKey: 'template_cycle_advanced_2_subtitle',
      intervals: [
        // Tabata Mix 16 (16:00)
        Interval.cycle(durationSeconds: 180, resistance: 6, rpm: 85),
        // 8 rounds: 0:20 on + 0:10 off = 4:00
        Interval.cycle(durationSeconds: 20, resistance: 14, rpm: 120),
        Interval.cycle(durationSeconds: 10, resistance: 4, rpm: 60),
        Interval.cycle(durationSeconds: 20, resistance: 14, rpm: 120),
        Interval.cycle(durationSeconds: 10, resistance: 4, rpm: 60),
        Interval.cycle(durationSeconds: 20, resistance: 14, rpm: 120),
        Interval.cycle(durationSeconds: 10, resistance: 4, rpm: 60),
        Interval.cycle(durationSeconds: 20, resistance: 14, rpm: 120),
        Interval.cycle(durationSeconds: 10, resistance: 4, rpm: 60),
        Interval.cycle(durationSeconds: 20, resistance: 14, rpm: 120),
        Interval.cycle(durationSeconds: 10, resistance: 4, rpm: 60),
        Interval.cycle(durationSeconds: 20, resistance: 14, rpm: 120),
        Interval.cycle(durationSeconds: 10, resistance: 4, rpm: 60),
        Interval.cycle(durationSeconds: 20, resistance: 14, rpm: 120),
        Interval.cycle(durationSeconds: 10, resistance: 4, rpm: 60),
        Interval.cycle(durationSeconds: 20, resistance: 14, rpm: 120),
        Interval.cycle(durationSeconds: 10, resistance: 4, rpm: 60),
        Interval.cycle(durationSeconds: 300, resistance: 7, rpm: 90),
        Interval.cycle(durationSeconds: 240, resistance: 4, rpm: 70),
      ],
    );
  }

  // STAIRMASTER TEMPLATES

  static RoutineTemplate _createStairmasterBeginner1() {
    return RoutineTemplate(
      id: 'stairmaster_beginner_1',
      machineType: MachineType.stairmaster,
      difficulty: Difficulty.beginner,
      titleKey: 'template_stairmaster_beginner_1_title',
      subtitleKey: 'template_stairmaster_beginner_1_subtitle',
      intervals: [
        // Easy Steps 20 (20:00)
        Interval.stairmaster(durationSeconds: 240, level: 4),
        // 7 sets (1:00 on / 1:00 off) = 14:00
        Interval.stairmaster(durationSeconds: 60, level: 6),
        Interval.stairmaster(durationSeconds: 60, level: 4),
        Interval.stairmaster(durationSeconds: 60, level: 6),
        Interval.stairmaster(durationSeconds: 60, level: 4),
        Interval.stairmaster(durationSeconds: 60, level: 6),
        Interval.stairmaster(durationSeconds: 60, level: 4),
        Interval.stairmaster(durationSeconds: 60, level: 6),
        Interval.stairmaster(durationSeconds: 60, level: 4),
        Interval.stairmaster(durationSeconds: 60, level: 6),
        Interval.stairmaster(durationSeconds: 60, level: 4),
        Interval.stairmaster(durationSeconds: 60, level: 6),
        Interval.stairmaster(durationSeconds: 60, level: 4),
        Interval.stairmaster(durationSeconds: 60, level: 6),
        Interval.stairmaster(durationSeconds: 60, level: 4),
        Interval.stairmaster(durationSeconds: 120, level: 3),
      ],
    );
  }

  static RoutineTemplate _createStairmasterBeginner2() {
    return RoutineTemplate(
      id: 'stairmaster_beginner_2',
      machineType: MachineType.stairmaster,
      difficulty: Difficulty.beginner,
      titleKey: 'template_stairmaster_beginner_2_title',
      subtitleKey: 'template_stairmaster_beginner_2_subtitle',
      intervals: [
        // Long Easy 25 (25:00)
        Interval.stairmaster(durationSeconds: 300, level: 4),
        Interval.stairmaster(durationSeconds: 180, level: 7),
        Interval.stairmaster(durationSeconds: 120, level: 5),
        Interval.stairmaster(durationSeconds: 180, level: 7),
        Interval.stairmaster(durationSeconds: 120, level: 5),
        Interval.stairmaster(durationSeconds: 180, level: 7),
        Interval.stairmaster(durationSeconds: 120, level: 5),
        Interval.stairmaster(durationSeconds: 180, level: 7),
        Interval.stairmaster(durationSeconds: 120, level: 5),
      ],
    );
  }

  static RoutineTemplate _createStairmasterIntermediate1() {
    return RoutineTemplate(
      id: 'stairmaster_intermediate_1',
      machineType: MachineType.stairmaster,
      difficulty: Difficulty.intermediate,
      titleKey: 'template_stairmaster_intermediate_1_title',
      subtitleKey: 'template_stairmaster_intermediate_1_subtitle',
      intervals: [
        // 2:1 Climb 21 (21:00)
        Interval.stairmaster(durationSeconds: 180, level: 5),
        // 5 blocks (2:00 climb + 1:00 easy) = 15:00
        Interval.stairmaster(durationSeconds: 120, level: 9),
        Interval.stairmaster(durationSeconds: 60, level: 6),
        Interval.stairmaster(durationSeconds: 120, level: 9),
        Interval.stairmaster(durationSeconds: 60, level: 6),
        Interval.stairmaster(durationSeconds: 120, level: 9),
        Interval.stairmaster(durationSeconds: 60, level: 6),
        Interval.stairmaster(durationSeconds: 120, level: 9),
        Interval.stairmaster(durationSeconds: 60, level: 6),
        Interval.stairmaster(durationSeconds: 120, level: 9),
        Interval.stairmaster(durationSeconds: 60, level: 6),
        Interval.stairmaster(durationSeconds: 180, level: 4),
      ],
    );
  }

  static RoutineTemplate _createStairmasterIntermediate2() {
    return RoutineTemplate(
      id: 'stairmaster_intermediate_2',
      machineType: MachineType.stairmaster,
      difficulty: Difficulty.intermediate,
      titleKey: 'template_stairmaster_intermediate_2_title',
      subtitleKey: 'template_stairmaster_intermediate_2_subtitle',
      intervals: [
        // Strong 1:1 24 (24:00)
        Interval.stairmaster(durationSeconds: 240, level: 5),
        // 8 sets (1:00 strong / 1:00 easy) = 16:00
        Interval.stairmaster(durationSeconds: 60, level: 10),
        Interval.stairmaster(durationSeconds: 60, level: 6),
        Interval.stairmaster(durationSeconds: 60, level: 10),
        Interval.stairmaster(durationSeconds: 60, level: 6),
        Interval.stairmaster(durationSeconds: 60, level: 10),
        Interval.stairmaster(durationSeconds: 60, level: 6),
        Interval.stairmaster(durationSeconds: 60, level: 10),
        Interval.stairmaster(durationSeconds: 60, level: 6),
        Interval.stairmaster(durationSeconds: 60, level: 10),
        Interval.stairmaster(durationSeconds: 60, level: 6),
        Interval.stairmaster(durationSeconds: 60, level: 10),
        Interval.stairmaster(durationSeconds: 60, level: 6),
        Interval.stairmaster(durationSeconds: 60, level: 10),
        Interval.stairmaster(durationSeconds: 60, level: 6),
        Interval.stairmaster(durationSeconds: 60, level: 10),
        Interval.stairmaster(durationSeconds: 60, level: 6),
        Interval.stairmaster(durationSeconds: 240, level: 4),
      ],
    );
  }

  static RoutineTemplate _createStairmasterAdvanced1() {
    return RoutineTemplate(
      id: 'stairmaster_advanced_1',
      machineType: MachineType.stairmaster,
      difficulty: Difficulty.advanced,
      titleKey: 'template_stairmaster_advanced_1_title',
      subtitleKey: 'template_stairmaster_advanced_1_subtitle',
      intervals: [
        // Hard Blocks 20 (20:00)
        Interval.stairmaster(durationSeconds: 120, level: 6),
        Interval.stairmaster(durationSeconds: 120, level: 13),
        Interval.stairmaster(durationSeconds: 120, level: 8),
        Interval.stairmaster(durationSeconds: 120, level: 13),
        Interval.stairmaster(durationSeconds: 120, level: 8),
        Interval.stairmaster(durationSeconds: 120, level: 13),
        Interval.stairmaster(durationSeconds: 120, level: 8),
        Interval.stairmaster(durationSeconds: 120, level: 13),
        Interval.stairmaster(durationSeconds: 120, level: 8),
        Interval.stairmaster(durationSeconds: 120, level: 5),
      ],
    );
  }

  static RoutineTemplate _createStairmasterAdvanced2() {
    return RoutineTemplate(
      id: 'stairmaster_advanced_2',
      machineType: MachineType.stairmaster,
      difficulty: Difficulty.advanced,
      titleKey: 'template_stairmaster_advanced_2_title',
      subtitleKey: 'template_stairmaster_advanced_2_subtitle',
      intervals: [
        // Sprint Steps 18 (18:00)
        Interval.stairmaster(durationSeconds: 120, level: 6),
        // 10 rounds: 0:30 sprint + 1:00 recover = 15:00
        Interval.stairmaster(durationSeconds: 30, level: 16),
        Interval.stairmaster(durationSeconds: 60, level: 8),
        Interval.stairmaster(durationSeconds: 30, level: 16),
        Interval.stairmaster(durationSeconds: 60, level: 8),
        Interval.stairmaster(durationSeconds: 30, level: 16),
        Interval.stairmaster(durationSeconds: 60, level: 8),
        Interval.stairmaster(durationSeconds: 30, level: 16),
        Interval.stairmaster(durationSeconds: 60, level: 8),
        Interval.stairmaster(durationSeconds: 30, level: 16),
        Interval.stairmaster(durationSeconds: 60, level: 8),
        Interval.stairmaster(durationSeconds: 30, level: 16),
        Interval.stairmaster(durationSeconds: 60, level: 8),
        Interval.stairmaster(durationSeconds: 30, level: 16),
        Interval.stairmaster(durationSeconds: 60, level: 8),
        Interval.stairmaster(durationSeconds: 30, level: 16),
        Interval.stairmaster(durationSeconds: 60, level: 8),
        Interval.stairmaster(durationSeconds: 30, level: 16),
        Interval.stairmaster(durationSeconds: 60, level: 8),
        Interval.stairmaster(durationSeconds: 30, level: 16),
        Interval.stairmaster(durationSeconds: 60, level: 8),
        Interval.stairmaster(durationSeconds: 60, level: 5),
      ],
    );
  }
}
