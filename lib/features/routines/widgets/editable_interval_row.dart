import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/cupertino.dart' hide Interval;
import 'package:valcue/l10n/app_localizations.dart';
import 'package:valcue/l10n/localized_format.dart';
import 'package:valcue/utils/responsive.dart';
import '../models/interval.dart';
import '../models/machine_type.dart';
import '../../../app_settings/app_settings_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_dialog.dart';
import '../../../widgets/app_bottom_sheet.dart';
import '../../../widgets/platform_icon.dart';

class EditableIntervalRow extends StatefulWidget {
  static const Duration removalAnimationDuration = Duration(milliseconds: 240);

  final Interval interval;
  final MachineType machineType;
  final AppSettingsProvider settingsProvider;
  final int? reorderIndex;
  final bool isEditing;
  final bool isEntering;
  final bool isRemoving;
  final Function(Interval) onUpdate;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;

  const EditableIntervalRow({
    super.key,
    required this.interval,
    required this.machineType,
    required this.settingsProvider,
    this.reorderIndex,
    required this.isEditing,
    this.isEntering = false,
    this.isRemoving = false,
    required this.onUpdate,
    this.onDuplicate,
    this.onDelete,
  });

  @override
  State<EditableIntervalRow> createState() => _EditableIntervalRowState();
}

