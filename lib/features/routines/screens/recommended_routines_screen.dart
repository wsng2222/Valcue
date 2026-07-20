import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valcue/l10n/app_localizations.dart';
import '../models/routine_template.dart';
import '../models/machine_type.dart';
import '../models/difficulty.dart';
import '../data/routine_templates.dart';
import '../storage/routine_provider.dart';
import '../../../app_settings/app_settings_provider.dart';
import '../../../widgets/bidi_safe_text.dart';
import 'routine_preview_sheet.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/app_shadows.dart';

class RecommendedRoutinesScreen extends StatefulWidget {
  final MachineType machineType;

  const RecommendedRoutinesScreen({
    super.key,
    required this.machineType,
  });

  @override
  State<RecommendedRoutinesScreen> createState() =>
      _RecommendedRoutinesScreenState();
}

class _RecommendedRoutinesScreenState extends State<RecommendedRoutinesScreen> {
  final List<RoutineTemplate> _allTemplates = [];

  @override
  void initState() {
    super.initState();
    _allTemplates.addAll(
      RoutineTemplates.getTemplatesByMachine(widget.machineType),
    );
  }

  // Group templates by difficulty in order: beginner, intermediate, advanced
  Map<Difficulty, List<RoutineTemplate>> get _templatesByDifficulty {
    final Map<Difficulty, List<RoutineTemplate>> grouped = {
      Difficulty.beginner: [],
      Difficulty.intermediate: [],
      Difficulty.advanced: [],
    };
    for (final template in _allTemplates) {
      grouped[template.difficulty]!.add(template);
    }
    return grouped;
  }

