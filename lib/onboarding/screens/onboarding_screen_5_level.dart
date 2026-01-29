import 'package:flutter/material.dart';

import '../../services/analytics_service.dart';
import '../onboarding_controller.dart';
import '../onboarding_storage.dart';
import '../onboarding_strings.dart';
import '../widgets/onboarding_emphasis_text.dart';
import '../widgets/onboarding_option_cards.dart';

class OnboardingScreen5Level extends StatelessWidget {
  final OnboardingController controller;

  const OnboardingScreen5Level({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final s = OnboardingStrings.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    const SizedBox(height: 60), // Adjusted for consistency
                    OnboardingRichTitle(spans: s.s5TitleSpans()),
                    const SizedBox(height: 22), // Consistent spacing
                    OnboardingSelectableCard(
                      leading: const Text('🐣', style: TextStyle(fontSize: 28)),
                      title: s.levelBeginnerTitle(),
                      subtitle: s.levelBeginnerSub(),
                      selected: controller.level == OnboardingLevel.beginner,
                      onTap: () {
                        AnalyticsService.instance
                            .logEvent('level_selected', {'level': 'beginner'});
                        controller.selectLevel(OnboardingLevel.beginner);
                      },
                    ),
                    const SizedBox(height: 12), // Reduced from 14
                    OnboardingSelectableCard(
                      leading: const Text('🏃', style: TextStyle(fontSize: 28)),
                      title: s.levelIntermediateTitle(),
                      subtitle: s.levelIntermediateSub(),
                      selected: controller.level == OnboardingLevel.intermediate,
                      onTap: () {
                        AnalyticsService.instance.logEvent(
                          'level_selected',
                          {'level': 'intermediate'},
                        );
                        controller.selectLevel(OnboardingLevel.intermediate);
                      },
                    ),
                    const SizedBox(height: 12), // Reduced from 14
                    OnboardingSelectableCard(
                      leading: const Text('💪', style: TextStyle(fontSize: 28)),
                      title: s.levelAdvancedTitle(),
                      subtitle: s.levelAdvancedSub(),
                      selected: controller.level == OnboardingLevel.advanced,
                      onTap: () {
                        AnalyticsService.instance
                            .logEvent('level_selected', {'level': 'advanced'});
                        controller.selectLevel(OnboardingLevel.advanced);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

}

