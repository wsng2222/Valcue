import 'package:flutter/material.dart' hide Interval;

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
    final isDark = theme.brightness == Brightness.dark;
    final trackColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : theme.colorScheme.onSurface.withValues(alpha: 0.06);
    return Container(
      height: widget.height ?? 12,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.08),
            blurRadius: 14,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        // Force LTR direction so progress bar always goes left to right, even in RTL mode
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              // Background
              Container(
                width: double.infinity,
                color: trackColor,
              ),
              // Primary fill bar with smooth animation (always left to right)
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return FractionallySizedBox(
                    widthFactor: _animation.value.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            Color.lerp(
                                  theme.colorScheme.primary,
                                  Colors.white,
                                  isDark ? 0.08 : 0.18,
                                ) ??
                                theme.colorScheme.primary,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Painter for progress ring: gray background + primary arc
