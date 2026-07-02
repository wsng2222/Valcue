import 'dart:async';
import 'package:flutter/material.dart' hide Interval;
import 'package:provider/provider.dart';
import 'package:interval_cardio/l10n/app_localizations.dart';
import '../models/routine_template.dart';
import '../models/routine.dart';
import '../models/interval.dart';
import '../models/machine_type.dart';
import '../models/difficulty.dart';
import '../storage/routine_provider.dart';
import '../../../app_settings/app_settings_provider.dart';
import '../../../app_shell/app_shell.dart';
import '../../../widgets/bidi_safe_text.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/app_shadows.dart';
import '../../membership/widgets/premium_bottom_sheet.dart';

enum _RoutinePreviewResult {
  saved,
  upgrade,
}

class RoutinePreviewSheet {
  static void _showSnack(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    // Intentionally disabled per request.
  }

  static void show(
    BuildContext context,
    RoutineTemplate template,
    AppSettingsProvider settingsProvider, {
    bool closeParentOnSave = true,
  }) {
    final theme = Theme.of(context);
    showModalBottomSheet<_RoutinePreviewResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: theme.colorScheme.shadow.withValues(alpha: 0.4),
      isDismissible: true,
      builder: (sheetContext) => _RoutinePreviewSheetContent(
        template: template,
        settingsProvider: settingsProvider,
      ),
    ).then((result) {
      if (!context.mounted || result == null) {
        return;
      }

      if (result == _RoutinePreviewResult.saved) {
        final l10n = AppLocalizations.of(context)!;
        String routineSavedMessage() {
          try {
            return (l10n as dynamic).routineSaved ?? 'Routine saved';
          } catch (e) {
            return 'Routine saved';
          }
        }

        _showSnack(context, routineSavedMessage());
      }

      if (closeParentOnSave && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (result == _RoutinePreviewResult.upgrade) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppShell.navigateToPremiumTab();
        });
      }
    });
  }
}

class _ToastOverlay extends StatefulWidget {
  final String message;
  final Duration duration;
  final VoidCallback onDismissed;

  const _ToastOverlay({
    required this.message,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
    });

    _timer = Timer(widget.duration, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _visible = false;
      });
      const fadeOut = Duration(milliseconds: 200);
      Timer(fadeOut, () {
        if (mounted) {
          widget.onDismissed();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final snackTheme = theme.snackBarTheme;
    final media = MediaQuery.of(context);
    final behavior = snackTheme.behavior ?? SnackBarBehavior.fixed;
    final isFloating = behavior == SnackBarBehavior.floating;
    final margin = snackTheme.insetPadding ??
        const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 10.0);
    final padding = EdgeInsets.symmetric(
      horizontal: isFloating ? 16.0 : 24.0,
      vertical: 14.0,
    );
    final width = snackTheme.width;
    final elevation = snackTheme.elevation ?? 6.0;
    final backgroundColor =
        snackTheme.backgroundColor ?? theme.colorScheme.inverseSurface;
    final textStyle = snackTheme.contentTextStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onInverseSurface,
        );
    final shape = snackTheme.shape ??
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        );

    final bottomOffset = media.padding.bottom +
        media.viewInsets.bottom +
        (isFloating ? margin.bottom : 0);
    final left = isFloating ? margin.left : 0.0;
    final right = isFloating ? margin.right : 0.0;

    Widget toast = Material(
      color: backgroundColor,
      elevation: elevation,
      shape: shape,
      child: Padding(
        padding: padding,
        child: Text(
          widget.message,
          style: textStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );

    if (isFloating && width != null) {
      toast = Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(width: width, child: toast),
      );
    }

    return Positioned(
      left: left,
      right: right,
      bottom: bottomOffset,
      child: IgnorePointer(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          opacity: _visible ? 1.0 : 0.0,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            offset: _visible ? Offset.zero : const Offset(0, 0.05),
            child: toast,
          ),
        ),
      ),
    );
  }
}

