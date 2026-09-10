import 'package:flutter/material.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'package:valcue/l10n/localized_format.dart';
import '../../../theme/app_theme.dart';
import '../models/workout_session.dart';

class ActivityHeatmap extends StatelessWidget {
  final List<WorkoutSession> sessions;

  const ActivityHeatmap({super.key, required this.sessions});

  int _getWorkoutCountOnDate(DateTime date) {
    return sessions.where((s) {
      return s.dateTime.year == date.year &&
          s.dateTime.month == date.month &&
          s.dateTime.day == date.day;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appColors = theme.extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // We want the last 20 weeks. Monday of the first week.
    final daysToSubtract = (today.weekday - 1) + (19 * 7);
    final startDate = today.subtract(Duration(days: daysToSubtract));

    const int cols = 20;
    const int rows = 7;

    Color getCellColor(DateTime date) {
      final count = _getWorkoutCountOnDate(date);
      if (count == 0) {
        return isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.grey.shade100;
      }
      final baseColor = theme.colorScheme.primary;
      if (count == 1) {
        return baseColor.withValues(alpha: 0.35);
      } else if (count == 2) {
        return baseColor.withValues(alpha: 0.65);
      } else {
        return baseColor;
      }
    }

    final columnWidgets = <Widget>[];

    for (int c = 0; c < cols; c++) {
      final cells = <Widget>[];
      for (int r = 0; r < rows; r++) {
        final cellDate = startDate.add(Duration(days: c * 7 + r));
        final isFuture = cellDate.isAfter(today);

        cells.add(
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.symmetric(vertical: 1.5),
            decoration: BoxDecoration(
              color: isFuture ? Colors.transparent : getCellColor(cellDate),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }

      final columnFirstDay = startDate.add(Duration(days: c * 7));
      Widget monthLabel = const SizedBox(height: 14);
      if (c == 0 || columnFirstDay.day <= 7) {
        final monthName =
            LocalizedFormat.monthAbbreviation(context, columnFirstDay);
        monthLabel = Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(
            monthName,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: appColors.mutedText,
            ),
          ),
        );
      }

      columnWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              monthLabel,
              ...cells,
            ],
          ),
        ),
      );
    }

    final weekdayLabelWidgets = <Widget>[
      const SizedBox(height: 14),
      for (int i = 0; i < 7; i++)
        SizedBox(
          height: 13,
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: (i % 2 == 0)
                ? Text(
                    switch (i) {
                      0 => l10n.mon.substring(0, 1),
                      2 => l10n.wed.substring(0, 1),
                      4 => l10n.fri.substring(0, 1),
                      6 => l10n.sun.substring(0, 1),
                      _ => '',
                    },
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: appColors.mutedText,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1C1C1E)
            : const Color.fromARGB(245, 245, 245, 245),
        borderRadius: BorderRadius.circular(20),
        border: isDark
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.trend,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: Directionality.of(context) == TextDirection.ltr,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: weekdayLabelWidgets,
                ),
                const SizedBox(width: 4),
                ...columnWidgets,
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  l10n.less,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 8, color: appColors.mutedText),
                ),
              ),
              const SizedBox(width: 4),
              for (int count = 0; count <= 3; count++)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: count == 0
                        ? (isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : Colors.grey.shade100)
                        : theme.colorScheme.primary.withValues(
                            alpha:
                                count == 1 ? 0.35 : (count == 2 ? 0.65 : 1.0)),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  l10n.more,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 8, color: appColors.mutedText),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Calendar Tab
