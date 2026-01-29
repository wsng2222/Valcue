import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'onboarding_theme.dart';

class OnboardingCtaButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const OnboardingCtaButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          OnboardingTheme.horizontalPadding,
          12,
          OnboardingTheme.horizontalPadding,
          16, // Increased from 14 for better safe-area padding on Android
        ),
        child: SizedBox(
          width: double.infinity,
          height: OnboardingTheme.ctaHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              boxShadow: [OnboardingTheme.subtleShadow], // Subtle shadow
            ),
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                onPressed();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: OnboardingTheme.primaryRed,
                foregroundColor: onPrimary,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ).copyWith(
                overlayColor: WidgetStatePropertyAll(
                  onPrimary.withValues(alpha: 0.12),
                ),
              ),
              child: Center(
                child: Text(
                  text,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: onPrimary,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