class _RoutinePreviewSheetContent extends StatelessWidget {
  final RoutineTemplate template;
  final AppSettingsProvider settingsProvider;

  const _RoutinePreviewSheetContent({
    required this.template,
    required this.settingsProvider,
  });

  String _getLocalizedTitle(AppLocalizations l10n) {
    try {
      switch (template.titleKey) {
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
      return 'Untitled Routine';
    }
  }

  String _getLocalizedSubtitle(AppLocalizations l10n) {
    try {
      switch (template.subtitleKey) {
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

  String _getDifficultyText(AppLocalizations l10n, Difficulty difficulty) {
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

  IconData _getMachineIcon(MachineType machineType) {
    switch (machineType) {
      case MachineType.treadmill:
        return Icons.directions_run;
      case MachineType.cycle:
        return Icons.pedal_bike;
      case MachineType.stairmaster:
        return Icons.stairs_rounded;
    }
  }

  bool _isTemplateSaved(RoutineProvider provider) {
    return provider.routines.any(
      (r) => r.source == 'recommended' && r.templateId == template.id,
    );
  }

  void _showFreeLimitSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    PremiumBottomSheet.show(
      context,
      title: l10n.premiumMembership,
      bulletItems: [
        (l10n as dynamic).routineLimitBenefit1 ?? l10n.benefitUnlimitedRoutines,
        (l10n as dynamic).routineLimitBenefit2 ?? '여러 목표별 루틴 저장',
        (l10n as dynamic).routineLimitBenefit3 ?? '러닝머신/사이클/천국의 계단 루틴 모두 사용',
      ],
      onPrimary: () {
        // Close premium sheet first
        Navigator.pop(context);
        // Close preview sheet on next frame to avoid double-pop glitches
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            Navigator.pop(context, _RoutinePreviewResult.upgrade);
          }
        });
      },
    );
  }

  Future<void> _saveTemplate(BuildContext context) async {
    final provider = Provider.of<RoutineProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    String routineAlreadySavedMessage() {
      try {
        return (l10n as dynamic).routineAlreadySaved ?? 'Routine already saved';
      } catch (e) {
        return 'Routine already saved';
      }
    }

    // Check if already saved
    if (_isTemplateSaved(provider)) {
      if (context.mounted) {
        RoutinePreviewSheet._showSnack(
          context,
          routineAlreadySavedMessage(),
          duration: const Duration(seconds: 1),
        );
        Navigator.pop(context);
      }
      return;
    }

    // Check free limit when saving treadmill routine
    if (template.machineType == MachineType.treadmill &&
        !settingsProvider.isPremium &&
        provider.routines
                .where((r) => r.machineType == MachineType.treadmill)
                .length >=
            2) {
      _showFreeLimitSheet(context);
      return;
    }

    // Create routine from template
    // IMPORTANT: Generate stable, unique IDs for each interval
    // Use routine ID + index to ensure uniqueness and stability
    final routineId = DateTime.now().millisecondsSinceEpoch.toString();
    final intervals = template.intervals.asMap().entries.map((entry) {
      final index = entry.key;
      final i = entry.value;
      // Generate stable ID: routineId_index (e.g., "1234567890_0", "1234567890_1")
      final stableId = '${routineId}_$index';

      if (template.machineType == MachineType.treadmill) {
        return Interval.treadmill(
          id: stableId, // Use stable ID based on routine ID and index
          durationSeconds: i.durationSeconds,
          speedKmh: i.speedKmh!,
          grade: i.grade!,
        );
      } else if (template.machineType == MachineType.cycle) {
        return Interval.cycle(
          id: stableId, // Use stable ID based on routine ID and index
          durationSeconds: i.durationSeconds,
          rpm: i.rpm!,
          resistance: i.resistance!,
        );
      } else {
        return Interval.stairmaster(
          id: stableId, // Use stable ID based on routine ID and index
          durationSeconds: i.durationSeconds,
          level: i.level!,
        );
      }
    }).toList();

    final title = _getLocalizedTitle(l10n);

    final routine = Routine(
      id: routineId, // Use the same ID that was used for interval IDs
      name: title,
      difficulty: template.difficulty.toJson(),
      intervals: intervals,
      machineType: template.machineType,
      source: 'recommended',
      templateId: template.id,
    );

    // Save routine
    await provider.addRoutine(routine);

    if (context.mounted) {
      // Close the bottom sheet and return result to parent
      Navigator.pop(context, _RoutinePreviewResult.saved);
    }
  }

  Widget _buildIntervalRow(
    BuildContext context,
    Interval interval,
    MachineType machineType,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final isDark = theme.brightness == Brightness.dark;
    final layeredSurfaceColor =
        isDark ? appColors.surfaceElevated : const Color(0xFFF2F2F7);
    final chipSurfaceColor = isDark ? const Color(0xFF3C3C3C) : Colors.white;
    String? pill1Text;
    String? pill2Text;

    switch (machineType) {
      case MachineType.treadmill:
        if (interval.speedKmh != null && interval.grade != null) {
          pill1Text = settingsProvider.formatSpeed(interval.speedKmh!);
          pill2Text = '${interval.grade!.toStringAsFixed(1)}% ${l10n.incline}';
        }
        break;
      case MachineType.cycle:
        if (interval.rpm != null && interval.resistance != null) {
          pill1Text = '${interval.rpm} ${l10n.rpm}';
          pill2Text = 'Level ${interval.resistance!}';
        }
        break;
      case MachineType.stairmaster:
        if (interval.level != null) {
          pill1Text = 'Level ${interval.level!}';
          pill2Text = null;
        }
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: layeredSurfaceColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : appColors.border,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: chipSurfaceColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: BidiSafeText(
                    interval.durationFormatted,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    forceLTR: true,
                  ),
                ),
                if (pill1Text != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: chipSurfaceColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: BidiSafeText(
                      pill1Text,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
                if (pill2Text != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: chipSurfaceColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: BidiSafeText(
                      pill2Text,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.9;
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<RoutineProvider>(context);
    final isSaved = _isTemplateSaved(provider);
    final theme = Theme.of(context);
    final appColors = context.appColors;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.08)
              : appColors.border,
        ),
        boxShadow: AppShadows.elevatedSoft,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Content (scrollable)
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getMachineIcon(template.machineType),
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getDifficultyText(l10n, template.difficulty),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    _getLocalizedTitle(l10n),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.7,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  if (_getLocalizedSubtitle(l10n).isNotEmpty)
                    Text(
                      _getLocalizedSubtitle(l10n),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: appColors.mutedText,
                        letterSpacing: -0.2,
                      ),
                    ),
                  if (_getLocalizedSubtitle(l10n).isNotEmpty)
                    const SizedBox(height: 16),
                  // Total duration (always LTR for timers)
                  BidiSafeText(
                    template.totalDurationFormatted,
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -1.2,
                    ),
                    forceLTR: true, // Timers must always be LTR
                  ),
                  const SizedBox(height: 24),
                  // Interval rows
                  ...template.intervals.map((interval) {
                    return _buildIntervalRow(
                      context,
                      interval,
                      template.machineType,
                    );
                  }),
                  // Bottom padding for save button
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
          // Bottom fixed save button
          Container(
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.08)
                      : appColors.border,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaved ? null : () => _saveTemplate(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  disabledBackgroundColor: appColors.surfaceElevated,
                  disabledForegroundColor: appColors.mutedText,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  (() {
                    try {
                      return isSaved
                          ? (l10n as dynamic).saved ?? 'Saved'
                          : (l10n as dynamic).saveRoutine ?? 'Save Routine';
                    } catch (e) {
                      return isSaved ? 'Saved' : 'Save Routine';
                    }
                  })(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
