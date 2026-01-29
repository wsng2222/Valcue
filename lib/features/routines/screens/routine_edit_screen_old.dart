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

  @override
  void initState() {
    super.initState();
    if (widget.routine != null) {
      _nameController = TextEditingController(text: widget.routine!.name);
      _difficulty = widget.routine!.difficulty;
      // Create deep copy of intervals to prevent modifying original routine
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
    } else {
      // Will be updated in didChangeDependencies with localized text
      _nameController = TextEditingController();
      // Default to Korean value, will be updated in didChangeDependencies if needed
      // But we store Korean values anyway, so this is fine
      _difficulty = '쉬움';
      _intervals = [];
      _machineType = widget.machineType ?? MachineType.treadmill;
    }

    // Add listener to validate name on change
    _nameController.addListener(_validateName);
    // Don't call _validateName here as it needs context
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Now we can safely access AppLocalizations
    // Set default name if empty - always use "Untitled Routine" regardless of language
    if (widget.routine == null && _nameController.text.isEmpty) {
      _nameController.text = 'Untitled Routine';
    }
    // Initial validation
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
    });
  }

  void _updateInterval(int index, Interval interval) {
    setState(() {
      _intervals[index] = interval;
    });
  }

  void _reorderIntervals(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _intervals.removeAt(oldIndex);
      _intervals.insert(newIndex, item);
    });
  }

  void _showFreeLimitSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
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
                      // Navigate to Premium tab (index 0) in AppShell after frame completes
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

  Future<void> _saveRoutine() async {
    final l10n = AppLocalizations.of(context)!;
    // Validate name first
    final trimmedName = _nameController.text.trim();
    if (trimmedName.isEmpty) {
      setState(() {
        _nameError = l10n.nameRequired;
      });
      return;
    }
    if (trimmedName.length > 24) {
      setState(() {
        _nameError = l10n.nameMaxLength;
      });
      return;
    }

    if (_intervals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.minIntervalsRequired)),
      );
      return;
    }

    final provider = Provider.of<RoutineProvider>(context, listen: false);
    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);
    final name = trimmedName;

    if (widget.routine != null) {
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

  void _showDifficultyPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => _DifficultyPickerSheet(
        currentDifficulty: _difficulty,
        onSelected: (difficulty) {
          setState(() {
            _difficulty = difficulty;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        child: CustomScrollView(
          slivers: [
            // Routine Info Section
            CupertinoSliverRefreshControl(
              onRefresh: () async {},
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: CupertinoListSection.insetGrouped(
                  children: [
                    // Name field with error message
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
                                  horizontal: 8, vertical: 8),
                              decoration: null,
                              style: TextStyle(
                                fontSize: 17,
                                color: _nameError != null
                                    ? CupertinoColors.destructiveRed
                                    : CupertinoColors.label,
                              ),
                              textAlign: TextAlign.right,
                              maxLength: 24,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(24),
                              ],
                            ),
                          ),
                        ),
                        if (_nameError != null)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, top: 4, bottom: 8),
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
                    // Difficulty picker
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
              ),
            ),
            // Intervals Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.interval,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: CupertinoColors.secondaryLabel,
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: _addInterval,
                            minimumSize: const Size(0, 0),
                            child: const Icon(
                              CupertinoIcons.add_circled,
                              color: CupertinoColors.systemRed,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_intervals.isEmpty)
                      CupertinoListSection.insetGrouped(
                        children: [
                          CupertinoListTile(
                            title: Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 32),
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .addIntervalPrompt,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    color: CupertinoColors.secondaryLabel,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color:
                              CupertinoColors.secondarySystemGroupedBackground,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ReorderableListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          buildDefaultDragHandles: false,
                          padding: EdgeInsets.zero,
                          itemCount: _intervals.length,
                          onReorder: _reorderIntervals,
                          itemBuilder: (context, index) {
                            return _buildIntervalTile(index);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Save button
            SliverFillRemaining(
              hasScrollBody: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        onPressed: (_isNameValid && _intervals.isNotEmpty)
                            ? _saveRoutine
                            : null,
                        color: CupertinoColors.systemRed,
                        disabledColor: CupertinoColors.systemGrey,
                        borderRadius: BorderRadius.circular(10),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalTile(int index) {
    return _IntervalRow(
      key: ValueKey(_intervals[index].hashCode),
      index: index,
      interval: _intervals[index],
      machineType: _machineType,
      onUpdate: (interval) => _updateInterval(index, interval),
      onDelete: () => _deleteInterval(index),
    );
  }
}

class _IntervalRow extends StatefulWidget {
  final int index;
  final Interval interval;
  final MachineType machineType;
  final Function(Interval) onUpdate;
  final VoidCallback onDelete;

  const _IntervalRow({
    required Key key,
    required this.index,
    required this.interval,
    required this.machineType,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<_IntervalRow> createState() => _IntervalRowState();
}

class _IntervalRowState extends State<_IntervalRow> {
  late TextEditingController _durationController;
  late TextEditingController _field1Controller;
  late TextEditingController _field2Controller;

  @override
  void initState() {
    super.initState();
    // Convert seconds to minutes for display (legacy UI)
    final minutes = widget.interval.durationSeconds ~/ 60;
    _durationController = TextEditingController(
      text: minutes.toString(),
    );

    switch (widget.machineType) {
      case MachineType.treadmill:
        // Preserve exact values - use the stored values directly without rounding
        // Format to 1 decimal place for display, but preserve original precision
        final speedKmh = widget.interval.speedKmh ?? 5.0;
        final grade = widget.interval.grade ?? 0.0;
        _field1Controller = TextEditingController(
          // Use exact value formatted to 1 decimal for display
          text: speedKmh.toStringAsFixed(1),
        );
        _field2Controller = TextEditingController(
          text: grade.toStringAsFixed(1),
        );
        break;
      case MachineType.cycle:
        _field1Controller = TextEditingController(
          text: widget.interval.rpm?.toString() ?? '60',
        );
        _field2Controller = TextEditingController(
          text: widget.interval.resistance?.toString() ?? '5',
        );
        break;
      case MachineType.stairmaster:
        _field1Controller = TextEditingController(
          text: widget.interval.level?.toString() ?? '5',
        );
        _field2Controller = TextEditingController(
          text: '', // SPM removed
        );
        break;
    }
  }

  @override
  void didUpdateWidget(_IntervalRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controllers if interval changed externally
    if (oldWidget.interval.id != widget.interval.id) {
      final minutes = widget.interval.durationSeconds ~/ 60;
      _durationController.text = minutes.toString();

      switch (widget.machineType) {
        case MachineType.treadmill:
          final speedKmh = widget.interval.speedKmh ?? 5.0;
          final grade = widget.interval.grade ?? 0.0;
          _field1Controller.text = speedKmh.toStringAsFixed(1);
          _field2Controller.text = grade.toStringAsFixed(1);
          break;
        case MachineType.cycle:
          _field1Controller.text = widget.interval.rpm?.toString() ?? '60';
          _field2Controller.text =
              widget.interval.resistance?.toString() ?? '5';
          break;
        case MachineType.stairmaster:
          _field1Controller.text = widget.interval.level?.toString() ?? '5';
          _field2Controller.text = '';
          break;
      }
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    _field1Controller.dispose();
    _field2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<AppSettingsProvider>(
      builder: (context, settingsProvider, child) {
        String field1Label;
        String field2Label;
        String field1Value;
        String field2Value;

        switch (widget.machineType) {
          case MachineType.treadmill:
            field1Label = l10n.speed;
            field2Label = l10n.incline;
            // Use formatSpeed to match detail screen display
            field1Value =
                settingsProvider.formatSpeed(widget.interval.speedKmh ?? 0.0);
            field2Value =
                '${widget.interval.grade?.toStringAsFixed(1) ?? '0.0'}% ${l10n.incline}';
            break;
          case MachineType.cycle:
            field1Label = l10n.rpm;
            field2Label = 'Level';
            field1Value = '${widget.interval.rpm ?? 0} ${l10n.rpm}';
            field2Value = 'Level ${widget.interval.resistance ?? 0}';
            break;
          case MachineType.stairmaster:
            field1Label = 'Level';
            field2Label = ''; // SPM removed
            field1Value = 'Level ${widget.interval.level ?? 0}';
            field2Value = ''; // SPM removed
            break;
        }

        return ReorderableDragStartListener(
          key: ValueKey(widget.interval.hashCode),
          index: widget.index,
          child: Dismissible(
            key: Key('interval_${widget.index}'),
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
            onDismissed: (direction) {
              widget.onDelete();
            },
            child: Container(
              decoration: const BoxDecoration(
                color: CupertinoColors.secondarySystemGroupedBackground,
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator,
                    width: 0.5,
                  ),
                ),
              ),
              child: CupertinoListTile(
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: CupertinoColors.systemGrey4,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${widget.index + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.label,
                      ),
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.interval.durationFormatted,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              color: CupertinoColors.label,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            field2Label.isNotEmpty
                                ? '$field1Label: $field1Value  •  $field2Label: $field2Value'
                                : '$field1Label: $field1Value',
                            style: const TextStyle(
                              fontSize: 13,
                              color: CupertinoColors.secondaryLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        CupertinoIcons.bars,
                        color: CupertinoColors.secondaryLabel,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                onTap: () => _showIntervalEditor(context),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showIntervalEditor(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => _IntervalEditorSheet(
        interval: widget.interval,
        machineType: widget.machineType,
        onSave: (interval) {
          widget.onUpdate(interval);
        },
      ),
    );
  }
}

class _DifficultyPickerSheet extends StatelessWidget {
  final String currentDifficulty;
  final Function(String) onSelected;

  const _DifficultyPickerSheet({
    required this.currentDifficulty,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final difficultyDisplayValues = [l10n.easy, l10n.medium, l10n.hard];
    final difficultyStorageValues = ['쉬움', '중간', '높음'];
    var initialIndex = difficultyStorageValues.indexOf(currentDifficulty);
    if (initialIndex < 0) {
      initialIndex = 0;
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.only(top: 6),
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
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    minimumSize: const Size(0, 0),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                  Text(
                    AppLocalizations.of(context)!.selectDifficulty,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    minimumSize: const Size(0, 0),
                    child: Text(AppLocalizations.of(context)!.done),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: initialIndex >= 0 ? initialIndex : 0,
                ),
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  // Map display index back to storage value
                  onSelected(difficultyStorageValues[index]);
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
    );
  }
}

class _IntervalEditorSheet extends StatefulWidget {
  final Interval interval;
  final MachineType machineType;
  final Function(Interval) onSave;

  const _IntervalEditorSheet({
    required this.interval,
    required this.machineType,
    required this.onSave,
  });

  @override
  State<_IntervalEditorSheet> createState() => _IntervalEditorSheetState();
}

class _IntervalEditorSheetState extends State<_IntervalEditorSheet> {
  late TextEditingController _durationController;
  late TextEditingController _field1Controller;
  late TextEditingController _field2Controller;

  @override
  void initState() {
    super.initState();
    // Convert seconds to minutes for display (legacy UI)
    final minutes = widget.interval.durationSeconds ~/ 60;
    _durationController = TextEditingController(
      text: minutes.toString(),
    );
    // Initialize controllers - values will be set in didChangeDependencies
    // to ensure AppSettingsProvider is available
    _field1Controller = TextEditingController();
    _field2Controller = TextEditingController();
  }

  bool _hasInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set field values now that context is available (only once)
    if (!_hasInitialized) {
      _hasInitialized = true;
      final settingsProvider =
          Provider.of<AppSettingsProvider>(context, listen: false);

      switch (widget.machineType) {
        case MachineType.treadmill:
          // Convert km/h to display unit (mph or km/h) for editing
          final speedKmh = widget.interval.speedKmh ?? 5.0;
          final displaySpeed = settingsProvider.measurement == 'mph'
              ? (speedKmh * 0.621371)
                  .toStringAsFixed(1) // Convert to mph for display
              : speedKmh.toStringAsFixed(1); // Keep km/h
          _field1Controller.text = displaySpeed;
          _field2Controller.text =
              widget.interval.grade?.toStringAsFixed(1) ?? '0.0';
          break;
        case MachineType.cycle:
          _field1Controller.text = widget.interval.rpm?.toString() ?? '60';
          _field2Controller.text =
              widget.interval.resistance?.toString() ?? '5';
          break;
        case MachineType.stairmaster:
          _field1Controller.text = widget.interval.level?.toString() ?? '5';
          _field2Controller.text = ''; // SPM removed
          break;
      }
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    _field1Controller.dispose();
    _field2Controller.dispose();
    super.dispose();
  }

  void _save() {
    final durationMinutes = int.tryParse(_durationController.text) ?? 1;
    final clampedMinutes = durationMinutes.clamp(1, 999);
    final durationSeconds = clampedMinutes * 60;

    Interval updatedInterval;
    switch (widget.machineType) {
      case MachineType.treadmill:
        final settingsProvider =
            Provider.of<AppSettingsProvider>(context, listen: false);
        final speedInput = double.tryParse(_field1Controller.text) ?? 5.0;
        // Convert mph to km/h if needed (always store in km/h)
        final speedKmh = settingsProvider.measurement == 'mph'
            ? speedInput / 0.621371 // Convert mph to km/h
            : speedInput;
        final grade = double.tryParse(_field2Controller.text) ?? 0.0;
        updatedInterval = Interval.treadmill(
          durationSeconds: durationSeconds,
          speedKmh: speedKmh.clamp(0.0, 30.0),
          grade: grade.clamp(0.0, 20.0),
        );
        break;
      case MachineType.cycle:
        final rpm = int.tryParse(_field1Controller.text) ?? 60;
        final resistance = int.tryParse(_field2Controller.text) ?? 5;
        updatedInterval = Interval.cycle(
          durationSeconds: durationSeconds,
          rpm: rpm.clamp(30, 200),
          resistance: resistance.clamp(1, 20),
        );
        break;
      case MachineType.stairmaster:
        final level = int.tryParse(_field1Controller.text) ?? 5;
        updatedInterval = Interval.stairmaster(
          durationSeconds: durationSeconds,
          level: level.clamp(1, 20),
        );
        break;
    }

    widget.onSave(updatedInterval);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<AppSettingsProvider>(
      builder: (context, settingsProvider, child) {
        String field1Label;
        String field2Label;

        switch (widget.machineType) {
          case MachineType.treadmill:
            // Use dynamic unit label based on settings
            field1Label = settingsProvider.measurement == 'mph'
                ? l10n.speed
                : l10n.speedKmh;
            field2Label = l10n.incline;
            break;
          case MachineType.cycle:
            field1Label = l10n.rpm;
            field2Label = 'Level';
            break;
          case MachineType.stairmaster:
            field1Label = 'Level';
            field2Label = ''; // SPM removed
            break;
        }

        return CupertinoPageScaffold(
          backgroundColor: CupertinoColors.systemGroupedBackground,
          navigationBar: CupertinoNavigationBar(
            middle: Text(AppLocalizations.of(context)!.intervalEdit),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _save,
              minimumSize: const Size(0, 0),
              child: Text(
                AppLocalizations.of(context)!.save,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          child: SafeArea(
            child: CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile(
                  title: Text(AppLocalizations.of(context)!.timeMinutes),
                  trailing: SizedBox(
                    width: 100,
                    child: CupertinoTextField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      decoration: null,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
                CupertinoListTile(
                  title: Text(field1Label),
                  trailing: SizedBox(
                    width: 100,
                    child: CupertinoTextField(
                      controller: _field1Controller,
                      keyboardType: TextInputType.numberWithOptions(
                          decimal: widget.machineType == MachineType.treadmill),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      decoration: null,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
                if (field2Label.isNotEmpty)
                  CupertinoListTile(
                    title: Text(field2Label),
                    trailing: SizedBox(
                      width: 100,
                      child: CupertinoTextField(
                        controller: _field2Controller,
                        keyboardType: TextInputType.numberWithOptions(
                            decimal:
                                widget.machineType == MachineType.treadmill),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        decoration: null,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
