import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/cupertino.dart' hide Interval;
import 'package:provider/provider.dart';
import 'package:valcue/l10n/app_localizations.dart';
import '../models/routine.dart';
import '../models/interval.dart';
import '../models/machine_type.dart';
import '../storage/routine_provider.dart';
import '../../../app_settings/app_settings_provider.dart';
import '../../../theme/app_theme.dart';

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
  State<AiRoutineGeneratorSheet> createState() => _AiRoutineGeneratorSheetState();
}

class _AiRoutineGeneratorSheetState extends State<AiRoutineGeneratorSheet> {
  late MachineType _machineType;
  int _durationMinutes = 20;
  String _difficulty = '중간'; // Default to Korean matching standard routines
  String _focus = 'hiit'; // 'hiit', 'fat_burn', 'endurance', 'cardio_peak'

  // Treadmill only features
  bool _useDistanceGoal = false; 
  double _distanceTargetKm = 5.0; // 1.0 to 10.0 km
  bool _includeIncline = true; 

  bool _isGenerating = false;
  int _loadingStep = 0;
  Routine? _generatedRoutine;
  Timer? _generationTimer;

  final List<String> _loadingPhrasesKo = [
    '유산소 강도 목표 설정 중...',
    '웜업 및 쿨다운 간격 설계 중...',
    '구간별 맞춤형 페이스 커브 연산 중...',
    '안내 음성 코칭 템플릿 튜닝 중...',
  ];

  final List<String> _loadingPhrasesEn = [
    'Analyzing cardio target heart zones...',
    'Structuring warm-up & cool-down intervals...',
    'Computing customized intensity curve...',
    'Optimizing voice coaching announcements...',
  ];

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
    _generationTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
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
    final isKorean = Localizations.localeOf(context).languageCode == 'ko';
    final random = Random();

    // Map difficulty display to storage keys
    String diffStorage = _difficulty;
    if (_difficulty == 'Easy' || _difficulty == '쉬움') diffStorage = '쉬움';
    if (_difficulty == 'Medium' || _difficulty == '중간') diffStorage = '중간';
    if (_difficulty == 'Hard' || _difficulty == '높음') diffStorage = '높음';

    final List<Interval> intervals = [];

