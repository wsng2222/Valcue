import 'package:flutter/material.dart';

import '../widgets/onboarding_emphasis_text.dart';
import '../widgets/onboarding_theme.dart';
import '../onboarding_strings.dart';

class OnboardingScreen4History extends StatelessWidget {
  const OnboardingScreen4History({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final s = OnboardingStrings.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
                const SizedBox(height: 60), // Adjusted for consistency
                OnboardingRichTitle(spans: s.s4TitleSpans()),
                const SizedBox(height: 20),

                // Mock Heatmap Grid
                _MockHeatmap(isDark: isDark, strings: s),
                const SizedBox(height: 26), // Consistent spacing

                _HistoryListMock(strings: s),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MockHeatmap extends StatelessWidget {
  final bool isDark;
  final OnboardingStrings strings;

  const _MockHeatmap({required this.isDark, required this.strings});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const baseColor = OnboardingTheme.primaryRed;

    // Define a 12 columns x 7 rows mock workout count matrix.
    // 0 = no workout, 1 = 1 workout, 2 = 2 workouts, 3 = 3+ workouts
    const List<List<int>> mockGrid = [
      [1, 0, 0, 2, 0, 1, 0],
      [0, 1, 0, 0, 3, 0, 0],
      [2, 0, 1, 0, 0, 1, 0],
      [0, 0, 0, 2, 0, 0, 1],
      [1, 0, 3, 0, 1, 0, 0],
      [0, 2, 0, 0, 0, 2, 0],
      [1, 0, 0, 1, 0, 1, 0],
      [0, 3, 0, 2, 0, 0, 2],
      [1, 0, 1, 0, 3, 0, 0],
      [0, 0, 0, 1, 0, 2, 0],
      [2, 0, 3, 0, 1, 0, 1],
      [0, 1, 0, 0, 0, 1, 0],
    ];

    Color getCellColor(int val) {
      if (val == 0) {
        return isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.grey.shade200;
      } else if (val == 1) {
        return baseColor.withValues(alpha: 0.35);
      } else if (val == 2) {
        return baseColor.withValues(alpha: 0.65);
      } else {
        return baseColor;
      }
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(OnboardingTheme.radiusLarge),
        border: Border.all(
          color: isDark ? const Color(0xFF3C3C3C) : const Color(0xFFE5E5EA),
          width: 0.8,
        ),
        boxShadow: [OnboardingTheme.subtleShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  strings.historyWeeklyConsistencyLabel(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  strings.historyWeekStreakLabel(12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: OnboardingTheme.primaryRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(mockGrid.length, (c) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                child: Column(
                  children: List.generate(7, (r) {
                    final val = mockGrid[c][r];
                    return Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(vertical: 2.0),
                      decoration: BoxDecoration(
                        color: getCellColor(val),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _HistoryListMock extends StatelessWidget {
  final OnboardingStrings strings;

  const _HistoryListMock({required this.strings});

  @override
  Widget build(BuildContext context) {
    final items = strings.historyItems();
    const icons = [
      Icons.directions_run,
      Icons.directions_run,
      Icons.directions_run,
      Icons.pedal_bike,
      Icons.stairs,
    ];

    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          _StaggeredAnimation(
            index: i,
            child: _HistoryCard(
              title: items[i].title,
              subtitle: items[i].subtitle,
              icon: icons[i],
            ),
          ),
          if (i != items.length - 1)
            const SizedBox(height: 10), // Reduced from 12
        ],
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _HistoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 12), // Reduced from (14, 14)
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(OnboardingTheme.radiusMedium),
        border: Border.all(
          color: isDark ? const Color(0xFF3C3C3C) : const Color(0xFFF0F0F0),
          width: 0.8,
        ),
        boxShadow: [OnboardingTheme.subtleShadow],
      ),
      child: Row(
        children: [
          Container(
            width: 40, // Reduced from 44 for more compact feel
            height: 40, // Reduced from 44
            decoration: BoxDecoration(
              color: isDark
                  ? OnboardingTheme.darkSelectedPink
                  : OnboardingTheme.selectedPink,
              borderRadius: BorderRadius.circular(OnboardingTheme.radiusSmall),
            ),
            child: Icon(
              icon,
              color: OnboardingTheme.primaryRed,
              size: 20, // Reduced from 22
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14, // Reduced from 15
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4), // Reduced from 6
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600, // Reduced from w700
                    letterSpacing: -0.2,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StaggeredAnimation extends StatefulWidget {
  final int index;
  final Widget child;

  const _StaggeredAnimation({
    required this.index,
    required this.child,
  });

  @override
  State<_StaggeredAnimation> createState() => _StaggeredAnimationState();
}

class _StaggeredAnimationState extends State<_StaggeredAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    Future.delayed(Duration(milliseconds: 100 + widget.index * 60), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
