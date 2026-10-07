import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'package:valcue/l10n/localized_format.dart';
import '../../../theme/app_theme.dart';
import '../../../app_settings/app_settings_provider.dart';
import '../models/weight_entry.dart';
import '../providers/weight_tracker_provider.dart';
import 'swipe_reveal_delete.dart';
import 'weight_entry_sheets.dart';

class WeightHistoryList extends StatelessWidget {
  final bool showAll;
  final VoidCallback? onShowAll;

  const WeightHistoryList({super.key, 
    required this.showAll,
    this.onShowAll,
  });

  void _showEditWeightBottomSheet(BuildContext context, WeightEntry entry) {
    showRecordWeightBottomSheet(context, editEntry: entry);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WeightTrackerProvider, AppSettingsProvider>(
      builder: (context, provider, settingsProvider, child) {
        final theme = Theme.of(context);
        final isWeightMetric = settingsProvider.weightUnit == 'kg';

        final entriesToShow =
            showAll ? provider.entries : provider.entries.take(7).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    AppLocalizations.of(context)!.history,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (!showAll && provider.entries.length > 7)
                  TextButton(
                    onPressed: onShowAll,
                    child: Text(
                      AppLocalizations.of(context)!.seeAll,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ...entriesToShow.map((entry) {
              String formatDate(DateTime dateTime) {
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final yesterday = today.subtract(const Duration(days: 1));
                final dateOnly =
                    DateTime(dateTime.year, dateTime.month, dateTime.day);

                if (dateOnly == today) {
                  return AppLocalizations.of(context)!.today;
                } else if (dateOnly == yesterday) {
                  return AppLocalizations.of(context)!.yesterday;
                } else {
                  return LocalizedFormat.mediumDate(context, dateTime);
                }
              }

              // Plain rows separated by hairlines, not separate cards - they
              // live inside the shared trend card.
              final isLast = entry == entriesToShow.last;

              return SwipeRevealDelete(
                key: Key(entry.id),
                itemId: 'weight_${entry.id}',
                buttonDiameter: 44,
                actionWidth: 60,
                onDelete: () {
                  provider.deleteEntry(entry.id);
                },
                child: InkWell(
                  onTap: () => _showEditWeightBottomSheet(context, entry),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      // Opaque: the swipe-to-delete button sits in a Stack
                      // behind this row and must stay hidden until swiped.
                      color: theme.colorScheme.surface,
                      border: isLast
                          ? null
                          : Border(
                              bottom: BorderSide(
                                color: theme.extension<AppColors>()!.border,
                              ),
                            ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            entry.formatWeight(
                              isWeightMetric,
                              localeName: LocalizedFormat.localeName(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            formatDate(entry.dateTime),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.extension<AppColors>()!.mutedText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

// Record Weight Bottom Sheet
