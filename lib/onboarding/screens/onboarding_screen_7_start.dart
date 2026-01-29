import 'package:flutter/material.dart';

import '../widgets/onboarding_emphasis_text.dart';
import '../widgets/onboarding_theme.dart';
import '../widgets/onboarding_treadmill_icon.dart';
import '../onboarding_strings.dart';

class OnboardingScreen7Start extends StatelessWidget {
  const OnboardingScreen7Start({
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
            child: _Content(
              titleSpans: s.s7TitleSpans(),
              line1: s.s7SubtitleLine1(),
              redPhrase: s.s7SubtitleRedPhrase(),
              tail: s.s7SubtitleTail(),
            ),
          ),
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  final List<EmphasisTextSpan> titleSpans;
  final String line1;
  final String redPhrase;
  final String tail;

  const _Content({
    required this.titleSpans,
    required this.line1,
    required this.redPhrase,
    required this.tail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const SizedBox(height: 80), // Reduced from 86
        const OnboardingTreadmillIcon(size: 104), // Reduced from 110 (~5%)
        const SizedBox(height: 28), // Reduced from 34 (tighter spacing)
        OnboardingRichTitle(spans: titleSpans),
        const SizedBox(height: 10), // Reduced from 14
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: line1,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.45, // Increased from 1.35
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  color: theme.colorScheme.onSurface.withOpacity(0.55),
                ),
              ),
              TextSpan(
                text: redPhrase,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.45, // Increased from 1.35
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: OnboardingTheme.primaryRed,
                ),
              ),
              TextSpan(
                text: tail,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.45, // Increased from 1.35
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  color: theme.colorScheme.onSurface.withOpacity(0.55),
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

