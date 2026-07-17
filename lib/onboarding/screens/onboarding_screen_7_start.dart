import 'dart:math';
import 'package:flutter/material.dart';

import '../widgets/onboarding_emphasis_text.dart';
import '../widgets/onboarding_theme.dart';
import '../widgets/onboarding_treadmill_icon.dart';
import '../onboarding_strings.dart';

class OnboardingScreen7Start extends StatelessWidget {
  const OnboardingScreen7Start({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final s = OnboardingStrings.of(context);
    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: _Content(
                  titleSpans: s.s7TitleSpans(),
                  line1: s.s7SubtitleLine1(),
                  redPhrase: s.s7SubtitleRedPhrase(),
                  tail: s.s7SubtitleTail(),
                ),
              ),
            );
          },
        ),
        const Positioned.fill(
          child: _ConfettiVisualizer(),
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  final List<EmphasisTextSpan> titleSpans;
  final String line1;
  final String redPhrase;
  final String tail;

  const _Content({
    required this.titleSpans,
    required this.line1,
    required this.redPhrase,
    required this.tail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 80), // Reduced from 86
          const OnboardingTreadmillIcon(size: 104), // Reduced from 110 (~5%)
          const SizedBox(height: 28), // Reduced from 34 (tighter spacing)
          OnboardingRichTitle(spans: titleSpans),
          const SizedBox(height: 10), // Reduced from 14
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: line1,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.45, // Increased from 1.35
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                TextSpan(
                  text: redPhrase,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.45, // Increased from 1.35
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: OnboardingTheme.primaryRed,
                  ),
                ),
                TextSpan(
                  text: tail,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.45, // Increased from 1.35
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double rotation;
  double rotationSpeed;
  Color color;
  bool isCircle;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.isCircle,
  });
}

class _ConfettiVisualizer extends StatefulWidget {
  const _ConfettiVisualizer();

  @override
  State<_ConfettiVisualizer> createState() => _ConfettiVisualizerState();
}

class _ConfettiVisualizerState extends State<_ConfettiVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // 4 seconds animation
    );

    final colors = [
      const Color(0xFFFF2D2D), // Primary Red
      const Color(0xFFFF9F0A), // Orange
      const Color(0xFF30D158), // Green
      const Color(0xFF0A84FF), // Blue
      const Color(0xFFBF5AF2), // Purple
      Colors.amber,
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < 80; i++) {
        _particles.add(
          _Particle(
            x: _random.nextDouble() * size.width,
            y: _random.nextDouble() * -400 - 20, // Start above screen
            vx: (_random.nextDouble() - 0.5) * 4,
            vy: _random.nextDouble() * 3 + 2.5, // Falling speed
            size: _random.nextDouble() * 8 + 6,
            rotation: _random.nextDouble() * 2 * pi,
            rotationSpeed: (_random.nextDouble() - 0.5) * 0.1,
            color: colors[_random.nextInt(colors.length)],
            isCircle: _random.nextBool(),
          ),
        );
      }
      _controller.repeat();
      _controller.addListener(() {
        if (mounted) {
          setState(() {
            bool allOffScreen = true;
            final screenHeight = MediaQuery.of(context).size.height;
            for (final p in _particles) {
              p.y += p.vy;
              p.x += p.vx;
              p.rotation += p.rotationSpeed;
              if (p.y < screenHeight + 50) {
                allOffScreen = false;
              }
            }
            if (allOffScreen) {
              _controller.stop();
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ConfettiPainter(particles: _particles),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;

  _ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      if (p.y < -50 || p.y > size.height) continue;
      if (p.x < -50 || p.x > size.width + 50) continue;

      final paint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: p.size, height: p.size / 2),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
