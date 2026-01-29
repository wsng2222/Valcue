import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:interval_cardio/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import '../features/routines/screens/routine_list_screen.dart';
import '../features/routines/models/machine_type.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../app_settings/app_settings_provider.dart';
import '../ui/glass/liquid_glass_pill_navbar.dart';
import '../theme/app_theme.dart';

// Extension to provide fallback for new localization keys until code generation runs
extension AppLocalizationsExtension on AppLocalizations {
  String get premiumHeadline {
    try {
      return (this as dynamic).premiumHeadline ?? '같은 30분, 결과는 다르게';
    } catch (_) {
      return '같은 30분, 결과는 다르게';
    }
  }

  String get premiumSubheadlineNew {
    try {
      return (this as dynamic).premiumSubheadlineNew ??
          '그냥 뛰지 말고, 살 빠지는 방식으로 운동해';
    } catch (_) {
      return '그냥 뛰지 말고, 살 빠지는 방식으로 운동해';
    }
  }

  String get mostPopular {
    try {
      return (this as dynamic).mostPopular ?? '가장 인기';
    } catch (_) {
      return '가장 인기';
    }
  }

  String get benefitVoiceCoaching {
    try {
      return (this as dynamic).benefitVoiceCoaching ?? '운동 중 자동 음성 코칭';
    } catch (_) {
      return '운동 중 자동 음성 코칭';
    }
  }

  String get benefitCycleStairmasterRoutines {
    try {
      return (this as dynamic).benefitCycleStairmasterRoutines ??
          '사이클 & 천국의 계단 루틴 사용';
    } catch (_) {
      return '사이클 & 천국의 계단 루틴 사용';
    }
  }

  String get benefitUnlimitedRoutinesNew {
    try {
      return (this as dynamic).benefitUnlimitedRoutinesNew ?? '루틴 무제한 저장';
    } catch (_) {
      return '루틴 무제한 저장';
    }
  }

  String get benefitNoAdsFocus {
    try {
      return (this as dynamic).benefitNoAdsFocus ?? '광고 없이 집중';
    } catch (_) {
      return '광고 없이 집중';
    }
  }

  String get benefitFutureFeaturesNew {
    try {
      return (this as dynamic).benefitFutureFeaturesNew ?? '추후 프리미엄 기능 전체 포함';
    } catch (_) {
      return '추후 프리미엄 기능 전체 포함';
    }
  }

  String get mostChosen {
    try {
      return (this as dynamic).mostChosen ?? '가장 많이 선택됨';
    } catch (_) {
      return '가장 많이 선택됨';
    }
  }

  String get canChangeAnytime {
    try {
      return (this as dynamic).canChangeAnytime ?? '언제든지 변경 가능';
    } catch (_) {
      return '언제든지 변경 가능';
    }
  }

  String get startPremium {
    try {
      return (this as dynamic).startPremium ?? '프리미엄 시작하기';
    } catch (_) {
      return '프리미엄 시작하기';
    }
  }

  String get cancelAnytimeKeepAccess {
    try {
      return (this as dynamic).cancelAnytimeKeepAccess ??
          '결제 후 바로 해지해도 기간 끝까지 이용 가능';
    } catch (_) {
      return '결제 후 바로 해지해도 기간 끝까지 이용 가능';
    }
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();

  // Global key to access AppShell state from anywhere
  static final GlobalKey<_AppShellState> globalKey =
      GlobalKey<_AppShellState>();

  // Method to navigate to Premium tab (index 0)
  static void navigateToPremiumTab() {
    // Try to navigate immediately
    final state = globalKey.currentState;
    if (state != null) {
      state._changeTab(0);
      return;
    }

    // If state is not available, try again after a short delay
    // This handles cases where the widget tree is still building
    Future.delayed(const Duration(milliseconds: 100), () {
      final retryState = globalKey.currentState;
      if (retryState != null) {
        retryState._changeTab(0);
      }
    });
  }

  // Method to navigate to Routine tab (index 1)
  static void navigateToRoutineTab() {
    final state = globalKey.currentState;
    if (state != null) {
      state._changeTab(1);
      return;
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      final retryState = globalKey.currentState;
      if (retryState != null) {
        retryState._changeTab(1);
      }
    });
  }

