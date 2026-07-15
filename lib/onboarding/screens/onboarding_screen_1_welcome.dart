import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/onboarding_emphasis_text.dart';
import '../widgets/onboarding_treadmill_icon.dart';
import '../onboarding_strings.dart';

class OnboardingScreen1Welcome extends StatelessWidget {
  const OnboardingScreen1Welcome({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final s = OnboardingStrings.of(context);
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
                const SizedBox(height: 80), // Reduced from 86
                const OnboardingTreadmillIcon(
                    size: 104), // Reduced from 110 (~5%)
                const SizedBox(height: 28), // Reduced from 34 (tighter spacing)
                OnboardingRichTitle(
                  spans: [EmphasisTextSpan(s.s1Title())],
                ),
                const SizedBox(
                    height: 10), // Reduced from 14 (more intentional)
                Text(
                  s.s1Subtitle(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    height: 1.45,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
