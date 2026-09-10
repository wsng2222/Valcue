
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:valcue/l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_segmented_control.dart';
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
    final theme = Theme.of(context);
    return Column(
      children: [
        // Title row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Segmented control
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(72, 0, 16, 12),
          child: _buildSegmentedControl(
            context: context,
            value: value,
            onChanged: onChanged,
            options: options,
            labels: labels,
          ),
        ),
      ],
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
    if (PlatformInfo.isIOS) {
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
            height: 36,
            color: selectedBg,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final segmentWidth = constraints.maxWidth / segmentOptions.length;
        final textDirection = Directionality.of(context);
        final theme = Theme.of(context);
        final appColors = context.appColors;
        final trackBackground = settingsSegmentTrackBackground(context);

        final thumbLeft = textDirection == TextDirection.ltr
            ? (safeIndex * segmentWidth)
            : ((segmentOptions.length - 1 - safeIndex) * segmentWidth);
        final thumbRight = textDirection == TextDirection.rtl
            ? (safeIndex * segmentWidth)
            : null;

        return Container(
          height: 36,
          decoration: BoxDecoration(
            color: trackBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                left: textDirection == TextDirection.ltr ? thumbLeft : null,
                right: thumbRight,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: settingsSelectedSegmentBackground(context),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: settingsSegmentThumbShadow(
                      context,
                      alpha: 0.1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ),
                ),
              ),
              Row(
                textDirection: textDirection,
                children: segmentOptions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  final label = index < segmentLabels.length
                      ? segmentLabels[index]
                      : option;
                  final isSelected = safeIndex == index;

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(option),
                      child: SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: Center(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? theme.colorScheme.onSurface
                                  : appColors.mutedText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
