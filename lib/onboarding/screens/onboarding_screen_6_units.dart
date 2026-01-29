import 'package:flutter/material.dart';

import '../../services/analytics_service.dart';
import '../onboarding_controller.dart';
import '../onboarding_storage.dart';
import '../onboarding_strings.dart';
import '../widgets/onboarding_emphasis_text.dart';
import '../widgets/onboarding_option_cards.dart';

class OnboardingScreen6Units extends StatelessWidget {
  final OnboardingController controller;

  const OnboardingScreen6Units({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final s = OnboardingStrings.of(context);
    final theme = Theme.of(context);
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
                    OnboardingRichTitle(spans: s.s6TitleSpans()),
                    const SizedBox(height: 28), // Consistent spacing
                    Row(
                      children: [
                        Expanded(
                          child: OnboardingUnitTile(
                            text: 'km/h',
                            selected: controller.speedUnit == SpeedUnit.kmh,
                            onTap: () {
                              AnalyticsService.instance.logEvent(
                                'unit_selected',
                                {
                                  'speedUnit': 'kmh',
                                  'weightUnit': controller.weightUnit.name,
                                },
                              );
                              controller.selectSpeedUnit(SpeedUnit.kmh);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OnboardingUnitTile(
                            text: 'mph',
                            selected: controller.speedUnit == SpeedUnit.mph,
                            onTap: () {
                              AnalyticsService.instance.logEvent(
                                'unit_selected',
                                {
                                  'speedUnit': 'mph',
                                  'weightUnit': controller.weightUnit.name,
                                },
                              );
                              controller.selectSpeedUnit(SpeedUnit.mph);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12), // Reduced from 14
                    Row(
                      children: [
                        Expanded(
                          child: OnboardingUnitTile(
                            text: 'kg',
                            selected: controller.weightUnit == WeightUnit.kg,
                            onTap: () {
                              AnalyticsService.instance.logEvent(
                                'unit_selected',
                                {
                                  'speedUnit': controller.speedUnit.name,
                                  'weightUnit': 'kg',
                                },
                              );
                              controller.selectWeightUnit(WeightUnit.kg);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OnboardingUnitTile(
                            text: 'lbs',
                            selected: controller.weightUnit == WeightUnit.lbs,
                            onTap: () {
                              AnalyticsService.instance.logEvent(
                                'unit_selected',
                                {
                                  'speedUnit': controller.speedUnit.name,
                                  'weightUnit': 'lbs',
                                },
                              );
                              controller.selectWeightUnit(WeightUnit.lbs);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16), // Increased spacing for helper text
                    Text(
                      s.s6Helper(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.50),
                      ),
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

