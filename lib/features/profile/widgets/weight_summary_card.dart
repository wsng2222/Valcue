import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'package:valcue/l10n/localized_format.dart';
import '../../../theme/app_theme.dart';
import '../../../app_settings/app_settings_provider.dart';
import '../../../utils/app_shadows.dart';
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
        final isDark = theme.brightness == Brightness.dark;
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
            // Goal already reached or passed
            progress = current <= goalWeight ? 1.0 : null;
          }
        }
        // If only one entry, progress remains null (will show gray bar only)

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : appColors.border,
              width: 1,
            ),
            boxShadow: AppShadows.elevatedSoft,
          ),
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
                        Text(
                          currentWeight.formatWeight(
                            isWeightMetric,
                            localeName: localeName,
                          ),
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -1.5,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
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
                                    size: 14,
                                    color: weightChange < 0
                                        ? Colors.green
                                        : appColors.mutedText,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      '${weightChange > 0 ? '+' : ''}${WeightEntry(dateTime: DateTime.now(), weightKg: weightChange.abs()).formatWeight(isWeightMetric, localeName: localeName)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: weightChange < 0
                                            ? Colors.green
                                            : appColors.mutedText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Always show separator between delta and goal button
                              const SizedBox(width: 12),
                              Container(
                                width: 1,
                                height: 14,
                                color:
                                    appColors.mutedText.withValues(alpha: 0.3),
                              ),
                              const SizedBox(width: 12),
                            ],
                            // Goal pill
                            GestureDetector(
                              onTap: () => _showSetGoalBottomSheet(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: goalWeight != null
                                      ? theme.colorScheme.primary
                                          .withValues(alpha: 0.1)
                                      : (isDark
                                          ? const Color(0xFF2C2C2E)
                                          : Colors.grey.shade100),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: goalWeight != null
                                        ? theme.colorScheme.primary
                                            .withValues(alpha: 0.3)
                                        : (isDark
                                            ? Colors.white
                                                .withValues(alpha: 0.1)
                                            : Colors.grey.shade300),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      goalWeight != null
                                          ? Icons.flag
                                          : Icons.flag_outlined,
                                      size: 12,
                                      color: goalWeight != null
                                          ? theme.colorScheme.primary
                                          : appColors.mutedText,
                                    ),
                                    const SizedBox(width: 4),
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
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.flag,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
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
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: appColors.mutedText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress, // null if only one entry (shows gray only)
                    minHeight: 8,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.shade200,
                    valueColor: progress != null
                        ? AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          )
                        : AlwaysStoppedAnimation<Color>(
                            isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.grey.shade200,
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
  }) {
    if (toGoal.abs() < 0.1) {
      return l10n.goalAchievedSummary(goalWeight);
    }
    if (toGoal > 0) {
      return l10n.goalRemainingSummary(goalWeight, difference);
    }
    return l10n.goalExceededSummary(goalWeight, difference);
  }
}

// Weight Trend Chart - Sparkline with timeframe selector
