
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class SettingsSliderRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final double value;
  final double min;
  final double max;
  final String displayValue;
  final ValueChanged<double> onChanged;
  final bool showDivider;

  const SettingsSliderRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.displayValue,
    required this.onChanged,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  displayValue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: appColors.mutedText,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 56, top: 4),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4.0,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 16.0),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                activeColor: theme.colorScheme.primary,
                inactiveColor: appColors.border,
                onChanged: onChanged,
              ),
            ),
          ),
          if (showDivider)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 56, top: 12),
              child: Divider(
                  height: 0.5, thickness: 0.5, color: theme.dividerColor),
            ),
        ],
      ),
    );
  }
}
