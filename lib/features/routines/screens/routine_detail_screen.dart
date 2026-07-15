import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/cupertino.dart' hide Interval;
import 'package:valcue/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../models/routine.dart';
import '../../../app_settings/app_settings_provider.dart';
import '../../workout/screens/workout_screen.dart';
import 'routine_edit_screen.dart';
import '../storage/routine_provider.dart';
import '../widgets/routine_shared_widgets.dart';
import '../../../services/ad_service.dart';
import '../../../widgets/secondary_outlined_button.dart';

class RoutineDetailSheet {
  static void show(BuildContext context, Routine routine,
      AppSettingsProvider settingsProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      isDismissible: true,
      builder: (context) => _RoutineDetailSheetContent(
        routine: routine,
        settingsProvider: settingsProvider,
      ),
    );
  }
}

class _RoutineDetailSheetContent extends StatelessWidget {
  final Routine routine;
  final AppSettingsProvider settingsProvider;

  const _RoutineDetailSheetContent({
    required this.routine,
    required this.settingsProvider,
  });

  int _calculateTotalDuration() {
    return routine.intervals
        .fold(0, (sum, interval) => sum + interval.durationSeconds);
  }

  void _showOverflowMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final routineProvider =
        Provider.of<RoutineProvider>(context, listen: false);

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context); // Close action sheet
              _confirmDelete(context, routineProvider);
            },
            child: Text(l10n.delete),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, RoutineProvider routineProvider) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final baseTextStyle = theme.textTheme.bodyMedium;

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: DefaultTextStyle.merge(
          style: baseTextStyle?.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
            decoration: TextDecoration.none,
          ),
          child: Text(l10n.deleteRoutineTitle),
        ),
        content: DefaultTextStyle.merge(
          style: baseTextStyle?.copyWith(
            fontSize: 13,
            color: theme.colorScheme.onSurface,
            decoration: TextDecoration.none,
          ),
          child: Text(l10n.deleteRoutineMessage),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: DefaultTextStyle.merge(
              style: baseTextStyle?.copyWith(decoration: TextDecoration.none),
              child: Text(l10n.cancel),
            ),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              routineProvider.deleteRoutine(routine.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail sheet
            },
            child: DefaultTextStyle.merge(
              style: baseTextStyle?.copyWith(
                color: theme.colorScheme.error,
                decoration: TextDecoration.none,
              ),
              child: Text(l10n.delete),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.9;
    final totalDuration = _calculateTotalDuration();

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
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
          // Header
          RoutineHeader(
            title: routine.name,
            totalDurationSeconds: totalDuration,
            intervalCount: routine.intervals.length,
            difficulty: routine.difficulty,
            onOverflowTap: () => _showOverflowMenu(context),
          ),
          // Intervals list
          Flexible(
            child: SingleChildScrollView(
              child: IntervalList(
                intervals: routine.intervals,
                machineType: routine.machineType,
                settingsProvider: settingsProvider,
                isEditable: false,
              ),
            ),
          ),
          // Bottom buttons
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.dividerColor,
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // Edit button (secondary)
                  Expanded(
                    child: SecondaryOutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RoutineEditScreen(routine: routine),
                          ),
                        );
                      },
                      borderRadius: 14,
                      child: Text(
                        AppLocalizations.of(context)!.editRoutine,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Start button (primary)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Check if user is premium - premium users don't see ads
                        final isPremium = settingsProvider.isPremium;

                        if (isPremium) {
                          // Premium user: close bottom sheet and navigate directly without ads
                          Navigator.pop(context);
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    WorkoutScreen(routine: routine),
                              ),
                            );
                          }
                          return;
                        }

                        // Save navigator context before closing bottom sheet
                        final navigatorContext =
                            Navigator.of(context, rootNavigator: true);

                        // Show interstitial ad if available, then navigate to workout
                        // Don't close bottom sheet yet - close it when ad is dismissed
                        final adService = AdService();
                        final wasAdShown = adService.showAd(
                          onAdClosed: () {
                            // Close bottom sheet and navigate to workout screen
                            if (context.mounted) {
                              Navigator.pop(context); // Close bottom sheet
                            }
                            // Use root navigator to push workout screen
                            navigatorContext.push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    WorkoutScreen(routine: routine),
                              ),
                            );
                          },
                        );

                        // If ad wasn't shown, close bottom sheet and navigate immediately
                        if (!wasAdShown) {
                          if (context.mounted) {
                            Navigator.pop(context); // Close bottom sheet
                          }
                          navigatorContext.push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  WorkoutScreen(routine: routine),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.start,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
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
}
