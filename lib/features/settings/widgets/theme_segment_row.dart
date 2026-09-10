
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:valcue/l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/app_segmented_control.dart';
import 'settings_theme.dart';

/// Premium Theme Mode row with title and embedded segmented control (2 segments: light/dark)
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
        PlatformInfo.isIOS
            ? Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(72, 0, 16, 12),
                child: _buildSegmentedControl(
                  context: context,
                  value: value,
                  onChanged: onChanged,
                ),
              )
            : Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(72, 0, 16, 12),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: settingsSegmentTrackBackground(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.brightness == Brightness.light
                          ? theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.35)
                          : Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                    boxShadow: settingsSegmentThumbShadow(
                      context,
                      alpha: 0.05,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ),
                  child: _buildSegmentedControl(
                    context: context,
                    value: value,
                    onChanged: onChanged,
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildSegmentedControl({
    required BuildContext context,
    required String value,
    required Function(String) onChanged,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final displayValue = value == 'system' ? 'light' : value;
    final selectedBg = settingsSelectedSegmentBackground(context);
    final brightnessKey = Theme.of(context).brightness;
    final localeKey = Localizations.localeOf(context).toLanguageTag();
    if (PlatformInfo.isIOS) {
      return SegmentedButtonTheme(
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
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final segmentWidth = (constraints.maxWidth - 4) / 2;
        final textDirection = Directionality.of(context);
        final theme = Theme.of(context);
        final appColors = context.appColors;

        final isLightSelected = displayValue == 'light';
        final thumbLeft = textDirection == TextDirection.ltr
            ? (isLightSelected ? 0.0 : segmentWidth + 4)
            : (isLightSelected ? segmentWidth + 4 : 0.0);
        final thumbRight = textDirection == TextDirection.rtl
            ? (isLightSelected ? 0.0 : segmentWidth + 4)
            : null;

        return SizedBox(
          height: 44,
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
                left: textDirection == TextDirection.ltr ? thumbLeft : null,
                right: thumbRight,
                top: 0,
                bottom: 0,
                width: segmentWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: settingsSelectedSegmentBackground(context),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: settingsSegmentThumbShadow(
                      context,
                      alpha: 0.15,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ),
                ),
              ),
              Row(
                textDirection: textDirection,
                children: [
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged('light'),
                      child: Container(
                        width: double.infinity,
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.sun_max_fill,
                              size: 16,
                              color: displayValue == 'light'
                                  ? theme.colorScheme.onSurface
                                  : appColors.mutedText,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                l10n.light,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: displayValue == 'light'
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: displayValue == 'light'
                                      ? theme.colorScheme.onSurface
                                      : appColors.mutedText,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged('dark'),
                      child: Container(
                        width: double.infinity,
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.moon_fill,
                              size: 16,
                              color: displayValue == 'dark'
                                  ? theme.colorScheme.onSurface
                                  : appColors.mutedText,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                l10n.dark,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: displayValue == 'dark'
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: displayValue == 'dark'
                                      ? theme.colorScheme.onSurface
                                      : appColors.mutedText,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
