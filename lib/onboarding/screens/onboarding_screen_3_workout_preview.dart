import 'package:flutter/material.dart';

import '../widgets/onboarding_emphasis_text.dart';
import '../widgets/onboarding_theme.dart';
import '../onboarding_strings.dart';

class OnboardingScreen3WorkoutPreview extends StatefulWidget {
  const OnboardingScreen3WorkoutPreview({
    super.key,
  });

  @override
  State<OnboardingScreen3WorkoutPreview> createState() =>
      _OnboardingScreen3WorkoutPreviewState();
}

class _OnboardingScreen3WorkoutPreviewState
    extends State<OnboardingScreen3WorkoutPreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    );
    _controller.reverse(from: 1.0);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        _controller.reverse(from: 1.0); // Loop back
      }
    });
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
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final double progressFraction = _controller.value;
        final int totalSecondsLeft = (progressFraction * 60).ceil();
        final minutes = totalSecondsLeft ~/ 60;
        final seconds = totalSecondsLeft % 60;
        final timeText = '$minutes:${seconds.toString().padLeft(2, '0')}';

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
                      children: [
                        Expanded(
                          child: _GrayChip(
                            text: s.chipNextSpeed('9.0 km/h'),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _GrayChip(
                            text: s.chipIncline('1.0%'),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28), // Slightly increased spacing
                    _RingTimer(
                      timeText: timeText,
                      progressFraction: progressFraction,
                      isDark: isDark,
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

class _GrayChip extends StatelessWidget {
  final String text;
  final bool isDark;

  const _GrayChip({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fill =
        isDark ? OnboardingTheme.darkGrayFill : const Color(0xFFF0F0F0);
    final border =
        isDark ? OnboardingTheme.darkGrayFill : const Color(0xFFF0F0F0);
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
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
  final double progressFraction;
  final bool isDark;

  const _RingTimer({
    required this.timeText,
    required this.progressFraction,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trackColor =
        isDark ? OnboardingTheme.darkGrayFill : const Color(0xFFF0F0F0);
    return Container(
      width: 200, // Reduced from 210 for premium feel
      height: 200, // Reduced from 210
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [OnboardingTheme.mediumShadow],
      ),
      child: CustomPaint(
        painter: _RingPainter(
          trackColor: trackColor,
          progressFraction: progressFraction,
        ),
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
  final double progressFraction;

  _RingPainter({
    required this.trackColor,
    required this.progressFraction,
  });

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
    // Align to exactly 12 o'clock (-π/2) and draw arc based on progressFraction
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // -π/2 for 12 o'clock alignment
      progressFraction * 2 * 3.14159265,
      false,
      progress,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progressFraction != progressFraction ||
        oldDelegate.trackColor != trackColor;
  }
}
