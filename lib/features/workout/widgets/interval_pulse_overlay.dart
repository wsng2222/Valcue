import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/services.dart';

class IntervalPulseOverlay extends StatefulWidget {
  final int triggerKey;
  final bool enabled;

  const IntervalPulseOverlay({super.key, 
    required this.triggerKey,
    required this.enabled,
  });

  @override
  State<IntervalPulseOverlay> createState() => _IntervalPulseOverlayState();
}

class _IntervalPulseOverlayState extends State<IntervalPulseOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(IntervalPulseOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled) return;
    if (oldWidget.triggerKey != widget.triggerKey) {
      HapticFeedback.lightImpact();
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final decay = Curves.easeOutQuad.transform(_controller.value);
          final intensity = 1 - decay;
          final flashOpacity = intensity * (isDark ? 0.16 : 0.10);
          final borderOpacity = intensity * (isDark ? 0.50 : 0.34);
          final glowOpacity = intensity * (isDark ? 0.28 : 0.16);
          final borderWidth = 1.0 + (intensity * 5.5);

          if (flashOpacity <= 0.001 &&
              borderOpacity <= 0.001 &&
              glowOpacity <= 0.001) {
            return const SizedBox.shrink();
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.05),
                    radius: 1.0,
                    colors: [
                      theme.colorScheme.primary.withValues(
                        alpha: flashOpacity,
                      ),
                      theme.colorScheme.primary.withValues(alpha: 0),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(
                      alpha: borderOpacity,
                    ),
                    width: borderWidth,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(
                        alpha: glowOpacity,
                      ),
                      blurRadius: 28,
                      spreadRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Bottom control bar widget (landscape mode)
