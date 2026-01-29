import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/cupertino.dart' hide Interval;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:interval_cardio/l10n/app_localizations.dart';
import '../models/routine.dart';
import '../models/interval.dart';
import '../models/machine_type.dart';
import '../storage/routine_provider.dart';
import '../../../app_settings/app_settings_provider.dart';
import '../../../app_shell/app_shell.dart';
import '../widgets/routine_shared_widgets.dart';
import '../widgets/interval_edit_popup.dart';

class RoutineEditScreen extends StatefulWidget {
  final Routine? routine;
  final MachineType? machineType;

  const RoutineEditScreen({super.key, this.routine, this.machineType});

  @override
  State<RoutineEditScreen> createState() => _RoutineEditScreenState();
}

class _RoutineEditScreenState extends State<RoutineEditScreen> {
  late TextEditingController _nameController;
  late String _difficulty;
  late List<Interval> _intervals;
  late MachineType _machineType;
  String? _nameError;
  int? _selectedIntervalIndex;

  // Original values for comparison
  late String _originalName;
  late String _originalDifficulty;
  late List<Interval> _originalIntervals;

  @override
  void initState() {
    super.initState();
    if (widget.routine != null) {
      _nameController = TextEditingController(text: widget.routine!.name);
      _difficulty = widget.routine!.difficulty;
      _intervals = widget.routine!.intervals.map((interval) {
        switch (widget.routine!.machineType) {
          case MachineType.treadmill:
            return Interval.treadmill(
              id: interval.id,
              durationSeconds: interval.durationSeconds,
              speedKmh: interval.speedKmh ?? 5.0,
              grade: interval.grade ?? 0.0,
            );
          case MachineType.cycle:
            return Interval.cycle(
              id: interval.id,
              durationSeconds: interval.durationSeconds,
              rpm: interval.rpm ?? 60,
              resistance: interval.resistance ?? 5,
            );
          case MachineType.stairmaster:
            return Interval.stairmaster(
              id: interval.id,
              durationSeconds: interval.durationSeconds,
              level: interval.level ?? 5,
            );
        }
      }).toList();
      _machineType = widget.routine!.machineType;

      // Store original values
      _originalName = widget.routine!.name;
      _originalDifficulty = widget.routine!.difficulty;
      _originalIntervals = _intervals.map((i) {
        switch (_machineType) {
          case MachineType.treadmill:
            return Interval.treadmill(
              id: i.id,
              durationSeconds: i.durationSeconds,
              speedKmh: i.speedKmh ?? 5.0,
              grade: i.grade ?? 0.0,
            );
          case MachineType.cycle:
            return Interval.cycle(
              id: i.id,
              durationSeconds: i.durationSeconds,
              rpm: i.rpm ?? 60,
              resistance: i.resistance ?? 5,
            );
          case MachineType.stairmaster:
            return Interval.stairmaster(
              id: i.id,
              durationSeconds: i.durationSeconds,
              level: i.level ?? 5,
            );
        }
      }).toList();
    } else {
      _nameController = TextEditingController();
      _difficulty = '쉬움';
      _intervals = [];
      _machineType = widget.machineType ?? MachineType.treadmill;

      // Default intervals for new routine
      _addInterval();
      if (_machineType == MachineType.treadmill) {
        _addInterval(); // Add second interval for treadmill
      }

      _originalName = '';
      _originalDifficulty = '쉬움';
      _originalIntervals = [];
    }

    _nameController.addListener(_validateName);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.routine == null && _nameController.text.isEmpty) {
      _nameController.text = 'Untitled Routine';
      _originalName = 'Untitled Routine';
    }
    _validateName();
  }

  @override
  void dispose() {
    _nameController.removeListener(_validateName);
    _nameController.dispose();
    super.dispose();
  }

  void _validateName() {
    final trimmed = _nameController.text.trim();
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    setState(() {
      if (trimmed.isEmpty) {
        _nameError = l10n.nameRequired;
      } else if (trimmed.length > 24) {
        _nameError = l10n.nameMaxLength;
      } else {
        _nameError = null;
      }
    });
  }

  bool get _isNameValid {
    final trimmed = _nameController.text.trim();
    return trimmed.isNotEmpty && trimmed.length <= 24;
  }

  bool get _hasChanges {
    if (widget.routine == null) {
      // New routine: valid if name is valid and has intervals
      return _isNameValid && _intervals.isNotEmpty;
    }

    // Existing routine: check if anything changed
    if (_nameController.text.trim() != _originalName) return true;
    if (_difficulty != _originalDifficulty) return true;
    if (_intervals.length != _originalIntervals.length) return true;

    // Compare intervals
    for (int i = 0; i < _intervals.length; i++) {
      if (i >= _originalIntervals.length) return true;
      final current = _intervals[i];
      final original = _originalIntervals[i];

      if (current.durationSeconds != original.durationSeconds) return true;
      if (current.speedKmh != original.speedKmh) return true;
      if (current.grade != original.grade) return true;
      if (current.rpm != original.rpm) return true;
      if (current.resistance != original.resistance) return true;
      if (current.level != original.level) return true;
    }

    return false;
  }

  int _calculateTotalDuration() {
    return _intervals.fold(
        0, (sum, interval) => sum + interval.durationSeconds);
  }

  void _addInterval() {
    setState(() {
      switch (_machineType) {
        case MachineType.treadmill:
          _intervals.add(Interval.treadmill(
            durationSeconds: 300, // 5 minutes
            speedKmh: 5.0,
            grade: 0.0,
          ));
          break;
        case MachineType.cycle:
          _intervals.add(Interval.cycle(
            durationSeconds: 300, // 5 minutes
            rpm: 60,
            resistance: 5,
          ));
          break;
        case MachineType.stairmaster:
          _intervals.add(Interval.stairmaster(
            durationSeconds: 300, // 5 minutes
            level: 5,
          ));
          break;
      }
    });
  }

  void _deleteInterval(int index) {
    setState(() {
      _intervals.removeAt(index);
      if (_selectedIntervalIndex == index) {
        _selectedIntervalIndex = null;
      } else if (_selectedIntervalIndex != null &&
          _selectedIntervalIndex! > index) {
        _selectedIntervalIndex = _selectedIntervalIndex! - 1;
      }
    });
  }

  void _onIntervalTap(int index) {
    setState(() {
      _selectedIntervalIndex = index;
    });

    final interval = _intervals[index];
    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);

    // Show field selection popup first
    _showFieldSelectionPopup(index, interval, settingsProvider);
  }

  void _showFieldSelectionPopup(
      int index, Interval interval, AppSettingsProvider settingsProvider) {
    final l10n = AppLocalizations.of(context)!;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              IntervalEditPopup.show(
                context,
                interval: interval,
                machineType: _machineType,
                field: IntervalEditField.duration,
                onSave: (updated) => _updateInterval(index, updated),
              );
            },
            child: Text(l10n.timeMinutes.split('(')[0].trim()),
          ),
          if (_machineType == MachineType.treadmill) ...[
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                IntervalEditPopup.show(
                  context,
                  interval: interval,
                  machineType: _machineType,
                  field: IntervalEditField.speed,
                  onSave: (updated) => _updateInterval(index, updated),
                );
              },
              child: Text(l10n.speed),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                IntervalEditPopup.show(
                  context,
                  interval: interval,
                  machineType: _machineType,
                  field: IntervalEditField.incline,
                  onSave: (updated) => _updateInterval(index, updated),
                );
              },
              child: Text(l10n.incline),
            ),
          ] else if (_machineType == MachineType.cycle) ...[
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                IntervalEditPopup.show(
                  context,
                  interval: interval,
                  machineType: _machineType,
                  field: IntervalEditField.rpm,
                  onSave: (updated) => _updateInterval(index, updated),
                );
              },
              child: Text(l10n.rpm),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                IntervalEditPopup.show(
                  context,
                  interval: interval,
                  machineType: _machineType,
                  field: IntervalEditField.resistance,
                  onSave: (updated) => _updateInterval(index, updated),
                );
              },
              child: const Text('Level'),
            ),
          ] else if (_machineType == MachineType.stairmaster) ...[
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                IntervalEditPopup.show(
                  context,
                  interval: interval,
                  machineType: _machineType,
                  field: IntervalEditField.level,
                  onSave: (updated) => _updateInterval(index, updated),
                );
              },
              child: const Text('Level'),
            ),
          ],
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              _selectedIntervalIndex = null;
            });
          },
          child: Text(l10n.cancel),
        ),
      ),
    );
  }

  void _updateInterval(int index, Interval updatedInterval) {
    setState(() {
      _intervals[index] = updatedInterval;
      _selectedIntervalIndex = null;
    });
  }

  void _showDifficultyPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final difficultyStorageValues = ['쉬움', '중간', '높음'];
    final difficultyDisplayValues = [l10n.easy, l10n.medium, l10n.hard];
    final currentIndex = difficultyStorageValues.indexOf(_difficulty);

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 350,
        padding: const EdgeInsets.only(top: 6),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.separator,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        l10n.cancel,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      minimumSize: Size(0, 0),
                    ),
                    Text(
                      l10n.difficulty,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        l10n.done,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.activeBlue,
                        ),
                      ),
                      minimumSize: Size(0, 0),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: currentIndex >= 0 ? currentIndex : 0,
                  ),
                  itemExtent: 40,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _difficulty = difficultyStorageValues[index];
                    });
                  },
                  children: difficultyDisplayValues.map((difficulty) {
                    return Center(
                      child: Text(
                        difficulty,
                        style: const TextStyle(fontSize: 20),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveRoutine() async {
    if (!_isNameValid || _intervals.isEmpty) return;

    final provider = Provider.of<RoutineProvider>(context, listen: false);
    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);
    final name = _nameController.text.trim();

    if (widget.routine != null) {
      // Check free limit when updating treadmill routine
      if (_machineType == MachineType.treadmill &&
          !settingsProvider.isPremium &&
          provider.routines
                  .where((r) => r.machineType == MachineType.treadmill)
                  .length >=
              2 &&
          widget.routine!.machineType != MachineType.treadmill) {
        _showFreeLimitSheet(context);
        return;
      }

      final updatedRoutine = Routine(
        id: widget.routine!.id,
        name: name,
        difficulty: _difficulty,
        intervals: _intervals,
        machineType: _machineType,
      );
      await provider.updateRoutine(updatedRoutine);
    } else {
      // Check free limit when adding new treadmill routine
      if (_machineType == MachineType.treadmill &&
          !settingsProvider.isPremium &&
          provider.routines
                  .where((r) => r.machineType == MachineType.treadmill)
                  .length >=
              2) {
        _showFreeLimitSheet(context);
        return;
      }

      final newRoutine = Routine(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        difficulty: _difficulty,
        intervals: _intervals,
        machineType: _machineType,
      );
      await provider.addRoutine(newRoutine);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showFreeLimitSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      isDismissible: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.freeLimitTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.freeLimitMessage,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        AppShell.navigateToPremiumTab();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.viewMembership,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);
    final totalDuration = _calculateTotalDuration();

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        middle: Text(AppLocalizations.of(context)!.routineEdit),
      ),
      child: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // Header
            RoutineHeader(
              title: _nameController.text.isEmpty
                  ? AppLocalizations.of(context)!.unnamedRoutine
                  : _nameController.text,
              totalDurationSeconds: totalDuration,
              intervalCount: _intervals.length,
              difficulty: _difficulty,
              isEditing: true,
            ),
            // Name and difficulty section
            CupertinoListSection.insetGrouped(
              margin: EdgeInsets.zero,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CupertinoListTile(
                      title: Text(AppLocalizations.of(context)!.name),
                      trailing: SizedBox(
                        width: 200,
                        child: CupertinoTextField(
                          controller: _nameController,
                          placeholder:
                              AppLocalizations.of(context)!.unnamedRoutine,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          decoration: null,
                          style: TextStyle(
                            fontSize: 17,
                            color: _nameError != null
                                ? CupertinoColors.destructiveRed
                                : CupertinoColors.label,
                          ),
                          textAlign: TextAlign.right,
                          maxLength: 24,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(24),
                          ],
                        ),
                      ),
                    ),
                    if (_nameError != null)
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 16, top: 4, bottom: 8),
                        child: Text(
                          _nameError!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: CupertinoColors.destructiveRed,
                          ),
                        ),
                      ),
                  ],
                ),
                CupertinoListTile(
                  title: Text(AppLocalizations.of(context)!.difficulty),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _difficulty,
                        style: const TextStyle(
                          fontSize: 17,
                          color: CupertinoColors.secondaryLabel,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        CupertinoIcons.chevron_right,
                        size: 16,
                        color: CupertinoColors.secondaryLabel,
                      ),
                    ],
                  ),
                  onTap: () => _showDifficultyPicker(context),
                ),
              ],
            ),
            // Intervals list
            Expanded(
              child: SingleChildScrollView(
                child: IntervalList(
                  intervals: _intervals,
                  machineType: _machineType,
                  settingsProvider: settingsProvider,
                  isEditable: true,
                  onIntervalTap: _onIntervalTap,
                  onIntervalDelete: _deleteInterval,
                  selectedIndex: _selectedIntervalIndex,
                  onAddInterval: _addInterval,
                ),
              ),
            ),
            // Save button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGroupedBackground,
                border: Border(
                  top: BorderSide(
                    color: theme.dividerColor,
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    onPressed:
                        (_isNameValid && _intervals.isNotEmpty && _hasChanges)
                            ? _saveRoutine
                            : null,
                    color: CupertinoColors.systemRed,
                    disabledColor: CupertinoColors.systemGrey,
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      AppLocalizations.of(context)!.save,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
