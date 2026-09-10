import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'package:valcue/l10n/localized_format.dart';
import '../../../theme/app_theme.dart';
import '../../../app_settings/app_settings_provider.dart';
import '../../../utils/app_shadows.dart';
import '../models/weight_entry.dart';
import '../providers/weight_tracker_provider.dart';
import '../../../widgets/app_bottom_sheet.dart';
import '../../../widgets/platform_icon.dart';

/// Helper function to show weight recording/editing bottom sheet
void showRecordWeightBottomSheet(
  BuildContext context, {
  DateTime? initialDateTime,
  WeightEntry? editEntry,
}) {
  final settingsProvider =
      Provider.of<AppSettingsProvider>(context, listen: false);
  final provider = Provider.of<WeightTrackerProvider>(context, listen: false);
  final isWeightMetric = settingsProvider.weightUnit == 'kg';
  final weightController = TextEditingController();

  if (editEntry != null) {
    weightController.text = isWeightMetric
        ? LocalizedFormat.decimal(context, editEntry.weightKg)
        : LocalizedFormat.decimal(context, editEntry.weightKg * 2.20462);
  } else {
    final currentWeight = provider.currentWeight;
    if (currentWeight != null) {
      weightController.text = isWeightMetric
          ? LocalizedFormat.decimal(context, currentWeight.weightKg)
          : LocalizedFormat.decimal(
              context,
              currentWeight.weightKg * 2.20462,
            );
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    builder: (context) => RecordWeightBottomSheet(
      weightController: weightController,
      isMetric: isWeightMetric,
      initialDateTime: initialDateTime ?? editEntry?.dateTime,
      isEditing: editEntry != null,
      entryId: editEntry?.id,
    ),
  );
}

class RecordWeightBottomSheet extends StatefulWidget {
  final TextEditingController weightController;
  final bool isMetric;
  final DateTime? initialDateTime;
  final bool isEditing;
  final String? entryId;

  const RecordWeightBottomSheet({super.key, 
    required this.weightController,
    required this.isMetric,
    this.initialDateTime,
    this.isEditing = false,
    this.entryId,
  });

  @override
  State<RecordWeightBottomSheet> createState() =>
      _RecordWeightBottomSheetState();
}

class _RecordWeightBottomSheetState extends State<RecordWeightBottomSheet> {
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
    final weight = LocalizedFormat.tryParseDecimal(context, text);
    setState(() {
      _isValid =
          text.isNotEmpty && weight != null && weight > 0 && weight < 500;
    });
  }

  void _addQuickValue(double value) {
    final current =
        LocalizedFormat.tryParseDecimal(context, _controller.text) ?? 0;
    final newValue = (current + value).clamp(0.0, 500.0);
    setState(() {
      _controller.text = LocalizedFormat.decimal(context, newValue);
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
          child: AppBottomSheetFrame(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
    final weight = LocalizedFormat.tryParseDecimal(context, weightText);
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
      } else {
        // Add new entry
        provider.addEntry(WeightEntry(
          dateTime: _selectedDateTime,
          weightKg: weightKg,
        ));
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
      return LocalizedFormat.mediumDate(context, dateTime);
    }
  }

  String? _getLastWeightComparison(bool isMetric) {
    final provider = Provider.of<WeightTrackerProvider>(context, listen: false);
    if (provider.entries.length < 2) return null;

    final lastWeight = provider.entries[1].weightKg;
    final currentText = _controller.text.trim();
    final currentWeight = LocalizedFormat.tryParseDecimal(context, currentText);

    if (currentWeight == null || currentText.isEmpty) return null;

    final currentWeightKg = isMetric ? currentWeight : currentWeight / 2.20462;
    final difference = currentWeightKg - lastWeight;

    String formatWeight(double kg, bool isMetric) {
      if (isMetric) {
        return '${LocalizedFormat.decimal(context, kg)} kg';
      } else {
        return '${LocalizedFormat.decimal(context, kg * 2.20462)} lbs';
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
            color: theme.colorScheme.surface,
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
              const AppBottomSheetHandle(),
              // Header with title and close button
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        widget.isEditing
                            ? AppLocalizations.of(context)!.editWeight
                            : AppLocalizations.of(context)!.recordWeight,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    PlatformInfo.isIOS
                        ? AdaptiveButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: CupertinoIcons.xmark,
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
                              PlatformIcon(
                                cupertino: CupertinoIcons.chevron_right,
                                material: Icons.chevron_right,
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
                  color: theme.colorScheme.surface,
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
class SetGoalBottomSheet extends StatefulWidget {
  final TextEditingController goalWeightController;
  final bool isMetric;
  final WeightEntry? currentWeight;

  const SetGoalBottomSheet({super.key, 
    required this.goalWeightController,
    required this.isMetric,
    this.currentWeight,
  });

  @override
  State<SetGoalBottomSheet> createState() => _SetGoalBottomSheetState();
}

class _SetGoalBottomSheetState extends State<SetGoalBottomSheet> {
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
    final weight = LocalizedFormat.tryParseDecimal(context, text);
    setState(() {
      _isValid =
          text.isNotEmpty && weight != null && weight > 0 && weight < 500;
    });
  }

  void _setPreset(double value) {
    setState(() {
      _controller.text = LocalizedFormat.decimal(context, value);
    });
  }

  void _save() {
    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);
    final isMetric = settingsProvider.weightUnit == 'kg';
    final provider = Provider.of<WeightTrackerProvider>(context, listen: false);
    final weightText = _controller.text.trim();

    if (weightText.isNotEmpty) {
      final weight = LocalizedFormat.tryParseDecimal(context, weightText);
      if (weight != null && weight > 0) {
        final weightKg = isMetric ? weight : weight / 2.20462;
        HapticFeedback.mediumImpact();
        provider.setGoalWeight(weightKg);
        Navigator.pop(context);
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
  }

  String? _getGoalHelperText(bool isMetric) {
    if (widget.currentWeight == null) return null;

    final currentText = _controller.text.trim();
    final goalWeight = LocalizedFormat.tryParseDecimal(context, currentText);

    if (goalWeight == null || currentText.isEmpty) return null;

    final goalWeightKg = isMetric ? goalWeight : goalWeight / 2.20462;
    final difference = goalWeightKg - widget.currentWeight!.weightKg;

    String formatWeight(double kg) {
      if (isMetric) {
        return '${LocalizedFormat.decimal(context, kg)} kg';
      } else {
        return '${LocalizedFormat.decimal(context, kg * 2.20462)} lbs';
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
            color: theme.colorScheme.surface,
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
              const AppBottomSheetHandle(),
              // Header with title and close button
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context)!.setGoal,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const PlatformIcon(
                        cupertino: CupertinoIcons.xmark,
                        material: Icons.close,
                        size: 24,
                      ),
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
                                  final displayedDiff =
                                      isMetric ? diff : diff * 2.20462;
                                  final value = LocalizedFormat.decimal(
                                    context,
                                    displayedDiff.abs(),
                                    decimalDigits: 0,
                                  );
                                  final sign = diff > 0
                                      ? '+'
                                      : diff < 0
                                          ? '-'
                                          : '';
                                  if (isMetric) {
                                    return '${l10n.current} $sign$value kg';
                                  } else {
                                    return '${l10n.current} $sign$value lbs';
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
                  color: theme.colorScheme.surface,
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
