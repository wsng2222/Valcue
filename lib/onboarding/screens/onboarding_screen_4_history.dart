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
                const SizedBox(height: 22), // Consistent spacing
                _HistoryListMock(strings: s),
              ],
            ),
          ),
        );
      },
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
          _HistoryCard(
            title: items[i].title,
            subtitle: items[i].subtitle,
            icon: icons[i],
          ),
          if (i != items.length - 1) const SizedBox(height: 10), // Reduced from 12
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), // Reduced from (14, 14)
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
              color: isDark ? OnboardingTheme.darkSelectedPink : OnboardingTheme.selectedPink,
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
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600, // Reduced from w700
                    letterSpacing: -0.2,
                    color: theme.colorScheme.onSurface.withOpacity(0.50),
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
