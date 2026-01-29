import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/cupertino.dart' hide Interval;
import 'package:interval_cardio/l10n/app_localizations.dart';
import '../models/interval.dart';
import '../models/machine_type.dart';
import '../../../app_settings/app_settings_provider.dart';
import 'metric_chip_group.dart' as metric_chip;

/// Shared header widget for routine screens
class RoutineHeader extends StatelessWidget {
  final String title;
  final int totalDurationSeconds;
  final int intervalCount;
  final String difficulty;
  final bool isEditing;
  final VoidCallback? onOverflowTap;

  const RoutineHeader({
    super.key,
    required this.title,
    required this.totalDurationSeconds,
    required this.intervalCount,
    required this.difficulty,
    this.isEditing = false,
    this.onOverflowTap,
  });

  String _getLocalizedDifficulty(
      BuildContext context, String storedDifficulty) {
    final l10n = AppLocalizations.of(context)!;
    final difficultyStorageValues = ['쉬움', '중간', '높음'];
    final difficultyDisplayValues = [l10n.easy, l10n.medium, l10n.hard];

    final index = difficultyStorageValues.indexOf(storedDifficulty);
    if (index >= 0 && index < difficultyDisplayValues.length) {
      return difficultyDisplayValues[index];
    }
    return storedDifficulty;
  }

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final localizedDifficulty = _getLocalizedDifficulty(context, difficulty);
    final durationText = _formatDuration(totalDurationSeconds);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  '$durationText · $intervalCount ${l10n.interval} · $localizedDifficulty',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          if (onOverflowTap != null)
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onOverflowTap,
              minimumSize: const Size(0, 0),
              child: Icon(
                CupertinoIcons.ellipsis_circle,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: 24,
              ),
            ),
        ],
      ),
    );
  }
}

/// Shared interval row widget
class IntervalRow extends StatelessWidget {
  final Interval interval;
  final MachineType machineType;
  final AppSettingsProvider settingsProvider;
  final bool isEditable;
  final VoidCallback? onTap;
  final bool isSelected;

  const IntervalRow({
    super.key,
    required this.interval,
    required this.machineType,
    required this.settingsProvider,
    this.isEditable = false,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    String value1;
    String value2;

    switch (machineType) {
      case MachineType.treadmill:
        value1 = settingsProvider.formatSpeed(interval.speedKmh ?? 0.0);
        value2 = '${interval.grade?.toStringAsFixed(1) ?? '0.0'}% ${l10n.incline}';
        break;
      case MachineType.cycle:
        value1 = '${interval.rpm ?? 0} ${l10n.rpm}';
        value2 = 'Level ${interval.resistance ?? 0}';
        break;
      case MachineType.stairmaster:
        value1 = 'Level ${interval.level ?? 0}';
        value2 = '';
        break;
    }

    final backgroundColor = isSelected
        ? theme.colorScheme.primary.withValues(alpha: 0.1)
        : Colors.transparent;

    // Build chip items for MetricChipGroup
    final chipItems = <String>[
      interval.durationFormatted,
      value1,
      if (value2.isNotEmpty) value2,
    ];

    return GestureDetector(
      onTap: isEditable ? onTap : null,
      child: Container(
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Center(
          child: metric_chip.MetricChipGroup(items: chipItems),
        ),
      ),
    );
  }
}

/// Shared interval list widget
class IntervalList extends StatelessWidget {
  final List<Interval> intervals;
  final MachineType machineType;
  final AppSettingsProvider settingsProvider;
  final bool isEditable;
  final Function(int)? onIntervalTap;
  final Function(int)? onIntervalDelete;
  final int? selectedIndex;
  final VoidCallback? onAddInterval;

  const IntervalList({
    super.key,
    required this.intervals,
    required this.machineType,
    required this.settingsProvider,
    this.isEditable = false,
    this.onIntervalTap,
    this.onIntervalDelete,
    this.selectedIndex,
    this.onAddInterval,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (intervals.isEmpty && !isEditable) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Text(
            l10n.noIntervals,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Interval rows
        ...intervals.asMap().entries.map((entry) {
          final index = entry.key;
          final interval = entry.value;

          if (isEditable && onIntervalDelete != null) {
            // Swipe-to-delete for editable mode
            // Use interval.id as key to ensure stable identity across rebuilds
            return Dismissible(
              key: Key('interval_${interval.id}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: CupertinoColors.destructiveRed,
                child: const Icon(
                  CupertinoIcons.delete,
                  color: CupertinoColors.white,
                ),
              ),
              onDismissed: (_) {
                // Find the current index of this interval by ID to ensure correct deletion
                final currentIndex =
                    intervals.indexWhere((i) => i.id == interval.id);
                if (currentIndex >= 0) {
                  onIntervalDelete!(currentIndex);
                }
              },
              child: IntervalRow(
                interval: interval,
                machineType: machineType,
                settingsProvider: settingsProvider,
                isEditable: isEditable,
                onTap:
                    onIntervalTap != null ? () => onIntervalTap!(index) : null,
                isSelected: selectedIndex == index,
              ),
            );
          } else {
            return IntervalRow(
              interval: interval,
              machineType: machineType,
              settingsProvider: settingsProvider,
              isEditable: isEditable,
              onTap: onIntervalTap != null ? () => onIntervalTap!(index) : null,
              isSelected: selectedIndex == index,
            );
          }
        }),
        // Add interval footer (only in editable mode)
        if (isEditable && onAddInterval != null)
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.dividerColor,
                  width: 0.5,
                ),
              ),
            ),
            child: CupertinoListTile(
              leading: Icon(
                CupertinoIcons.add_circled,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text(
                l10n.addInterval,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.primary,
                ),
              ),
              onTap: onAddInterval,
            ),
          ),
      ],
    );
  }
}
