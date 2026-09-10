import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'package:valcue/l10n/localized_format.dart';
import '../../../theme/app_theme.dart';
import '../../../app_settings/app_settings_provider.dart';
import '../../../utils/app_shadows.dart';
import '../models/weight_entry.dart';
import '../providers/weight_tracker_provider.dart';
import '../../../widgets/app_dialog.dart';
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom > 0 ? 6 : 0,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showRecordWeightBottomSheet(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Card with Record button
                    WeightSummaryCard(
                      onRecordTap: () => _showRecordWeightBottomSheet(context),
                    ),
                    const SizedBox(height: 20),
                    // Weight Calendar
                    const _WeightCalendar(),
                    const SizedBox(height: 20),
                    // Trend Chart (only if 2+ entries - need at least 2 points to draw a line)
                    if (provider.entries.length >= 2) ...[
                      WeightTrendChart(timeframe: _selectedTimeframe),
                      const SizedBox(height: 20),
                    ] else if (provider.entries.length == 1) ...[
                      _buildTrendEmptyState(context),
                      const SizedBox(height: 20),
                    ],
                    // History List
                    if (provider.entries.isNotEmpty)
                      WeightHistoryList(
                        showAll: _showAllHistory,
                        onShowAll: () {
                          setState(() {
                            _showAllHistory = true;
                          });
                        },
                      ),
                    const SizedBox(height: 16), // Space for sticky button
                  ],
                ),
              ),
            ),
            // Sticky Record Button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom > 0 ? 6 : 0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showRecordWeightBottomSheet(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
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

  Widget _buildTrendEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;

    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: appColors.border,
            width: 1,
          ),
          boxShadow: AppShadows.elevatedSoft,
        ),
        child: Column(
          children: [
            Icon(
              Icons.show_chart,
              size: 40,
              color: appColors.mutedText.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.addOneMoreRecordToSeeTrend,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: appColors.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecordWeightBottomSheet(BuildContext context) {
    showRecordWeightBottomSheet(context);
  }
}

class _WeightCalendar extends StatefulWidget {
  const _WeightCalendar();

  @override
  State<_WeightCalendar> createState() => _WeightCalendarState();
}

class _WeightCalendarState extends State<_WeightCalendar> {
  DateTime _currentMonth = DateTime.now();

  String _getWeightCalendarTitle(BuildContext context) {
    return AppLocalizations.of(context)!.weightCalendar;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WeightTrackerProvider, AppSettingsProvider>(
      builder: (context, provider, settingsProvider, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final appColors = theme.extension<AppColors>()!;
        final isWeightMetric = settingsProvider.weightUnit == 'kg';
        final l10n = AppLocalizations.of(context)!;
        final now = DateTime.now();
        final isCurrentMonth =
            _currentMonth.year == now.year && _currentMonth.month == now.month;

        // Group entries by date (date only)
        final entriesByDate = <DateTime, WeightEntry>{};
        for (final entry in provider.entries) {
          final dateOnly = DateTime(
            entry.dateTime.year,
            entry.dateTime.month,
            entry.dateTime.day,
          );
          entriesByDate.putIfAbsent(dateOnly, () => entry);
        }

        final title = _getWeightCalendarTitle(context);

        return Container(
          padding: const EdgeInsets.all(20),
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
              // Header: Title & Month Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, size: 20),
                          tooltip: l10n.previousMonth,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              _currentMonth = DateTime(
                                _currentMonth.year,
                                _currentMonth.month - 1,
                              );
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            LocalizedFormat.yearMonth(context, _currentMonth),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const PlatformIcon(
                            cupertino: CupertinoIcons.chevron_right,
                            material: Icons.chevron_right,
                            size: 20,
                          ),
                          tooltip: l10n.nextMonth,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: isCurrentMonth
                              ? null
                              : () {
                                  setState(() {
                                    _currentMonth = DateTime(
                                      _currentMonth.year,
                                      _currentMonth.month + 1,
                                    );
                                  });
                                },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Weekday Headers
              _buildWeekdayHeaders(context, appColors),
              const SizedBox(height: 8),
              // Calendar Grid
              _buildCalendarGrid(
                context,
                provider,
                entriesByDate,
                isWeightMetric,
                theme,
                appColors,
                isDark,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeekdayHeaders(BuildContext context, AppColors appColors) {
    final l10n = AppLocalizations.of(context)!;
    final weekdays = <String>[
      l10n.mon,
      l10n.tue,
      l10n.wed,
      l10n.thu,
      l10n.fri,
      l10n.sat,
      l10n.sun,
    ];

    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: appColors.mutedText,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    WeightTrackerProvider provider,
    Map<DateTime, WeightEntry> entriesByDate,
    bool isWeightMetric,
    ThemeData theme,
    AppColors appColors,
    bool isDark,
  ) {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = firstDay.weekday; // 1 = Monday, 7 = Sunday
    final daysInMonth = lastDay.day;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.85,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemCount: (firstWeekday - 1) + daysInMonth,
      itemBuilder: (context, index) {
        if (index < firstWeekday - 1) {
          return const SizedBox.shrink();
        }

        final day = index - (firstWeekday - 1) + 1;
        final date = DateTime(_currentMonth.year, _currentMonth.month, day);
        final entry = entriesByDate[date];
        final isToday = date == today;

        return _buildCalendarCell(
          context,
          date,
          day,
          entry,
          isToday,
          isWeightMetric,
          theme,
          appColors,
          isDark,
          provider,
        );
      },
    );
  }

  Widget _buildCalendarCell(
    BuildContext context,
    DateTime date,
    int day,
    WeightEntry? entry,
    bool isToday,
    bool isWeightMetric,
    ThemeData theme,
    AppColors appColors,
    bool isDark,
    WeightTrackerProvider provider,
  ) {
    final hasEntry = entry != null;

    return GestureDetector(
      onTap: () {
        if (hasEntry) {
          _showCellOptions(context, entry, provider);
        } else {
          showRecordWeightBottomSheet(context, initialDateTime: date);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: hasEntry
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : isToday
                  ? (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.shade100)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasEntry
                ? theme.colorScheme.primary.withValues(alpha: 0.35)
                : isToday
                    ? theme.colorScheme.primary.withValues(alpha: 0.5)
                    : isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey.shade200,
            width: isToday ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              LocalizedFormat.decimal(context, day, decimalDigits: 0),
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isToday || hasEntry ? FontWeight.bold : FontWeight.normal,
                color: isToday
                    ? theme.colorScheme.primary
                    : hasEntry
                        ? theme.colorScheme.onSurface
                        : isDark
                            ? Colors.white70
                            : Colors.black87,
              ),
            ),
            if (hasEntry) ...[
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  isWeightMetric
                      ? LocalizedFormat.decimal(context, entry.weightKg)
                      : LocalizedFormat.decimal(
                          context,
                          entry.weightKg * 2.20462,
                        ),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 2),
              Text(
                '+',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white30 : Colors.black26,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCellOptions(
    BuildContext context,
    WeightEntry entry,
    WeightTrackerProvider provider,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF1C1C1E)
                : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    LocalizedFormat.mediumDate(context, entry.dateTime),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: Text(l10n.edit),
                  onTap: () {
                    Navigator.pop(context);
                    showRecordWeightBottomSheet(context,
                        editEntry: entry);
                  },
                ),
                ListTile(
                  leading: const PlatformIcon(
                    cupertino: CupertinoIcons.trash,
                    material: Icons.delete_outline,
                    color: Colors.red,
                  ),
                  title: Text(
                    l10n.delete,
                    style: const TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete(context, entry, provider);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    WeightEntry entry,
    WeightTrackerProvider provider,
  ) {
    final l10n = AppLocalizations.of(context)!;
    HapticFeedback.mediumImpact();
    showAppDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AppDialog(
          icon: platformIconData(
            cupertino: CupertinoIcons.trash,
            material: Icons.delete_outline_rounded,
          ),
          iconColor: Theme.of(dialogContext).colorScheme.error,
          title: l10n.weightDeleteTitle,
          message: l10n.weightDeleteConfirm,
          actions: [
            AppDialogAction(
              label: l10n.cancel,
              style: AppDialogActionStyle.secondary,
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            AppDialogAction(
              label: l10n.delete,
              style: AppDialogActionStyle.destructive,
              onPressed: () {
                Navigator.of(dialogContext).pop();
                provider.deleteEntry(entry.id);
                HapticFeedback.lightImpact();
              },
            ),
          ],
        );
      },
    );
  }
}
