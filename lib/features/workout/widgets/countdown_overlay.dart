import 'package:flutter/material.dart' hide Interval;

class CountdownOverlay extends StatefulWidget {
  final int countdownNumber;

  const CountdownOverlay({super.key, 
    required this.countdownNumber,
  });

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay> {
  @override
  Widget build(BuildContext context) {
    // Persistent background that never flickers - stays mounted for entire countdown
    return Container(
      color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.35),
      child: Stack(
        children: [
          // Animated number in center - only this part changes
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              child: Text(
                '${widget.countdownNumber}',
                key: ValueKey(widget.countdownNumber),
                style: const TextStyle(
                  fontSize: 120,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -3.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
