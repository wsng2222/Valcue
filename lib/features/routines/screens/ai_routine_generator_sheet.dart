import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/cupertino.dart' hide Interval;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'package:valcue/l10n/localized_format.dart';
import '../models/routine.dart';
import '../models/interval.dart';
import '../models/machine_type.dart';
import '../storage/routine_provider.dart';
import '../../../app_settings/app_settings_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../services/sound_service.dart';
import '../../../services/voice_guide_service.dart';
import '../../../services/analytics_service.dart';
import '../../../widgets/bottom_sheet_action_bar.dart';
import '../../../widgets/app_bottom_sheet.dart';

class AiRoutineGeneratorSheet extends StatefulWidget {
  final MachineType initialMachineType;

  const AiRoutineGeneratorSheet({
    super.key,
    required this.initialMachineType,
  });

  static void show(BuildContext context, MachineType initialMachineType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) => AiRoutineGeneratorSheet(
        initialMachineType: initialMachineType,
      ),
    );
  }

  @override
  State<AiRoutineGeneratorSheet> createState() =>
      _AiRoutineGeneratorSheetState();
}

class _AiRoutineGeneratorSheetState extends State<AiRoutineGeneratorSheet> {
  late MachineType _machineType;
  int _durationMinutes = 20;

  // Workout Goal Variables
  double _distanceTargetKm = 5.0; // 1.0 to 10.0 km
  int _stairsTargetFloors = 50; // 10 to 200 floors (StairMaster only)
  int _caloriesTarget = 250; // 50 to 1000 kcal
  double _bodyWeightKg = 70.0;
  bool _includeIncline = true;

  bool _isGenerating = false;
  int _loadingStep = 0;
  Routine? _generatedRoutine;
  Timer? _generationTimer;

  @override
  void initState() {
    super.initState();
    _machineType = widget.initialMachineType;
  }

  @override
  void dispose() {
    _generationTimer?.cancel();
    super.dispose();
  }

