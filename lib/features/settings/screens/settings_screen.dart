import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:interval_cardio/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app_settings/app_settings_provider.dart';
import '../../membership/widgets/premium_gate_modal.dart';
import '../../membership/models/premium_feature.dart';
import '../../../theme/app_theme.dart';
import '../../../onboarding/onboarding_flow.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          // Icon with circle background
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
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
                borderRadius: BorderRadius.circular(12),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
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
          padding: const EdgeInsets.fromLTRB(72, 0, 16, 16),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use custom options if provided, otherwise default to kmh/mph
        final segmentOptions = options ?? ['kmh', 'mph'];
        final segmentLabels = labels ??
            [
              AppLocalizations.of(context)!.kmh,
              AppLocalizations.of(context)!.mph,
            ];

        final segmentWidth = constraints.maxWidth / segmentOptions.length;
        final textDirection = Directionality.of(context);
        final theme = Theme.of(context);
        final appColors = context.appColors;

        // Find selected index
        final selectedIndex = segmentOptions.indexOf(value);
        final thumbLeft = textDirection == TextDirection.ltr
            ? (selectedIndex * segmentWidth)
            : ((segmentOptions.length - 1 - selectedIndex) * segmentWidth);
        final thumbRight = textDirection == TextDirection.rtl
            ? (selectedIndex * segmentWidth)
            : null;

        return Container(
          height: 36,
          decoration: BoxDecoration(
            color: appColors.surfaceElevated,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Stack(
            children: [
              // Animated sliding thumb
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
                    // 라이트 모드: 밝은 색상, 다크 모드: 어두운 색상
                    color: theme.brightness == Brightness.light
                        ? const Color.fromARGB(255, 255, 255, 255) // 라이트 모드: 흰색
                        : const Color.fromARGB(
                            255, 60, 60, 60), // 다크 모드: 어두운 회색
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              // Buttons
              Row(
                textDirection: textDirection,
                children: segmentOptions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  final label = segmentLabels[index];
                  final isSelected = value == option;

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
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
        // Premium card-like container with segmented control
        Padding(
          padding: const EdgeInsets.fromLTRB(72, 0, 16, 8),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.light
                  ? Colors.grey.shade50
                  : const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.brightness == Brightness.light
                    ? Colors.grey.shade200
                    : Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Account for 4px gap between segments
        final segmentWidth = (constraints.maxWidth - 4) / 2;
        final textDirection = Directionality.of(context);
        final theme = Theme.of(context);
        final appColors = context.appColors;
        final l10n = AppLocalizations.of(context)!;

        // Convert 'system' to 'light' for display (system option removed)
        final displayValue = value == 'system' ? 'light' : value;

        // Calculate thumb position based on selected value
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
              // Animated sliding thumb with premium styling
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
                    color: theme.brightness == Brightness.light
                        ? Colors.white
                        : const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              // Buttons with icons
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
  int _aboutTapCount = 0;

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
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.settings,
                            size: 32,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          AppLocalizations.of(context)!.settingsTitle,
                          style: GoogleFonts.lato(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: theme.colorScheme.onSurface,
                            letterSpacing: -1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                      const SizedBox(height: 8),
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
                      const SizedBox(height: 8),
                      // Voice Guide section
                      SettingsSection(
                        children: [
                          SettingsRow(
                            icon: Icons.volume_up,
                            iconColor: Colors.green,
                            title: AppLocalizations.of(context)!.voiceGuide,
                            subtitle:
                                AppLocalizations.of(context)!.audioNavigator,
                            trailing: Switch.adaptive(
                              value: provider.voiceGuideEnabled,
                              onChanged: (value) {
                                if (!provider.isPremium) {
                                  // Revert toggle immediately
                                  // The switch will revert on its own since value is controlled by voiceGuideEnabled
                                  // Show premium gate modal
                                  PremiumGateModal.show(
                                    context,
                                    PremiumFeature.voiceGuide,
                                  );
                                } else {
                                  provider.updateVoiceGuide(value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Sound Effects section
                      SettingsSection(
                        children: [
                          SettingsRow(
                            icon: Icons.music_note,
                            iconColor: Colors.orange,
                            title: AppLocalizations.of(context)!.soundEffects,
                            trailing: Switch.adaptive(
                              value: provider.soundEffectsEnabled,
                              onChanged: (value) {
                                provider.updateSoundEffects(value);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Language section
                      SettingsSection(
                        children: [
                          SettingsRow(
                            icon: Icons.language,
                            iconColor: Colors.blue,
                            title: AppLocalizations.of(context)!.language,
                            subtitle: _getLanguageDisplayName(
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
                      const SizedBox(height: 8),
                      // About section
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _aboutTapCount++;
                          });
                          if (_aboutTapCount >= 10) {
                            _aboutTapCount = 0;
                            // Navigate to onboarding
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const OnboardingGate(
                                  home: SizedBox.shrink(),
                                  forceShowOnboarding: true,
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SettingsRow(
                            icon: Icons.info_outline,
                            iconColor: Colors.grey,
                            title: AppLocalizations.of(context)!.about,
                            subtitle:
                                AppLocalizations.of(context)!.version('1.0.0'),
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

    // Build language options list (all languages, no system option)
    final languageOptions = LanguageHelper.supportedLanguages;

    // Find current selected index
    int selectedIndex = languageOptions.indexOf(provider.language);
    if (selectedIndex == -1) selectedIndex = languageOptions.indexOf('en'); // Default to English

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
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Fixed header
                    Padding(
                      padding: const EdgeInsets.all(16),
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
                        children: languageOptions.map((langCode) {
                          final displayName = LanguageHelper.getLanguageDisplayName(langCode);
                          return Center(
                            child: Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
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
                            final selectedLanguage =
                                languageOptions[selectedIndex];
                            provider.updateLanguage(selectedLanguage);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
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
