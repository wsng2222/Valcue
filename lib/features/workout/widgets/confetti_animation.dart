import 'dart:math' as math;
import 'package:flutter/material.dart' hide Interval;


// Advanced physics-based confetti particle animation
class ConfettiAnimation extends StatelessWidget {
  final AnimationController controller;

  const ConfettiAnimation({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ConfettiPainter(progress: controller.value),
          size: MediaQuery.of(context).size,
        );
      },
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;

  _ConfettiPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0 || progress >= 1.0) return;

    final width = size.width;
    final height = size.height;

    final colors = [
      const Color(0xFFFF1744), // Vibrant Red
      const Color(0xFFFF9100), // Orange
      const Color(0xFFFFEA00), // Yellow
      const Color(0xFF00E676), // Green
      const Color(0xFF2979FF), // Blue
      const Color(0xFFD500F9), // Purple
      const Color(0xFF00E5FF), // Cyan
    ];

    const particleCount = 100;

    for (int i = 0; i < particleCount; i++) {
      // Use deterministic random based on particle index so we don't need real-time state updates
      final rand = math.Random(i + 100);

      // Emitter side: true = left bottom, false = right bottom
      final isLeft = i % 2 == 0;
      final startX = isLeft ? width * 0.10 : width * 0.90;
      final startY = height * 0.85;

      // Launch Angle: shoot upwards and towards the center
      // Left side shoots at -30 to -60 degrees, Right side shoots at -120 to -150 degrees
      final angleRange = rand.nextDouble() * (math.pi / 4); // 0 to 45 deg
      final baseAngle =
          isLeft ? -math.pi / 6 - angleRange : -5 * math.pi / 6 + angleRange;

      // Initial speed (pixels per second)
      final speed = 700 + rand.nextDouble() * 600;
      final vx = math.cos(baseAngle) * speed;
      final vy = math.sin(baseAngle) * speed;

      // Gravity (pixels per second squared)
      final gravity = 700 + rand.nextDouble() * 300;

      // Wind (sinusoidal horizontal drift)
      final windFreq = 2.0 + rand.nextDouble() * 3.0;
      final windAmp = 40.0 + rand.nextDouble() * 50.0;

      // Rotation settings
      final rotationSpeed = (rand.nextDouble() - 0.5) * 8.0;
      final rotationPhase = rand.nextDouble() * math.pi;

      // Size and scale settings
      final sizeScale = 8.0 + rand.nextDouble() * 10.0;
      final shapeType = rand.nextInt(3); // 0: rectangle, 1: circle, 2: triangle

      // Time (t goes from 0.0 to 3.0 seconds based on progress)
      final t = progress * 3.0;

      // Update positions using projectile physics with drag & wind
      final drag = math.exp(-0.25 * t);

      // Position equations
      final x = startX +
          (vx * t) * drag +
          math.sin(t * windFreq + rotationPhase) * windAmp * t;
      final y = startY + (vy * t) * drag + (0.5 * gravity * t * t);

      // Skip painting if off-screen below bottom
      if (y > height + 20) continue;

      // Fading opacity: stays solid, then fades out in the last 30% of progress
      final double opacity =
          progress < 0.7 ? 1.0 : (1.0 - (progress - 0.7) / 0.3).clamp(0.0, 1.0);
      if (opacity <= 0.0) continue;

      // Rotation angle
      final angle = rotationPhase + rotationSpeed * t;

      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);

      // 3D scaling simulation
      final scaleX = math.sin(t * 5.0 + rotationPhase).abs().clamp(0.1, 1.0);
      canvas.scale(scaleX, 1.0);

      // Draw different shapes
      switch (shapeType) {
        case 0: // Rectangle ribbon
          canvas.drawRect(
            Rect.fromCenter(
                center: Offset.zero, width: sizeScale, height: sizeScale * 0.5),
            paint,
          );
          break;
        case 1: // Circle dot
          canvas.drawCircle(Offset.zero, sizeScale * 0.35, paint);
          break;
        case 2: // Triangle
          final path = Path();
          final r = sizeScale * 0.5;
          path.moveTo(0, -r);
          path.lineTo(r * 0.86, r * 0.5);
          path.lineTo(-r * 0.86, r * 0.5);
          path.close();
          canvas.drawPath(path, paint);
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
