import 'package:flutter/material.dart' hide Interval;
import 'package:valcue/l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/valcue_ui.dart';

class PauseBottomSheet extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onEndWorkout;

  const PauseBottomSheet({super.key, 
    required this.onResume,
    required this.onEndWorkout,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _WorkoutSheetFrame(
      icon: Icons.pause_rounded,
      title: l10n.pausedTitle,
      message: l10n.pausedSubtitle,
      actions: [
        PrimaryPillButton(
          label: l10n.resume,
          height: 56,
          onPressed: onResume,
        ),
        const SizedBox(height: 10),
        OutlinePillButton(
          label: l10n.endWorkout,
          fontSize: 18,
          onPressed: onEndWorkout,
        ),
      ],
    );
  }
}

class _WorkoutSheetFrame extends StatelessWidget {
  const _WorkoutSheetFrame({
    required this.icon,
    required this.title,
    required this.message,
    required this.actions,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final List<Widget> actions;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final accent = destructive ? appColors.danger : theme.colorScheme.primary;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 34),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: destructive
                        ? accent.withValues(alpha: 0.12)
                        : appColors.tint,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 30, color: accent),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: appColors.mutedText,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                ...actions,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Premium end workout confirmation bottom sheet
class EndWorkoutConfirmationBottomSheet extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const EndWorkoutConfirmationBottomSheet({super.key, 
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    return _WorkoutSheetFrame(
      icon: Icons.stop_circle_outlined,
      title: l10n.endWorkoutQuestion,
      message: l10n.endWorkoutConfirmationMessage,
      destructive: true,
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinePillButton(
                label: l10n.cancel,
                onPressed: onCancel,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appColors.danger,
                    foregroundColor: theme.colorScheme.onError,
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    l10n.end,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
