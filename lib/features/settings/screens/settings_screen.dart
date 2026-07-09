import 'dart:async';

import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:interval_cardio/l10n/app_localizations.dart';
import 'package:intl/intl.dart' as intl;
import '../../../app_settings/app_settings_provider.dart';
import '../../membership/widgets/premium_gate_modal.dart';
import '../../membership/models/premium_feature.dart';
import '../../../theme/app_theme.dart';
import '../../../onboarding/onboarding_flow.dart';
import '../../../utils/app_shadows.dart';
import '../../../widgets/unified_screen_header.dart';

Color _segmentedSelectedBackground(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? const Color(0xFF2C2C2E) : Colors.white;
}

Color _segmentedTrackBackground(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
}

List<BoxShadow>? _settingsCardShadow(BuildContext context) {
  return AppShadows.elevatedSoft;
}

List<BoxShadow>? _segmentedThumbShadow(
  BuildContext context, {
  required double alpha,
  required double blurRadius,
  required Offset offset,
}) {
  return [
    BoxShadow(
      color: Theme.of(context).colorScheme.shadow.withValues(alpha: alpha),
      blurRadius: blurRadius,
      offset: offset,
    ),
  ];
}

SegmentedButtonThemeData _segmentedThemeData(
  BuildContext context,
  Color selectedBackground,
) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final selectedForeground = isDark ? Colors.white : Colors.black87;
  final borderColor = theme.colorScheme.outline.withValues(alpha: 0.35);

  return SegmentedButtonThemeData(
    style: SegmentedButton.styleFrom(
      selectedBackgroundColor: selectedBackground,
      selectedForegroundColor: selectedForeground,
      foregroundColor: theme.colorScheme.onSurface,
      backgroundColor: theme.colorScheme.surface,
      side: BorderSide(color: borderColor),
    ),
  );
}

Widget _buildPlatformSegmentedControl({
  required Key key,
  required List<String> labels,
  required int selectedIndex,
  required ValueChanged<int> onValueChanged,
  required double height,
  Color? color,
  bool shrinkWrap = false,
}) {
  if (PlatformInfo.isIOS) {
    return AdaptiveSegmentedControl(
      key: key,
      labels: labels,
      selectedIndex: selectedIndex,
      onValueChanged: onValueChanged,
      height: height,
      color: color,
      shrinkWrap: shrinkWrap,
    );
  }

  final hasLabels = labels.isNotEmpty;
  final safeIndex = hasLabels ? selectedIndex.clamp(0, labels.length - 1) : 0;

  return SizedBox(
    key: key,
    width: shrinkWrap ? null : double.infinity,
    height: height,
    child: SegmentedButton<int>(
      segments: [
        for (var i = 0; i < labels.length; i++)
          ButtonSegment<int>(value: i, label: Text(labels[i])),
      ],
      selected: hasLabels ? {safeIndex} : const <int>{},
      showSelectedIcon: false,
      onSelectionChanged: (selection) {
        if (selection.isEmpty) return;
        onValueChanged(selection.first);
      },
    ),
  );
}

Widget _buildPlatformSwitch({
  required BuildContext context,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return CupertinoSwitch(
    value: value,
    onChanged: onChanged,
    activeTrackColor: Theme.of(context).colorScheme.primary,
  );
}

// Language helper class
class LanguageHelper {
  static const Map<String, String> languageNames = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'de': 'Deutsch',
    'ru': 'Русский',
    'pt': 'Português',
    'ja': '日本語',
    'zh': '中文',
    'ko': '한국어',
    'vi': 'Tiếng Việt',
    'ar': 'العربية',
    'nl': 'Nederlands',
    'nb': 'Norsk',
    'da': 'Dansk',
    'it': 'Italiano',
    'th': 'ไทย',
  };

  static const Map<String, String> languageFlags = {
    'en': '🇬🇧',
    'es': '🇪🇸',
    'fr': '🇫🇷',
    'de': '🇩🇪',
    'ru': '🇷🇺',
    'pt': '🇵🇹',
    'ja': '🇯🇵',
    'zh': '🇨🇳',
    'ko': '🇰🇷',
    'vi': '🇻🇳',
    'ar': '🇸🇦',
    'nl': '🇳🇱',
    'nb': '🇳🇴',
    'da': '🇩🇰',
    'it': '🇮🇹',
    'th': '🇹🇭',
  };

  // Fixed order (curated): West EU -> North EU -> East EU -> Asia -> MENA
  static const List<String> _orderedLanguageCodes = [
    'en',
    'es',
    'fr',
    'de',
    'it',
    'nl',
    'da',
    'nb',
    'ru',
    'pt',
    'ja',
    'zh',
    'ko',
    'vi',
    'ar',
    'th',
  ];

  static String getLanguageName(String code) {
    return languageNames[code] ?? code;
  }

  static String getLanguageFlag(String code) {
    return languageFlags[code] ?? '';
  }

  static String getLanguageDisplayName(String code) {
    final name = getLanguageName(code);
    final flag = getLanguageFlag(code);
    return '$name $flag';
  }

  static List<String> get supportedLanguages => _orderedLanguageCodes;
  // All supported languages are now implemented via ARB files.
  static List<String> get implementedLanguages => supportedLanguages;
}

