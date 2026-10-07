import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valcue/l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/valcue_ui.dart';
import '../providers/weight_tracker_provider.dart';
import '../../../widgets/platform_icon.dart';
import 'weight_summary_card.dart';
import 'weight_trend_chart.dart';
import 'weight_history_list.dart';
import 'weight_entry_sheets.dart';

class WeightTab extends StatefulWidget {
  const WeightTab({super.key});

  @override
  State<WeightTab> createState() => _WeightTabState();
}

class _WeightTabState extends State<WeightTab> {
  final int _selectedTimeframe = 2; // 0: 7D, 1: 30D, 2: 90D, 3: ALL
  bool _showAllHistory = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<WeightTrackerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Empty state - no entries at all
        if (provider.entries.isEmpty) {
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: _buildEmptyState(context),
                ),
              ),
              // Sticky Record Button
              Container(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom > 0 ? 6 : 0,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showRecordWeightBottomSheet(context),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        padding: EdgeInsets.zero,
                        textStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const PlatformIcon(
                            cupertino: CupertinoIcons.add,
                            material: Icons.add,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              AppLocalizations.of(context)!.recordWeight,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Card with Record button
                    WeightSummaryCard(
                      onRecordTap: () => _showRecordWeightBottomSheet(context),
                    ),
                    const SizedBox(height: 16),
                    // Trend and history share one card, split by a divider
                    // that runs the full width of it.
                    Container(
                      decoration: valcueCardDecoration(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                            child: WeightTrendChart(
                              timeframe: _selectedTimeframe,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: context.appColors.border,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
                            child: WeightHistoryList(
                              showAll: _showAllHistory,
                              onShowAll: () {
                                setState(() {
                                  _showAllHistory = true;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16), // Space for sticky button
                  ],
                ),
              ),
            ),
            // Sticky Record Button
            Container(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom > 0 ? 6 : 0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showRecordWeightBottomSheet(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      padding: EdgeInsets.zero,
                      textStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const PlatformIcon(
                          cupertino: CupertinoIcons.add,
                          material: Icons.add,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            AppLocalizations.of(context)!.recordWeight,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.scale_outlined,
          size: 48,
          color: appColors.mutedText,
        ),
        const SizedBox(height: 14),
        Text(
          AppLocalizations.of(context)!.noWeightRecorded,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.startTrackingYourWeight,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: appColors.mutedText,
          ),
        ),
      ],
    );
  }

  void _showRecordWeightBottomSheet(BuildContext context) {
    showRecordWeightBottomSheet(context);
  }
}
