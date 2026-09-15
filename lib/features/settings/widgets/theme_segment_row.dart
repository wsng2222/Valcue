import 'package:flutter/material.dart';
import 'package:valcue/l10n/app_localizations.dart';
import '../../../widgets/app_segmented_control.dart';
import 'settings_section.dart';
import 'settings_theme.dart';

/// Theme Mode row with title and embedded segmented control (light/dark)
class ThemeSegmentRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final String value;
  final Function(String) onChanged;

  const ThemeSegmentRow({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayValue = value == 'system' ? 'light' : value;
    final selectedBg = settingsSelectedSegmentBackground(context);
    final brightnessKey = Theme.of(context).brightness;
    final localeKey = Localizations.localeOf(context).toLanguageTag();

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Column(
        children: [
          SettingsSegmentHeader(icon: icon, iconColor: iconColor, title: title),
          const SizedBox(height: 12),
          SegmentedButtonTheme(
            data: settingsSegmentThemeData(context, selectedBg),
            child: SizedBox(
              width: double.infinity,
              child: AppSegmentedControl(
                key: ValueKey('theme_segment_${brightnessKey.name}_$localeKey'),
                labels: [l10n.light, l10n.dark],
                selectedIndex: displayValue == 'light' ? 0 : 1,
                onValueChanged: (index) {
                  onChanged(index == 0 ? 'light' : 'dark');
                },
                height: 44,
                color: selectedBg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
