import 'package:flutter/material.dart';

import 'onboarding_cta_button.dart';
import 'onboarding_theme.dart';

class OnboardingScaffold extends StatelessWidget {
  final Widget child;
  final String ctaText;
  final VoidCallback onCtaPressed;

  const OnboardingScaffold({
    super.key,
    required this.child,
    required this.ctaText,
    required this.onCtaPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OnboardingTheme.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: OnboardingTheme.horizontalPadding,
                ),
                child: child,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: OnboardingCtaButton(
              text: ctaText,
              onPressed: onCtaPressed,
            ),
          ),
        ],
      ),
    );
  }
}
