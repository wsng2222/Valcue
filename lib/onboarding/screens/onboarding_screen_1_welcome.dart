import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/onboarding_emphasis_text.dart';
import '../widgets/onboarding_treadmill_icon.dart';
import '../onboarding_strings.dart';

class OnboardingScreen1Welcome extends StatefulWidget {
  const OnboardingScreen1Welcome({
    super.key,
  });

  @override
  State<OnboardingScreen1Welcome> createState() =>
      _OnboardingScreen1WelcomeState();
}

class _OnboardingScreen1WelcomeState extends State<OnboardingScreen1Welcome>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                const SizedBox(height: 80),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: const OnboardingTreadmillIcon(size: 104),
                ),
                const SizedBox(height: 28),
                OnboardingRichTitle(
                  spans: [EmphasisTextSpan(s.s1Title())],
                ),
                const SizedBox(height: 10),
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
