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
    try {
      switch (widget.machineType) {
        case MachineType.treadmill:
          return (l10n as dynamic).recommendedRoutinesTreadmill ??
              'Recommended Treadmill Routines';
        case MachineType.cycle:
          return (l10n as dynamic).recommendedRoutinesCycle ??
              'Recommended Bike Routines';
        case MachineType.stairmaster:
          return (l10n as dynamic).recommendedRoutinesStairmaster ??
              'Recommended Stairmaster Routines';
      }
    } catch (e) {
      switch (widget.machineType) {
        case MachineType.treadmill:
          return 'Recommended Treadmill Routines';
        case MachineType.cycle:
          return 'Recommended Bike Routines';
        case MachineType.stairmaster:
          return 'Recommended Stairmaster Routines';
      }
    }
  }

  String _getDifficultyText(BuildContext context, Difficulty difficulty) {
    final l10n = AppLocalizations.of(context)!;
    try {
      switch (difficulty) {
        case Difficulty.beginner:
          return (l10n as dynamic).beginner ?? 'Beginner';
        case Difficulty.intermediate:
          return (l10n as dynamic).intermediate ?? 'Intermediate';
        case Difficulty.advanced:
          return (l10n as dynamic).advanced ?? 'Advanced';
      }
    } catch (e) {
      switch (difficulty) {
        case Difficulty.beginner:
          return 'Beginner';
        case Difficulty.intermediate:
          return 'Intermediate';
        case Difficulty.advanced:
          return 'Advanced';
      }
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
          return (l10n as dynamic).templateTreadmillBeginner1Title ??
              'Easy Start 20';
        case 'template_treadmill_beginner_2_title':
          return (l10n as dynamic).templateTreadmillBeginner2Title ??
              'Incline Walk 25';
        case 'template_treadmill_intermediate_1_title':
          return (l10n as dynamic).templateTreadmillIntermediate1Title ??
              'Classic 1:1 24';
        case 'template_treadmill_intermediate_2_title':
          return (l10n as dynamic).templateTreadmillIntermediate2Title ??
              'Speed Ladder 20';
        case 'template_treadmill_advanced_1_title':
          return (l10n as dynamic).templateTreadmillAdvanced1Title ??
              '2:1 Burner 21';
        case 'template_treadmill_advanced_2_title':
          return (l10n as dynamic).templateTreadmillAdvanced2Title ??
              'Sprint Pop 18';
        // Cycle
        case 'template_cycle_beginner_1_title':
          return (l10n as dynamic).templateCycleBeginner1Title ??
              'Cadence Builder 20';
        case 'template_cycle_beginner_2_title':
          return (l10n as dynamic).templateCycleBeginner2Title ??
              'Steady Ride 25';
        case 'template_cycle_intermediate_1_title':
          return (l10n as dynamic).templateCycleIntermediate1Title ??
              'Spin 1:1 24';
        case 'template_cycle_intermediate_2_title':
          return (l10n as dynamic).templateCycleIntermediate2Title ??
              'Hill Simulation 22';
        case 'template_cycle_advanced_1_title':
          return (l10n as dynamic).templateCycleAdvanced1Title ??
              'Power Intervals 20';
        case 'template_cycle_advanced_2_title':
          return (l10n as dynamic).templateCycleAdvanced2Title ??
              'Tabata Mix 16';
        // Stairmaster
        case 'template_stairmaster_beginner_1_title':
          return (l10n as dynamic).templateStairmasterBeginner1Title ??
              'Easy Steps 20';
        case 'template_stairmaster_beginner_2_title':
          return (l10n as dynamic).templateStairmasterBeginner2Title ??
              'Long Easy 25';
        case 'template_stairmaster_intermediate_1_title':
          return (l10n as dynamic).templateStairmasterIntermediate1Title ??
              '2:1 Climb 21';
        case 'template_stairmaster_intermediate_2_title':
          return (l10n as dynamic).templateStairmasterIntermediate2Title ??
              'Strong 1:1 24';
        case 'template_stairmaster_advanced_1_title':
          return (l10n as dynamic).templateStairmasterAdvanced1Title ??
              'Hard Blocks 20';
        case 'template_stairmaster_advanced_2_title':
          return (l10n as dynamic).templateStairmasterAdvanced2Title ??
              'Sprint Steps 18';
        // Legacy support (backward compatibility)
        case 'template_treadmill_beginner_title':
          return (l10n as dynamic).templateTreadmillBeginner1Title ??
              'Easy Start 20';
        case 'template_treadmill_intermediate_title':
          return (l10n as dynamic).templateTreadmillIntermediate1Title ??
              'Classic 1:1 24';
        case 'template_treadmill_advanced_title':
          return (l10n as dynamic).templateTreadmillAdvanced1Title ??
              '2:1 Burner 21';
        case 'template_cycle_beginner_title':
          return (l10n as dynamic).templateCycleBeginner1Title ??
              'Cadence Builder 20';
        case 'template_cycle_intermediate_title':
          return (l10n as dynamic).templateCycleIntermediate1Title ??
              'Spin 1:1 24';
        case 'template_cycle_advanced_title':
          return (l10n as dynamic).templateCycleAdvanced1Title ??
              'Power Intervals 20';
        case 'template_stairmaster_beginner_title':
          return (l10n as dynamic).templateStairmasterBeginner1Title ??
              'Easy Steps 20';
        case 'template_stairmaster_intermediate_title':
          return (l10n as dynamic).templateStairmasterIntermediate1Title ??
              '2:1 Climb 21';
        case 'template_stairmaster_advanced_title':
          return (l10n as dynamic).templateStairmasterAdvanced1Title ??
              'Hard Blocks 20';
        default:
          return 'Untitled Routine';
      }
    } catch (e) {
      // Fallback to English defaults
      switch (key) {
        case 'template_treadmill_beginner_1_title':
          return 'Easy Start 20';
        case 'template_treadmill_beginner_2_title':
          return 'Incline Walk 25';
        case 'template_treadmill_intermediate_1_title':
          return 'Classic 1:1 24';
        case 'template_treadmill_intermediate_2_title':
          return 'Speed Ladder 20';
        case 'template_treadmill_advanced_1_title':
          return '2:1 Burner 21';
        case 'template_treadmill_advanced_2_title':
          return 'Sprint Pop 18';
        case 'template_cycle_beginner_1_title':
          return 'Cadence Builder 20';
        case 'template_cycle_beginner_2_title':
          return 'Steady Ride 25';
        case 'template_cycle_intermediate_1_title':
          return 'Spin 1:1 24';
        case 'template_cycle_intermediate_2_title':
          return 'Hill Simulation 22';
        case 'template_cycle_advanced_1_title':
          return 'Power Intervals 20';
        case 'template_cycle_advanced_2_title':
          return 'Tabata Mix 16';
        case 'template_stairmaster_beginner_1_title':
          return 'Easy Steps 20';
        case 'template_stairmaster_beginner_2_title':
          return 'Long Easy 25';
        case 'template_stairmaster_intermediate_1_title':
          return '2:1 Climb 21';
        case 'template_stairmaster_intermediate_2_title':
          return 'Strong 1:1 24';
        case 'template_stairmaster_advanced_1_title':
          return 'Hard Blocks 20';
        case 'template_stairmaster_advanced_2_title':
          return 'Sprint Steps 18';
        default:
          return 'Untitled Routine';
      }
    }
  }

  String _getLocalizedSubtitle(AppLocalizations l10n, String key) {
    try {
      switch (key) {
        // Treadmill
        case 'template_treadmill_beginner_1_subtitle':
          return (l10n as dynamic).templateTreadmillBeginner1Subtitle ??
              'Perfect for beginners';
        case 'template_treadmill_beginner_2_subtitle':
          return (l10n as dynamic).templateTreadmillBeginner2Subtitle ??
              'Steady pace maintain';
        case 'template_treadmill_intermediate_1_subtitle':
          return (l10n as dynamic).templateTreadmillIntermediate1Subtitle ??
              'Build endurance';
        case 'template_treadmill_intermediate_2_subtitle':
          return (l10n as dynamic).templateTreadmillIntermediate2Subtitle ??
              'Progressive intensity';
        case 'template_treadmill_advanced_1_subtitle':
          return (l10n as dynamic).templateTreadmillAdvanced1Subtitle ??
              'High intensity workout';
        case 'template_treadmill_advanced_2_subtitle':
          return (l10n as dynamic).templateTreadmillAdvanced2Subtitle ??
              'Maximum burst intensity';
        // Cycle
        case 'template_cycle_beginner_1_subtitle':
          return (l10n as dynamic).templateCycleBeginner1Subtitle ??
              '4 min warm-up + 1:1 cadence';
        case 'template_cycle_beginner_2_subtitle':
          return (l10n as dynamic).templateCycleBeginner2Subtitle ??
              'Long steady block';
        case 'template_cycle_intermediate_1_subtitle':
          return (l10n as dynamic).templateCycleIntermediate1Subtitle ??
              'Classic 1:1 spin intervals';
        case 'template_cycle_intermediate_2_subtitle':
          return (l10n as dynamic).templateCycleIntermediate2Subtitle ??
              'Climb repeats';
        case 'template_cycle_advanced_1_subtitle':
          return (l10n as dynamic).templateCycleAdvanced1Subtitle ??
              '30s power bursts';
        case 'template_cycle_advanced_2_subtitle':
          return (l10n as dynamic).templateCycleAdvanced2Subtitle ??
              '20s on / 10s off mix';
        // Stairmaster
        case 'template_stairmaster_beginner_1_subtitle':
          return (l10n as dynamic).templateStairmasterBeginner1Subtitle ??
              '4 min warm-up + 1:1 steps';
        case 'template_stairmaster_beginner_2_subtitle':
          return (l10n as dynamic).templateStairmasterBeginner2Subtitle ??
              'Long easy climb blocks';
        case 'template_stairmaster_intermediate_1_subtitle':
          return (l10n as dynamic).templateStairmasterIntermediate1Subtitle ??
              '2:1 climb repeats';
        case 'template_stairmaster_intermediate_2_subtitle':
          return (l10n as dynamic).templateStairmasterIntermediate2Subtitle ??
              'Strong 1:1 intervals';
        case 'template_stairmaster_advanced_1_subtitle':
          return (l10n as dynamic).templateStairmasterAdvanced1Subtitle ??
              '2-min hard blocks';
        case 'template_stairmaster_advanced_2_subtitle':
          return (l10n as dynamic).templateStairmasterAdvanced2Subtitle ??
              '30s sprints + 60s recoveries';
        // Legacy support (backward compatibility)
        case 'template_treadmill_beginner_subtitle':
          return (l10n as dynamic).templateTreadmillBeginner1Subtitle ??
              'Perfect for beginners';
        case 'template_treadmill_intermediate_subtitle':
          return (l10n as dynamic).templateTreadmillIntermediate1Subtitle ??
              'Build endurance';
        case 'template_treadmill_advanced_subtitle':
          return (l10n as dynamic).templateTreadmillAdvanced1Subtitle ??
              'High intensity workout';
        case 'template_cycle_beginner_subtitle':
          return (l10n as dynamic).templateCycleBeginner1Subtitle ??
              '4 min warm-up + 1:1 cadence';
        case 'template_cycle_intermediate_subtitle':
          return (l10n as dynamic).templateCycleIntermediate1Subtitle ??
              'Classic 1:1 spin intervals';
        case 'template_cycle_advanced_subtitle':
          return (l10n as dynamic).templateCycleAdvanced1Subtitle ??
              '30s power bursts';
        case 'template_stairmaster_beginner_subtitle':
          return (l10n as dynamic).templateStairmasterBeginner1Subtitle ??
              '4 min warm-up + 1:1 steps';
        case 'template_stairmaster_intermediate_subtitle':
          return (l10n as dynamic).templateStairmasterIntermediate1Subtitle ??
              '2:1 climb repeats';
        case 'template_stairmaster_advanced_subtitle':
          return (l10n as dynamic).templateStairmasterAdvanced1Subtitle ??
              '2-min hard blocks';
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
                        (() {
                          try {
                            return (l10n as dynamic).noTemplatesFound ??
                                'No templates found';
                          } catch (e) {
                            return 'No templates found';
                          }
                        })(),
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
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      BidiSafeText(
                        template.totalDurationFormatted,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
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
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
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
