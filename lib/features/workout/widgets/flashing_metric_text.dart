import 'package:flutter/material.dart';
import '../../../widgets/bidi_safe_text.dart';

/// A reusable widget that flashes text from black to red and back, 3 times.
/// Used to indicate session transitions in workouts.
class FlashingMetricText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Color defaultColor;
  final Color flashColor;
  final int flashCount;
  final bool enableScalePulse;
  final int? triggerKey; // When this changes, trigger the flash

  const FlashingMetricText({
    super.key,
    required this.text,
    required this.style,
    this.defaultColor = Colors.black,
    this.flashColor = Colors.red,
    this.flashCount = 3,
    this.enableScalePulse = false,
    this.triggerKey,
  });

  @override
  State<FlashingMetricText> createState() => _FlashingMetricTextState();
}

class _FlashingMetricTextState extends State<FlashingMetricText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _disableAnimations = false;

  // 3 flashes = 6 half-steps (black->red, red->black, black->red, red->black, black->red, red->black)
  // Each half-step is ~350ms, so total duration = 2100ms
  static const Duration _halfStepDuration = Duration(milliseconds: 350);
  static const int _halfStepsPerFlash = 2; // black->red->black = 2 half-steps

  @override
  void initState() {
    super.initState();

    // Total duration = flashCount * halfStepsPerFlash * halfStepDuration
    final totalDuration = Duration(
      milliseconds: widget.flashCount *
          _halfStepsPerFlash *
          _halfStepDuration.inMilliseconds,
    );

    _controller = AnimationController(
      duration: totalDuration,
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disableAnimations = MediaQuery.of(context).disableAnimations;
  }

  @override
  void didUpdateWidget(FlashingMetricText oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if triggerKey changed (indicating a session transition)
    // Only trigger if triggerKey actually changed from the previous widget's value
    if (widget.triggerKey != null &&
        oldWidget.triggerKey != null &&
        widget.triggerKey != oldWidget.triggerKey) {
      _triggerFlash();
    }
  }

  void _triggerFlash() {
    _controller.reset();
    _controller.forward().then((_) {
      // Animation completed, reset to default state
      if (mounted) {
        _controller.reset();
      }
    });
  }

  Color _getColor(double animationValue) {
    // animationValue goes from 0.0 to 1.0
    // For 3 flashes, we need 6 segments: default->flash->default->flash->default->flash->default
    final segment = (animationValue * 6).floor();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color defColor = widget.defaultColor;
    if (defColor == Colors.black) {
      defColor = isDark ? Colors.white : Colors.black;
    }
    Color flColor = widget.flashColor;
    if (flColor == Colors.red) {
      flColor = Theme.of(context).colorScheme.primary;
    }

    return segment % 2 == 0 ? defColor : flColor;
  }

  double _getScale(double animationValue) {
    if (!widget.enableScalePulse || _disableAnimations) {
      return 1.0;
    }

    // Scale pulses synchronized with color: 1.0 -> 1.06 -> 1.0
    final segment = (animationValue * 6).floor();
    final segmentProgress = (animationValue * 6) - segment;

    // Even segments (0, 2, 4): 1.0 -> 1.06
    // Odd segments (1, 3, 5): 1.06 -> 1.0
    if (segment % 2 == 0) {
      return 1.0 + (0.06 * segmentProgress);
    } else {
      return 1.06 - (0.06 * segmentProgress);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _getScale(_controller.value),
          child: BidiSafeText(
            widget.text,
            style: widget.style.copyWith(
              color: _getColor(_controller.value),
            ),
            forceLTR: true, // Always LTR for metric values
          ),
        );
      },
    );
  }
}
