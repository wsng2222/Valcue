import 'dart:math' as math;
import 'package:flutter/material.dart' hide Interval;

class ProgressRingPainter extends CustomPainter {
  final double strokeWidth;
  final double progress; // 0.0 to 1.0
  final Color trackColor;
  final Color progressColor;

  final Paint _trackPaint;
  final Paint _progressPaint;

  ProgressRingPainter({
    required this.strokeWidth,
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  })  : _trackPaint = Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
        _progressPaint = Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background ring (full circle)
    canvas.drawCircle(center, radius, _trackPaint);

    // Draw progress arc (clockwise from top)
    if (progress > 0) {
      // Start from top (-90 degrees) and draw clockwise
      // Progress arc: sweepAngle = progress * 360 degrees (2π radians)
      // Positive sweepAngle = clockwise direction in Flutter
      final sweepAngle = progress * 2 * math.pi;
      const startAngle = -math.pi / 2; // Start from top (-90 degrees)

      final rect = Rect.fromCircle(center: center, radius: radius);

      // Draw main progress arc
      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        _progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}

// Primary button (red) - for Pause/Resume
