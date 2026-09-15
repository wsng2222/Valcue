import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'package:valcue/l10n/localized_format.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/routine.dart';
import '../models/machine_type.dart';
import '../models/difficulty.dart';
import '../models/routine_template.dart';
import '../data/routine_templates.dart';
import '../storage/routine_provider.dart';
import '../../../app_settings/app_settings_provider.dart';
import '../../../app_shell/app_shell.dart';
import '../../../onboarding/onboarding_storage.dart';
import '../../../widgets/bidi_safe_text.dart';
import '../../../widgets/platform_icon.dart';
import 'routine_bottom_sheet.dart';
import 'ai_routine_generator_sheet.dart';
import '../utils/routine_sharing.dart';
import '../utils/custom_routine_generator.dart';
import '../utils/interval_intensity.dart';
import 'qr_scanner_screen.dart';
import 'recommended_routines_screen.dart';
import 'routine_preview_sheet.dart';
import '../../../theme/app_theme.dart';
import '../../membership/widgets/premium_bottom_sheet.dart';
import '../../../widgets/bounceable.dart';
import '../../../widgets/app_dialog.dart';
import '../../../services/analytics_service.dart';
import '../../../widgets/app_segmented_control.dart';
import '../../../widgets/app_message.dart';
import '../../../widgets/valcue_ui.dart';

Color _segmentedSelectedBackground(BuildContext context) {
  return appSegmentedSelectedBackground(context);
}

SegmentedButtonThemeData _segmentedThemeData(
  BuildContext context,
  Color selectedBackground,
) {
  return appSegmentedThemeData(context, selectedBackground);
}

Widget _buildPlatformSegmentedControl({
  required Key key,
  required List<String> labels,
  required int selectedIndex,
  required ValueChanged<int> onValueChanged,
  required double height,
  Color? color,
}) {
  return AppSegmentedControl(
    key: key,
    labels: labels,
    selectedIndex: selectedIndex,
    onValueChanged: onValueChanged,
    height: height,
    color: color,
  );
}

class RoutineListScreen extends StatefulWidget {
  const RoutineListScreen({super.key});

  // Global key to access RoutineListScreen state from anywhere
  static final GlobalKey<State<RoutineListScreen>> globalKey =
      GlobalKey<State<RoutineListScreen>>();

  // Static variable to store the target machine type for navigation
  static MachineType? targetMachineType;

  static void navigateToMachineTypeIfReady(MachineType machineType) {
    final state = globalKey.currentState;
    if (state is _RoutineListScreenState) {
      state.navigateToMachineType(machineType);
    }
  }

  @override
  State<RoutineListScreen> createState() => _RoutineListScreenState();
}

