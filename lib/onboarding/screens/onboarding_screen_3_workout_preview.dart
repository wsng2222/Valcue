import 'package:flutter/material.dart';

import '../widgets/onboarding_emphasis_text.dart';
import '../widgets/onboarding_theme.dart';
import '../onboarding_strings.dart';

class OnboardingScreen3WorkoutPreview extends StatelessWidget {
  const OnboardingScreen3WorkoutPreview({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final s = OnboardingStrings.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
                const SizedBox(height: 60), // Adjusted for consistency
                OnboardingRichTitle(spans: s.s3TitleSpans()),
                const SizedBox(height: 22), // Consistent spacing
                const Text(
                  '5.0 km/h',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                    color: OnboardingTheme.primaryRed,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _GrayChip(
                      text: s.chipNextSpeed('9.0 km/h'),
                      isDark: isDark,
                    ),
                    const SizedBox(width: 12),
                    _GrayChip(
                      text: s.chipIncline('1.0%'),
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 28), // Slightly increased spacing
                _RingTimer(timeText: '2:00', isDark: isDark),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GrayChip extends StatelessWidget {
  final String text;
  final bool isDark;

  const _GrayChip({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fill = isDark
        ? OnboardingTheme.darkGrayFill
        : const Color(0xFFF0F0F0);
    final border = isDark
        ? OnboardingTheme.darkGrayFill
        : const Color(0xFFF0F0F0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(OnboardingTheme.radiusPill),
        border: Border.all(
          color: border,
          width: 0.5,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}

class _RingTimer extends StatelessWidget {
  final String timeText;
  final bool isDark;

  const _RingTimer({required this.timeText, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trackColor = isDark
        ? OnboardingTheme.darkGrayFill
        : const Color(0xFFF0F0F0);
    return Container(
      width: 200, // Reduced from 210 for premium feel
      height: 200, // Reduced from 210
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [OnboardingTheme.mediumShadow],
      ),
      child: CustomPaint(
        painter: _RingPainter(trackColor: trackColor),
        child: Center(
          child: Text(
            timeText,
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color trackColor;

  _RingPainter({required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 12;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10 // Reduced from 12 (~15% reduction)
      ..color = trackColor
      ..strokeCap = StrokeCap.round;
    final progress = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10 // Reduced from 12
      ..color = OnboardingTheme.primaryRed
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);
    // Align to exactly 12 o'clock (-π/2) and draw arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // -π/2 for 12 o'clock alignment
      5.0,
      false,
      progress,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

