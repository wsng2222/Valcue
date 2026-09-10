import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../../app_settings/app_settings_provider.dart';
import '../../../app_shell/app_shell.dart';
import '../models/achievement_translations.dart';
import '../widgets/workout_history_tab.dart';
import '../widgets/calendar_tab.dart';
import '../widgets/achievements_tab.dart';
import '../widgets/weight_tab.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedMachineTab = 0; // 0: Treadmill, 1: Bike, 2: Stairmaster

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header - same style as Settings screen
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(
                        alpha: 0.10,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 22,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      AppLocalizations.of(context)!.myTab,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lato(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.9,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Tabs: Workout History, Calendar, Achievements, Weight
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  child: Text(
                    AppLocalizations.of(context)!.historyTab,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Tab(
                  child: Text(
                    AppLocalizations.of(context)!.calendarTab,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Tab(
                  child: Text(
                    AchievementTranslations.getUiString(
                      'tab_achievements',
                      Localizations.localeOf(context).languageCode,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Tab(
                  child: Text(
                    AppLocalizations.of(context)!.weightTab,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.extension<AppColors>()!.mutedText,
              indicatorColor: theme.colorScheme.primary,
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
            ),
            // Tab content
            Expanded(
              child: Consumer<AppSettingsProvider>(
                builder: (context, settingsProvider, child) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      WorkoutHistoryTab(
                        selectedMachineTab: _selectedMachineTab,
                        onMachineTabChanged: (i) =>
                            setState(() => _selectedMachineTab = i),
                      ),
                      const CalendarTab(),
                      const AchievementsTab(),
                      Stack(
                        children: [
                          const WeightTab(),
                          if (!settingsProvider.isPremium)
                            _buildPremiumLockOverlay(context),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumLockOverlay(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned.fill(
      child: Container(
        color: theme.scaffoldBackgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_fire_department,
                size: 80,
                color: theme.extension<AppColors>()!.mutedText,
              ),
              const SizedBox(height: 24),
              Text(
                AppLocalizations.of(context)!.premium,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)!.premiumFeature,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.extension<AppColors>()!.mutedText,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  AppShell.navigateToPremiumTab();
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
        ),
      ),
    );
  }
}

// Workout History Tab
