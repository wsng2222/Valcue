import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:interval_cardio/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../app_settings/app_settings_provider.dart';
import '../../../app_shell/app_shell.dart';
import '../../../utils/app_shadows.dart';
import '../../../widgets/unified_screen_header.dart';
import '../models/workout_session.dart';
import '../models/weight_entry.dart';
import '../providers/workout_history_provider.dart';
import '../providers/weight_tracker_provider.dart';
import '../../routines/models/machine_type.dart';

Color _weightSegmentSelectedBackground(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? const Color(0xFF2C2C2E) : Colors.white;
}

SegmentedButtonThemeData _weightSegmentThemeData(
  BuildContext context,
  Color selectedBackground,
) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final selectedForeground = isDark ? Colors.white : Colors.black87;
  final borderColor = theme.colorScheme.outline.withValues(alpha: 0.35);

  return SegmentedButtonThemeData(
    style: SegmentedButton.styleFrom(
      selectedBackgroundColor: selectedBackground,
      selectedForegroundColor: selectedForeground,
      foregroundColor: theme.colorScheme.onSurface,
      backgroundColor: theme.colorScheme.surface,
      side: BorderSide(color: borderColor),
      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
  );
}

Widget _buildPlatformSegmentedControl({
  required Key key,
  required List<String> labels,
  required int selectedIndex,
  required ValueChanged<int> onValueChanged,
  required double height,
  bool shrinkWrap = false,
  Color? color,
}) {
  if (PlatformInfo.isIOS) {
    return AdaptiveSegmentedControl(
      key: key,
      labels: labels,
      selectedIndex: selectedIndex,
      onValueChanged: onValueChanged,
      height: height,
      shrinkWrap: shrinkWrap,
      color: color,
    );
  }

  final hasLabels = labels.isNotEmpty;
  final safeIndex = hasLabels ? selectedIndex.clamp(0, labels.length - 1) : 0;

  return SizedBox(
    key: key,
    width: shrinkWrap ? null : double.infinity,
    height: height,
    child: SegmentedButton<int>(
      segments: [
        for (var i = 0; i < labels.length; i++)
          ButtonSegment<int>(value: i, label: Text(labels[i])),
      ],
      selected: hasLabels ? {safeIndex} : const <int>{},
      showSelectedIcon: false,
      onSelectionChanged: (selection) {
        if (selection.isEmpty) return;
        onValueChanged(selection.first);
      },
    ),
  );
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedMachineTab = 0; // 0: Treadmill, 1: Bike, 2: Stairmaster

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header - same style as Settings screen
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: UnifiedScreenHeader(
                icon: Icons.person,
                title: AppLocalizations.of(context)!.myTab,
              ),
            ),
            // Tabs: Workout History, Calendar, Weight
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: AppLocalizations.of(context)!.historyTab),
                Tab(text: AppLocalizations.of(context)!.calendarTab),
                Tab(text: AppLocalizations.of(context)!.weightTab),
              ],
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.extension<AppColors>()!.mutedText,
              indicatorColor: theme.colorScheme.primary,
            ),
            // Tab content
            Expanded(
              child: Consumer<AppSettingsProvider>(
                builder: (context, settingsProvider, child) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _WorkoutHistoryTab(
                        selectedMachineTab: _selectedMachineTab,
                        onMachineTabChanged: (i) =>
                            setState(() => _selectedMachineTab = i),
                      ),
                      const _CalendarTab(),
                      Stack(
                        children: [
                          const _WeightTab(),
                          if (!settingsProvider.isPremium)
                            _buildPremiumLockOverlay(context),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumLockOverlay(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned.fill(
      child: Container(
        color: theme.scaffoldBackgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_fire_department,
                size: 80,
                color: theme.extension<AppColors>()!.mutedText,
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.premium,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.premiumFeature,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.extension<AppColors>()!.mutedText,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  AppShell.navigateToPremiumTab();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  AppLocalizations.of(context)!.viewMembership,
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
      ),
    );
  }
}

// Workout History Tab
class _WorkoutHistoryTab extends StatefulWidget {
  final int selectedMachineTab;
  final ValueChanged<int> onMachineTabChanged;

  const _WorkoutHistoryTab({
    required this.selectedMachineTab,
    required this.onMachineTabChanged,
  });

  @override
  State<_WorkoutHistoryTab> createState() => _WorkoutHistoryTabState();
}

class _WorkoutHistoryTabState extends State<_WorkoutHistoryTab> {
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
                padding: const EdgeInsets.all(16),
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
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.08) : appColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPillChip(
              0,
              AppLocalizations.of(context)!.treadmill,
              context,
              machineTypes[0],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildPillChip(
              1,
              AppLocalizations.of(context)!.bike,
              context,
              machineTypes[1],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildPillChip(
              2,
              AppLocalizations.of(context)!.stairmaster,
              context,
              machineTypes[2],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillChip(
      int index, String label, BuildContext context, MachineType machineType) {
    final theme = Theme.of(context);
    final isSelected = _selectedMachineTab == index;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedMachineTab = index);
        widget.onMachineTabChanged(index);
      },
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFECECEC))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: isSelected
              ? Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.black.withValues(alpha: 0.04),
                  width: 1.0,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
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
        padding: const EdgeInsets.all(16),
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
                  padding: const EdgeInsets.only(left: 4, bottom: 6),
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
                      child: _SwipeRevealDelete(
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
        // Auto-format: show km if >= 0.1 km, otherwise show m
        if (meters >= 100) {
          return '${(meters / 1000).toStringAsFixed(2)} km';
        }
        return '${meters.toStringAsFixed(0)} m';
      } else {
        const metersPerMile = 1609.344;
        final miles = meters / metersPerMile;
        if (miles >= 0.1) {
          return '${miles.toStringAsFixed(2)} mi';
        }
        // Convert to feet for very small distances
        final feet = meters * 3.28084;
        return '${feet.toStringAsFixed(0)} ft';
      }
    }

    // Determine which metrics to show
    final showDistance =
        machineType == MachineType.treadmill && totalDistance > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
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
                  label: AppLocalizations.of(context)!.sessions,
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
      final locale = Localizations.localeOf(context);
      // Use locale-appropriate date format
      return DateFormat.yMMMd(locale.toString()).format(date);
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
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.startYourFirstWorkout,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: appColors.mutedText,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Navigate to Routine tab with specific machine type
                AppShell.navigateToRoutineTabWithMachineType(machineType);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
    final isDark = theme.brightness == Brightness.dark;
    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);
    final isMetric = settingsProvider.measurement == 'kmh';

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
        if (meters >= 100) {
          return '${(meters / 1000).toStringAsFixed(2)} km';
        }
        return '${meters.toStringAsFixed(0)} m';
      } else {
        const metersPerMile = 1609.344;
        final miles = meters / metersPerMile;
        if (miles >= 0.1) {
          return '${miles.toStringAsFixed(2)} mi';
        }
        final feet = meters * 3.28084;
        return '${feet.toStringAsFixed(0)} ft';
      }
    }

    // Calculate average speed for treadmill (if distance and time available)
    String? formatAverageSpeed() {
      if (session.machineType == MachineType.treadmill &&
          session.distanceMeters != null &&
          session.durationSeconds > 0) {
        final hours = session.durationSeconds / 3600.0;
        final speedKmh = (session.distanceMeters! / 1000.0) / hours;
        if (isMetric) {
          return 'Avg. ${speedKmh.toStringAsFixed(1)} km/h';
        } else {
          final speedMph = speedKmh / 1.609344;
          return 'Avg. ${speedMph.toStringAsFixed(1)} mph';
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
              ? 'Avg RPM ${session.averageRpm!.round()}'
              : null;
        case MachineType.stairmaster:
          return session.averageLevel != null
              ? 'Avg Level ${session.averageLevel!.toStringAsFixed(1)}'
              : null;
      }
    }

    final friendlyName = _getFriendlyRoutineName(
        session.routineName, session.machineType, context);
    final avgSpeed = formatAverageSpeed();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.1) : appColors.border,
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

