import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valcue/l10n/app_localizations.dart';

import '../features/profile/providers/workout_history_provider.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/routines/models/machine_type.dart';
import '../features/routines/screens/ai_routine_generator_sheet.dart';
import '../features/routines/screens/routine_bottom_sheet.dart';
import '../features/workout/screens/workout_finished_screen.dart';
import '../features/workout/screens/workout_screen.dart';
import 'store_screenshot_data.dart';

/// Five deterministic, localized app screens for App Store capture.
///
/// Tap anywhere to advance. Tapping the fifth screen exits the flow.
class StoreScreenshotCaptureScreen extends StatefulWidget {
  const StoreScreenshotCaptureScreen({super.key});

  @override
  State<StoreScreenshotCaptureScreen> createState() =>
      _StoreScreenshotCaptureScreenState();
}

class _StoreScreenshotCaptureScreenState
    extends State<StoreScreenshotCaptureScreen> {
  static const int _sceneCount = 5;
  int _sceneIndex = 0;

  void _advance() {
    if (_sceneIndex == _sceneCount - 1) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _sceneIndex++);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final routineName = l10n.templateTreadmillIntermediate1Title;
    final routine = buildStoreScreenshotRoutine(name: routineName);

    final scenes = <Widget>[
      WorkoutScreen(
        routine: buildStoreLiveWorkoutRoutine(name: routineName),
        previewElapsed: const Duration(seconds: 143),
      ),
      const _ModalStage(
        child: AiRoutineGeneratorSheet(
          initialMachineType: MachineType.treadmill,
        ),
      ),
      _ModalStage(
        child: RoutineBottomSheetCapture(routine: routine),
      ),
      ChangeNotifierProvider<WorkoutHistoryProvider>(
        create: (_) => WorkoutHistoryProvider(
          initialSessions: buildStoreScreenshotSessions(
            morningTempo: l10n.templateTreadmillBeginner1Title,
            speedIntervals: l10n.templateTreadmillIntermediate2Title,
            enduranceRun: l10n.templateTreadmillAdvanced1Title,
          ),
        ),
        child: const _HistoryStage(),
      ),
      WorkoutFinishedScreen(
        routine: routine,
        elapsedSeconds: 30 * 60,
        elapsedMilliseconds: 30 * 60 * 1000,
        finishTime: DateTime.now(),
        distanceMeters: 5240,
        currentIntervalIndex: routine.intervals.length,
        elapsedSecondsInCurrentSession: 0,
        previewMode: true,
      ),
    ];

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: KeyedSubtree(
                key: ValueKey<int>(_sceneIndex),
                child: scenes[_sceneIndex],
              ),
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _advance,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModalStage extends StatelessWidget {
  final Widget child;

  const _ModalStage({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: ColoredBox(color: Color(0xFFA3A3A3)),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Material(
              type: MaterialType.transparency,
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryStage extends StatelessWidget {
  const _HistoryStage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: const ProfileScreen(),
    );
  }
}
