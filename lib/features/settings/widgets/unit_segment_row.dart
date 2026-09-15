
import 'package:flutter/material.dart';
import 'package:valcue/l10n/app_localizations.dart';
import '../../../widgets/app_segmented_control.dart';
import 'settings_section.dart';
import 'settings_theme.dart';

/// Unit Setting row with title and embedded segmented control
class UnitSegmentRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String value;
  final Function(String) onChanged;
  final List<String>? options; // Custom options (e.g., ['kg', 'lbs'])
  final List<String>? labels; // Custom labels for display

  const UnitSegmentRow({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.onChanged,
    this.options,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
      child: Column(
        children: [
          SettingsSegmentHeader(icon: icon, iconColor: iconColor, title: title),
          const SizedBox(height: 12),
          _buildSegmentedControl(
            context: context,
            value: value,
            onChanged: onChanged,
            options: options,
            labels: labels,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl({
    required BuildContext context,
    required String value,
    required Function(String) onChanged,
    List<String>? options,
    List<String>? labels,
  }) {
    return UnitSegmentRow.buildSegmentedControl(
      context: context,
      value: value,
      onChanged: onChanged,
      options: options,
      labels: labels,
    );
  }

  static Widget buildSegmentedControl({
    required BuildContext context,
    required String value,
    required Function(String) onChanged,
    List<String>? options,
    List<String>? labels,
  }) {
    final segmentOptions = options ?? ['kmh', 'mph'];
    final segmentLabels = labels ??
        [
          AppLocalizations.of(context)!.kmh,
          AppLocalizations.of(context)!.mph,
        ];

    final resolvedLabels = segmentLabels.length == segmentOptions.length
        ? segmentLabels
        : segmentOptions;
    final selectedIndex = segmentOptions.indexOf(value);
    final safeIndex = selectedIndex >= 0 ? selectedIndex : 0;
    final selectedBg = settingsSelectedSegmentBackground(context);
    final brightnessKey = Theme.of(context).brightness;
    return SegmentedButtonTheme(
      data: settingsSegmentThemeData(context, selectedBg),
      child: SizedBox(
        width: double.infinity,
        child: AppSegmentedControl(
          key: ValueKey(
            'unit_segment_${brightnessKey.name}_${resolvedLabels.join('|')}',
          ),
          labels: resolvedLabels,
          selectedIndex: safeIndex,
          onValueChanged: (index) {
            if (index < 0 || index >= segmentOptions.length) return;
            onChanged(segmentOptions[index]);
          },
          height: 44,
          color: selectedBg,
        ),
      ),
    );
  }
}