class _EditableIntervalRowState extends State<EditableIntervalRow>
    with SingleTickerProviderStateMixin {
  // State values for pickers
  late int _durationMinutes;
  late int _durationSeconds;
  late double
      _speedKmh; // Double (preserve 1 decimal) - stores value in user's selected unit (mph or km/h)
  late double _grade; // Double (preserve 1 decimal)
  late int _rpm;
  late int _resistance;
  late int _level;
  late final AnimationController _visibilityController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _sizeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool get _isVisible => !widget.isEntering && !widget.isRemoving;

  @override
  void initState() {
    super.initState();
    _visibilityController = AnimationController(
      vsync: this,
      duration: EditableIntervalRow.removalAnimationDuration,
      value: _isVisible ? 1 : 0,
    );
    final curved = CurvedAnimation(
      parent: _visibilityController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _visibilityController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    );
    _sizeAnimation = curved;
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.06, 0),
      end: Offset.zero,
    ).animate(curved);
    _initializeValues();
  }

  void _initializeValues() {
    final totalSeconds = widget.interval.durationSeconds;
    _durationMinutes = totalSeconds ~/ 60;
    _durationSeconds = totalSeconds % 60;

    // Ensure minimum duration of 1 second
    if (_durationMinutes == 0 && _durationSeconds == 0) {
      _durationSeconds = 1;
    }

    switch (widget.machineType) {
      case MachineType.treadmill:
        // Initialize from stored km/h and convert to user's selected unit for display/editing
        final storedSpeedKmh = widget.interval.speedKmh ?? 5.0;
        if (widget.settingsProvider.measurement == 'mph') {
          // Convert km/h to mph for user's selected unit
          _speedKmh = storedSpeedKmh * 0.621371;
        } else {
          _speedKmh = storedSpeedKmh;
        }
        _grade = widget.interval.grade ?? 0.0;
        // Ensure speed > 0
        if (_speedKmh <= 0) {
          _speedKmh = widget.settingsProvider.measurement == 'mph'
              ? (5.0 * 0.621371)
              : 5.0;
        }
        break;
      case MachineType.cycle:
        _rpm = widget.interval.rpm ?? 60;
        _resistance = widget.interval.resistance ?? 5;
        break;
      case MachineType.stairmaster:
        _level = widget.interval.level ?? 5;
        break;
    }

    // Don't call _updateInterval() here - it triggers parent setState during initState/didUpdateWidget
    // Only update when user actually changes values via pickers
  }

  @override
  void didUpdateWidget(EditableIntervalRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update values when interval changes externally
    // Use WidgetsBinding to defer update to avoid setState during build
    if (oldWidget.interval != widget.interval) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _initializeValues();
        }
      });
    }

    final wasVisible = !oldWidget.isEntering && !oldWidget.isRemoving;
    if (wasVisible != _isVisible) {
      if (_isVisible) {
        _visibilityController.forward();
      } else {
        _visibilityController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _visibilityController.dispose();
    super.dispose();
  }

  void _updateInterval() {
    if (!widget.isEditing) return;

    final totalSeconds = _durationMinutes * 60 + _durationSeconds;
    // Ensure minimum duration of 1 second
    if (totalSeconds < 1) return;
    if (totalSeconds > 10800) return; // Max 3 hours

    // Use copyWith with doubles for speed/grade
    Interval updatedInterval;
    switch (widget.machineType) {
      case MachineType.treadmill:
        // Ensure speed > 0
        if (_speedKmh <= 0) return;
        // Convert from user's selected unit to km/h for storage (always store in km/h)
        final speedKmh = widget.settingsProvider.measurement == 'mph'
            ? _speedKmh / 0.621371 // Convert mph to km/h
            : _speedKmh;
        updatedInterval = widget.interval.copyWith(
          durationSeconds: totalSeconds,
          speedKmh: speedKmh.clamp(0.5, 25.0),
          grade: _grade.clamp(0.0, 15.0),
        );
        break;
      case MachineType.cycle:
        updatedInterval = widget.interval.copyWith(
          durationSeconds: totalSeconds,
          rpm: _rpm.clamp(30, 200),
          resistance: _resistance.clamp(1, 20),
        );
        break;
      case MachineType.stairmaster:
        updatedInterval = widget.interval.copyWith(
          durationSeconds: totalSeconds,
          level: _level.clamp(1, 20),
        );
        break;
    }

    widget.onUpdate(updatedInterval);
  }

  String _getPill1Text() {
    final l10n = AppLocalizations.of(context)!;
    switch (widget.machineType) {
      case MachineType.treadmill:
        return widget.settingsProvider
            .formatSpeed(widget.interval.speedKmh ?? 0.0);
      case MachineType.cycle:
        return l10n.rpmValue(
          LocalizedFormat.decimal(
            context,
            widget.interval.rpm ?? 0,
            decimalDigits: 0,
          ),
        );
      case MachineType.stairmaster:
        return l10n.levelColon(
          LocalizedFormat.decimal(
            context,
            widget.interval.level ?? 0,
            decimalDigits: 0,
          ),
        );
    }
  }

  String _getPill2Text() {
    final l10n = AppLocalizations.of(context)!;
    switch (widget.machineType) {
      case MachineType.treadmill:
        return '${LocalizedFormat.decimal(context, widget.interval.grade ?? 0)}%';
      case MachineType.cycle:
        return l10n.resistanceColon(
          LocalizedFormat.decimal(
            context,
            widget.interval.resistance ?? 0,
            decimalDigits: 0,
          ),
        );
      case MachineType.stairmaster:
        return ''; // SPM removed
    }
  }

  void _showDurationPicker(BuildContext context) {
    // CRITICAL: Initialize picker from ACTUAL interval duration (single source of truth)
    final intervalTotalSeconds = widget.interval.durationSeconds;
    final initialMinutes = intervalTotalSeconds ~/ 60;
    final initialSeconds = intervalTotalSeconds % 60;
    final safeMinutes = initialMinutes;
    final safeSeconds =
        (initialMinutes == 0 && initialSeconds == 0) ? 1 : initialSeconds;

    // Local temp values - DO NOT mutate model during scrolling
    int tempMinutes = safeMinutes;
    int tempSeconds = safeSeconds;

    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true, // Allow tap outside to dismiss (cancel)
      builder: (context) => AppCompactPickerSheetFrame(
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CupertinoButton(
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        onPressed: () {
                          // Cancel: DO NOT commit changes, just close
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      AppLocalizations.of(context)!.duration,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: CupertinoButton(
                        child: Text(
                          AppLocalizations.of(context)!.done,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        onPressed: () {
                          // Done: Commit temp values to model
                          Navigator.pop(context);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                _durationMinutes = tempMinutes;
                                _durationSeconds = tempSeconds;
                                // Ensure minimum of 1 second
                                if (_durationMinutes == 0 &&
                                    _durationSeconds == 0) {
                                  _durationSeconds = 1;
                                }
                                _updateInterval();
                              });
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.ms,
                  minuteInterval: 1,
                  secondInterval: 1,
                  initialTimerDuration: Duration(
                    minutes: safeMinutes,
                    seconds: safeSeconds,
                  ),
                  onTimerDurationChanged: (Duration duration) {
                    // Update ONLY temp values during scrolling - DO NOT mutate model
                    tempMinutes = duration.inMinutes;
                    tempSeconds = duration.inSeconds % 60;
                    if (tempMinutes == 0 && tempSeconds == 0) {
                      tempSeconds = 1;
                    }
                    // DO NOT call _updateInterval() here - only update on Done
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSpeedPicker(BuildContext context) {
    // Initialize picker from current _speedKmh (which is in user's selected unit)
    final currentSpeed = _speedKmh;

    // Generate speed values in user's selected unit (0.5 step increments)
    final List<double> speedValues;
    if (widget.settingsProvider.measurement == 'mph') {
      // Generate mph values: 0.5 to 15.5 mph (equivalent to 0.5-25.0 km/h) in 0.5 steps
      speedValues =
          List.generate(31, (i) => 0.5 + (i * 0.5)); // 0.5, 1.0, 1.5, ..., 15.5
    } else {
      // Generate km/h values: 0.5 to 25.0 km/h in 0.5 steps
      speedValues =
          List.generate(50, (i) => 0.5 + (i * 0.5)); // 0.5, 1.0, 1.5, ..., 25.0
    }

    final initialIndex = speedValues.indexWhere((s) => s >= currentSpeed);
    final selectedIndex = initialIndex >= 0 ? initialIndex : 0;

    // Local temp value - DO NOT mutate model during scrolling (in user's selected unit)
    double tempSpeed = currentSpeed;

    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true, // Allow tap outside to dismiss (cancel)
      builder: (context) => AppCompactPickerSheetFrame(
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CupertinoButton(
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        onPressed: () {
                          // Cancel: DO NOT commit changes, just close
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${AppLocalizations.of(context)!.speed} ${widget.settingsProvider.measurement == 'mph' ? '(mph)' : '(km/h)'}',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: CupertinoButton(
                        child: Text(
                          AppLocalizations.of(context)!.done,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        onPressed: () {
                          // Done: Commit temp value to model (in user's selected unit)
                          Navigator.pop(context);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                _speedKmh = tempSpeed;
                                _updateInterval();
                              });
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController:
                      FixedExtentScrollController(initialItem: selectedIndex),
                  itemExtent: 40,
                  onSelectedItemChanged: (int index) {
                    // Update ONLY temp value during scrolling - DO NOT mutate model (in user's selected unit)
                    tempSpeed = speedValues[index];
                    // DO NOT call _updateInterval() here - only update on Done
                  },
                  children: speedValues.map((speed) {
                    return Center(
                      child: Text(
                        LocalizedFormat.decimal(context, speed),
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
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

  void _showGradePicker(BuildContext context) {
    // CRITICAL: Initialize picker from ACTUAL interval grade (single source of truth)
    final intervalGrade = widget.interval.grade ?? 0.0;
    // Generate grade values: 0.0 to 15.0 in 0.5 steps
    final gradeValues =
        List.generate(31, (i) => i * 0.5); // 0.0, 0.5, 1.0, ..., 15.0
    final initialIndex = gradeValues.indexWhere((g) => g >= intervalGrade);
    final selectedIndex = initialIndex >= 0 ? initialIndex : 0;

    // Local temp value - DO NOT mutate model during scrolling
    double tempGrade = intervalGrade;

    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true, // Allow tap outside to dismiss (cancel)
      builder: (context) => AppCompactPickerSheetFrame(
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CupertinoButton(
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        onPressed: () {
                          // Cancel: DO NOT commit changes, just close
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      AppLocalizations.of(context)!.incline,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: CupertinoButton(
                        child: Text(
                          AppLocalizations.of(context)!.done,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        onPressed: () {
                          // Done: Commit temp value to model
                          Navigator.pop(context);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                _grade = tempGrade;
                                _updateInterval();
                              });
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController:
                      FixedExtentScrollController(initialItem: selectedIndex),
                  itemExtent: 40,
                  onSelectedItemChanged: (int index) {
                    // Update ONLY temp value during scrolling - DO NOT mutate model
                    tempGrade = gradeValues[index];
                    // DO NOT call _updateInterval() here - only update on Done
                  },
                  children: gradeValues.map((grade) {
                    return Center(
                      child: Text(
                        LocalizedFormat.decimal(context, grade),
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
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

  void _showRpmPicker(BuildContext context) {
    // CRITICAL: Initialize picker from ACTUAL interval rpm (single source of truth)
    final intervalRpm = widget.interval.rpm ?? 60;
    // Generate RPM values in steps of 5: 30, 35, 40, ..., 195, 200
    final rpms =
        List.generate(35, (i) => 30 + i * 5); // 30 to 200 in steps of 5
    // Round to nearest 5-step value
    final roundedRpm = ((intervalRpm / 5).round() * 5).clamp(30, 200);
    final initialIndex = rpms.indexWhere((r) => r >= roundedRpm);
    final selectedIndex = initialIndex >= 0 ? initialIndex : 0;

    // Local temp value - DO NOT mutate model during scrolling
    int tempRpm = intervalRpm;

    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (context) => AppCompactPickerSheetFrame(
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CupertinoButton(
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              AppLocalizations.of(context)!.rpm,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(28, 28),
                            onPressed: () => _showRpmInfoSheet(context),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.06),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                CupertinoIcons.info,
                                size: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: CupertinoButton(
                        child: Text(
                          AppLocalizations.of(context)!.done,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                _rpm = tempRpm;
                                _updateInterval();
                              });
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController:
                      FixedExtentScrollController(initialItem: selectedIndex),
                  itemExtent: 40,
                  onSelectedItemChanged: (int index) {
                    // Update ONLY temp value during scrolling - DO NOT mutate model
                    tempRpm = rpms[index];
                  },
                  children: rpms.map((rpm) {
                    return Center(
                      child: Text(
                        LocalizedFormat.decimal(
                          context,
                          rpm,
                          decimalDigits: 0,
                        ),
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
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

  void _showRpmInfoSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showAppDialog<void>(
      context: context,
      builder: (dialogContext) => AppDialog(
        icon: CupertinoIcons.info,
        title: l10n.rpm,
        message: l10n.rpmInfoDescription,
        actions: [
          AppDialogAction(
            label: l10n.done,
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      ),
    );
  }

  void _showResistancePicker(BuildContext context) {
    // CRITICAL: Initialize picker from ACTUAL interval resistance (single source of truth)
    final intervalResistance = widget.interval.resistance ?? 5;
    final resistances = List.generate(20, (i) => i + 1); // 1 to 20
    final initialIndex = resistances.indexWhere((r) => r >= intervalResistance);
    final selectedIndex = initialIndex >= 0 ? initialIndex : 0;

    // Local temp value - DO NOT mutate model during scrolling
    int tempResistance = intervalResistance;

    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (context) => AppCompactPickerSheetFrame(
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CupertinoButton(
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      AppLocalizations.of(context)!.resistance,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: CupertinoButton(
                        child: Text(
                          AppLocalizations.of(context)!.done,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                _resistance = tempResistance;
                                _updateInterval();
                              });
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController:
                      FixedExtentScrollController(initialItem: selectedIndex),
                  itemExtent: 40,
                  onSelectedItemChanged: (int index) {
                    // Update ONLY temp value during scrolling - DO NOT mutate model
                    tempResistance = resistances[index];
                  },
                  children: resistances.map((resistance) {
                    return Center(
                      child: Text(
                        LocalizedFormat.decimal(
                          context,
                          resistance,
                          decimalDigits: 0,
                        ),
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
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

  void _showLevelPicker(BuildContext context) {
    // CRITICAL: Initialize picker from ACTUAL interval level (single source of truth)
    final intervalLevel = widget.interval.level ?? 5;
    final levels = List.generate(20, (i) => i + 1); // 1 to 20
    final initialIndex = levels.indexWhere((l) => l >= intervalLevel);
    final selectedIndex = initialIndex >= 0 ? initialIndex : 0;

    // Local temp value - DO NOT mutate model during scrolling
    int tempLevel = intervalLevel;

    showCupertinoModalPopup(
      context: context,
      barrierDismissible: true,
      builder: (context) => AppCompactPickerSheetFrame(
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CupertinoButton(
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      AppLocalizations.of(context)!.level,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: CupertinoButton(
                        child: Text(
                          AppLocalizations.of(context)!.done,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                _level = tempLevel;
                                _updateInterval();
                              });
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController:
                      FixedExtentScrollController(initialItem: selectedIndex),
                  itemExtent: 40,
                  onSelectedItemChanged: (int index) {
                    // Update ONLY temp value during scrolling - DO NOT mutate model
                    tempLevel = levels[index];
                  },
                  children: levels.map((level) {
                    return Center(
                      child: Text(
                        LocalizedFormat.decimal(
                          context,
                          level,
                          decimalDigits: 0,
                        ),
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
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

  // _showSpmPicker removed - SPM feature removed

  String _getEditableField1Text() {
    final l10n = AppLocalizations.of(context)!;
    switch (widget.machineType) {
      case MachineType.treadmill:
        final value = LocalizedFormat.decimal(context, _speedKmh);
        final unit =
            widget.settingsProvider.measurement == 'mph' ? 'mph' : 'km/h';
        return '$value $unit';
      case MachineType.cycle:
        return l10n.rpmValue(
          LocalizedFormat.decimal(context, _rpm, decimalDigits: 0),
        );
      case MachineType.stairmaster:
        return l10n.levelColon(
          LocalizedFormat.decimal(context, _level, decimalDigits: 0),
        );
    }
  }

  String _getEditableField2Text() {
    final l10n = AppLocalizations.of(context)!;
    switch (widget.machineType) {
      case MachineType.treadmill:
        return '${LocalizedFormat.decimal(context, _grade)}%';
      case MachineType.cycle:
        return l10n.resistanceColon(
          LocalizedFormat.decimal(
            context,
            _resistance,
            decimalDigits: 0,
          ),
        );
      case MachineType.stairmaster:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final isDark = theme.brightness == Brightness.dark;
    final layeredSurfaceColor =
        isDark ? appColors.surfaceElevated : const Color(0xFFF2F2F7);
    final chipSurfaceColor = isDark ? const Color(0xFF3C3C3C) : Colors.white;
    final chipTextStyle = TextStyle(
      fontSize: 14 * ResponsiveUtils.getFontScale(context),
      fontWeight: FontWeight.w500,
      color: theme.colorScheme.onSurface,
    );

    Widget buildChipLabel(String text) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          maxLines: 1,
          softWrap: false,
          style: chipTextStyle,
        ),
      );
    }

    Widget buildChipContainer({
      required Widget child,
      VoidCallback? onTap,
    }) {
      final chip = Container(
        width: double.infinity,
        padding: ResponsiveUtils.getChipPadding(context),
        decoration: BoxDecoration(
          color: chipSurfaceColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(child: child),
      );

      if (onTap == null) {
        return chip;
      }

      return GestureDetector(
        onTap: onTap,
        child: chip,
      );
    }

    // Build chips for VIEW and EDIT modes
    Widget durationChip;
    Widget field1Chip;
    Widget? field2Chip; // Nullable for Stairmaster (SPM removed)

    if (widget.isEditing) {
      // EDIT mode: tappable chips that open pickers
      durationChip = buildChipContainer(
        onTap: () => _showDurationPicker(context),
        child: buildChipLabel(
          '${_durationMinutes.toString().padLeft(2, '0')}:${_durationSeconds.toString().padLeft(2, '0')}',
        ),
      );

      field1Chip = buildChipContainer(
        onTap: () {
          if (widget.machineType == MachineType.treadmill) {
            _showSpeedPicker(context);
          } else if (widget.machineType == MachineType.cycle) {
            _showRpmPicker(context);
          } else {
            _showLevelPicker(context);
          }
        },
        child: buildChipLabel(_getEditableField1Text()),
      );

      // Field2 chip - only for Treadmill and Cycle (SPM removed for Stairmaster)
      if (widget.machineType != MachineType.stairmaster) {
        field2Chip = buildChipContainer(
          onTap: () {
            if (widget.machineType == MachineType.treadmill) {
              _showGradePicker(context);
            } else if (widget.machineType == MachineType.cycle) {
              _showResistancePicker(context);
            }
          },
          child: buildChipLabel(_getEditableField2Text()),
        );
      } else {
        field2Chip = null; // SPM removed for Stairmaster
      }
    } else {
      // VIEW mode: read-only chips
      durationChip = buildChipContainer(
        child: buildChipLabel(widget.interval.durationFormatted),
      );

      field1Chip = buildChipContainer(
        child: buildChipLabel(_getPill1Text()),
      );

      if (widget.machineType != MachineType.stairmaster) {
        field2Chip = buildChipContainer(
          child: buildChipLabel(_getPill2Text()),
        );
      } else {
        field2Chip = null; // SPM removed for Stairmaster
      }
    }

    final chipRow = Row(
      children: [
        Expanded(flex: field2Chip != null ? 30 : 36, child: durationChip),
        const SizedBox(width: 6),
        Expanded(flex: 35, child: field1Chip),
        if (field2Chip != null) ...[
          const SizedBox(width: 6),
          Expanded(flex: 35, child: field2Chip),
        ],
      ],
    );

    final rowContent = Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: layeredSurfaceColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : appColors.border,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: chipRow,
            ),
            if (widget.reorderIndex != null ||
                widget.onDuplicate != null ||
                widget.onDelete != null) ...[
              const SizedBox(width: 10),
              Container(
                width: 1,
                height: 28,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : appColors.border,
              ),
              const SizedBox(width: 2),
              if (widget.reorderIndex != null)
                ReorderableDragStartListener(
                  index: widget.reorderIndex!,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.grab,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.drag_indicator_rounded,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.56,
                        ),
                        size: 22,
                      ),
                    ),
                  ),
                ),
              if (widget.onDuplicate != null)
                Tooltip(
                  message: l10n.duplicate,
                  child: GestureDetector(
                    onTap: widget.onDuplicate,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.content_copy_outlined,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              if (widget.onDelete != null)
                Tooltip(
                  message: l10n.delete,
                  child: GestureDetector(
                    onTap: widget.onDelete,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: PlatformIcon(
                        cupertino: CupertinoIcons.trash,
                        material: Icons.delete_outline,
                        color: theme.colorScheme.error,
                        size: 22,
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );

    return IgnorePointer(
      ignoring: widget.isRemoving || widget.isEntering,
      child: SizeTransition(
        sizeFactor: _sizeAnimation,
        axisAlignment: -1,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: rowContent,
          ),
        ),
      ),
    );
  }
}
