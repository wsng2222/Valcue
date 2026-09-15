import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'package:valcue/l10n/localized_format.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../app_settings/app_settings_provider.dart';
import '../../../app_shell/app_shell.dart';
import '../../../widgets/valcue_ui.dart';
import '../models/workout_session.dart';
import '../providers/workout_history_provider.dart';
import '../../routines/models/machine_type.dart';
import '../../../widgets/app_segmented_control.dart';
import 'swipe_reveal_delete.dart';

class WorkoutHistoryTab extends StatefulWidget {
  final int selectedMachineTab;
  final ValueChanged<int> onMachineTabChanged;

  const WorkoutHistoryTab({super.key, 
    required this.selectedMachineTab,
    required this.onMachineTabChanged,
  });

  @override
  State<WorkoutHistoryTab> createState() => _WorkoutHistoryTabState();
}

class _WorkoutHistoryTabState extends State<WorkoutHistoryTab> {
  int _selectedMachineTab = 0;

  @override
  void initState() {
    super.initState();
    _selectedMachineTab = widget.selectedMachineTab;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutHistoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final machineTypes = [
          MachineType.treadmill,
          MachineType.cycle,
          MachineType.stairmaster
        ];
        final selectedType = machineTypes[_selectedMachineTab];
        final allSessions = provider.getSessionsByMachineType(selectedType);

        return Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              // Machine type pill chips
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                child: _buildMachineTypePills(context, provider, machineTypes),
              ),
              // Content area
              Expanded(
                child: allSessions.isEmpty
                    ? _buildEmptyState(context, selectedType)
                    : _buildHistoryContent(
                        context, provider, selectedType, allSessions),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMachineTypePills(BuildContext context,
      WorkoutHistoryProvider provider, List<MachineType> machineTypes) {
    final titles = [
      AppLocalizations.of(context)!.treadmill,
      AppLocalizations.of(context)!.bike,
      AppLocalizations.of(context)!.stairmaster,
    ];
    final selectedIndex = _selectedMachineTab.clamp(0, titles.length - 1);
    final selectedBg = appSegmentedSelectedBackground(context);
    final brightnessKey = Theme.of(context).brightness;
    final localeKey = Localizations.localeOf(context).toLanguageTag();

    return SegmentedButtonTheme(
      data: appSegmentedThemeData(context, selectedBg),
      child: SizedBox(
        width: double.infinity,
        child: AppSegmentedControl(
          key: ValueKey(
              'profile_machine_segment_${brightnessKey.name}_$localeKey'),
          labels: titles,
          selectedIndex: selectedIndex,
          onValueChanged: (index) {
            setState(() => _selectedMachineTab = index);
            widget.onMachineTabChanged(index);
          },
          height: 44,
          color: selectedBg,
        ),
      ),
    );
  }

  Widget _buildHistoryContent(
      BuildContext context,
      WorkoutHistoryProvider provider,
      MachineType machineType,
      List<WorkoutSession> sessions) {
    final theme = Theme.of(context);

    // Group sessions by date
    final groupedSessions = <DateTime, List<WorkoutSession>>{};
    for (final session in sessions) {
      final date = DateTime(
          session.dateTime.year, session.dateTime.month, session.dateTime.day);
      groupedSessions.putIfAbsent(date, () => []).add(session);
    }

    // Sort dates descending
    final sortedDates = groupedSessions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    // Calculate this week's stats
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final thisWeekSessions = sessions.where((s) {
      final date = DateTime(s.dateTime.year, s.dateTime.month, s.dateTime.day);
      return date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          date.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
        children: [
          // This week summary card
          _buildWeekSummaryCard(context, thisWeekSessions, machineType),
          const SizedBox(height: 20),
          // Grouped history
          ...sortedDates.map((date) {
            final dateSessions = groupedSessions[date]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 10),
                  child: Text(
                    _formatDateHeader(date),
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.extension<AppColors>()!.mutedText,
                    ),
                  ),
                ),
                ...dateSessions.map((session) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SwipeRevealDelete(
                        key: Key(session.id),
                        itemId: 'session_${session.id}',
                        onDelete: () {
                          provider.deleteSession(session.id);
                        },
                        child: _WorkoutHistoryCard(session: session),
                      ),
                    )),
                const SizedBox(height: 12),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWeekSummaryCard(BuildContext context,
      List<WorkoutSession> sessions, MachineType machineType) {
    final theme = Theme.of(context);
    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);
    final isMetric = settingsProvider.measurement == 'kmh';

    int totalSeconds = 0;
    double totalDistance = 0.0;
    for (final session in sessions) {
      totalSeconds += session.durationSeconds;
      if (session.distanceMeters != null) {
        totalDistance += session.distanceMeters!;
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

    String formatDistance(double meters) {
      if (isMetric) {
        // Keep metric distance formatting consistent across the app.
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
        // Convert to feet for very small distances
        final feet = meters * 3.28084;
        return '${LocalizedFormat.decimal(context, feet, decimalDigits: 0)} ft';
      }
    }

    // Determine which metrics to show
    final showDistance =
        machineType == MachineType.treadmill && totalDistance > 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: valcueCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.thisWeek,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SummaryStat(
                  label: AppLocalizations.of(context)!.totalWorkoutTime,
                  value: formatDuration(totalSeconds),
                ),
              ),
              Expanded(
                child: _SummaryStat(
                  label: AppLocalizations.of(context)!.workouts,
                  value: '${sessions.length}',
                ),
              ),
              if (showDistance)
                Expanded(
                  child: _SummaryStat(
                    label: AppLocalizations.of(context)!.distance,
                    value: formatDistance(totalDistance),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return AppLocalizations.of(context)!.today;
    } else if (dateOnly == yesterday) {
      return AppLocalizations.of(context)!.yesterday;
    } else {
      return LocalizedFormat.mediumDate(context, date);
    }
  }

  Widget _buildEmptyState(BuildContext context, MachineType machineType) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.noWorkoutsYet,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to Routine tab with specific machine type
                AppShell.navigateToRoutineTabWithMachineType(machineType);
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: Text(
                AppLocalizations.of(context)!.goToRoutines,
                style: GoogleFonts.lato(
                  fontSize: 16,
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

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: appColors.mutedText,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

class _WorkoutHistoryCard extends StatelessWidget {
  final WorkoutSession session;

  const _WorkoutHistoryCard({required this.session});

  String _getFriendlyRoutineName(
      String routineName, MachineType machineType, BuildContext context) {
    if (routineName.isEmpty || routineName.toLowerCase().contains('untitled')) {
      final l10n = AppLocalizations.of(context)!;
      switch (machineType) {
        case MachineType.treadmill:
          return l10n.treadmillSession;
        case MachineType.cycle:
          return l10n.bikeSession;
        case MachineType.stairmaster:
          return l10n.stairmasterSession;
      }
    }
    return routineName;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);
    final isMetric = settingsProvider.measurement == 'kmh';
    final l10n = AppLocalizations.of(context)!;

    String formatDuration(int seconds) {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      final secs = seconds % 60;

      if (hours > 0) {
        return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
      }
      return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }

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

    // Calculate average speed for treadmill (if distance and time available)
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: valcueCardDecoration(context),
      child: Row(
        children: [
          // Leading icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: appColors.tint,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              _getMachineIcon(session.machineType),
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friendlyName,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      formatDuration(session.durationSeconds),
                      style: TextStyle(
                        fontSize: 13,
                        color: appColors.mutedText,
                      ),
                    ),
                    if (formatMetric() != null) ...[
                      Text(
                        '•',
                        style: TextStyle(color: appColors.mutedText),
                      ),
                      Text(
                        formatMetric()!,
                        style: TextStyle(
                          fontSize: 13,
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
                          fontSize: 13,
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
}
