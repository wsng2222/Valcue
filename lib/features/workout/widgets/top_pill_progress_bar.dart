import 'package:flutter/material.dart' hide Interval;

import '../../../theme/app_theme.dart';

class TopPillProgressBar extends StatefulWidget {
  final double progress;
  final double? height;

  const TopPillProgressBar({super.key, 
    required this.progress,
    this.height,
  });

  @override
  State<TopPillProgressBar> createState() => _TopPillProgressBarState();
}

class _TopPillProgressBarState extends State<TopPillProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _previousProgress = widget.progress;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: widget.progress,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
    _controller.value = 1.0; // Start at the end
  }

  @override
  void didUpdateWidget(TopPillProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _previousProgress = _animation.value;

      // If progress decreased (session ended, resetting to 0), skip animation and reset immediately
      if (widget.progress < _previousProgress) {
        _animation = Tween<double>(
          begin: widget.progress,
          end: widget.progress,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.linear,
        ));
        _controller.value = 1.0; // Set immediately without animation
      } else {
        // Progress increased (new session starting), animate normally
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
    final trackColor = context.appColors.track;
    // Full width on purpose: under loose constraints the FractionallySizedBox
    // below shrink-wraps to the fill, so the track vanished and the bar just
    // shrank toward the centre instead of emptying left to right.
    return SizedBox(
      width: double.infinity,
      height: widget.height ?? 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        // Force LTR direction so progress bar always goes left to right, even in RTL mode
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: ColoredBox(
            color: trackColor,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _animation.value.clamp(0.0, 1.0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// Painter for progress ring: gray background + primary arc