// Calendar Tab
class _CalendarTab extends StatefulWidget {
  const _CalendarTab();

  @override
  State<_CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<_CalendarTab> {
  DateTime _currentMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutHistoryProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Month navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        _currentMonth = DateTime(
                            _currentMonth.year, _currentMonth.month - 1);
                      });
                    },
                  ),
                  Text(
                    DateFormat.yMMMM(Localizations.localeOf(context).toString())
                        .format(_currentMonth),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
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
                    AppLocalizations.of(context)!.workoutDays(workoutDays),
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
                    AppLocalizations.of(context)!.restDays(restDays),
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
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
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
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme
                      .extension<AppColors>()!
                      .mutedText
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
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
                      DateFormat.yMMMMd(
                              Localizations.localeOf(context).toString())
                          .format(date),
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
                          child: _SwipeRevealDelete(
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
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
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

class _SwipeRevealDelete extends StatefulWidget {
  final String itemId;
  final Widget child;
  final VoidCallback onDelete;
  final double? buttonDiameter;
  final double? actionWidth;
  final double? verticalInset;
  final double verticalOffset;

  const _SwipeRevealDelete({
    super.key,
    required this.itemId,
    required this.child,
    required this.onDelete,
    this.buttonDiameter,
    this.actionWidth,
    this.verticalInset,
    this.verticalOffset = 0,
  });

  @override
  State<_SwipeRevealDelete> createState() => _SwipeRevealDeleteState();
}

class _SwipeRevealDeleteState extends State<_SwipeRevealDelete> {
  static const double _triggerOffset = 44;
  static final ValueNotifier<String?> _openItemId =
      ValueNotifier<String?>(null);
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _openItemId.addListener(_handleOpenItemChanged);
  }

  @override
  void dispose() {
    _openItemId.removeListener(_handleOpenItemChanged);
    super.dispose();
  }

  void _handleOpenItemChanged() {
    if (!mounted) return;
    final openItemId = _openItemId.value;
    if (openItemId != widget.itemId && _dragOffset != 0) {
      setState(() {
        _dragOffset = 0;
      });
    }
  }

  void _handleDragUpdate(DragUpdateDetails details, double actionWidth) {
    if (_openItemId.value != widget.itemId) {
      _openItemId.value = widget.itemId;
    }
    final nextOffset =
        (_dragOffset + details.delta.dx).clamp(-actionWidth, 0.0);
    setState(() {
      _dragOffset = nextOffset;
    });
  }

  void _handleDragEnd(DragEndDetails details, double actionWidth) {
    final shouldOpen = _dragOffset.abs() > _triggerOffset;
    setState(() {
      _dragOffset = shouldOpen ? -actionWidth : 0;
    });
    _openItemId.value = shouldOpen ? widget.itemId : null;
  }

  void _close() {
    if (_dragOffset == 0) return;
    setState(() {
      _dragOffset = 0;
    });
    if (_openItemId.value == widget.itemId) {
      _openItemId.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight =
            constraints.maxHeight.isFinite ? constraints.maxHeight : 80.0;
        final verticalInset = widget.verticalInset ?? 8.0;
        final buttonDiameter = widget.buttonDiameter ??
            (availableHeight - (verticalInset * 2)).clamp(46.0, 60.0);
        final actionWidth = widget.actionWidth ?? (buttonDiameter + 20);

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragUpdate: (details) =>
              _handleDragUpdate(details, actionWidth),
          onHorizontalDragEnd: (details) =>
              _handleDragEnd(details, actionWidth),
          onTap: _close,
          child: Stack(
            children: [
              Positioned(
                top: ((availableHeight - buttonDiameter) / 2) +
                    widget.verticalOffset,
                right: 2,
                child: SizedBox(
                  width: actionWidth,
                  height: buttonDiameter,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: buttonDiameter,
                      height: buttonDiameter,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: widget.onDelete,
                          child: Center(
                            child: Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: buttonDiameter * 0.42,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                transform: Matrix4.translationValues(
                  _dragOffset.clamp(-actionWidth, 0.0),
                  0,
                  0,
                ),
                child: widget.child,
              ),
            ],
          ),
        );
      },
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
    final isDark = theme.brightness == Brightness.dark;
    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);
    final isMetric = settingsProvider.measurement == 'kmh';

    String? formatDistance(double meters) {
      if (isMetric) {
        if (meters >= 100) {
          return '${(meters / 1000).toStringAsFixed(2)} km';
        }
        return '${meters.toStringAsFixed(0)} m';
      } else {
        const metersPerMile = 1609.344;
        final miles = meters / metersPerMile;
        if (miles >= 0.1) {
          return '${miles.toStringAsFixed(2)} mi';
        }
        final feet = meters * 3.28084;
        return '${feet.toStringAsFixed(0)} ft';
      }
    }

    String? formatAverageSpeed() {
      if (session.machineType == MachineType.treadmill &&
          session.distanceMeters != null &&
          session.durationSeconds > 0) {
        final hours = session.durationSeconds / 3600.0;
        final speedKmh = (session.distanceMeters! / 1000.0) / hours;
        if (isMetric) {
          return 'Avg. ${speedKmh.toStringAsFixed(1)} km/h';
        } else {
          final speedMph = speedKmh / 1.609344;
          return 'Avg. ${speedMph.toStringAsFixed(1)} mph';
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
              ? 'Avg RPM ${session.averageRpm!.round()}'
              : null;
        case MachineType.stairmaster:
          return session.averageLevel != null
              ? 'Avg Level ${session.averageLevel!.toStringAsFixed(1)}'
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
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.1) : appColors.border,
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
class _WeightTab extends StatefulWidget {
  const _WeightTab();

  @override
  State<_WeightTab> createState() => _WeightTabState();
}

class _WeightTabState extends State<_WeightTab> {
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
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, size: 20),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.recordWeight),
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
                    _WeightSummaryCard(
                      onRecordTap: () => _showRecordWeightBottomSheet(context),
                    ),
                    const SizedBox(height: 20),
                    // Trend Chart (only if 2+ entries - need at least 2 points to draw a line)
                    if (provider.entries.length >= 2) ...[
                      _WeightTrendChart(timeframe: _selectedTimeframe),
                      const SizedBox(height: 20),
                    ] else if (provider.entries.length == 1) ...[
                      _buildTrendEmptyState(context),
                      const SizedBox(height: 20),
                    ],
                    // History List
                    if (provider.entries.isNotEmpty)
                      _WeightHistoryList(
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
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add, size: 20),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.recordWeight),
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
    final isDark = theme.brightness == Brightness.dark;
    final appColors = theme.extension<AppColors>()!;

    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color:
                isDark ? Colors.white.withValues(alpha: 0.1) : appColors.border,
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
    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);
    final provider = Provider.of<WeightTrackerProvider>(context, listen: false);
    final isWeightMetric = settingsProvider.weightUnit == 'kg';
    final weightController = TextEditingController();
    final currentWeight = provider.currentWeight;

    if (currentWeight != null) {
      weightController.text = isWeightMetric
          ? currentWeight.weightKg.toStringAsFixed(1)
          : (currentWeight.weightKg * 2.20462).toStringAsFixed(1);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => _RecordWeightBottomSheet(
        weightController: weightController,
        isMetric: isWeightMetric,
      ),
    );
  }
}