  // Method to navigate to Routine tab with specific machine type
  static void navigateToRoutineTabWithMachineType(MachineType machineType) {
    // Set the target machine type before navigating
    RoutineListScreen.targetMachineType = machineType;

    final state = globalKey.currentState;
    if (state != null) {
      state._changeTab(1);
      // If RoutineListScreen is already built, navigate immediately
      final routineState = RoutineListScreen.globalKey.currentState;
      if (routineState != null) {
        routineState.navigateToMachineType(machineType);
      }
      return;
    }

    // If state is null, set target and navigate when ready
    Future.microtask(() {
      final retryState = globalKey.currentState;
      if (retryState != null) {
        retryState._changeTab(1);
        final routineState = RoutineListScreen.globalKey.currentState;
        if (routineState != null) {
          routineState.navigateToMachineType(machineType);
        }
      }
    });
  }
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 1; // Default to Routine tab

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  final List<Widget> _screens = [
    const _PremiumScreen(),
    RoutineListScreen(key: RoutineListScreen.globalKey),
    const SettingsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        bottom: false, // Don't add extra padding - just use bottomMargin
        child: Consumer<AppSettingsProvider>(
          builder: (context, settingsProvider, child) {
            final l10n = AppLocalizations.of(context)!;
            final double bottomMargin = 12;

            return LiquidGlassPillNavBar(
              currentIndex: _currentIndex,
              onTap: _changeTab,
              bottomMargin: bottomMargin,
              items: [
                LiquidGlassNavItem(
                  icon: Icons.local_fire_department,
                  label: l10n.premiumTab,
                ),
                LiquidGlassNavItem(
                  icon: Icons.directions_run,
                  label: l10n.routineTab,
                ),
                LiquidGlassNavItem(
                  icon: Icons.settings,
                  label: l10n.settingsTab,
                ),
                LiquidGlassNavItem(
                  icon: Icons.person,
                  label: '',
                  iconSize: 28.0,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PremiumScreen extends StatefulWidget {
  const _PremiumScreen();

  @override
  State<_PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<_PremiumScreen> {
  late final _PlanSelectionNotifier _selectionNotifier;

  @override
  void initState() {
    super.initState();
    _selectionNotifier = _PlanSelectionNotifier();
  }

  @override
  void dispose() {
    _selectionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                const _PremiumHeroCard(),
                const SizedBox(height: 28),
                // Plan selector
                _PlanSelector(selectionNotifier: _selectionNotifier),
                const SizedBox(height: 32),
                // Benefits list
                const _BenefitsList(),
                const SizedBox(height: 32),
                // Supporting line above CTA (will be updated by _PlanSelector)
                _SupportingLine(selectionNotifier: _selectionNotifier),
                // Purchase button
                Consumer<AppSettingsProvider>(
                  builder: (context, provider, child) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement actual purchase flow
                          // For now, activate premium for testing
                          provider.updatePremium(true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!
                                  .premiumActivated),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.startPremium,
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Trust lines
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Column(
                      children: [
                        Text(
                          l10n.cancelAnytime,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: theme.extension<AppColors>()!.mutedText,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.cancelAnytimeKeepAccess,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: theme.extension<AppColors>()!.mutedText,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.autoRenewableSubscription,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: theme
                                .extension<AppColors>()!
                                .mutedText
                                .withValues(alpha: 0.7),
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Footer links
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _FooterLink(
                          text: l10n.terms,
                          onTap: () {
                            // TODO: Navigate to Terms
                          },
                        ),
                        Text(
                          ' • ',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.extension<AppColors>()!.mutedText,
                          ),
                        ),
                        _FooterLink(
                          text: l10n.privacy,
                          onTap: () {
                            // TODO: Navigate to Privacy
                          },
                        ),
                        Text(
                          ' • ',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.extension<AppColors>()!.mutedText,
                          ),
                        ),
                        _FooterLink(
                          text: l10n.restore,
                          onTap: () {
                            // TODO: Implement restore purchases
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.restore),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumHeroCard extends StatelessWidget {
  const _PremiumHeroCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final accent = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.18),
            theme.colorScheme.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_fire_department,
                  size: 22,
                  color: accent,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Premium',
                style: GoogleFonts.lato(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.premiumHeadline,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.4,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.premiumSubheadlineNew,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: theme.extension<AppColors>()!.mutedText,
              letterSpacing: -0.2,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _PremiumFeaturePill(
                icon: Icons.record_voice_over,
                text: l10n.benefitVoiceCoaching,
              ),
              _PremiumFeaturePill(
                icon: Icons.fitness_center,
                text: l10n.benefitCycleStairmasterRoutines,
              ),
              _PremiumFeaturePill(
                icon: Icons.bookmark_added,
                text: l10n.benefitUnlimitedRoutinesNew,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PremiumFeaturePill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PremiumFeaturePill({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final isDark = theme.brightness == Brightness.dark;
    final background =
        isDark ? const Color(0xFF2C2C2E) : Colors.white.withValues(alpha: 0.7);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: appColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Supporting line above CTA button
class _SupportingLine extends StatelessWidget {
  final _PlanSelectionNotifier selectionNotifier;

  const _SupportingLine({required this.selectionNotifier});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ValueListenableBuilder<PlanType>(
      valueListenable: selectionNotifier,
      builder: (context, selectedPlan, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            selectedPlan == PlanType.yearly ? l10n.mostChosen : l10n.canChangeAnytime,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.primary,
              letterSpacing: -0.1,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}

// Enum for plan selection
enum PlanType { monthly, yearly, lifetime }

// Shared state for plan selection
class _PlanSelectionNotifier extends ValueNotifier<PlanType> {
  _PlanSelectionNotifier() : super(PlanType.yearly); // Default to yearly
}

// Plan selector with Monthly, Yearly, and Lifetime options
class _PlanSelector extends StatefulWidget {
  final _PlanSelectionNotifier? selectionNotifier;

  const _PlanSelector({this.selectionNotifier});

  @override
  State<_PlanSelector> createState() => _PlanSelectorState();
}

class _PlanSelectorState extends State<_PlanSelector> {
  late _PlanSelectionNotifier _notifier;
  late PlanType _selectedPlan;

  @override
  void initState() {
    super.initState();
    _notifier = widget.selectionNotifier ?? _PlanSelectionNotifier();
    _selectedPlan = _notifier.value;
    _notifier.addListener(_onSelectionChanged);
  }

  @override
  void dispose() {
    if (widget.selectionNotifier == null) {
      _notifier.dispose();
    } else {
      _notifier.removeListener(_onSelectionChanged);
    }
    super.dispose();
  }

  void _onSelectionChanged() {
    setState(() {
      _selectedPlan = _notifier.value;
    });
  }

  // Pricing constants
  static const double monthlyPrice = 5700.0; // KRW
  static const double yearlyPrice = 49000.0; // KRW (8.6 months = ~28% savings)
  static const double lifetimePrice = 99000.0; // KRW (lifetime)

  int get _savingsPercent {
    const monthlyTotal = monthlyPrice * 12;
    return ((monthlyTotal - yearlyPrice) / monthlyTotal * 100).round();
  }

  int get _lifetimeSavingsPercent {
    const monthlyTotal = monthlyPrice * 12 * 5; // Compare to 5 years
    return ((monthlyTotal - lifetimePrice) / monthlyTotal * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Monthly plan (first option)
        _PlanCard(
          title: l10n.monthly,
          price: '5,700',
          period: l10n.perMonth,
          isSelected: _selectedPlan == PlanType.monthly,
          isPrimary: false,
          onTap: () {
            _notifier.value = PlanType.monthly;
          },
        ),
        const SizedBox(height: 16),
        // Yearly plan (second option with Most Popular badge)
        Stack(
          clipBehavior: Clip.none,
          children: [
            _PlanCard(
              title: l10n.yearly,
              price: '49,000',
              period: l10n.perYear,
              isSelected: _selectedPlan == PlanType.yearly,
              savingsPercent: _savingsPercent,
              badgeText: '가장 인기',
              isPrimary: true,
              onTap: () {
                _notifier.value = PlanType.yearly;
              },
            ),
            // "Most Popular" badge
            if (_selectedPlan == PlanType.yearly)
              Positioned(
                top: -8,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    l10n.mostPopular,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onPrimary,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        // Lifetime plan (third option with Best Value badge)
        Stack(
          clipBehavior: Clip.none,
          children: [
            _PlanCard(
              title: l10n.lifetime,
              price: '99,000',
              period: l10n.oneTime,
              isSelected: _selectedPlan == PlanType.lifetime,
              savingsPercent: _lifetimeSavingsPercent,
              badgeText: '최고 가치',
              isPrimary: true,
              onTap: () {
                _notifier.value = PlanType.lifetime;
              },
            ),
            // "Best Value" badge
            if (_selectedPlan == PlanType.lifetime)
              Positioned(
                top: -8,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    l10n.bestValue,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// Individual plan card
class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final bool isSelected;
  final int? savingsPercent;
  final String? badgeText;
  final bool isPrimary;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.period,
    required this.isSelected,
    this.savingsPercent,
    this.badgeText,
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appColors = theme.extension<AppColors>()!;

    // Card background color
    final cardColor = isDark
        ? const Color(0xFF1C1C1E) // Dark surface
        : Colors.grey.shade50;

    // Primary cards are slightly larger
    final cardPadding = isPrimary ? 24.0 : 20.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(cardPadding),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF2C2C2E) : Colors.white)
              : cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.grey.shade300),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Radio button / Check icon
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : appColors.mutedText,
                  width: 2,
                ),
                color:
                    isSelected ? theme.colorScheme.primary : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: theme.colorScheme.onPrimary,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // Plan details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isPrimary ? 18 : 17,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (savingsPercent != null) ...[
                        const SizedBox(width: 8),
                        Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                l10n.savePercent(savingsPercent!),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                  letterSpacing: -0.1,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        price,
                        style: GoogleFonts.lato(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'KRW',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: appColors.mutedText,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        period,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: appColors.mutedText,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Benefits list widget with loss-aversion wording
class _BenefitsList extends StatelessWidget {
  const _BenefitsList();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final benefits = [
      _BenefitItem(
        icon: Icons.record_voice_over,
        text: l10n.benefitVoiceCoaching,
      ),
      _BenefitItem(
        icon: Icons.fitness_center,
        text: l10n.benefitCycleStairmasterRoutines,
      ),
      _BenefitItem(
        icon: Icons.bookmark_added,
        text: l10n.benefitUnlimitedRoutinesNew,
      ),
      _BenefitItem(
        icon: Icons.monitor_weight,
        text: (l10n as dynamic).benefitWeightFeature ?? 'Weight tracking',
      ),
      _BenefitItem(
        icon: Icons.do_not_disturb_alt,
        text: l10n.benefitNoAdsFocus,
      ),
      _BenefitItem(
        icon: Icons.auto_awesome,
        text: l10n.benefitFutureFeaturesNew,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 2;
        const cardHeight = 118.0;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final item in benefits)
              SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: _BenefitCard(item: item),
              ),
          ],
        );
      },
    );
  }
}

class _BenefitItem {
  final IconData icon;
  final String text;

  const _BenefitItem({
    required this.icon,
    required this.text,
  });
}

class _BenefitCard extends StatelessWidget {
  final _BenefitItem item;

  const _BenefitCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final isDark = theme.brightness == Brightness.dark;
    final background =
        isDark ? const Color(0xFF1C1C1E) : Colors.grey.shade50;

    return Container(
      constraints: const BoxConstraints.expand(),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              size: 16,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: Text(
                item.text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: -0.2,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Footer link widget
class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _FooterLink({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: theme.colorScheme.primary,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}
