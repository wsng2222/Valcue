import 'package:flutter/material.dart';

import 'onboarding_theme.dart';

class OnboardingTreadmillIcon extends StatelessWidget {
  final double size;

  const OnboardingTreadmillIcon({
    super.key,
    this.size = 96,
  });

  @override
  Widget build(BuildContext context) {
    // Pixel-close requires the provided asset. We still provide a safe fallback
    // so the app runs even before the asset is added.
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/onboarding/treadmill_runner.png',
        color: OnboardingTheme.primaryRed,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.directions_run,
            color: OnboardingTheme.primaryRed,
            size: size * 0.9,
          );
        },
      ),
    );
  }
}