// Weight Summary Card - Unified card with current weight, delta, goal, progress bar
class _WeightSummaryCard extends StatelessWidget {
  final VoidCallback? onRecordTap;

  const _WeightSummaryCard({this.onRecordTap});

  @override
  Widget build(BuildContext context) {
    return Consumer2<WeightTrackerProvider, AppSettingsProvider>(
      builder: (context, provider, settingsProvider, child) {
        final theme = Theme.of(context);
        final appColors = theme.extension<AppColors>()!;
        final isDark = theme.brightness == Brightness.dark;
        final isWeightMetric = settingsProvider.weightUnit == 'kg';

        final currentWeight = provider.currentWeight;
        final weightChange = provider.getWeightChange();
        final goalWeight = provider.goalWeight;
        final toGoal = provider.getWeightToGoal();

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
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
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
                          currentWeight.formatWeight(isWeightMetric),
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
                                  Text(
                                    '${weightChange > 0 ? '+' : ''}${WeightEntry(dateTime: DateTime.now(), weightKg: weightChange.abs()).formatWeight(isWeightMetric)}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: weightChange < 0
                                          ? Colors.green
                                          : appColors.mutedText,
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
                                    Text(
                                      goalWeight != null
                                          ? WeightEntry(
                                              dateTime: DateTime.now(),
                                              weightKg: goalWeight,
                                            ).formatWeight(isWeightMetric)
                                          : AppLocalizations.of(context)!
                                              .setGoal,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: goalWeight != null
                                            ? theme.colorScheme.primary
                                            : appColors.mutedText,
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
                        toGoal.abs() < 0.1
                            ? '${AppLocalizations.of(context)!.goal} ${WeightEntry(dateTime: DateTime.now(), weightKg: goalWeight).formatWeight(isWeightMetric)} • ${AppLocalizations.of(context)!.goalAchieved}'
                            : '${AppLocalizations.of(context)!.goal} ${WeightEntry(dateTime: DateTime.now(), weightKg: goalWeight).formatWeight(isWeightMetric)} • ${WeightEntry(dateTime: DateTime.now(), weightKg: toGoal.abs()).formatWeight(isWeightMetric)} ${toGoal > 0 ? AppLocalizations.of(context)!.toGo : AppLocalizations.of(context)!.over}',
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
              ? provider.goalWeight!.toStringAsFixed(1)
              : (provider.goalWeight! * 2.20462).toStringAsFixed(1))
          : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => _SetGoalBottomSheet(
        goalWeightController: goalWeightController,
        isMetric: isWeightMetric,
        currentWeight: provider.currentWeight,
      ),
    );
  }
}

// Weight Trend Chart - Sparkline with timeframe selector
class _WeightTrendChart extends StatefulWidget {
  final int timeframe; // 0: 7D, 1: 30D, 2: 90D, 3: ALL

  const _WeightTrendChart({required this.timeframe});

  @override
  State<_WeightTrendChart> createState() => _WeightTrendChartState();
}

class _WeightTrendChartState extends State<_WeightTrendChart> {
  late int _selectedTimeframe;

  @override
  void initState() {
    super.initState();
    _selectedTimeframe = widget.timeframe;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeightTrackerProvider>(
      builder: (context, provider, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final appColors = theme.extension<AppColors>()!;

        Widget buildHeader() {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.trend,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: PlatformInfo.isIOS
                      ? ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 240),
                          child: _TimeframeSelector(
                            selectedIndex: _selectedTimeframe,
                            onSelect: (index) {
                              setState(() {
                                _selectedTimeframe = index;
                              });
                            },
                          ),
                        )
                      : _TimeframeSelector(
                          selectedIndex: _selectedTimeframe,
                          onSelect: (index) {
                            setState(() {
                              _selectedTimeframe = index;
                            });
                          },
                        ),
                ),
              ),
            ],
          );
        }

        Widget buildTrendCard({required Widget body}) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
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
                buildHeader(),
                const SizedBox(height: 16),
                body,
              ],
            ),
          );
        }

        // Filter entries by timeframe
        final now = DateTime.now();
        List<WeightEntry> chartEntries;
        switch (_selectedTimeframe) {
          case 0: // 7D
            final cutoff = now.subtract(const Duration(days: 7));
            chartEntries = provider.entries
                .where((e) => !e.dateTime.isBefore(cutoff))
                .toList()
                .reversed
                .toList();
            break;
          case 1: // 30D
            final cutoff = now.subtract(const Duration(days: 30));
            chartEntries = provider.entries
                .where((e) => !e.dateTime.isBefore(cutoff))
                .toList()
                .reversed
                .toList();
            break;
          case 2: // 90D
            final cutoff = now.subtract(const Duration(days: 90));
            chartEntries = provider.entries
                .where((e) => !e.dateTime.isBefore(cutoff))
                .toList()
                .reversed
                .toList();
            break;
          case 3: // ALL
          default:
            chartEntries = provider.entries.reversed.toList();
            break;
        }

        if (chartEntries.length < 2) {
          return buildTrendCard(
            body: SizedBox(
              height: 130,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.show_chart_rounded,
                      size: 34,
                      color: appColors.mutedText.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      AppLocalizations.of(context)!.addOneMoreRecordToSeeTrend,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: appColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final weights = chartEntries.map((e) => e.weightKg).toList();
        final minWeight = weights.reduce((a, b) => a < b ? a : b);
        final maxWeight = weights.reduce((a, b) => a > b ? a : b);
        final range = maxWeight - minWeight;
        final padding = range > 0 ? range * 0.1 : 1.0;

        return buildTrendCard(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 130,
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: CustomPaint(
                  painter: _WeightSparklinePainter(
                    entries: chartEntries,
                    minWeight: minWeight - padding,
                    maxWeight: maxWeight + padding,
                    color: theme.colorScheme.primary,
                  ),
                  size: Size.infinite,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TimeframeSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _TimeframeSelector({
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final labels = [
      AppLocalizations.of(context)!.timeframe7D,
      AppLocalizations.of(context)!.timeframe30D,
      AppLocalizations.of(context)!.timeframe90D,
      AppLocalizations.of(context)!.timeframeAll,
    ];

    if (!PlatformInfo.isIOS) {
      final theme = Theme.of(context);
      final appColors = theme.extension<AppColors>()!;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: labels.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onSelect(index),
            child: Container(
              margin: const EdgeInsets.only(left: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color:
                    isSelected ? theme.colorScheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : appColors.mutedText,
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    final selectedBg = _weightSegmentSelectedBackground(context);
    final brightnessKey = Theme.of(context).brightness;

    return SegmentedButtonTheme(
      data: _weightSegmentThemeData(context, selectedBg),
      child: _buildPlatformSegmentedControl(
        key: ValueKey('weight_timeframe_${brightnessKey.name}'),
        labels: labels,
        selectedIndex: selectedIndex,
        onValueChanged: onSelect,
        height: 32,
        shrinkWrap: true,
        color: selectedBg,
      ),
    );
  }
}

// Sparkline painter for weight trend
class _WeightSparklinePainter extends CustomPainter {
  final List<WeightEntry> entries;
  final double minWeight;
  final double maxWeight;
  final Color color;

  _WeightSparklinePainter({
    required this.entries,
    required this.minWeight,
    required this.maxWeight,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty || entries.length == 1) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final stepX = entries.length > 1 ? size.width / (entries.length - 1) : 0.0;
    final weightRange = maxWeight - minWeight;

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final x = (i * stepX).toDouble();
      final normalizedWeight =
          weightRange > 0 ? (entry.weightKg - minWeight) / weightRange : 0.5;
      final y = (size.height - (normalizedWeight * size.height)).toDouble();

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Highlight last point
      if (i == entries.length - 1) {
        canvas.drawCircle(Offset(x, y), 4.0, pointPaint);
        canvas.drawCircle(Offset(x, y), 2.0, Paint()..color = Colors.white);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WeightSparklinePainter oldDelegate) {
    return oldDelegate.entries != entries ||
        oldDelegate.minWeight != minWeight ||
        oldDelegate.maxWeight != maxWeight;
  }
}

// Weight History List with swipe actions
class _WeightHistoryList extends StatelessWidget {
  final bool showAll;
  final VoidCallback? onShowAll;

  const _WeightHistoryList({
    required this.showAll,
    this.onShowAll,
  });

  void _showEditWeightBottomSheet(BuildContext context, WeightEntry entry) {
    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);
    final isWeightMetric = settingsProvider.weightUnit == 'kg';
    final weightController = TextEditingController(
      text: isWeightMetric
          ? entry.weightKg.toStringAsFixed(1)
          : (entry.weightKg * 2.20462).toStringAsFixed(1),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => _RecordWeightBottomSheet(
        weightController: weightController,
        isMetric: isWeightMetric,
        initialDateTime: entry.dateTime,
        isEditing: true,
        entryId: entry.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WeightTrackerProvider, AppSettingsProvider>(
      builder: (context, provider, settingsProvider, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final isWeightMetric = settingsProvider.weightUnit == 'kg';

        final entriesToShow =
            showAll ? provider.entries : provider.entries.take(7).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.history,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
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
                  final locale = Localizations.localeOf(context);
                  // Use locale-appropriate date format
                  return DateFormat.yMMMd(locale.toString()).format(dateTime);
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SwipeRevealDelete(
                  key: Key(entry.id),
                  itemId: 'weight_${entry.id}',
                  buttonDiameter: 44,
                  actionWidth: 60,
                  verticalInset: 0,
                  verticalOffset: -10,
                  onDelete: () {
                    provider.deleteEntry(entry.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            AppLocalizations.of(context)!.weightEntryDeleted),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: InkWell(
                    onTap: () => _showEditWeightBottomSheet(context, entry),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : theme.extension<AppColors>()!.border,
                          width: 1,
                        ),
                        boxShadow: AppShadows.elevatedSoft,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.formatWeight(isWeightMetric),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            formatDate(entry.dateTime),
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.extension<AppColors>()!.mutedText,
                            ),
                          ),
                        ],
                      ),
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
class _RecordWeightBottomSheet extends StatefulWidget {
  final TextEditingController weightController;
  final bool isMetric;
  final DateTime? initialDateTime;
  final bool isEditing;
  final String? entryId;

  const _RecordWeightBottomSheet({
    required this.weightController,
    required this.isMetric,
    this.initialDateTime,
    this.isEditing = false,
    this.entryId,
  });

  @override
  State<_RecordWeightBottomSheet> createState() =>
      _RecordWeightBottomSheetState();
}

class _RecordWeightBottomSheetState extends State<_RecordWeightBottomSheet> {
  late TextEditingController _controller;
  bool _isValid = false;
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _controller = widget.weightController;
    _selectedDateTime = widget.initialDateTime ?? DateTime.now();
    _isValid = _controller.text.isNotEmpty;
    _controller.addListener(_validateInput);
  }

  @override
  void dispose() {
    _controller.removeListener(_validateInput);
    super.dispose();
  }

  void _validateInput() {
    final text = _controller.text.trim();
    final weight = double.tryParse(text);
    setState(() {
      _isValid =
          text.isNotEmpty && weight != null && weight > 0 && weight < 500;
    });
  }

  void _addQuickValue(double value) {
    final current = double.tryParse(_controller.text.trim()) ?? 0;
    final newValue = (current + value).clamp(0.0, 500.0);
    setState(() {
      _controller.text = newValue.toStringAsFixed(1);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate =
        _selectedDateTime.isAfter(now) ? now : _selectedDateTime;
    var tempPicked = DateTime(
      initialDate.year,
      initialDate.month,
      initialDate.day,
    );

    final pickedDate = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final l10n = AppLocalizations.of(context)!;

        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.only(top: 12, bottom: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : theme.extension<AppColors>()!.border,
              ),
              boxShadow: AppShadows.elevatedSoft,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: theme.extension<AppColors>()!.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              theme.extension<AppColors>()!.mutedText,
                        ),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, tempPicked),
                        child: Text(l10n.done),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 260,
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      brightness: isDark ? Brightness.dark : Brightness.light,
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: tempPicked,
                      minimumDate: DateTime(2020),
                      maximumDate: now,
                      onDateTimeChanged: (value) {
                        tempPicked = DateTime(
                          value.year,
                          value.month,
                          value.day,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        // Set time to start of day (00:00:00)
        _selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
        );
      });
    }
  }

  void _save() {
    if (!_isValid) return;

    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);
    final isMetric = settingsProvider.weightUnit == 'kg';
    final weightText = _controller.text.trim();
    final weight = double.tryParse(weightText);
    if (weight != null && weight > 0) {
      final weightKg = isMetric ? weight : weight / 2.20462;
      final provider =
          Provider.of<WeightTrackerProvider>(context, listen: false);

      HapticFeedback.mediumImpact();

      if (widget.isEditing && widget.entryId != null) {
        // Update existing entry
        provider.updateEntry(
          widget.entryId!,
          WeightEntry(
            id: widget.entryId!,
            dateTime: _selectedDateTime,
            weightKg: weightKg,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.weightUpdated),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Add new entry
        provider.addEntry(WeightEntry(
          dateTime: _selectedDateTime,
          weightKg: weightKg,
        ));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.weightRecorded),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      Navigator.pop(context);
    }
  }

  String _formatDateDisplay(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final l10n = AppLocalizations.of(context)!;
    if (dateOnly == today) {
      return l10n.today;
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return l10n.yesterday;
    } else {
      final locale = Localizations.localeOf(context);
      // Use locale-appropriate date format
      return DateFormat.yMMMd(locale.toString()).format(dateTime);
    }
  }

  String? _getLastWeightComparison(bool isMetric) {
    final provider = Provider.of<WeightTrackerProvider>(context, listen: false);
    if (provider.entries.length < 2) return null;

    final lastWeight = provider.entries[1].weightKg;
    final currentText = _controller.text.trim();
    final currentWeight = double.tryParse(currentText);

    if (currentWeight == null || currentText.isEmpty) return null;

    final currentWeightKg = isMetric ? currentWeight : currentWeight / 2.20462;
    final difference = currentWeightKg - lastWeight;

    String formatWeight(double kg, bool isMetric) {
      if (isMetric) {
        return '${kg.toStringAsFixed(1)} kg';
      } else {
        return '${(kg * 2.20462).toStringAsFixed(1)} lbs';
      }
    }

    final sign = difference > 0 ? '+' : '';
    final l10n = AppLocalizations.of(context)!;
    return '${l10n.last} ${formatWeight(lastWeight, isMetric)} → ${l10n.newLabel} ${formatWeight(currentWeightKg, isMetric)} ($sign${formatWeight(difference.abs(), isMetric)})';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettingsProvider>(
      builder: (context, settingsProvider, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final appColors = theme.extension<AppColors>()!;
        final isMetric = settingsProvider.weightUnit == 'kg';
        final lastComparison = _getLastWeightComparison(isMetric);

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : appColors.border,
            ),
            boxShadow: AppShadows.elevatedSoft,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: appColors.mutedText.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header with title and close button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.isEditing
                          ? AppLocalizations.of(context)!.editWeight
                          : AppLocalizations.of(context)!.recordWeight,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    PlatformInfo.isIOS
                        ? AdaptiveButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: Icons.close,
                            iconColor: appColors.mutedText,
                            style: AdaptiveButtonStyle.glass,
                            size: AdaptiveButtonSize.small,
                            color: appColors.mutedText,
                            padding: const EdgeInsets.all(6),
                            minSize: const Size(32, 32),
                            borderRadius: BorderRadius.circular(999),
                            useSmoothRectangleBorder: false,
                          )
                        : IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              size: 24,
                              color: appColors.mutedText,
                            ),
                          ),
                  ],
                ),
              ),
              // Content area (scrollable)
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero input area
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Large number input
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              autofocus: true,
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                                letterSpacing: -1.5,
                                height: 1.0,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: isMetric ? '70.5' : '155.5',
                                hintStyle: TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.w700,
                                  color: appColors.mutedText
                                      .withValues(alpha: 0.3),
                                  letterSpacing: -1.5,
                                  height: 1.0,
                                ),
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Unit pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: appColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : appColors.border,
                              ),
                            ),
                            child: Text(
                              isMetric ? 'kg' : 'lbs',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: appColors.mutedText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Last weight comparison preview
                      if (lastComparison != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          lastComparison,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: appColors.mutedText,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Date selector (premium list item style)
                      InkWell(
                        onTap: () => _selectDate(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: appColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : appColors.border,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _formatDateDisplay(_selectedDateTime),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: appColors.mutedText,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Quick adjust chips (2-row grid)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.quickAdjust,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: appColors.mutedText,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // First row: negative values
                          Row(
                            children: [
                              Expanded(
                                child: _QuickChip(
                                  label: '-1.0',
                                  onTap: () => _addQuickValue(-1.0),
                                  isNegative: true,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _QuickChip(
                                  label: '-0.5',
                                  onTap: () => _addQuickValue(-0.5),
                                  isNegative: true,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _QuickChip(
                                  label: '-0.2',
                                  onTap: () => _addQuickValue(-0.2),
                                  isNegative: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Second row: positive values
                          Row(
                            children: [
                              Expanded(
                                child: _QuickChip(
                                  label: '+0.2',
                                  onTap: () => _addQuickValue(0.2),
                                  isNegative: false,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _QuickChip(
                                  label: '+0.5',
                                  onTap: () => _addQuickValue(0.5),
                                  isNegative: false,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _QuickChip(
                                  label: '+1.0',
                                  onTap: () => _addQuickValue(1.0),
                                  isNegative: false,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // Sticky Save button (above keyboard)
              Container(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isValid ? _save : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isValid
                            ? theme.colorScheme.primary
                            : (isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.grey.shade200),
                        foregroundColor: _isValid
                            ? theme.colorScheme.onPrimary
                            : appColors.mutedText,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.save,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isNegative;

  const _QuickChip({
    required this.label,
    required this.onTap,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isNegative
              ? Colors.transparent
              : (isDark
                  ? const Color(0xFF2C2C2E)
                  : theme.colorScheme.primary.withValues(alpha: 0.08)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isNegative
                ? (isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade300)
                : theme.colorScheme.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isNegative
                ? theme.colorScheme.onSurface
                : theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

// Set Goal Bottom Sheet
class _SetGoalBottomSheet extends StatefulWidget {
  final TextEditingController goalWeightController;
  final bool isMetric;
  final WeightEntry? currentWeight;

  const _SetGoalBottomSheet({
    required this.goalWeightController,
    required this.isMetric,
    this.currentWeight,
  });

  @override
  State<_SetGoalBottomSheet> createState() => _SetGoalBottomSheetState();
}

class _SetGoalBottomSheetState extends State<_SetGoalBottomSheet> {
  late TextEditingController _controller;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.goalWeightController;
    _isValid = _controller.text.isNotEmpty;
    _controller.addListener(_validateInput);
  }

  @override
  void dispose() {
    _controller.removeListener(_validateInput);
    super.dispose();
  }

  void _validateInput() {
    final text = _controller.text.trim();
    final weight = double.tryParse(text);
    setState(() {
      _isValid =
          text.isNotEmpty && weight != null && weight > 0 && weight < 500;
    });
  }

  void _setPreset(double value) {
    setState(() {
      _controller.text = value.toStringAsFixed(1);
    });
  }

  void _save() {
    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);
    final isMetric = settingsProvider.weightUnit == 'kg';
    final provider = Provider.of<WeightTrackerProvider>(context, listen: false);
    final weightText = _controller.text.trim();

    if (weightText.isNotEmpty) {
      final weight = double.tryParse(weightText);
      if (weight != null && weight > 0) {
        final weightKg = isMetric ? weight : weight / 2.20462;
        HapticFeedback.mediumImpact();
        provider.setGoalWeight(weightKg);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.goalWeightSet),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      provider.setGoalWeight(null);
      Navigator.pop(context);
    }
  }

  void _remove() {
    final provider = Provider.of<WeightTrackerProvider>(context, listen: false);
    HapticFeedback.mediumImpact();
    provider.setGoalWeight(null);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.goalWeightRemoved),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String? _getGoalHelperText(bool isMetric) {
    if (widget.currentWeight == null) return null;

    final currentText = _controller.text.trim();
    final goalWeight = double.tryParse(currentText);

    if (goalWeight == null || currentText.isEmpty) return null;

    final goalWeightKg = isMetric ? goalWeight : goalWeight / 2.20462;
    final difference = goalWeightKg - widget.currentWeight!.weightKg;

    String formatWeight(double kg) {
      if (isMetric) {
        return '${kg.toStringAsFixed(1)} kg';
      } else {
        return '${(kg * 2.20462).toStringAsFixed(1)} lbs';
      }
    }

    final l10n = AppLocalizations.of(context)!;
    if (difference.abs() < 0.1) {
      return l10n.goalMatchesCurrentWeight;
    } else if (difference < 0) {
      return l10n.youNeed(
          formatWeight(difference.abs()), formatWeight(goalWeightKg));
    } else {
      return l10n.youNeedPlus(
          formatWeight(difference), formatWeight(goalWeightKg));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettingsProvider>(
      builder: (context, settingsProvider, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final appColors = theme.extension<AppColors>()!;
        final isMetric = settingsProvider.weightUnit == 'kg';
        final provider =
            Provider.of<WeightTrackerProvider>(context, listen: false);
        final hasGoal = provider.goalWeight != null;
        final helperText = _getGoalHelperText(isMetric);

        // Calculate preset values based on current weight (relative to current)
        double? diff1, diff2, diff3;
        double? preset1, preset2, preset3;
        if (widget.currentWeight != null) {
          diff1 = -2.0;
          diff2 = -5.0;
          diff3 = -10.0;
          preset1 = widget.currentWeight!.weightKg + diff1;
          preset2 = widget.currentWeight!.weightKg + diff2;
          preset3 = widget.currentWeight!.weightKg + diff3;
        }

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : appColors.border,
            ),
            boxShadow: AppShadows.elevatedSoft,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: appColors.mutedText.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header with title and close button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.setGoal,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 24),
                      color: appColors.mutedText,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Content area (scrollable)
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero input area
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Large number input
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              autofocus: true,
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                                letterSpacing: -1.5,
                                height: 1.0,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: isMetric ? '65.0' : '143.0',
                                hintStyle: TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.w700,
                                  color: appColors.mutedText
                                      .withValues(alpha: 0.3),
                                  letterSpacing: -1.5,
                                  height: 1.0,
                                ),
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Unit pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: appColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : appColors.border,
                              ),
                            ),
                            child: Text(
                              isMetric ? 'kg' : 'lbs',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: appColors.mutedText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Helper text showing weight difference
                      if (helperText != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          helperText,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: appColors.mutedText,
                          ),
                        ),
                      ],
                      if (preset1 != null &&
                          preset2 != null &&
                          preset3 != null) ...[
                        const SizedBox(height: 24),
                        // Suggested goal chips
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.suggested,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: appColors.mutedText,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Builder(
                              builder: (context) {
                                // Assign to local non-null variables for use in callbacks
                                final p1 = preset1!;
                                final p2 = preset2!;
                                final p3 = preset3!;
                                final d1 = diff1!;
                                final d2 = diff2!;
                                final d3 = diff3!;

                                String formatLabel(double diff, double preset) {
                                  final l10n = AppLocalizations.of(context)!;
                                  if (isMetric) {
                                    return '${l10n.current} ${diff > 0 ? '+' : ''}${diff.toStringAsFixed(0)} kg';
                                  } else {
                                    return '${l10n.current} ${diff > 0 ? '+' : ''}${(diff * 2.20462).toStringAsFixed(0)} lbs';
                                  }
                                }

                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _QuickChip(
                                            label: formatLabel(d1, p1),
                                            onTap: () => _setPreset(
                                                isMetric ? p1 : p1 * 2.20462),
                                            isNegative: false,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _QuickChip(
                                            label: formatLabel(d2, p2),
                                            onTap: () => _setPreset(
                                                isMetric ? p2 : p2 * 2.20462),
                                            isNegative: false,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: _QuickChip(
                                        label: formatLabel(d3, p3),
                                        onTap: () => _setPreset(
                                            isMetric ? p3 : p3 * 2.20462),
                                        isNegative: false,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // Sticky action area (Remove Goal + Save button)
              Container(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      if (hasGoal)
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: _remove,
                            style: TextButton.styleFrom(
                              foregroundColor: appColors.danger,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child:
                                Text(AppLocalizations.of(context)!.removeGoal),
                          ),
                        ),
                      if (hasGoal) const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isValid ? _save : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isValid
                                ? theme.colorScheme.primary
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.grey.shade200),
                            foregroundColor: _isValid
                                ? theme.colorScheme.onPrimary
                                : appColors.mutedText,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.save,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
