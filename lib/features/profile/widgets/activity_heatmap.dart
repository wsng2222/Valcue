import 'package:flutter/material.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'package:valcue/l10n/localized_format.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/valcue_ui.dart';
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
    final appColors = theme.extension<AppColors>()!;
    final l10n = AppLocalizations.of(context)!;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    const int cols = 22;
    const int rows = 7;
    const double gap = 3;

    // Monday of the first of the last [cols] weeks.
    final daysToSubtract = (today.weekday - 1) + ((cols - 1) * 7);
    final startDate = today.subtract(Duration(days: daysToSubtract));

    Color levelColor(int count) {
      if (count <= 0) return appColors.subtle;
      if (count == 1) return appColors.tint;
      if (count == 2) return const Color(0xFFF4A399);
      return theme.colorScheme.primary;
    }

    final labelStyle = TextStyle(fontSize: 11, color: appColors.mutedText);
    final weekdayLabels = <String>[
      l10n.mon,
      '',
      l10n.wed,
      '',
      l10n.fri,
      '',
      l10n.sun,
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      padding: const EdgeInsets.all(16),
      decoration: valcueCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.activityTitle,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              const labelWidth = 22.0;
              final gridWidth = constraints.maxWidth - labelWidth - 6;
              final cell = (gridWidth - gap * (cols - 1)) / cols;

              final monthLabels = <Widget>[];
              for (int c = 0; c < cols; c++) {
                final columnFirstDay = startDate.add(Duration(days: c * 7));
                final showLabel = c == 0 || columnFirstDay.day <= 7;
                monthLabels.add(
                  SizedBox(
                    width: cell + (c == cols - 1 ? 0 : gap),
                    child: showLabel
                        ? OverflowBox(
                            alignment: AlignmentDirectional.centerStart,
                            maxWidth: 40,
                            child: Text(
                              LocalizedFormat.monthAbbreviation(
                                  context, columnFirstDay),
                              maxLines: 1,
                              style: labelStyle,
                            ),
                          )
                        : null,
                  ),
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: labelWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        for (int r = 0; r < rows; r++)
                          SizedBox(
                            height: cell + (r == rows - 1 ? 0 : gap),
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  weekdayLabels[r].characters.take(1).string,
                                  style: labelStyle,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 14, child: Row(children: monthLabels)),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (int c = 0; c < cols; c++)
                                Padding(
                                  padding: EdgeInsets.only(
                                    right: c == cols - 1 ? 0 : gap,
                                  ),
                                  child: Column(
                                    children: [
                                      for (int r = 0; r < rows; r++)
                                        Builder(builder: (context) {
                                          final date = startDate.add(
                                              Duration(days: c * 7 + r));
                                          final isFuture =
                                              date.isAfter(today);
                                          return Container(
                                            width: cell,
                                            height: cell,
                                            margin: EdgeInsets.only(
                                              bottom: r == rows - 1 ? 0 : gap,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isFuture
                                                  ? Colors.transparent
                                                  : levelColor(
                                                      _getWorkoutCountOnDate(
                                                          date)),
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          );
                                        }),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  l10n.less,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: labelStyle.copyWith(fontSize: 12),
                ),
              ),
              const SizedBox(width: 6),
              for (int count = 1; count <= 3; count++)
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    color: levelColor(count),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  l10n.more,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: labelStyle.copyWith(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