/// iOS-like grouped settings section container
class SettingsSection extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const SettingsSection({
    super.key,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : appColors.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.08) : appColors.border,
        ),
        boxShadow: _settingsCardShadow(context),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

/// Individual settings row with icon, title, subtitle, and trailing widget
class SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;

    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Icon with circle background
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
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 13,
                      color: appColors.mutedText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Trailing widget
          if (trailing != null) trailing!,
        ],
      ),
    );

    return Column(
      children: [
        onTap != null
            ? InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(24),
                child: content,
              )
            : content,
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
            indent: 72,
          ),
      ],
    );
  }
}

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
          padding: const EdgeInsets.fromLTRB(72, 0, 16, 12),
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
    return UnitSegmentRow._buildSegmentedControlStatic(
      context: context,
      value: value,
      onChanged: onChanged,
      options: options,
      labels: labels,
    );
  }

  static Widget _buildSegmentedControlStatic({
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
    final selectedBg = _segmentedSelectedBackground(context);
    final brightnessKey = Theme.of(context).brightness;
    if (PlatformInfo.isIOS) {
      return SegmentedButtonTheme(
        data: _segmentedThemeData(context, selectedBg),
        child: SizedBox(
          width: double.infinity,
          child: _buildPlatformSegmentedControl(
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
        final trackBackground = _segmentedTrackBackground(context);

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
                    color: _segmentedSelectedBackground(context),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: _segmentedThumbShadow(
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
                padding: const EdgeInsets.fromLTRB(72, 0, 16, 12),
                child: _buildSegmentedControl(
                  context: context,
                  value: value,
                  onChanged: onChanged,
                ),
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(72, 0, 16, 12),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _segmentedTrackBackground(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.brightness == Brightness.light
                          ? theme.colorScheme.outlineVariant
                              .withValues(alpha: 0.35)
                          : Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                    boxShadow: _segmentedThumbShadow(
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
    final selectedBg = _segmentedSelectedBackground(context);
    final brightnessKey = Theme.of(context).brightness;
    final localeKey = Localizations.localeOf(context).toLanguageTag();
    if (PlatformInfo.isIOS) {
      return SegmentedButtonTheme(
        data: _segmentedThemeData(context, selectedBg),
        child: SizedBox(
          width: double.infinity,
          child: _buildPlatformSegmentedControl(
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
                    color: _segmentedSelectedBackground(context),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _segmentedThumbShadow(
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
                            Text(
                              l10n.light,
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
                            Text(
                              l10n.dark,
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

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Timer? _aboutHoldTimer;
  String _appVersionLabel = '...';
  static const List<int> _weekdayOrder = <int>[
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
    DateTime.saturday,
    DateTime.sunday,
  ];

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  @override
  void dispose() {
    _aboutHoldTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;

      final buildNumber = info.buildNumber.trim();
      setState(() {
        _appVersionLabel = buildNumber.isEmpty
            ? info.version
            : '${info.version}+${info.buildNumber}';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _appVersionLabel = 'unknown';
      });
    }
  }

  void _startAboutHold() {
    _aboutHoldTimer?.cancel();
    _aboutHoldTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      _aboutHoldTimer?.cancel();
      _aboutHoldTimer = null;
      _showOnboardingFromAbout();
    });
  }

  void _cancelAboutHold() {
    _aboutHoldTimer?.cancel();
    _aboutHoldTimer = null;
  }

  void _showOnboardingFromAbout() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const OnboardingGate(
          home: SizedBox.shrink(),
          forceShowOnboarding: true,
        ),
      ),
    );
  }

  String _weekdayLabel(BuildContext context, int weekday) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final date = DateTime(2024, 1, weekday);
    return intl.DateFormat.E(locale).format(date);
  }

  String _formatReminderTime(BuildContext context, TimeOfDay time) {
    return MaterialLocalizations.of(context).formatTimeOfDay(
      time,
      alwaysUse24HourFormat: false,
    );
  }

  String _weekdaySummary(BuildContext context, List<int> weekdays) {
    if (weekdays.length == 7) {
      return AppLocalizations.of(context)!.workoutReminderEveryDay;
    }
    return weekdays.map((day) => _weekdayLabel(context, day)).join(', ');
  }

  String _reminderSubtitle(BuildContext context, AppSettingsProvider provider) {
    if (!provider.workoutReminderEnabled) {
      return AppLocalizations.of(context)!.workoutReminderOff;
    }

    return '${_weekdaySummary(context, provider.workoutReminderWeekdays)}  '
        '${_formatReminderTime(context, provider.workoutReminderTime)}';
  }

  Future<void> _pickReminderTime(
    BuildContext context,
    AppSettingsProvider provider,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    DateTime draft = DateTime(
      2024,
      1,
      1,
      provider.workoutReminderTime.hour,
      provider.workoutReminderTime.minute,
    );

    final picked = await showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: theme.colorScheme.shadow.withValues(alpha: 0.4),
      isScrollControlled: true,
      enableDrag: false,
      isDismissible: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return SafeArea(
              top: false,
              bottom: true,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(30)),
                  border: Border.all(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.08)
                        : context.appColors.border,
                  ),
                  boxShadow: AppShadows.elevatedSoft,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            context.appColors.mutedText.withValues(alpha: 0.24),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
                      child: Text(
                        AppLocalizations.of(context)!.workoutReminderSelectTime,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 220,
                      child: CupertinoTheme(
                        data: CupertinoTheme.of(modalContext).copyWith(
                          brightness: theme.brightness,
                        ),
                        child: CupertinoDatePicker(
                          mode: CupertinoDatePickerMode.time,
                          use24hFormat: false,
                          initialDateTime: draft,
                          onDateTimeChanged: (value) {
                            setModalState(() {
                              draft = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(sheetContext).pop(
                              TimeOfDay(
                                hour: draft.hour,
                                minute: draft.minute,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            l10n.done,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (picked == null) return;
    await provider.updateWorkoutReminderTime(picked);
  }

  Widget _buildWeekdayChips(
    BuildContext context,
    AppSettingsProvider provider,
  ) {
    final selectedDays = provider.workoutReminderWeekdays.toSet();
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 56),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: appColors.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : appColors.border,
                ),
              ),
              child: Row(
                children: List.generate(_weekdayOrder.length * 2 - 1, (index) {
                  if (index.isOdd) {
                    return const SizedBox(width: 6);
                  }

                  final weekday = _weekdayOrder[index ~/ 2];
                  final isSelected = selectedDays.contains(weekday);
                  final label = _weekdayLabel(context, weekday);

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        final updated = Set<int>.from(selectedDays);
                        if (isSelected) {
                          if (updated.length == 1) return;
                          updated.remove(weekday);
                        } else {
                          updated.add(weekday);
                        }
                        provider
                            .updateWorkoutReminderWeekdays(updated.toList());
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOutCubic,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surface,
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.55),
                            width: 1.2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.18),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Consumer<AppSettingsProvider>(
          builder: (context, provider, child) {
            return CustomScrollView(
              slivers: [
                // Top header area
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: UnifiedScreenHeader(
                      icon: Icons.settings,
                      title: AppLocalizations.of(context)!.settingsTitle,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
                // Settings sections
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Theme Mode section (with segmented control)
                      SettingsSection(
                        children: [
                          ThemeSegmentRow(
                            icon: Icons.palette,
                            iconColor: Colors.indigo,
                            title: AppLocalizations.of(context)!.themeMode,
                            value: provider.themeMode,
                            onChanged: (value) =>
                                provider.updateThemeMode(value),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Unit Setting section (with segmented control)
                      SettingsSection(
                        children: [
                          UnitSegmentRow(
                            icon: Icons.speed,
                            iconColor: Colors.purple,
                            title: AppLocalizations.of(context)!.unitSetting,
                            value: provider.measurement,
                            onChanged: (value) =>
                                provider.updateMeasurement(value),
                          ),
                          // Weight Unit Setting (options only, same section)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(72, 0, 16, 16),
                            child: UnitSegmentRow._buildSegmentedControlStatic(
                              context: context,
                              value: provider.weightUnit,
                              onChanged: (value) =>
                                  provider.updateWeightUnit(value),
                              options: const ['kg', 'lbs'],
                              labels: const ['kg', 'lbs'],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Voice Guide section
                      SettingsSection(
                        children: [
                          SettingsRow(
                            icon: Icons.volume_up,
                            iconColor: Colors.green,
                            title: AppLocalizations.of(context)!.voiceGuide,
                            onTap: provider.isPremium
                                ? null
                                : () {
                                    PremiumGateModal.show(
                                      context,
                                      PremiumFeature.voiceGuide,
                                    );
                                  },
                            trailing: IgnorePointer(
                              ignoring: !provider.isPremium,
                              child: _buildPlatformSwitch(
                                context: context,
                                value: provider.voiceGuideEnabled,
                                onChanged: (value) {
                                  if (!provider.isPremium) return;
                                  provider.updateVoiceGuide(value);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Sound Effects section
                      SettingsSection(
                        children: [
                          SettingsRow(
                            icon: Icons.music_note,
                            iconColor: Colors.orange,
                            title: AppLocalizations.of(context)!.soundEffects,
                            trailing: _buildPlatformSwitch(
                              context: context,
                              value: provider.soundEffectsEnabled,
                              onChanged: (value) {
                                provider.updateSoundEffects(value);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Workout reminder section
                      SettingsSection(
                        children: [
                          SettingsRow(
                            icon: Icons.notifications_active_outlined,
                            iconColor: Colors.redAccent,
                            title: AppLocalizations.of(context)!
                                .workoutReminderTitle,
                            subtitle: _reminderSubtitle(context, provider),
                            trailing: _buildPlatformSwitch(
                              context: context,
                              value: provider.workoutReminderEnabled,
                              onChanged: (enabled) async {
                                final success =
                                    await provider.updateWorkoutReminderEnabled(
                                  enabled,
                                );
                                if (success) return;
                                if (!mounted) return;
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(this.context)!
                                          .workoutReminderPermissionRequired,
                                    ),
                                  ),
                                );
                              },
                            ),
                            showDivider: false,
                          ),
                          if (provider.workoutReminderEnabled)
                            _buildWeekdayChips(context, provider),
                          if (provider.workoutReminderEnabled)
                            SettingsRow(
                              icon: Icons.schedule,
                              iconColor: Colors.teal,
                              title: AppLocalizations.of(context)!
                                  .workoutReminderTimeLabel,
                              subtitle: _formatReminderTime(
                                context,
                                provider.workoutReminderTime,
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                size: 20,
                                color: context.appColors.mutedText,
                              ),
                              onTap: () => _pickReminderTime(context, provider),
                              showDivider: false,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Language section
                      SettingsSection(
                        children: [
                          SettingsRow(
                            icon: Icons.language,
                            iconColor: Colors.blue,
                            title: AppLocalizations.of(context)!.language,
                            subtitle: provider.settings.language == null
                                ? AppLocalizations.of(context)!.system
                                : _getLanguageDisplayName(
                                    context, provider.language),
                            trailing: Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: context.appColors.mutedText,
                            ),
                            onTap: () =>
                                _showLanguageSelector(context, provider),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // About section
                      GestureDetector(
                        onTapDown: (_) => _startAboutHold(),
                        onTapUp: (_) => _cancelAboutHold(),
                        onTapCancel: _cancelAboutHold,
                        onDoubleTap: () {
                          _cancelAboutHold();
                          if (provider.isPremium) {
                            provider.updatePremium(false);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(20, 6, 20, 0),
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark
                                ? theme.colorScheme.surface
                                : context.appColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: theme.brightness == Brightness.dark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : context.appColors.border,
                            ),
                            boxShadow: _settingsCardShadow(context),
                          ),
                          child: SettingsRow(
                            icon: Icons.info_outline,
                            iconColor: Colors.grey,
                            title: AppLocalizations.of(context)!.about,
                            subtitle: AppLocalizations.of(context)!.version(
                              _appVersionLabel,
                            ),
                            showDivider: false,
                          ),
                        ),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 30),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _getLanguageDisplayName(BuildContext context, String languageCode) {
    return LanguageHelper.getLanguageName(languageCode);
  }

  void _showLanguageSelector(
      BuildContext context, AppSettingsProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final languageOptions = LanguageHelper.supportedLanguages;

    // Index 0 = System, 1..N = specific languages
    final isSystem = provider.settings.language == null;
    int selectedIndex =
        isSystem ? 0 : 1 + languageOptions.indexOf(provider.settings.language!);
    if (selectedIndex <= 0 && !isSystem) selectedIndex = 1;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: theme.colorScheme.shadow.withValues(alpha: 0.4),
      isScrollControlled: true,
      enableDrag: false,
      isDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SafeArea(
              top: false,
              bottom: true,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(30)),
                  border: Border.all(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.08)
                        : context.appColors.border,
                  ),
                  boxShadow: AppShadows.elevatedSoft,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            context.appColors.mutedText.withValues(alpha: 0.24),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    // Fixed header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
                      child: Text(
                        l10n.selectLanguage,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    // Picker
                    SizedBox(
                      height: 200,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: selectedIndex,
                        ),
                        itemExtent: 40,
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        children: [
                          Center(
                            child: Text(
                              '📱 ${l10n.system}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          ...languageOptions.map((langCode) {
                            final displayName =
                                LanguageHelper.getLanguageDisplayName(langCode);
                            return Center(
                              child: Text(
                                displayName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Red confirm button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedIndex == 0) {
                              provider.resetLanguageToSystem();
                            } else {
                              provider.updateLanguage(
                                  languageOptions[selectedIndex - 1]);
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            l10n.done,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