class _RoutineListScreenState extends State<RoutineListScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  Difficulty? _preferredDifficulty;

  @override
  void initState() {
    super.initState();
    _loadPreferredDifficulty();
    // Check if there's a target machine type to navigate to
    final targetType = RoutineListScreen.targetMachineType;
    int initialPage = 0;
    if (targetType != null) {
      switch (targetType) {
        case MachineType.treadmill:
          initialPage = 0;
          break;
        case MachineType.cycle:
          initialPage = 1;
          break;
        case MachineType.stairmaster:
          initialPage = 2;
          break;
      }
      RoutineListScreen.targetMachineType = null; // Clear after use
    }
    _currentPage = initialPage;
    _pageController = PageController(initialPage: initialPage);
  }

  Future<void> _loadPreferredDifficulty() async {
    final level = await OnboardingStorage.getLevel();
    if (!mounted) return;
    setState(() {
      _preferredDifficulty = _mapLevelToDifficulty(
        level ?? OnboardingLevel.intermediate,
      );
    });
  }

  Difficulty _mapLevelToDifficulty(OnboardingLevel level) {
    switch (level) {
      case OnboardingLevel.beginner:
        return Difficulty.beginner;
      case OnboardingLevel.intermediate:
        return Difficulty.intermediate;
      case OnboardingLevel.advanced:
        return Difficulty.advanced;
    }
  }

  Future<void> _scanQrCode(BuildContext context) async {
    final routineProvider =
        Provider.of<RoutineProvider>(context, listen: false);
    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    final scannedLink = await QrScannerScreen.startScanner(context);
    if (scannedLink == null || !context.mounted) return;

    // Parse the scanned link and show the import dialog
    final routine = await RoutineSharing.parseShareLink(scannedLink);
    if (routine == null || !context.mounted) return;

    // Limit check for Treadmill free users
    if (routine.machineType == MachineType.treadmill &&
        !settingsProvider.isPremium &&
        routineProvider.routines
                .where((r) => r.machineType == MachineType.treadmill)
                .length >=
            2) {
      showAppDialog<void>(
        context: context,
        builder: (dialogContext) => AppDialog(
          icon: Icons.lock_outline_rounded,
          title: l10n.routineLimitReached,
          message: l10n.routineLimitMessage,
          actions: [
            AppDialogAction(
              label: l10n.ok,
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        ),
      );
      return;
    }

    // Show import confirmation dialog
    showAppDialog<void>(
      context: context,
      builder: (dialogContext) => AppDialog(
        icon: Icons.download_rounded,
        title: l10n.importSharedRoutine,
        message: l10n.importQrRoutinePrompt(
          routine.name,
          _getLocalizedDifficulty(context, routine.difficulty),
          LocalizedFormat.decimal(
            context,
            routine.intervals.length,
            decimalDigits: 0,
          ),
        ),
        actions: [
          AppDialogAction(
            label: l10n.cancel,
            style: AppDialogActionStyle.secondary,
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          AppDialogAction(
            label: l10n.importAction,
            onPressed: () async {
              await routineProvider.addRoutine(routine);
              AnalyticsService.instance.logEvent(
                'routine_imported',
                {
                  'method': 'qr',
                  'machine_type': routine.machineType.name,
                  'interval_count': routine.intervals.length,
                },
              );
              if (!context.mounted || !dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();

              showAppMessage(
                context,
                l10n.importRoutineSuccess(routine.name),
                type: AppMessageType.success,
              );
            },
          ),
        ],
      ),
    );
  }

  // Method to navigate to specific machine type page
  void navigateToMachineType(MachineType machineType) {
    int pageIndex;
    switch (machineType) {
      case MachineType.treadmill:
        pageIndex = 0;
        break;
      case MachineType.cycle:
        pageIndex = 1;
        break;
      case MachineType.stairmaster:
        pageIndex = 2;
        break;
    }
    _pageController.jumpToPage(pageIndex);
    setState(() {
      _currentPage = pageIndex;
    });
  }

  List<String> _getMachineTitles(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.treadmill,
      l10n.cycle,
      l10n.stairmaster,
    ];
  }

  Widget _buildMachineSegmentedControl(BuildContext context) {
    final titles = _getMachineTitles(context);
    final selectedIndex = _currentPage.clamp(0, titles.length - 1);
    final selectedBg = _segmentedSelectedBackground(context);

    final brightnessKey = Theme.of(context).brightness;
    final localeKey = Localizations.localeOf(context).toLanguageTag();
    return SegmentedButtonTheme(
      data: _segmentedThemeData(context, selectedBg),
      child: SizedBox(
        width: double.infinity,
        child: _buildPlatformSegmentedControl(
          key: ValueKey('machine_segment_${brightnessKey.name}_$localeKey'),
          labels: titles,
          selectedIndex: selectedIndex,
          onValueChanged: (index) {
            if (_currentPage == index) return;
            final currentPage = _pageController.hasClients
                ? (_pageController.page ?? _currentPage.toDouble())
                : _currentPage.toDouble();
            final distance = (currentPage - index).abs();
            final durationMs =
                (220 + (120 * distance)).clamp(260, 420).round();
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: durationMs),
              curve: Curves.easeInOutCubic,
            );
          },
          height: 44,
          color: selectedBg,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleAddRoutine(BuildContext context, MachineType machineType) {
    HapticFeedback.lightImpact();
    final routineProvider =
        Provider.of<RoutineProvider>(context, listen: false);
    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    // Check free limit when adding new treadmill routine
    if (machineType == MachineType.treadmill &&
        !settingsProvider.isPremium &&
        routineProvider.routines
                .where((r) => r.machineType == MachineType.treadmill)
                .length >=
            2) {
      _showFreeLimitSheet(context);
      return;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(l10n.addRoutineOption),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              RoutineBottomSheet.show(
                context,
                initialEditing: true,
                isNew: true,
                machineType: machineType,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.edit_outlined, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    l10n.createCustomRoutine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              AiRoutineGeneratorSheet.show(context, machineType);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome,
                    size: 20, color: Colors.blueAccent),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    l10n.customRoutineBuilder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              // Trigger manual check
              RoutineSharing
                  .resetLastProcessedLink(); // Reset tracking so it always triggers
              RoutineSharing.checkClipboardAndImport(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.content_paste_go, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    l10n.importFromClipboard,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ),
    );
  }

  void _navigateToRecommendedRoutines(
      BuildContext context, MachineType machineType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecommendedRoutinesScreen(
          machineType: machineType,
        ),
      ),
    );
  }

  Widget _buildRecommendedButton(
      BuildContext context, MachineType machineType) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Center(
      child: GestureDetector(
        onTap: () => _navigateToRecommendedRoutines(context, machineType),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
          decoration: BoxDecoration(
            color: context.appColors.tint,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '${l10n.viewRecommendedRoutines} →',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, MachineType machineType) {
    final theme = Theme.of(context);
    return Center(
      child: GestureDetector(
        onTap: () => _handleAddRoutine(context, machineType),
        child: Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: PlatformIcon(
            cupertino: CupertinoIcons.add,
            material: Icons.add,
            color: theme.colorScheme.surface,
            size: 36,
          ),
        ),
      ),
    );
  }

  void _showFreeLimitSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    PremiumBottomSheet.show(
      context,
      title: l10n.premiumMembership,
      bulletItems: [
        l10n.routineLimitBenefit1,
        l10n.routineLimitBenefit2,
        l10n.routineLimitBenefit3,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Assign global key to this widget's state
    if (widget.key != RoutineListScreen.globalKey) {
      // This is a workaround - we'll use a different approach
    }
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: null, // Explicitly no AppBar
      body: SafeArea(
        bottom: false,
        child: Consumer2<RoutineProvider, AppSettingsProvider>(
          builder: (context, routineProvider, settingsProvider, child) {
            if (routineProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      kScreenGutter, 10, kScreenGutter, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TabTitleHeader(
                        icon: Icons.directions_run,
                        title: l10n.routineTab,
                        trailing: IconButton(
                          icon: const Icon(Icons.qr_code_scanner),
                          color: theme.colorScheme.onSurface,
                          iconSize: 26,
                          alignment: AlignmentDirectional.centerEnd,
                          padding: const EdgeInsetsDirectional.only(end: 4),
                          constraints: const BoxConstraints(
                            minWidth: 42,
                            minHeight: 42,
                          ),
                          tooltip: l10n.scanQrCode,
                          onPressed: () => _scanQrCode(context),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildMachineSegmentedControl(context),
                    ],
                  ),
                ),
                // PageView with 3 pages
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      // Page 0: 러닝머신 routines
                      _buildRoutinePage(
                        context,
                        routineProvider.routines
                            .where(
                                (r) => r.machineType == MachineType.treadmill)
                            .toList(),
                        settingsProvider,
                        MachineType.treadmill,
                      ),
                      // Page 1: 사이클 (premium gated)
                      _buildMachinePage(
                        context,
                        MachineType.cycle,
                        settingsProvider.isPremium,
                        routineProvider,
                        settingsProvider,
                      ),
                      // Page 2: 천국의 계단 (premium gated)
                      _buildMachinePage(
                        context,
                        MachineType.stairmaster,
                        settingsProvider.isPremium,
                        routineProvider,
                        settingsProvider,
                      ),
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

  Widget _buildRoutinePage(
    BuildContext context,
    List<Routine> routines,
    AppSettingsProvider settingsProvider,
    MachineType machineType,
  ) {
    return Column(
      children: [
        Expanded(
          child: routines.isEmpty
              ? _buildEmptyState(context, machineType, settingsProvider)
              : _buildRoutineList(
                  context, routines, settingsProvider, machineType),
        ),
      ],
    );
  }

  Widget _buildMachinePage(
    BuildContext context,
    MachineType machineType,
    bool isPremium,
    RoutineProvider routineProvider,
    AppSettingsProvider settingsProvider,
  ) {
    return Column(
      children: [
        Expanded(
          child: !isPremium
              ? _buildLockedScreen(context)
              : _buildContentForMachine(
                  context, machineType, routineProvider, settingsProvider),
        ),
      ],
    );
  }

  Widget _buildContentForMachine(
    BuildContext context,
    MachineType machineType,
    RoutineProvider routineProvider,
    AppSettingsProvider settingsProvider,
  ) {
    final routines = routineProvider.routines
        .where((r) => r.machineType == machineType)
        .toList();
    if (routines.isEmpty) {
      return _buildEmptyState(context, machineType, settingsProvider);
    }
    return _buildRoutineList(context, routines, settingsProvider, machineType);
  }

  Widget _buildLockedScreen(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 80,
            color: context.appColors.mutedText,
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.premium,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.premiumFeature,
            style: TextStyle(
              fontSize: 16,
              color: context.appColors.mutedText,
            ),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () {
              // Close any open bottom sheets/dialogs
              Navigator.of(context).popUntil((route) => route.isFirst);
              // Open the purchase screen directly after frame completes
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!context.mounted) return;
                AppShell.navigateToPremiumTab();
              });
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text(
              AppLocalizations.of(context)!.viewMembership,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    MachineType machineType,
    AppSettingsProvider settingsProvider,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final templates = RoutineTemplates.getTemplatesByMachine(machineType);
    final preferredDifficulty = _preferredDifficulty ?? Difficulty.intermediate;
    final difficultyTemplates = templates
        .where((template) => template.difficulty == preferredDifficulty)
        .toList();
    final previewTemplates =
        (difficultyTemplates.isNotEmpty ? difficultyTemplates : templates)
            .take(2)
            .toList();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        kScreenGutter,
        80,
        kScreenGutter,
        40 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.noRoutinesSaved,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.tapButtonToCreate,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: context.appColors.mutedText,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 24),
          _buildAddButton(context, machineType),
          if (previewTemplates.isNotEmpty) ...[
            const SizedBox(height: 80),
            Text(
              l10n.quickStart,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),
            for (final template in previewTemplates)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _buildTemplatePreviewCard(
                  context,
                  template,
                  settingsProvider,
                ),
              ),
          ],
          const SizedBox(height: 22),
          _buildRecommendedButton(context, machineType),
        ],
      ),
    );
  }

  Widget _buildTemplatePreviewCard(
    BuildContext context,
    RoutineTemplate template,
    AppSettingsProvider settingsProvider,
  ) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    void openPreview() {
      RoutinePreviewSheet.show(
        context,
        template,
        settingsProvider,
        closeParentOnSave: false,
      );
    }

    return Bounceable(
      onTap: openPreview,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: valcueCardDecoration(context, radius: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: appColors.tint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _machineIcon(template.machineType),
                    size: 24,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTemplateTitle(l10n, template),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getTemplateSubtitle(l10n, template),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: appColors.mutedText,
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
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: appColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.schedule,
                          size: 16, color: appColors.mutedText),
                      const SizedBox(width: 7),
                      BidiSafeText(
                        template.totalDurationFormatted,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                        forceLTR: true,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.32),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 26,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _machineIcon(MachineType machineType) {
    switch (machineType) {
      case MachineType.treadmill:
        return Icons.directions_run;
      case MachineType.cycle:
        return Icons.directions_bike;
      case MachineType.stairmaster:
        return Icons.stairs;
    }
  }

  String _getTemplateTitle(AppLocalizations l10n, RoutineTemplate template) {
    try {
      switch (template.titleKey) {
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
        default:
          return l10n.unnamedRoutine;
      }
    } catch (e) {
      return l10n.unnamedRoutine;
    }
  }

  String _getTemplateSubtitle(AppLocalizations l10n, RoutineTemplate template) {
    try {
      switch (template.subtitleKey) {
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
        default:
          return l10n.templateTreadmillBeginner1Subtitle;
      }
    } catch (e) {
      return l10n.templateTreadmillBeginner1Subtitle;
    }
  }

  Widget _buildRoutineList(
    BuildContext context,
    List<Routine> routines,
    AppSettingsProvider settingsProvider,
    MachineType machineType,
  ) {
    final isPremium = settingsProvider.isPremium;
    final shouldShowAddButton =
        machineType == MachineType.treadmill || isPremium;

    // Reserve just a small safe-area gap at the bottom (AdaptiveScaffold already pads)
    final bottomReserved = 16.0 + MediaQuery.of(context).padding.bottom;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
              kScreenGutter, 22, kScreenGutter, 0),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final routine = routines[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildRoutineCard(context, routine, settingsProvider),
                );
              },
              childCount: routines.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(top: 18, bottom: bottomReserved + 24),
            child: Column(
              children: [
                if (shouldShowAddButton) ...[
                  _buildAddButton(context, machineType),
                  const SizedBox(height: 22),
                ],
                _buildRecommendedButton(context, machineType),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoutineCard(BuildContext context, Routine routine,
      AppSettingsProvider settingsProvider) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final localizedDifficulty =
        _getLocalizedDifficulty(context, routine.difficulty);
    final sessionsText = '${routine.intervals.length} ${l10n.sessions}';
    final String amountText;
    final IconData amountIcon;
    switch (routine.machineType) {
      case MachineType.treadmill:
        amountIcon = Icons.straighten;
        amountText =
            _buildTotalDistanceText(context, routine, settingsProvider);
      case MachineType.cycle:
        amountIcon = Icons.straighten;
        amountText =
            _buildCycleDistanceText(context, routine, settingsProvider);
      case MachineType.stairmaster:
        amountIcon = Icons.stairs;
        amountText = _buildStairsFloorsText(context, routine);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: valcueCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  routine.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.42,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ValcueChip(
                icon: Icons.bolt,
                text: localizedDifficulty,
                muted: true,
                fontSize: 14,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BidiSafeText(
            routine.totalDurationFormatted,
            style: TextStyle(
              fontSize: 46,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              letterSpacing: -1.84,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            forceLTR: true, // Timers must always be LTR
          ),
          const SizedBox(height: 14),
          _buildIntervalPatternBar(context, routine),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              ValcueChip(icon: amountIcon, text: amountText),
              ValcueChip(icon: Icons.repeat, text: sessionsText),
            ],
          ),
          const SizedBox(height: 18),
          PrimaryPillButton(
            label: l10n.checkRoutineStart,
            italic: true,
            onPressed: () {
              RoutineBottomSheet.show(context, routine: routine);
            },
          ),
        ],
      ),
    );
  }

  String _buildTotalDistanceText(
    BuildContext context,
    Routine routine,
    AppSettingsProvider settings,
  ) {
    double totalKm = 0;
    for (final interval in routine.intervals) {
      if (interval.speedKmh != null) {
        totalKm += interval.speedKmh! * (interval.durationSeconds / 3600.0);
      }
    }
    if (settings.measurement == 'kmh') {
      return '${LocalizedFormat.decimal(context, totalKm, decimalDigits: 2)} km';
    } else {
      return '${LocalizedFormat.decimal(context, totalKm / 1.609344, decimalDigits: 2)} mi';
    }
  }

  String _buildCycleDistanceText(
    BuildContext context,
    Routine routine,
    AppSettingsProvider settings,
  ) {
    final totalKm = cycleDistanceKm(routine.intervals);
    if (settings.measurement == 'kmh') {
      return '${LocalizedFormat.decimal(context, totalKm, decimalDigits: 2)} km';
    } else {
      return '${LocalizedFormat.decimal(context, totalKm / 1.609344, decimalDigits: 2)} mi';
    }
  }

  String _buildStairsFloorsText(BuildContext context, Routine routine) {
    final l10n = AppLocalizations.of(context)!;
    final floors = stairmasterFloorsClimbed(routine.intervals).round();
    return l10n.floorCount(
      LocalizedFormat.decimal(context, floors, decimalDigits: 0),
    );
  }

  Widget _buildIntervalPatternBar(BuildContext context, Routine routine) {
    if (routine.intervals.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hardColor = theme.colorScheme.primary;
    final easyColor =
        isDark ? const Color(0x59EF5350) : const Color(0xFFFFCDD2);

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 10,
        child: Row(
          children: [
            for (final interval in routine.intervals)
              Expanded(
                flex: (interval.durationSeconds / 20).round().clamp(1, 1 << 20),
                child: ColoredBox(
                  color: isHardInterval(interval) ? hardColor : easyColor,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedDifficulty(
      BuildContext context, String storedDifficulty) {
    final l10n = AppLocalizations.of(context)!;
    final difficultyStorageValues = ['쉬움', '중간', '높음'];
    final difficultyDisplayValues = [l10n.easy, l10n.medium, l10n.hard];

    final index = difficultyStorageValues.indexOf(storedDifficulty);
    if (index >= 0 && index < difficultyDisplayValues.length) {
      return difficultyDisplayValues[index];
    }
    // Fallback to stored value if not found
    return storedDifficulty;
  }
}