    if (_machineType == MachineType.treadmill) {
      // Warm up: 3 min (180s)
      double baseWarmupSpeed = 4.5 + random.nextDouble() * 0.5; // 4.5-5.0
      double baseWarmupGrade = _includeIncline ? 1.0 : 0.0;

      double workSpeed = 8.0;
      double restSpeed = 5.5;
      double workGrade = _includeIncline ? 2.0 : 0.0;
      double restGrade = _includeIncline ? 1.0 : 0.0;

      if (diffStorage == '쉬움') {
        workSpeed = 7.0 + random.nextInt(2) * 0.5; // 7.0-7.5
        restSpeed = 5.0;
      } else if (diffStorage == '중간') {
        workSpeed = 9.0 + random.nextInt(3) * 0.5; // 9.0-10.0
        restSpeed = 5.5;
        workGrade = _includeIncline ? 3.0 : 0.0;
      } else {
        workSpeed = 11.5 + random.nextInt(4) * 0.5; // 11.5-13.0
        restSpeed = 6.0;
        workGrade = _includeIncline ? 4.0 : 0.0;
      }

      if (_focus == 'fat_burn') {
        // Fat burn focuses more on steady state + steep inclines (grade)
        workSpeed -= 1.0;
        workGrade = _includeIncline ? (workGrade + 2.0) : 0.0;
        restGrade = _includeIncline ? (restGrade + 1.0) : 0.0;
      }

      if (_useDistanceGoal) {
        // Distance Goal Mode
        // Warm up distance = 180s @ warmup speed
        double warmupDist = baseWarmupSpeed * (180 / 3600); // ~0.24km
        // Cool down distance = 120s @ cooldown speed
        double cooldownSpeed = baseWarmupSpeed - 0.5;
        double cooldownDist = cooldownSpeed * (120 / 3600); // ~0.15km
        double remainingDist = _distanceTargetKm - warmupDist - cooldownDist;

        // Ensure target is reasonable
        if (remainingDist < 0.1) remainingDist = 0.5;

        // One cycle duration & distance
        int workSeconds = _focus == 'hiit' ? 60 : 120;
        int restSeconds = 60;
        int cycleDuration = workSeconds + restSeconds; // 120s or 180s

        double cycleDist = (workSpeed * (workSeconds / 3600)) + (restSpeed * (restSeconds / 3600));
        int cycles = (remainingDist / cycleDist).round();

        // Limit cycles so that the total workout duration does not exceed 1 hour (3600s)
        int maxCycles = (3600 - 180 - 120) ~/ cycleDuration;
        if (cycles > maxCycles) cycles = maxCycles;
        if (cycles < 1) cycles = 1;

        // Recalculate workSpeed to EXACTLY fit the target distance over these cycles
        // remainingDist = cycles * (workSpeed * (workSeconds / 3600) + restSpeed * (restSeconds / 3600))
        // workSpeed * (workSeconds / 3600) = (remainingDist / cycles) - (restSpeed * (restSeconds / 3600))
        // workSpeed = ((remainingDist / cycles) - (restSpeed * restSeconds / 3600)) * 3600 / workSeconds
        double calculatedWorkSpeed = ((remainingDist / cycles) - (restSpeed * restSeconds / 3600)) * 3600 / workSeconds;
        
        // Clamp speed to realistic bounds (e.g. 5.5 to 16.0 km/h)
        workSpeed = calculatedWorkSpeed.clamp(restSpeed + 0.5, 16.0);

        // Add Warm up
        intervals.add(Interval.treadmill(
          durationSeconds: 180,
          speedKmh: baseWarmupSpeed,
          grade: baseWarmupGrade,
        ));

        String groupId = 'ai_group_${random.nextInt(10000)}';
        for (int i = 0; i < cycles; i++) {
          intervals.add(Interval.treadmill(
            durationSeconds: workSeconds,
            speedKmh: double.parse(workSpeed.toStringAsFixed(1)),
            grade: workGrade,
            groupId: groupId,
            repeatCount: cycles,
          ));
          intervals.add(Interval.treadmill(
            durationSeconds: restSeconds,
            speedKmh: restSpeed,
            grade: restGrade,
            groupId: groupId,
            repeatCount: cycles,
          ));
        }

        // Add Cool down
        intervals.add(Interval.treadmill(
          durationSeconds: 120,
          speedKmh: cooldownSpeed,
          grade: 0.0,
        ));
      } else {
        // Time Goal Mode
        final totalSeconds = _durationMinutes * 60;
        intervals.add(Interval.treadmill(
          durationSeconds: 180,
          speedKmh: baseWarmupSpeed,
          grade: baseWarmupGrade,
        ));

        int remainingSeconds = totalSeconds - 180 - 120;
        int intervalLen = _focus == 'hiit' ? 120 : 180;
        int cycles = remainingSeconds ~/ intervalLen;
        if (cycles < 1) cycles = 1;

        String groupId = 'ai_group_${random.nextInt(10000)}';
        for (int i = 0; i < cycles; i++) {
          if (_focus == 'hiit') {
            intervals.add(Interval.treadmill(
              durationSeconds: 60,
              speedKmh: workSpeed,
              grade: workGrade,
              groupId: groupId,
              repeatCount: cycles,
            ));
            intervals.add(Interval.treadmill(
              durationSeconds: 60,
              speedKmh: restSpeed,
              grade: restGrade,
              groupId: groupId,
              repeatCount: cycles,
            ));
          } else if (_focus == 'fat_burn') {
            intervals.add(Interval.treadmill(
              durationSeconds: 120,
              speedKmh: workSpeed,
              grade: workGrade,
              groupId: groupId,
              repeatCount: cycles,
            ));
            intervals.add(Interval.treadmill(
              durationSeconds: 60,
              speedKmh: restSpeed,
              grade: restGrade,
              groupId: groupId,
              repeatCount: cycles,
            ));
          } else {
            double speedPyramid = workSpeed - 1.0 + (i % 3) * 0.7;
            intervals.add(Interval.treadmill(
              durationSeconds: 120,
              speedKmh: double.parse(speedPyramid.toStringAsFixed(1)),
              grade: workGrade,
              groupId: groupId,
              repeatCount: cycles,
            ));
            intervals.add(Interval.treadmill(
              durationSeconds: 60,
              speedKmh: restSpeed,
              grade: restGrade,
              groupId: groupId,
              repeatCount: cycles,
            ));
          }
        }

        intervals.add(Interval.treadmill(
          durationSeconds: 120,
          speedKmh: baseWarmupSpeed - 0.5,
          grade: 0.0,
        ));
      }

    } else if (_machineType == MachineType.cycle) {
      // Cycle: Time goal only (DurationMinutes max 60)
      final totalSeconds = _durationMinutes * 60;
      int baseRes = diffStorage == '쉬움' ? 5 : (diffStorage == '중간' ? 8 : 12);
      int workRes = baseRes + 4;
      int workRpm = _focus == 'hiit' ? 105 : 90;
      int restRpm = 75;

      intervals.add(Interval.cycle(
        durationSeconds: 180,
        rpm: 80,
        resistance: baseRes,
      ));

      int remainingSeconds = totalSeconds - 180 - 120;
      int intervalLen = 120;
      int cycles = remainingSeconds ~/ intervalLen;
      if (cycles < 1) cycles = 1;
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
          resistance: baseRes,
          groupId: groupId,
          repeatCount: cycles,
        ));
      }

      intervals.add(Interval.cycle(
        durationSeconds: 120,
        rpm: 70,
        resistance: baseRes - 2 > 2 ? baseRes - 2 : 2,
      ));

    } else {
      // StairMaster: Time goal only (DurationMinutes max 60)
      final totalSeconds = _durationMinutes * 60;
      int baseLevel = diffStorage == '쉬움' ? 4 : (diffStorage == '중간' ? 7 : 11);
      int workLevel = baseLevel + 4;

      intervals.add(Interval.stairmaster(
        durationSeconds: 180,
        level: baseLevel,
      ));

      int remainingSeconds = totalSeconds - 180 - 120;
      int intervalLen = 120;
      int cycles = remainingSeconds ~/ intervalLen;
      if (cycles < 1) cycles = 1;
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
          level: baseLevel,
          groupId: groupId,
          repeatCount: cycles,
        ));
      }

      intervals.add(Interval.stairmaster(
        durationSeconds: 120,
        level: baseLevel - 2 > 1 ? baseLevel - 2 : 1,
      ));
    }

    // Name translation
    String focusName = '';
    if (_focus == 'hiit') focusName = isKorean ? '고강도 인터벌' : 'HIIT';
    if (_focus == 'fat_burn') focusName = isKorean ? '지방 연소' : 'Fat Burn';
    if (_focus == 'endurance') focusName = isKorean ? '지구력' : 'Endurance';
    if (_focus == 'cardio_peak') focusName = isKorean ? '심폐 극대화' : 'Cardio Peak';

    String name = '';
    if (_machineType == MachineType.treadmill && _useDistanceGoal) {
      name = 'AI $focusName ${_distanceTargetKm.toStringAsFixed(1)}km';
    } else {
      name = 'AI $focusName ${_durationMinutes}m';
    }

    setState(() {
      _isGenerating = false;
      _generatedRoutine = Routine(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        difficulty: diffStorage,
        intervals: intervals,
        machineType: _machineType,
      );
    });
  }

  void _saveRoutine() {
    if (_generatedRoutine == null) return;

    final routineProvider = Provider.of<RoutineProvider>(context, listen: false);
    routineProvider.addRoutine(_generatedRoutine!);

    Navigator.pop(context); // Close bottom sheet
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final isKorean = Localizations.localeOf(context).languageCode == 'ko';

    final focusOptions = [
      (key: 'hiit', label: isKorean ? 'HIIT 인터벌' : 'HIIT'),
      (key: 'fat_burn', label: isKorean ? '지방 태우기' : 'Fat Burn'),
      (key: 'endurance', label: isKorean ? '지구력 향상' : 'Endurance'),
      (key: 'cardio_peak', label: isKorean ? '심폐 기능 극대화' : 'Cardio Peak'),
    ];

    final difficultyOptions = isKorean ? ['쉬움', '중간', '높음'] : ['Easy', 'Medium', 'Hard'];

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          if (_isGenerating) ...[
            _buildLoadingState(theme, appColors, isKorean)
          ] else if (_generatedRoutine != null) ...[
            _buildPreviewState(theme, appColors, isKorean)
          ] else ...[
            Flexible(
              child: _buildConfigurationState(theme, appColors, isKorean, focusOptions, difficultyOptions),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme, AppColors appColors, bool isKorean) {
    final phrases = isKorean ? _loadingPhrasesKo : _loadingPhrasesEn;
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
                    colors: [Colors.purpleAccent, Colors.blueAccent, Colors.cyanAccent],
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
                isKorean ? 'AI가 운동 루틴을 생성하고 있습니다' : 'AI is designing your routine...',
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
                          isDone ? Icons.check_circle : (isCurrent ? Icons.circle_outlined : Icons.circle_outlined),
                          color: isDone 
                              ? Colors.greenAccent 
                              : (isCurrent ? Colors.blueAccent : Colors.grey.withValues(alpha: 0.4)),
                          size: 20,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          phrases[idx],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                            color: isDone 
                                ? theme.colorScheme.onSurface 
                                : (isCurrent ? theme.colorScheme.primary : appColors.mutedText),
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

  Widget _buildPreviewState(ThemeData theme, AppColors appColors, bool isKorean) {
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
                        isKorean ? '생성 완료!' : 'Generation Complete!',
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
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _startGeneration,
                  child: Text(isKorean ? '재생성' : 'Regenerate'),
                ),
              ],
            ),
          ),
          const Divider(height: 0.5, thickness: 0.5),

          // Scrollable Preview List
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _buildFlatIntervalList(theme, appColors, isKorean),
            ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: theme.dividerColor, width: 0.5)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => setState(() => _generatedRoutine = null),
                      child: Text(
                        isKorean ? '이전으로' : 'Back',
                        style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _saveRoutine,
                      child: Text(
                        isKorean ? '루틴 저장' : 'Save Routine',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlatIntervalList(ThemeData theme, AppColors appColors, bool isKorean) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final layeredSurfaceColor =
        isDark ? appColors.surfaceElevated : const Color(0xFFF2F2F7);
    final chipSurfaceColor = isDark ? const Color(0xFF3C3C3C) : Colors.white;
    final settingsProvider = Provider.of<AppSettingsProvider>(context, listen: false);

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
              pill2Text = '${interval.grade!.toStringAsFixed(1)}% ${l10n.incline}';
            }
            break;
          case MachineType.cycle:
            if (interval.rpm != null && interval.resistance != null) {
              pill1Text = '${interval.rpm} ${l10n.rpm}';
              pill2Text = 'Level ${interval.resistance!}';
            }
            break;
          case MachineType.stairmaster:
            if (interval.level != null) {
              pill1Text = 'Level ${interval.level!}';
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
    bool isKorean,
    List<({String key, String label})> focusOptions,
    List<String> difficultyOptions,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with AI Gradient
          Center(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.purpleAccent, Colors.blueAccent],
              ).createShader(bounds),
              child: Text(
                isKorean ? 'AI Workout Designer' : 'AI Workout Designer',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Goal Type Selection (Treadmill only)
          if (_machineType == MachineType.treadmill) ...[
            Text(
              isKorean ? '목표 설정 방식' : 'Goal Type',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _useDistanceGoal = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: !_useDistanceGoal 
                            ? theme.colorScheme.primary.withValues(alpha: 0.1) 
                            : theme.colorScheme.onSurface.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: !_useDistanceGoal ? theme.colorScheme.primary : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        isKorean ? '시간 목표' : 'Time Goal',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: !_useDistanceGoal ? FontWeight.w600 : FontWeight.w400,
                          color: !_useDistanceGoal ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _useDistanceGoal = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _useDistanceGoal 
                            ? theme.colorScheme.primary.withValues(alpha: 0.1) 
                            : theme.colorScheme.onSurface.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _useDistanceGoal ? theme.colorScheme.primary : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        isKorean ? '거리 목표' : 'Distance Goal',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: _useDistanceGoal ? FontWeight.w600 : FontWeight.w400,
                          color: _useDistanceGoal ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // Goal Parameter Slider
          if (_machineType != MachineType.treadmill || !_useDistanceGoal) ...[
            // Time Goal Duration Slider (Max 60 Minutes)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isKorean ? '운동 시간' : 'Duration',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                Text(
                  '$_durationMinutes ${isKorean ? '분' : 'min'}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.colorScheme.primary),
                ),
              ],
            ),
            Slider(
              value: _durationMinutes.toDouble(),
              min: 10,
              max: 60,
              divisions: 10, // 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60
              activeColor: theme.colorScheme.primary,
              onChanged: (val) => setState(() => _durationMinutes = val.toInt()),
            ),
          ] else ...[
            // Distance Goal Slider (Treadmill only: 1.0 to 10.0 km)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isKorean ? '목표 거리' : 'Target Distance',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                Text(
                  '${_distanceTargetKm.toStringAsFixed(1)} km',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: theme.colorScheme.primary),
                ),
              ],
            ),
            Slider(
              value: _distanceTargetKm,
              min: 1.0,
              max: 10.0,
              divisions: 18, // Steps of 0.5km
              onChanged: (val) => setState(() => _distanceTargetKm = val),
            ),
          ],
          const SizedBox(height: 12),

          // Incline Toggle (Treadmill only)
          if (_machineType == MachineType.treadmill) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isKorean ? '경사도(Incline) 적용' : 'Include Incline (Grade)',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                CupertinoSwitch(
                  value: _includeIncline,
                  activeTrackColor: theme.colorScheme.primary,
                  onChanged: (val) => setState(() => _includeIncline = val),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // Workout Focus Options
          Text(
            isKorean ? '운동 목표' : 'Workout Goal Focus',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: focusOptions.map((opt) {
              final isSel = _focus == opt.key;
              return GestureDetector(
                onTap: () => setState(() => _focus = opt.key),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSel ? theme.colorScheme.primary.withValues(alpha: 0.1) : theme.colorScheme.onSurface.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSel ? theme.colorScheme.primary : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    opt.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                      color: isSel ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Difficulty Options
          Text(
            isKorean ? '난이도' : 'Difficulty',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            children: difficultyOptions.map((diff) {
              String diffKey = diff;
              if (diff == 'Easy' || diff == '쉬움') diffKey = '쉬움';
              if (diff == 'Medium' || diff == '중간') diffKey = '중간';
              if (diff == 'Hard' || diff == '높음') diffKey = '높음';

              String myDiffKey = _difficulty;
              if (_difficulty == 'Easy' || _difficulty == '쉬움') myDiffKey = '쉬움';
              if (_difficulty == 'Medium' || _difficulty == '중간') myDiffKey = '중간';
              if (_difficulty == 'Hard' || _difficulty == '높음') myDiffKey = '높음';

              final isSel = myDiffKey == diffKey;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _difficulty = diffKey),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSel ? theme.colorScheme.primary.withValues(alpha: 0.1) : theme.colorScheme.onSurface.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSel ? theme.colorScheme.primary : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      diff,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                        color: isSel ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Generate Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: theme.colorScheme.onSurface,
                foregroundColor: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: _startGeneration,
              child: Text(
                isKorean ? 'AI 루틴 생성하기' : 'Generate AI Routine',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
