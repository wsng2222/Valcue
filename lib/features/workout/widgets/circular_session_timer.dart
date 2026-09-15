import 'dart:ui' as ui;
import 'package:flutter/material.dart' hide Interval;
import 'package:valcue/l10n/app_localizations.dart';
import '../../../widgets/bidi_safe_text.dart';
import '../../../theme/app_theme.dart';
import 'progress_ring_painter.dart';

class CircularSessionTimer extends StatefulWidget {
  final String timeText;
  final double progress; // 0.0 to 1.0, where 1.0 = full ring, 0.0 = empty
  final bool isPaused;
  final double size;
  final int currentIntervalIndex;
  final double scaleFactor;

  const CircularSessionTimer({super.key, 
    required this.timeText,
    required this.progress,
    required this.isPaused,
    required this.size,
    required this.currentIntervalIndex,
    required this.scaleFactor,
  });

  double _scaled(double base) => base * scaleFactor;

  @override
  State<CircularSessionTimer> createState() => _CircularSessionTimerState();
}

class _CircularSessionTimerState extends State<CircularSessionTimer>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _animation;
  late Animation<double> _pulseAnimation;
  double _previousProgress = 0.0;
  int _previousIntervalIndex = -1;

  @override
  void initState() {
    super.initState();
    _previousProgress = widget.progress;
    _previousIntervalIndex = widget.currentIntervalIndex;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: widget.progress,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _controller.value = 1.0; // Start at the end
  }

  @override
  void didUpdateWidget(CircularSessionTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _previousProgress = _animation.value;
      _animation = Tween<double>(
        begin: _previousProgress,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ));
      _controller.reset();
      _controller.forward();
    }
    // Pulse animation when interval changes
    if (oldWidget.currentIntervalIndex != widget.currentIntervalIndex &&
        _previousIntervalIndex != widget.currentIntervalIndex) {
      _previousIntervalIndex = widget.currentIntervalIndex;
      _pulseController.reset();
      _pulseController.forward().then((_) {
        // Ensure animation returns to original state after completion
        if (mounted) {
          _pulseController.reset();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final trackColor = theme.extension<AppColors>()!.track;
    final strokeWidth = widget.size * 13 / 196;
    final fontSize =
        (widget.size * 0.214).clamp(widget._scaled(24.0), widget._scaled(46.0));

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Circular timer
        SizedBox(
          key: const ValueKey('workout-session-timer'),
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              // Progress ring with smooth animation and pulse effect
              AnimatedBuilder(
                animation: Listenable.merge([_animation, _pulseAnimation]),
                builder: (context, child) {
                  final pulseScale = _pulseAnimation.value;
                  return Transform.scale(
                    scale: pulseScale,
                    child: SizedBox(
                      width: widget.size,
                      height: widget.size,
                      child: CustomPaint(
                        painter: ProgressRingPainter(
                          strokeWidth: strokeWidth,
                          progress: _animation.value,
                          trackColor: trackColor,
                          progressColor: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Time text (always LTR for timers) with tabular digits
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BidiSafeText(
                    widget.timeText,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.5,
                      fontFeatures: const [
                        ui.FontFeature.tabularFigures()
                      ], // Tabular/monospaced digits
                    ),
                    forceLTR: true, // Timers must always be LTR
                  ),
                  if (widget.isPaused) ...[
                    SizedBox(height: widget.size * 0.03),
                    Text(
                      AppLocalizations.of(context)!.paused,
                      style: TextStyle(
                        fontSize: fontSize * 0.33,
                        fontWeight: FontWeight.w600,
                        color: textColor.withValues(alpha: 0.6),
                        letterSpacing: widget._scaled(0.2),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Premium pause bottom sheet widget