  String _getMachineTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (widget.machineType) {
      case MachineType.treadmill:
        return l10n.recommendedRoutinesTreadmill;
      case MachineType.cycle:
        return l10n.recommendedRoutinesCycle;
      case MachineType.stairmaster:
        return l10n.recommendedRoutinesStairmaster;
    }
  }

  String _getDifficultyText(BuildContext context, Difficulty difficulty) {
    final l10n = AppLocalizations.of(context)!;
    switch (difficulty) {
      case Difficulty.beginner:
        return l10n.beginner;
      case Difficulty.intermediate:
        return l10n.intermediate;
      case Difficulty.advanced:
        return l10n.advanced;
    }
  }

  IconData _getMachineIcon() {
    switch (widget.machineType) {
      case MachineType.treadmill:
        return Icons.directions_run;
      case MachineType.cycle:
        return Icons.pedal_bike;
      case MachineType.stairmaster:
        return Icons.stairs_rounded;
    }
  }

  String _getLocalizedTitle(AppLocalizations l10n, String key) {
    // Try dynamic access for new keys, fallback to old keys
    try {
      switch (key) {
        // Treadmill
        case 'template_treadmill_beginner_1_title':
          return l10n.templateTreadmillBeginner1Title;
        case 'template_treadmill_beginner_2_title':
          return l10n.templateTreadmillBeginner2Title;
        case 'template_treadmill_intermediate_1_title':
          return l10n.templateTreadmillIntermediate1Title;
        case 'template_treadmill_intermediate_2_title':
          return l10n.templateTreadmillIntermediate2Title;
        case 'template_treadmill_advanced_1_title':
          return l10n.templateTreadmillAdvanced1Title;
        case 'template_treadmill_advanced_2_title':
          return l10n.templateTreadmillAdvanced2Title;
        // Cycle
        case 'template_cycle_beginner_1_title':
          return l10n.templateCycleBeginner1Title;
        case 'template_cycle_beginner_2_title':
          return l10n.templateCycleBeginner2Title;
        case 'template_cycle_intermediate_1_title':
          return l10n.templateCycleIntermediate1Title;
        case 'template_cycle_intermediate_2_title':
          return l10n.templateCycleIntermediate2Title;
        case 'template_cycle_advanced_1_title':
          return l10n.templateCycleAdvanced1Title;
        case 'template_cycle_advanced_2_title':
          return l10n.templateCycleAdvanced2Title;
        // Stairmaster
        case 'template_stairmaster_beginner_1_title':
          return l10n.templateStairmasterBeginner1Title;
        case 'template_stairmaster_beginner_2_title':
          return l10n.templateStairmasterBeginner2Title;
        case 'template_stairmaster_intermediate_1_title':
          return l10n.templateStairmasterIntermediate1Title;
        case 'template_stairmaster_intermediate_2_title':
          return l10n.templateStairmasterIntermediate2Title;
        case 'template_stairmaster_advanced_1_title':
          return l10n.templateStairmasterAdvanced1Title;
        case 'template_stairmaster_advanced_2_title':
          return l10n.templateStairmasterAdvanced2Title;
        // Legacy support (backward compatibility)
        case 'template_treadmill_beginner_title':
          return l10n.templateTreadmillBeginner1Title;
        case 'template_treadmill_intermediate_title':
          return l10n.templateTreadmillIntermediate1Title;
        case 'template_treadmill_advanced_title':
          return l10n.templateTreadmillAdvanced1Title;
        case 'template_cycle_beginner_title':
          return l10n.templateCycleBeginner1Title;
        case 'template_cycle_intermediate_title':
          return l10n.templateCycleIntermediate1Title;
        case 'template_cycle_advanced_title':
          return l10n.templateCycleAdvanced1Title;
        case 'template_stairmaster_beginner_title':
          return l10n.templateStairmasterBeginner1Title;
        case 'template_stairmaster_intermediate_title':
          return l10n.templateStairmasterIntermediate1Title;
        case 'template_stairmaster_advanced_title':
          return l10n.templateStairmasterAdvanced1Title;
        default:
          return l10n.unnamedRoutine;
      }
    } catch (e) {
      return l10n.unnamedRoutine;
    }
  }

  String _getLocalizedSubtitle(AppLocalizations l10n, String key) {
    try {
      switch (key) {
        // Treadmill
        case 'template_treadmill_beginner_1_subtitle':
          return l10n.templateTreadmillBeginner1Subtitle;
        case 'template_treadmill_beginner_2_subtitle':
          return l10n.templateTreadmillBeginner2Subtitle;
        case 'template_treadmill_intermediate_1_subtitle':
          return l10n.templateTreadmillIntermediate1Subtitle;
        case 'template_treadmill_intermediate_2_subtitle':
          return l10n.templateTreadmillIntermediate2Subtitle;
        case 'template_treadmill_advanced_1_subtitle':
          return l10n.templateTreadmillAdvanced1Subtitle;
        case 'template_treadmill_advanced_2_subtitle':
          return l10n.templateTreadmillAdvanced2Subtitle;
        // Cycle
        case 'template_cycle_beginner_1_subtitle':
          return l10n.templateCycleBeginner1Subtitle;
        case 'template_cycle_beginner_2_subtitle':
          return l10n.templateCycleBeginner2Subtitle;
        case 'template_cycle_intermediate_1_subtitle':
          return l10n.templateCycleIntermediate1Subtitle;
        case 'template_cycle_intermediate_2_subtitle':
          return l10n.templateCycleIntermediate2Subtitle;
        case 'template_cycle_advanced_1_subtitle':
          return l10n.templateCycleAdvanced1Subtitle;
        case 'template_cycle_advanced_2_subtitle':
          return l10n.templateCycleAdvanced2Subtitle;
        // Stairmaster
        case 'template_stairmaster_beginner_1_subtitle':
          return l10n.templateStairmasterBeginner1Subtitle;
        case 'template_stairmaster_beginner_2_subtitle':
          return l10n.templateStairmasterBeginner2Subtitle;
        case 'template_stairmaster_intermediate_1_subtitle':
          return l10n.templateStairmasterIntermediate1Subtitle;
        case 'template_stairmaster_intermediate_2_subtitle':
          return l10n.templateStairmasterIntermediate2Subtitle;
        case 'template_stairmaster_advanced_1_subtitle':
          return l10n.templateStairmasterAdvanced1Subtitle;
        case 'template_stairmaster_advanced_2_subtitle':
          return l10n.templateStairmasterAdvanced2Subtitle;
        // Legacy support (backward compatibility)
        case 'template_treadmill_beginner_subtitle':
          return l10n.templateTreadmillBeginner1Subtitle;
        case 'template_treadmill_intermediate_subtitle':
          return l10n.templateTreadmillIntermediate1Subtitle;
        case 'template_treadmill_advanced_subtitle':
          return l10n.templateTreadmillAdvanced1Subtitle;
        case 'template_cycle_beginner_subtitle':
          return l10n.templateCycleBeginner1Subtitle;
        case 'template_cycle_intermediate_subtitle':
          return l10n.templateCycleIntermediate1Subtitle;
        case 'template_cycle_advanced_subtitle':
          return l10n.templateCycleAdvanced1Subtitle;
        case 'template_stairmaster_beginner_subtitle':
          return l10n.templateStairmasterBeginner1Subtitle;
        case 'template_stairmaster_intermediate_subtitle':
          return l10n.templateStairmasterIntermediate1Subtitle;
        case 'template_stairmaster_advanced_subtitle':
          return l10n.templateStairmasterAdvanced1Subtitle;
        default:
          return '';
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<RoutineProvider>(context);
    final settingsProvider = Provider.of<AppSettingsProvider>(context);
    final grouped = _templatesByDifficulty;
    final difficultyOrder = [
      Difficulty.beginner,
      Difficulty.intermediate,
      Difficulty.advanced
    ];

    final theme = Theme.of(context);
    final baseTextStyle = theme.textTheme.bodyMedium ?? const TextStyle();
    final navTextStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurface,
      decoration: TextDecoration.none,
    );

    return CupertinoTheme(
      data: CupertinoTheme.of(context).copyWith(
        textTheme: CupertinoTextThemeData(textStyle: baseTextStyle),
        primaryColor: theme.colorScheme.primary,
        scaffoldBackgroundColor: theme.scaffoldBackgroundColor,
        barBackgroundColor: theme.colorScheme.surface,
      ),
      child: DefaultTextStyle.merge(
        style: baseTextStyle,
        child: CupertinoPageScaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          navigationBar: CupertinoNavigationBar(
            leading: CupertinoNavigationBarBackButton(
              color: theme.colorScheme.onSurface,
              onPressed: () => Navigator.of(context).pop(),
            ),
            middle: Text(
              _getMachineTitle(context),
              style: navTextStyle,
            ),
            backgroundColor: theme.colorScheme.surface,
            border: Border(
              bottom: BorderSide(color: theme.dividerColor, width: 0.0),
            ),
          ),
          child: Container(
            color: theme.scaffoldBackgroundColor,
            child: SafeArea(
              child: _allTemplates.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noTemplatesFound,
                        style: baseTextStyle.copyWith(
                          fontSize: 16,
                          color: context.appColors.mutedText,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                      children: _buildSections(context, grouped,
                          difficultyOrder, provider, settingsProvider, l10n),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSections(
    BuildContext context,
    Map<Difficulty, List<RoutineTemplate>> grouped,
    List<Difficulty> difficultyOrder,
    RoutineProvider provider,
    AppSettingsProvider settingsProvider,
    AppLocalizations l10n,
  ) {
    final List<Widget> sections = [];

    for (int i = 0; i < difficultyOrder.length; i++) {
      final difficulty = difficultyOrder[i];
      final templates = grouped[difficulty]!;

      if (templates.isEmpty) continue;

      // Section header
      final theme = Theme.of(context);
      sections.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: 14,
            top: i > 0 ? 28 : 8,
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getDifficultyText(context, difficulty),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurface,
                  decoration: TextDecoration.none,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      );

      // Section cards
      for (final template in templates) {
        sections
            .add(_buildTemplateCard(context, template, settingsProvider, l10n));
      }
    }

    return sections;
  }

  Widget _buildTemplateCard(
    BuildContext context,
    RoutineTemplate template,
    AppSettingsProvider settingsProvider,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.08) : appColors.border,
        ),
        boxShadow: AppShadows.elevatedSoft,
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _getMachineIcon(),
                    size: 22,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getLocalizedTitle(l10n, template.titleKey),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.4,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _getLocalizedSubtitle(l10n, template.subtitleKey),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          color: appColors.mutedText,
                          letterSpacing: -0.2,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: appColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : appColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      BidiSafeText(
                        template.totalDurationFormatted,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.8),
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.none,
                        ),
                        forceLTR: true,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    RoutinePreviewSheet.show(
                        context, template, settingsProvider);
                  },
                  minimumSize: const Size(0, 0),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: theme.colorScheme.onPrimary,
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
}
