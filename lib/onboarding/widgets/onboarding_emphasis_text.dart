import 'package:flutter/material.dart';

import 'onboarding_theme.dart';

class EmphasisTextSpan {
  final String text;
  final bool isRed;

  const EmphasisTextSpan(this.text, {this.isRed = false});
}

class OnboardingRichTitle extends StatelessWidget {
  final List<EmphasisTextSpan> spans;
  final TextAlign textAlign;
  final double fontSize;

  const OnboardingRichTitle({
    super.key,
    required this.spans,
    this.textAlign = TextAlign.center,
    this.fontSize = 26,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text.rich(
      TextSpan(
        children: spans
            .map(
              (s) => TextSpan(
                text: s.text,
                style: TextStyle(
                  fontSize: fontSize,
                  height: 1.30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  color: s.isRed
                      ? OnboardingTheme.primaryRed
                      : theme.colorScheme.onSurface,
                ),
              ),
            )
            .toList(),
      ),
      textAlign: textAlign,
    );
  }
}
