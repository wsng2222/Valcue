import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'onboarding_theme.dart';

class OnboardingSelectableCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const OnboardingSelectableCard({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseFill = isDark
        ? OnboardingTheme.darkGrayFill
        : OnboardingTheme.lightGrayFill;
    final selectedFill = isDark
        ? OnboardingTheme.darkSelectedPink
        : OnboardingTheme.selectedPink;
    final onSurface = theme.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(OnboardingTheme.radiusMedium),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Reduced from 18
          decoration: BoxDecoration(
            color: selected ? selectedFill : baseFill,
            borderRadius: BorderRadius.circular(OnboardingTheme.radiusMedium),
            border: Border.all(
              color: selected
                  ? OnboardingTheme.primaryRed.withValues(alpha: 0.25) // Slightly stronger
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: OnboardingTheme.primaryRed.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: 4), // Reduced from 6
                    Text(
                      subtitle,
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: onSurface.withValues(alpha: 0.50),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                child: selected
                    ? const Icon(
                        Icons.check_circle,
                        key: ValueKey('check'),
                        color: OnboardingTheme.primaryRed,
                        size: 24,
                      )
                    : const SizedBox(
                        key: ValueKey('empty'),
                        width: 24,
                        height: 24,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingUnitTile extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const OnboardingUnitTile({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseFill = isDark
        ? OnboardingTheme.darkGrayFill
        : OnboardingTheme.lightGrayFill;
    final selectedFill = isDark
        ? OnboardingTheme.darkSelectedPink
        : OnboardingTheme.selectedPink;
    final onSurface = theme.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(OnboardingTheme.radiusMedium),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          height: 68, // Reduced from 72
          decoration: BoxDecoration(
            color: selected ? selectedFill : baseFill,
            borderRadius: BorderRadius.circular(OnboardingTheme.radiusMedium),
            border: Border.all(
              color: selected
                  ? OnboardingTheme.primaryRed.withValues(alpha: 0.25)
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: OnboardingTheme.primaryRed.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
                color: selected
                    ? OnboardingTheme.primaryRed
                    : onSurface.withValues(alpha: 0.70),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
