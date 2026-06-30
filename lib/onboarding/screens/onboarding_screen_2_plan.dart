import 'package:flutter/material.dart';

import '../widgets/onboarding_emphasis_text.dart';
import '../widgets/onboarding_theme.dart';
import '../onboarding_strings.dart';

class OnboardingScreen2Plan extends StatelessWidget {
  const OnboardingScreen2Plan({
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
                OnboardingRichTitle(spans: s.s2TitleSpans()),
                const SizedBox(height: 22), // Consistent spacing
                _PlanMockCard(strings: s),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlanMockCard extends StatelessWidget {
  final OnboardingStrings strings;

  const _PlanMockCard({required this.strings});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20), // Optimized padding
      decoration: BoxDecoration(
        color: isDark ? OnboardingTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(OnboardingTheme.radiusLarge),
        boxShadow: [OnboardingTheme.mediumShadow],
        border: Border.all(
          color:
              isDark ? OnboardingTheme.darkGrayFill : const Color(0xFFF0F0F0),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.planTotalWorkoutTimeLabel(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.50),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '12:00',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 18),
          _PlanRow(
            setLabel: strings.setLabel(1),
            time: '2:00',
            speed: '5.0km/h',
          ),
          const SizedBox(height: 10),
          _PlanRow(
            setLabel: strings.setLabel(2),
            time: '4:00',
            speed: '9.0km/h',
          ),
          const SizedBox(height: 10),
          _PlanRow(
            setLabel: strings.setLabel(3),
            time: '2:00',
            speed: '5.0km/h',
          ),
          const SizedBox(height: 10),
          _PlanRow(
            setLabel: strings.setLabel(4),
            time: '4:00',
            speed: '10.0km/h',
          ),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  final String setLabel;
  final String time;
  final String speed;

  const _PlanRow({
    required this.setLabel,
    required this.time,
    required this.speed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            setLabel,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const Spacer(),
        _Pill(text: time),
        const SizedBox(width: 10),
        _Pill(text: speed, isAccent: true),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final bool isAccent;

  const _Pill({
    required this.text,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: isAccent
            ? (isDark
                ? OnboardingTheme.darkSelectedPink
                : OnboardingTheme.selectedPink)
            : (isDark ? OnboardingTheme.darkGrayFill : const Color(0xFFF0F0F0)),
        borderRadius: BorderRadius.circular(OnboardingTheme.radiusPill),
        border: isAccent
            ? Border.all(
                color: OnboardingTheme.primaryRed.withValues(alpha: 0.15),
                width: 0.5,
              )
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
          color: isAccent
              ? OnboardingTheme.primaryRed
              : theme.colorScheme.onSurface.withValues(alpha: 0.80),
        ),
      ),
    );
  }
}