  void _startGeneration() {
    setState(() {
      _isGenerating = true;
      _loadingStep = 0;
      _generatedRoutine = null;
    });

    _generationTimer?.cancel();
    int currentStep = 0;
    _generationTimer =
        Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (currentStep < 3) {
        currentStep++;
        setState(() {
          _loadingStep = currentStep;
        });
      } else {
        timer.cancel();
        _finalizeGeneration();
      }
    });
  }

  void _finalizeGeneration() {
    final l10n = AppLocalizations.of(context)!;
    final random = Random();
    final List<Interval> intervals = [];

    // 1. Common Time Config
    final totalSeconds = _durationMinutes * 60;
    int remainingSeconds =
        totalSeconds - 180 - 120; // 3 min warmup, 2 min cooldown
    if (remainingSeconds < 120) remainingSeconds = 120; // safety fallback

    if (_machineType == MachineType.treadmill) {
      // 2. Treadmill Math
      double avgSpeed = _distanceTargetKm / (_durationMinutes / 60.0);
      avgSpeed = avgSpeed.clamp(4.0, 15.0);

      double baseWarmupSpeed = (avgSpeed - 1.5).clamp(3.5, 6.0);
      double cooldownSpeed = (avgSpeed - 2.0).clamp(3.0, 5.0);

      double speedMMin = avgSpeed * 16.67;
      double baseCaloriesPerMin =
          (3.5 + 0.2 * speedMMin) * _bodyWeightKg / 200.0;
      double baseKcal = baseCaloriesPerMin * _durationMinutes;

      double avgGrade = 0.0;
      double workGrade = 0.0;
      double restGrade = 0.0;
      double warmupGrade = 0.0;

      if (_includeIncline) {
        // Adjust average incline (grade %) to match target calories
        if (_caloriesTarget > baseKcal) {
          double diff =
              (_caloriesTarget * 200.0 / _bodyWeightKg) / _durationMinutes -
                  (3.5 + 0.2 * speedMMin);
          if (diff > 0) {
            avgGrade = (diff / (0.9 * speedMMin)) * 100.0;
          }
        }
        avgGrade = avgGrade.clamp(0.0, 12.0);
        workGrade = (avgGrade * 1.4).clamp(0.0, 15.0);
        restGrade = (avgGrade * 0.6).clamp(0.0, 8.0);
        warmupGrade = 1.0;
      } else {
        // No Incline: recalculate speed to match calories
        if (_caloriesTarget > baseKcal) {
          double targetPerMin =
              (_caloriesTarget * 200.0) / (_bodyWeightKg * _durationMinutes);
          double neededSpeedMMin = (targetPerMin - 3.5) / 0.2;
          avgSpeed = neededSpeedMMin / 16.67;
          avgSpeed = avgSpeed.clamp(4.0, 16.0);
          baseWarmupSpeed = (avgSpeed - 1.5).clamp(3.5, 6.0);
          cooldownSpeed = (avgSpeed - 2.0).clamp(3.0, 5.0);
        }
      }

      double workSpeed = (avgSpeed + 1.5).clamp(4.5, 16.0);
      double restSpeed = (avgSpeed - 1.0).clamp(3.0, 10.0);

      // Warm up
      intervals.add(Interval.treadmill(
        durationSeconds: 180,
        speedKmh: double.parse(baseWarmupSpeed.toStringAsFixed(1)),
        grade: warmupGrade,
      ));

      // Intervals (2 min cycles)
      int cycleDuration = 120;
      int cycles = remainingSeconds ~/ cycleDuration;
      if (cycles < 1) cycles = 1;

      String groupId = 'ai_group_${random.nextInt(10000)}';
      for (int i = 0; i < cycles; i++) {
        intervals.add(Interval.treadmill(
          durationSeconds: 60,
          speedKmh: double.parse(workSpeed.toStringAsFixed(1)),
          grade: double.parse(workGrade.toStringAsFixed(1)),
          groupId: groupId,
          repeatCount: cycles,
        ));
        intervals.add(Interval.treadmill(
          durationSeconds: 60,
          speedKmh: double.parse(restSpeed.toStringAsFixed(1)),
          grade: double.parse(restGrade.toStringAsFixed(1)),
          groupId: groupId,
          repeatCount: cycles,
        ));
      }

      // Cool down
      intervals.add(Interval.treadmill(
        durationSeconds: 120,
        speedKmh: double.parse(cooldownSpeed.toStringAsFixed(1)),
        grade: 0.0,
      ));
    } else if (_machineType == MachineType.cycle) {
      // 3. Cycle Math
      double avgSpeed = _distanceTargetKm / (_durationMinutes / 60.0);
      double avgRpm = (avgSpeed * 2.8).clamp(50.0, 110.0);

      double avgRes = _caloriesTarget /
          (avgRpm * _durationMinutes * 0.002 * (_bodyWeightKg / 200.0));
      avgRes = avgRes.clamp(2.0, 18.0);

      // Warm up
      intervals.add(Interval.cycle(
        durationSeconds: 180,
        rpm: (avgRpm - 10).clamp(50, 90).toInt(),
        resistance: (avgRes - 2).clamp(1, 15).toInt(),
      ));

      // Intervals (2 min cycles)
      int cycleDuration = 120;
      int cycles = remainingSeconds ~/ cycleDuration;
      if (cycles < 1) cycles = 1;

      int workRpm = (avgRpm + 12).clamp(60, 120).toInt();
      int restRpm = (avgRpm - 8).clamp(45, 95).toInt();
      int workRes = (avgRes + 2).clamp(2, 20).toInt();
      int restRes = (avgRes - 1).clamp(1, 16).toInt();

      String groupId = 'ai_group_${random.nextInt(10000)}';
      for (int i = 0; i < cycles; i++) {
        intervals.add(Interval.cycle(
          durationSeconds: 60,
          rpm: workRpm,
          resistance: workRes,
          groupId: groupId,
          repeatCount: cycles,
        ));
        intervals.add(Interval.cycle(
          durationSeconds: 60,
          rpm: restRpm,
          resistance: restRes,
          groupId: groupId,
          repeatCount: cycles,
        ));
      }

      // Cool down
      intervals.add(Interval.cycle(
        durationSeconds: 120,
        rpm: (avgRpm - 15).clamp(45, 80).toInt(),
        resistance: (avgRes - 3).clamp(1, 12).toInt(),
      ));
    } else {
      // 4. StairMaster Math
      double floorsPerMin = _stairsTargetFloors / _durationMinutes;
      double stepsPerMin = floorsPerMin * 16.0;
      double avgLevel = (stepsPerMin / 6.0).clamp(3.0, 15.0);

      double baseCaloriesPerMin = avgLevel * _bodyWeightKg * 0.05;
      double baseKcal = baseCaloriesPerMin * _durationMinutes;
      double levelDelta = 0.0;
      if (_caloriesTarget > baseKcal) {
        levelDelta = ((_caloriesTarget - baseKcal) /
                (_bodyWeightKg * _durationMinutes * 0.05))
            .clamp(0.0, 4.0);
      }

      // Warm up
      intervals.add(Interval.stairmaster(
        durationSeconds: 180,
        level: (avgLevel - 2).clamp(2, 12).toInt(),
      ));

      // Intervals (2 min cycles)
      int cycleDuration = 120;
      int cycles = remainingSeconds ~/ cycleDuration;
      if (cycles < 1) cycles = 1;

      int workLevel = (avgLevel + levelDelta).clamp(4, 20).toInt();
      int restLevel = (avgLevel - (levelDelta / 2)).clamp(2, 14).toInt();

      String groupId = 'ai_group_${random.nextInt(10000)}';
      for (int i = 0; i < cycles; i++) {
        intervals.add(Interval.stairmaster(
          durationSeconds: 60,
          level: workLevel,
          groupId: groupId,
          repeatCount: cycles,
        ));
        intervals.add(Interval.stairmaster(
          durationSeconds: 60,
          level: restLevel,
          groupId: groupId,
          repeatCount: cycles,
        ));
      }

      // Cool down
      intervals.add(Interval.stairmaster(
        durationSeconds: 120,
        level: (avgLevel - 3).clamp(1, 10).toInt(),
      ));
    }

    // Name formatting
    String name = '';
    if (_machineType == MachineType.treadmill) {
      name = l10n.customRunName(
        LocalizedFormat.decimal(context, _distanceTargetKm),
        LocalizedFormat.decimal(
          context,
          _caloriesTarget,
          decimalDigits: 0,
        ),
      );
    } else if (_machineType == MachineType.cycle) {
      name = l10n.customCycleName(
        LocalizedFormat.decimal(context, _distanceTargetKm),
        LocalizedFormat.decimal(
          context,
          _caloriesTarget,
          decimalDigits: 0,
        ),
      );
    } else {
      name = l10n.customStairsName(
        LocalizedFormat.decimal(
          context,
          _stairsTargetFloors,
          decimalDigits: 0,
        ),
        LocalizedFormat.decimal(
          context,
          _caloriesTarget,
          decimalDigits: 0,
        ),
      );
    }

    setState(() {
      _isGenerating = false;
      _generatedRoutine = Routine(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        difficulty: _caloriesTarget > 350
            ? l10n.hard
            : (_caloriesTarget > 200 ? l10n.medium : l10n.easy),
        intervals: intervals,
        machineType: _machineType,
      );
    });

    // Trigger completion feedback effects
    unawaited(SoundService().playFinished());
    unawaited(
      VoiceGuideService.instance.speakCustom(
        l10n.customRoutineSpeech(
          LocalizedFormat.decimal(
            context,
            _caloriesTarget,
            decimalDigits: 0,
          ),
        ),
      ),
    );
  }

  Future<void> _saveRoutine() async {
    if (_generatedRoutine == null) return;

    final routineProvider =
        Provider.of<RoutineProvider>(context, listen: false);
    await routineProvider.addRoutine(_generatedRoutine!);
    if (!mounted) return;
    AnalyticsService.instance.logEvent(
      'custom_routine_created',
      {
        'machine_type': _machineType.name,
        'duration_minutes': _durationMinutes,
        'interval_count': _generatedRoutine!.intervals.length,
      },
    );

    Navigator.pop(context); // Close bottom sheet
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;

    return AppBottomSheetFrame(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isGenerating) ...[
            _buildLoadingState(theme, appColors)
          ] else if (_generatedRoutine != null) ...[
            _buildPreviewState(theme, appColors)
          ] else ...[
            Flexible(
              child: _buildConfigurationState(theme, appColors),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme, AppColors appColors) {
    final l10n = AppLocalizations.of(context)!;
    final phrases = [
      l10n.customRoutineLoadingTarget,
      l10n.customRoutineLoadingStructure,
      l10n.customRoutineLoadingPace,
      l10n.customRoutineLoadingVoice,
    ];
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Premium glowing AI circle loader
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Colors.purpleAccent,
                      Colors.blueAccent,
                      Colors.cyanAccent
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withValues(alpha: 0.4),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                l10n.customRoutineGenerating,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 32),
              // Step status checker list
              Column(
                children: List.generate(phrases.length, (idx) {
                  final isDone = _loadingStep > idx;
                  final isCurrent = _loadingStep == idx;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(
                          isDone
                              ? Icons.check_circle
                              : (isCurrent
                                  ? Icons.circle_outlined
                                  : Icons.circle_outlined),
                          color: isDone
                              ? Colors.greenAccent
                              : (isCurrent
                                  ? Colors.blueAccent
                                  : Colors.grey.withValues(alpha: 0.4)),
                          size: 20,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          phrases[idx],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                isCurrent ? FontWeight.w600 : FontWeight.w400,
                            color: isDone
                                ? theme.colorScheme.onSurface
                                : (isCurrent
                                    ? theme.colorScheme.primary
                                    : appColors.mutedText),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewState(ThemeData theme, AppColors appColors) {
    final l10n = AppLocalizations.of(context)!;
    return Expanded(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.generationComplete,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _generatedRoutine!.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.caloriesEstimateByWeight,
                        style: TextStyle(
                          fontSize: 12,
                          color: appColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _startGeneration,
                  child: Text(l10n.regenerate),
                ),
              ],
            ),
          ),
          const Divider(height: 0.5, thickness: 0.5),

          // Scrollable Preview List
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _buildFlatIntervalList(theme, appColors),
            ),
          ),

          BottomSheetActionBar(
            secondaryLabel: l10n.adjustGoals,
            primaryLabel: l10n.saveRoutine,
            onSecondaryPressed: () => setState(() => _generatedRoutine = null),
            onPrimaryPressed: _saveRoutine,
          ),
        ],
      ),
    );
  }

  Widget _buildFlatIntervalList(ThemeData theme, AppColors appColors) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final layeredSurfaceColor =
        isDark ? appColors.surfaceElevated : const Color(0xFFF2F2F7);
    final chipSurfaceColor = isDark ? const Color(0xFF3C3C3C) : Colors.white;
    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _generatedRoutine!.intervals.length,
      itemBuilder: (context, index) {
        final interval = _generatedRoutine!.intervals[index];
        String? pill1Text;
        String? pill2Text;

        switch (_machineType) {
          case MachineType.treadmill:
            if (interval.speedKmh != null && interval.grade != null) {
              pill1Text = settingsProvider.formatSpeed(interval.speedKmh!);
              pill2Text = l10n.inclineValue(
                LocalizedFormat.decimal(context, interval.grade!),
              );
            }
            break;
          case MachineType.cycle:
            if (interval.rpm != null && interval.resistance != null) {
              pill1Text = l10n.rpmValue(
                LocalizedFormat.decimal(
                  context,
                  interval.rpm!,
                  decimalDigits: 0,
                ),
              );
              pill2Text = l10n.resistanceColon(
                LocalizedFormat.decimal(
                  context,
                  interval.resistance!,
                  decimalDigits: 0,
                ),
              );
            }
            break;
          case MachineType.stairmaster:
            if (interval.level != null) {
              pill1Text = l10n.levelColon(
                LocalizedFormat.decimal(
                  context,
                  interval.level!,
                  decimalDigits: 0,
                ),
              );
              pill2Text = null;
            }
            break;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: layeredSurfaceColor,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : appColors.border,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: chipSurfaceColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        interval.durationFormatted,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (pill1Text != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: chipSurfaceColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          pill1Text,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                    if (pill2Text != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: chipSurfaceColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          pill2Text,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfigurationState(
    ThemeData theme,
    AppColors appColors,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isStairMaster = _machineType == MachineType.stairmaster;

    // Premium styling tokens
    final cardBgColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
        : theme.colorScheme.onSurface.withValues(alpha: 0.03);
    final borderColor = theme.colorScheme.onSurface.withValues(alpha: 0.06);
    final iconColor = theme.colorScheme.onSurface.withValues(alpha: 0.5);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Premium Header with clear primary text color (No blurry gradient)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: theme.colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.customRoutineBuilder,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 2. Goal Selection Cards
          // Time Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, color: iconColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          l10n.duration,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      l10n.durationMinutes(
                        LocalizedFormat.decimal(
                          context,
                          _durationMinutes,
                          decimalDigits: 0,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    activeTrackColor: theme.colorScheme.primary,
                    inactiveTrackColor:
                        theme.colorScheme.primary.withValues(alpha: 0.08),
                    thumbColor: theme.colorScheme.primary,
                    overlayColor:
                        theme.colorScheme.primary.withValues(alpha: 0.12),
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 9),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 18),
                  ),
                  child: Slider(
                    value: _durationMinutes.toDouble(),
                    min: 10,
                    max: 60,
                    divisions: 10,
                    onChanged: (val) =>
                        setState(() => _durationMinutes = val.toInt()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Distance or Floor Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isStairMaster
                              ? Icons.stairs_outlined
                              : Icons.directions_run_outlined,
                          color: iconColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isStairMaster
                              ? l10n.targetStairs
                              : l10n.targetDistance,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      isStairMaster
                          ? l10n.floorCount(
                              LocalizedFormat.decimal(
                                context,
                                _stairsTargetFloors,
                                decimalDigits: 0,
                              ),
                            )
                          : '${LocalizedFormat.decimal(context, _distanceTargetKm)} km',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    activeTrackColor: theme.colorScheme.primary,
                    inactiveTrackColor:
                        theme.colorScheme.primary.withValues(alpha: 0.08),
                    thumbColor: theme.colorScheme.primary,
                    overlayColor:
                        theme.colorScheme.primary.withValues(alpha: 0.12),
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 9),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 18),
                  ),
                  child: isStairMaster
                      ? Slider(
                          value: _stairsTargetFloors.toDouble(),
                          min: 10,
                          max: 200,
                          divisions: 19,
                          onChanged: (val) =>
                              setState(() => _stairsTargetFloors = val.toInt()),
                        )
                      : Slider(
                          value: _distanceTargetKm,
                          min: 1.0,
                          max: 15.0,
                          divisions: 28,
                          onChanged: (val) =>
                              setState(() => _distanceTargetKm = val),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Used only for this calculation and never saved to weight history.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.monitor_weight_outlined, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.currentWeight,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: TextFormField(
                    initialValue: LocalizedFormat.decimal(
                      context,
                      70,
                      decimalDigits: 0,
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.end,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[0-9٠-٩۰-۹]'),
                      ),
                      LengthLimitingTextInputFormatter(3),
                    ],
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                    ),
                    onChanged: (value) {
                      final weight =
                          LocalizedFormat.tryParseDecimal(context, value);
                      if (weight != null && weight > 0) {
                        _bodyWeightKg = weight;
                      }
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'kg',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: appColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Calories Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_fire_department_outlined,
                            color: iconColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          l10n.targetCalories,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$_caloriesTarget kcal',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    activeTrackColor: theme.colorScheme.primary,
                    inactiveTrackColor:
                        theme.colorScheme.primary.withValues(alpha: 0.08),
                    thumbColor: theme.colorScheme.primary,
                    overlayColor:
                        theme.colorScheme.primary.withValues(alpha: 0.12),
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 9),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 18),
                  ),
                  child: Slider(
                    value: _caloriesTarget.toDouble(),
                    min: 50,
                    max: 1000,
                    divisions: 19,
                    onChanged: (val) =>
                        setState(() => _caloriesTarget = val.toInt()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Incline Toggle Card (Treadmill only)
          if (_machineType == MachineType.treadmill) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: iconColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.includeIncline,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  Transform.scale(
                    scale: 0.85,
                    child: CupertinoSwitch(
                      value: _includeIncline,
                      activeTrackColor: theme.colorScheme.primary,
                      onChanged: (val) => setState(() => _includeIncline = val),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ] else ...[
            const SizedBox(height: 28),
          ],

          // 3. Action Button (Red Sporty accent)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: const Color(0xFFE53935), // 스포츠 레드
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: _startGeneration,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    l10n.generateCustomRoutine,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
