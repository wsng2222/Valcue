import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
    if (PlatformInfo.isIOS) {
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

    final theme = Theme.of(context);
    final appColors = context.appColors;
    final isDark = theme.brightness == Brightness.dark;
    final titles = [
      AppLocalizations.of(context)!.treadmill,
      AppLocalizations.of(context)!.bike,
      AppLocalizations.of(context)!.stairmaster,
    ];
    final items = [
      _MachineTabItem(icon: Icons.directions_run, label: titles[0]),
      _MachineTabItem(icon: Icons.pedal_bike, label: titles[1]),
      _MachineTabItem(icon: Icons.stairs, label: titles[2]),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const outerPadding = 4.0;
        final innerWidth = (constraints.maxWidth - (outerPadding * 2))
            .clamp(0.0, double.infinity)
            .toDouble();
        final segmentWidth = innerWidth / items.length;

        return Container(
          padding: const EdgeInsets.all(outerPadding),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : appColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeInOutCubic,
                left: segmentWidth * _selectedMachineTab,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: appColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.black.withValues(alpha: 0.04),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final isSelected = _selectedMachineTab == index;
                  final iconColor = isSelected
                      ? theme.colorScheme.primary
                      : appColors.mutedText;
                  final textColor = isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5);
                  final fontWeight =
                      isSelected ? FontWeight.w700 : FontWeight.w600;

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() => _selectedMachineTab = index);
                        widget.onMachineTabChanged(index);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.icon,
                              size: 17,
                              color: iconColor,
                            ),
                            const SizedBox(width: 7),
                            Flexible(
                              child: Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: fontWeight,
                                  color: textColor,
                                  letterSpacing: -0.25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryContent(
      BuildContext context,
      WorkoutHistoryProvider provider,
      MachineType machineType,
      List<WorkoutSession> sessions) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
      color: isDark ? Colors.black : Colors.white,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          // This week summary card
          _buildWeekSummaryCard(context, thisWeekSessions, machineType),
          const SizedBox(height: 16),
          // Grouped history
          ...sortedDates.map((date) {
            final dateSessions = groupedSessions[date]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 4,
                    bottom: 6,
                  ),
                  child: Text(
                    _formatDateHeader(date),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.extension<AppColors>()!.mutedText,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                ...dateSessions.map((session) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
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
    final isDark = theme.brightness == Brightness.dark;
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : context.appColors.border,
          width: 1,
        ),
        boxShadow: AppShadows.elevatedSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.thisWeek,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
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
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Navigate to Routine tab with specific machine type
                AppShell.navigateToRoutineTabWithMachineType(machineType);
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
            fontSize: 12,
            color: appColors.mutedText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
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
        return Icons.pedal_bike;
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
                const SizedBox(height: 4),
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
                    if (formatMetric() != null) ...[
                      Text(
                        '•',
                        style: TextStyle(color: appColors.mutedText),
                      ),
                      Text(
                        formatMetric()!,
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
}

// Heatmap of workouts for the last 20 weeks

class _MachineTabItem {
  final IconData icon;
  final String label;

  const _MachineTabItem({
    required this.icon,
    required this.label,
  });
}
