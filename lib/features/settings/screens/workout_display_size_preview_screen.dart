import 'dart:async';

import 'package:flutter/material.dart' hide Interval;
import 'package:provider/provider.dart';

import '../../../app_settings/app_settings_model.dart';
import '../../../app_settings/app_settings_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/app_shadows.dart';
import '../../../widgets/app_segmented_control.dart';
import '../../routines/models/interval.dart';
import '../../routines/models/machine_type.dart';
import '../../routines/models/routine.dart';
import '../../workout/screens/workout_screen.dart';

class WorkoutDisplaySizePreviewScreen extends StatelessWidget {
  const WorkoutDisplaySizePreviewScreen({super.key});

  static Routine _previewRoutine() {
    return Routine(
      id: 'workout-display-size-preview',
      name: 'Workout display preview',
      difficulty: 'medium',
      machineType: MachineType.treadmill,
      intervals: [
        Interval.treadmill(
          id: 'preview-warm-up',
          durationSeconds: 120,
          speedKmh: 6,
          grade: 1,
        ),
        Interval.treadmill(
          id: 'preview-work',
          durationSeconds: 180,
          speedKmh: 9.5,
          grade: 2,
        ),
        Interval.treadmill(
          id: 'preview-recovery',
          durationSeconds: 120,
          speedKmh: 6,
          grade: 1,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final backButtonTooltip =
        MaterialLocalizations.of(context).backButtonTooltip;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Semantics(
            container: true,
            image: true,
            label: l10n.workoutDisplaySizeSubtitle,
            child: ExcludeSemantics(
              child: IgnorePointer(
                child: WorkoutScreen(
                  routine: _previewRoutine(),
                  previewElapsed: const Duration(seconds: 165),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: 0,
            start: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: 20, top: 12),
                child: Semantics(
                  button: true,
                  label: backButtonTooltip,
                  child: Tooltip(
                    message: backButtonTooltip,
                    child: Material(
                      key: const ValueKey('workout-display-size-back'),
                      color: Colors.transparent,
                      child: Ink(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context)
                              .colorScheme
                              .surface
                              .withValues(alpha: 0.94),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.12),
                          ),
                        ),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.of(context).pop(),
                          child: IconTheme(
                            data: IconThemeData(
                              size: 20,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.72),
                            ),
                            child: const BackButtonIcon(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            start: 0,
            end: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Consumer<AppSettingsProvider>(
                    builder: (context, provider, child) {
                      return _SizeSelectorCard(
                        value: provider.workoutDisplaySize,
                        onChanged: (size) {
                          unawaited(provider.updateWorkoutDisplaySize(size));
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SizeSelectorCard extends StatelessWidget {
  const _SizeSelectorCard({
    required this.value,
    required this.onChanged,
  });

  final WorkoutDisplaySize value;
  final ValueChanged<WorkoutDisplaySize> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    const sizes = WorkoutDisplaySize.values;
    final labels = [
      l10n.workoutDisplaySizeStandard,
      l10n.workoutDisplaySizeLarge,
      l10n.workoutDisplaySizeExtraLarge,
    ];
    final selectedBackground = appSegmentedSelectedBackground(context);

    return Container(
      key: const ValueKey('workout-display-size-selector-card'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: appColors.border),
        boxShadow: AppShadows.elevatedSoft,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.workoutDisplaySizeTitle,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          SegmentedButtonTheme(
            data: appSegmentedThemeData(context, selectedBackground),
            child: SizedBox(
              width: double.infinity,
              child: AppSegmentedControl(
                key: ValueKey(
                  'workout_display_size_${theme.brightness.name}_'
                  '${Localizations.localeOf(context).toLanguageTag()}',
                ),
                labels: labels,
                selectedIndex: sizes.indexOf(value),
                onValueChanged: (index) {
                  if (index < 0 || index >= sizes.length) return;
                  onChanged(sizes[index]);
                },
                height: 44,
                color: selectedBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
