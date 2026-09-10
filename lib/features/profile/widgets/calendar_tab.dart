import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'package:valcue/l10n/localized_format.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../app_settings/app_settings_provider.dart';
import '../../../app_shell/app_shell.dart';
import '../../../utils/app_shadows.dart';
import '../models/workout_session.dart';
import '../providers/workout_history_provider.dart';
import '../../routines/models/machine_type.dart';
import '../../../widgets/app_bottom_sheet.dart';
import '../../../widgets/platform_icon.dart';
import 'activity_heatmap.dart';
import 'swipe_reveal_delete.dart';

class CalendarTab extends StatefulWidget {
  const CalendarTab({super.key});

  @override
  State<CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<CalendarTab> {
  DateTime _currentMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final isCurrentMonth =
        _currentMonth.year == now.year && _currentMonth.month == now.month;
    return Consumer<WorkoutHistoryProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            ActivityHeatmap(sessions: provider.sessions),
            const SizedBox(height: 8),
            // Month navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    tooltip: l10n.previousMonth,
                    onPressed: () {
                      setState(() {
                        _currentMonth = DateTime(
                            _currentMonth.year, _currentMonth.month - 1);
                      });
                    },
                  ),
                  Flexible(
                    child: Text(
                      LocalizedFormat.yearMonth(context, _currentMonth),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const PlatformIcon(
                      cupertino: CupertinoIcons.chevron_right,
                      material: Icons.chevron_right,
                    ),
                    tooltip: l10n.nextMonth,
                    onPressed: isCurrentMonth
                        ? null
                        : () {
                            setState(() {
                              _currentMonth = DateTime(
                                  _currentMonth.year, _currentMonth.month + 1);
                            });
                          },
                  ),
                ],
              ),
            ),
            // Calendar grid
            Expanded(
              child: _buildCalendarGrid(context, provider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalendarGrid(
      BuildContext context, WorkoutHistoryProvider provider) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;

    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = firstDay.weekday; // 1 = Monday, 7 = Sunday
    final daysInMonth = lastDay.day;

    // Weekday headers
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

    // Calculate workout days and rest days for the month (only up to today)
    final today = DateTime.now();
    int workoutDays = 0;
    int restDays = 0;

    // Only count days up to today if we're viewing the current month
    final lastDayToCount =
        (_currentMonth.year == today.year && _currentMonth.month == today.month)
            ? today.day
            : daysInMonth;

    for (int day = 1; day <= lastDayToCount; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      if (provider.hasWorkoutOnDate(date)) {
        workoutDays++;
      } else {
        restDays++;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Weekday headers
          Row(
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
          ),
          const SizedBox(height: 8),
          // Calendar days
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: firstWeekday - 1 + daysInMonth,
              itemBuilder: (context, index) {
                if (index < firstWeekday - 1) {
                  return const SizedBox.shrink();
                }

                final day = index - (firstWeekday - 1) + 1;
                final date =
                    DateTime(_currentMonth.year, _currentMonth.month, day);
                final hasWorkout = provider.hasWorkoutOnDate(date);

                return GestureDetector(
                  onTap: hasWorkout
                      ? () => _showDayWorkouts(context, provider, date)
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: hasWorkout
                          ? theme.colorScheme.primary.withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: hasWorkout
                          ? Border.all(
                              color: theme.colorScheme.primary,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              hasWorkout ? FontWeight.w600 : FontWeight.w400,
                          color: hasWorkout
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 0),
          // Statistics bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: appColors.surfaceElevated,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.08)
                      : appColors.border,
                ),
                boxShadow: AppShadows.elevatedSoft,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Workout days
                  Text(
                    AppLocalizations.of(context)!.workoutDays(
                      LocalizedFormat.decimal(
                        context,
                        workoutDays,
                        decimalDigits: 0,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                  // Divider
                  Container(
                    height: 20,
                    width: 1.2,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF4C4C4C)
                        : const Color(0xFFCCCCCC),
                  ),
                  // Rest days
                  Text(
                    AppLocalizations.of(context)!.restDays(
                      LocalizedFormat.decimal(
                        context,
                        restDays,
                        decimalDigits: 0,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.3,
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

  void _showDayWorkouts(
      BuildContext context, WorkoutHistoryProvider provider, DateTime date) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => _DayWorkoutsSheet(date: date),
    );
  }
}

class _DayWorkoutsSheet extends StatelessWidget {
  final DateTime date;

  const _DayWorkoutsSheet({required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appColors = theme.extension<AppColors>()!;

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      expand: false,
      snap: true,
      snapSizes: const [0.45, 0.70, 0.92],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : theme.extension<AppColors>()!.border,
            ),
            boxShadow: AppShadows.elevatedSoft,
          ),
          child: Column(
            children: [
              // Drag handle
              const AppBottomSheetHandle(),
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : appColors.border,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Date title
                    Text(
                      LocalizedFormat.longDate(context, date),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Consumer<WorkoutHistoryProvider>(
                  builder: (context, provider, child) {
                    final sessions = provider.getSessionsByDate(date);
                    if (sessions.isEmpty) {
                      return _buildEmptyState(context);
                    }
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SwipeRevealDelete(
                            key: Key(session.id),
                            itemId: 'calendar_session_${session.id}',
                            onDelete: () {
                              provider.deleteSession(session.id);
                            },
                            child: _DayWorkoutRow(session: session),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: 48,
              color: appColors.mutedText,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.noWorkoutsYet,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.startAWorkoutToSeeItHere,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: appColors.mutedText,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                AppShell.navigateToRoutineTab();
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              ),
              child: Text(
                AppLocalizations.of(context)!.goToRoutines,
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayWorkoutRow extends StatelessWidget {
  final WorkoutSession session;

  const _DayWorkoutRow({required this.session});

  String _getFriendlyRoutineName(
      String? routineName, MachineType machineType, BuildContext context) {
    if (routineName != null && routineName.isNotEmpty) {
      return routineName;
    }
    final l10n = AppLocalizations.of(context)!;
    switch (machineType) {
      case MachineType.treadmill:
        return l10n.treadmillWorkout;
      case MachineType.cycle:
        return l10n.bikeWorkout;
      case MachineType.stairmaster:
        return l10n.stairmasterWorkout;
    }
  }

  String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);
    final isMetric = settingsProvider.measurement == 'kmh';
    final l10n = AppLocalizations.of(context)!;

    String? formatDistance(double meters) {
      if (isMetric) {
        if (meters >= 1000) {
          return '${LocalizedFormat.decimal(context, meters / 1000, decimalDigits: 2)} km';
        }
        return '${LocalizedFormat.decimal(context, meters, decimalDigits: 0)} m';
      } else {
        const metersPerMile = 1609.344;
        final miles = meters / metersPerMile;
        if (miles >= 0.1) {
          return '${LocalizedFormat.decimal(context, miles, decimalDigits: 2)} mi';
        }
        final feet = meters * 3.28084;
        return '${LocalizedFormat.decimal(context, feet, decimalDigits: 0)} ft';
      }
    }

    String? formatAverageSpeed() {
      if (session.machineType == MachineType.treadmill &&
          session.distanceMeters != null &&
          session.durationSeconds > 0) {
        final elapsedSeconds = session.elapsedMilliseconds != null &&
                session.elapsedMilliseconds! > 0
            ? session.elapsedMilliseconds! / 1000.0
            : session.durationSeconds.toDouble();
        final hours = elapsedSeconds / 3600.0;
        final speedKmh = (session.distanceMeters! / 1000.0) / hours;
        if (isMetric) {
          return l10n.averageSpeedKmh(
            LocalizedFormat.decimal(context, speedKmh),
          );
        } else {
          final speedMph = speedKmh / 1.609344;
          return l10n.averageSpeedMph(
            LocalizedFormat.decimal(context, speedMph),
          );
        }
      }
      return null;
    }

    String? formatMetric() {
      switch (session.machineType) {
        case MachineType.treadmill:
          return session.distanceMeters != null
              ? formatDistance(session.distanceMeters!)
              : null;
        case MachineType.cycle:
          return session.averageRpm != null
              ? l10n.averageRpmValue(
                  LocalizedFormat.decimal(
                    context,
                    session.averageRpm!.round(),
                    decimalDigits: 0,
                  ),
                )
              : null;
        case MachineType.stairmaster:
          return session.averageLevel != null
              ? l10n.averageLevelValue(
                  LocalizedFormat.decimal(context, session.averageLevel!),
                )
              : null;
      }
    }

    final friendlyName = _getFriendlyRoutineName(
        session.routineName, session.machineType, context);
    final avgSpeed = formatAverageSpeed();
    final metric = formatMetric();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: appColors.border,
          width: 1,
        ),
        boxShadow: AppShadows.elevatedSoft,
      ),
      child: Row(
        children: [
          // Leading icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getMachineIcon(session.machineType),
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friendlyName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      formatDuration(session.durationSeconds),
                      style: TextStyle(
                        fontSize: 14,
                        color: appColors.mutedText,
                      ),
                    ),
                    if (metric != null) ...[
                      Text(
                        '•',
                        style: TextStyle(color: appColors.mutedText),
                      ),
                      Text(
                        metric,
                        style: TextStyle(
                          fontSize: 14,
                          color: appColors.mutedText,
                        ),
                      ),
                    ],
                    if (avgSpeed != null) ...[
                      Text(
                        '•',
                        style: TextStyle(color: appColors.mutedText),
                      ),
                      Text(
                        avgSpeed,
                        style: TextStyle(
                          fontSize: 14,
                          color: appColors.mutedText,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMachineIcon(MachineType machineType) {
    switch (machineType) {
      case MachineType.treadmill:
        return Icons.directions_run;
      case MachineType.cycle:
        return Icons.directions_bike;
      case MachineType.stairmaster:
        return Icons.stairs;
    }
  }
}

// Weight Tab
