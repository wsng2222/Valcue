import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'package:valcue/l10n/localized_format.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/valcue_ui.dart';
import '../../../app_settings/app_settings_provider.dart';
import '../models/weight_entry.dart';
import '../providers/weight_tracker_provider.dart';
import 'weight_entry_sheets.dart';

class WeightSummaryCard extends StatelessWidget {
  final VoidCallback? onRecordTap;

  const WeightSummaryCard({super.key, this.onRecordTap});

  @override
  Widget build(BuildContext context) {
    return Consumer2<WeightTrackerProvider, AppSettingsProvider>(
      builder: (context, provider, settingsProvider, child) {
        final theme = Theme.of(context);
        final appColors = theme.extension<AppColors>()!;
        final isWeightMetric = settingsProvider.weightUnit == 'kg';
        final localeName = LocalizedFormat.localeName(context);

        final currentWeight = provider.currentWeight;
        final weightChange = provider.getWeightChange();
        final goalWeight = provider.goalWeight;
        final toGoal = provider.getWeightToGoal();
        final l10n = AppLocalizations.of(context)!;

        // Empty state - should not happen as we handle it at tab level, but return empty widget as fallback
        if (currentWeight == null) {
          return const SizedBox.shrink();
        }

        // Calculate progress toward goal (0.0 to 1.0)
        // Use the oldest entry as starting weight, or null if only one entry (no progress to show)
        double? progress;
        if (goalWeight != null &&
            toGoal != null &&
            provider.entries.length > 1) {
          final startWeight = provider.entries.last.weightKg; // Oldest entry
          final current = currentWeight.weightKg;

          if (startWeight > goalWeight && current >= goalWeight) {
            // Weight loss goal: progress = how much lost / total to lose
            final totalToLose = startWeight - goalWeight;
            final lost = startWeight - current;
            progress = (lost / totalToLose).clamp(0.0, 1.0);
          } else if (startWeight < goalWeight && current <= goalWeight) {
            // Weight gain goal: progress = how much gained / total to gain
            final totalToGain = goalWeight - startWeight;
            final gained = current - startWeight;
            progress = (gained / totalToGain).clamp(0.0, 1.0);
          } else {
            // Goal reached or passed, in whichever direction it was set.
            final passedLossGoal =
                startWeight > goalWeight && current < goalWeight;
            final passedGainGoal =
                startWeight < goalWeight && current > goalWeight;
            progress = passedLossGoal || passedGainGoal ? 1.0 : null;
          }
        }
        // If only one entry, progress remains null (will show gray bar only)

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: valcueCardDecoration(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Weight (Hero) - Large number
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _WeightHeroValue(
                          text: currentWeight.formatWeight(
                            isWeightMetric,
                            localeName: localeName,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Delta + Goal in one row
                        Row(
                          children: [
                            // Delta indicator
                            if (weightChange != null) ...[
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    weightChange < 0
                                        ? Icons.trending_down
                                        : Icons.trending_up,
                                    size: 18,
                                    color: weightChange < 0
                                        ? const Color(0xFF34C759)
                                        : const Color(0xFFFF3B30),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      '${weightChange > 0 ? '+' : ''}${WeightEntry(dateTime: DateTime.now(), weightKg: weightChange.abs()).formatWeight(isWeightMetric, localeName: localeName)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: weightChange < 0
                                            ? const Color(0xFF34C759)
                                            : const Color(0xFFFF3B30),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Always show separator between delta and goal button
                              const SizedBox(width: 12),
                              Container(
                                width: 1,
                                height: 18,
                                color: appColors.border,
                              ),
                              const SizedBox(width: 12),
                            ],
                            // Goal pill
                            GestureDetector(
                              onTap: () => _showSetGoalBottomSheet(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: goalWeight != null
                                      ? appColors.tint
                                      : appColors.subtle,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: goalWeight != null
                                        ? theme.colorScheme.primary
                                            .withValues(alpha: 0.25)
                                        : appColors.border,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      goalWeight != null
                                          ? Icons.flag
                                          : Icons.flag_outlined,
                                      size: 16,
                                      color: goalWeight != null
                                          ? theme.colorScheme.primary
                                          : appColors.mutedText,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        goalWeight != null
                                            ? WeightEntry(
                                                dateTime: DateTime.now(),
                                                weightKg: goalWeight,
                                              ).formatWeight(
                                                isWeightMetric,
                                                localeName: localeName,
                                              )
                                            : AppLocalizations.of(context)!
                                                .setGoal,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: goalWeight != null
                                              ? theme.colorScheme.primary
                                              : appColors.mutedText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Goal indicator (only show if goal is set)
              if (goalWeight != null && toGoal != null) ...[
                const SizedBox(height: 18),
                Row(
                  children: [
                    Icon(
                      Icons.flag,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _goalSummary(
                          l10n: l10n,
                          goalWeight: WeightEntry(
                            dateTime: DateTime.now(),
                            weightKg: goalWeight,
                          ).formatWeight(
                            isWeightMetric,
                            localeName: localeName,
                          ),
                          difference: WeightEntry(
                            dateTime: DateTime.now(),
                            weightKg: toGoal.abs(),
                          ).formatWeight(
                            isWeightMetric,
                            localeName: localeName,
                          ),
                          toGoal: toGoal,
                          // The oldest entry says which way the goal points;
                          // with a single entry, the goal is still ahead.
                          startWeightKg: provider.entries.last.weightKg,
                          goalWeightKg: goalWeight,
                        ),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: appColors.mutedText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress, // null if only one entry (shows gray only)
                    minHeight: 8,
                    backgroundColor: appColors.subtle,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress != null
                          ? theme.colorScheme.primary
                          : appColors.subtle,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showSetGoalBottomSheet(BuildContext context) {
    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);
    final provider = Provider.of<WeightTrackerProvider>(context, listen: false);
    final isWeightMetric = settingsProvider.weightUnit == 'kg';
    final goalWeightController = TextEditingController(
      text: provider.goalWeight != null
          ? (isWeightMetric
              ? LocalizedFormat.decimal(context, provider.goalWeight!)
              : LocalizedFormat.decimal(
                  context,
                  provider.goalWeight! * 2.20462,
                ))
          : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => SetGoalBottomSheet(
        goalWeightController: goalWeightController,
        isMetric: isWeightMetric,
        currentWeight: provider.currentWeight,
      ),
    );
  }

  String _goalSummary({
    required AppLocalizations l10n,
    required String goalWeight,
    required String difference,
    required double toGoal,
    required double startWeightKg,
    required double goalWeightKg,
  }) {
    if (toGoal.abs() < 0.1) {
      return l10n.goalAchievedSummary(goalWeight);
    }
    // toGoal is goal minus current, and its sign alone cannot tell "still
    // to go" from "went past it": a 72 kg person aiming for 68 kg has a
    // negative toGoal yet is nowhere near the goal. The goal's direction,
    // set by the starting weight, decides.
    final isLossGoal = startWeightKg > goalWeightKg;
    final stillToGo = isLossGoal ? toGoal < 0 : toGoal > 0;
    if (stillToGo || startWeightKg == goalWeightKg) {
      return l10n.goalRemainingSummary(goalWeight, difference);
    }
    return l10n.goalExceededSummary(goalWeight, difference);
  }
}

// Weight Trend Chart - Sparkline with timeframe selector

/// "72.4 kg" split into a large number and a muted unit.
class _WeightHeroValue extends StatelessWidget {
  final String text;

  const _WeightHeroValue({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final split = text.lastIndexOf(' ');
    final value = split > 0 ? text.substring(0, split) : text;
    final unit = split > 0 ? text.substring(split + 1) : '';

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 68,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              letterSpacing: -2.0,
              height: 1.0,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          if (unit.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              unit,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: theme.extension<AppColors>()!.mutedText,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
