import 'package:flutter/material.dart' hide Interval;
import 'flashing_metric_text.dart';
import 'workout_hero_panel.dart';

class CurrentValueSection extends StatefulWidget {
  final String metricLabel;
  final String mainValueText;
  final List<WorkoutDetailChipData> detailChips;
  final double mainFontSize;
  final int currentIntervalIndex;
  final double scaleFactor;
  final bool alignCenter;

  const CurrentValueSection({super.key, 
    required this.metricLabel,
    required this.mainValueText,
    required this.detailChips,
    required this.mainFontSize,
    required this.currentIntervalIndex,
    required this.scaleFactor,
    required this.alignCenter,
  });

  double _scaled(double base) => base * scaleFactor;

  @override
  State<CurrentValueSection> createState() => _CurrentValueSectionState();
}

class _CurrentValueSectionState extends State<CurrentValueSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int _previousIntervalIndex = -1;

  @override
  void initState() {
    super.initState();
    _previousIntervalIndex = widget.currentIntervalIndex;
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(CurrentValueSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Pulse animation when interval changes
    if (oldWidget.currentIntervalIndex != widget.currentIntervalIndex &&
        _previousIntervalIndex != widget.currentIntervalIndex) {
      _previousIntervalIndex = widget.currentIntervalIndex;
      _pulseController.reset();
      _pulseController.forward();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: widget.alignCenter
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          widget.metricLabel,
          style: TextStyle(
            fontSize: widget._scaled(13),
            fontWeight: FontWeight.w700,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.56),
            letterSpacing: 1.3,
          ),
          textAlign: widget.alignCenter ? TextAlign.center : TextAlign.start,
        ),
        SizedBox(height: widget._scaled(12)),
        // Current session value (large primary text) with pulse animation
        Align(
          alignment: widget.alignCenter
              ? Alignment.center
              : AlignmentDirectional.centerStart,
          widthFactor: widget.alignCenter ? null : 1,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = 1.0 + (_pulseController.value * 0.1);
              return Transform.scale(
                scale: scale,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: widget.alignCenter
                      ? Alignment.center
                      : AlignmentDirectional.centerStart,
                  child: FlashingMetricText(
                    text: widget.mainValueText,
                    style: TextStyle(
                      fontSize: widget.mainFontSize,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: -1.8,
                    ),
                    defaultColor: Theme.of(context).colorScheme.onSurface,
                    flashColor: Theme.of(context).colorScheme.primary,
                    enableScalePulse: true,
                    triggerKey: widget.currentIntervalIndex,
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.detailChips.isNotEmpty) ...[
          SizedBox(height: widget._scaled(16)),
          Align(
            alignment: widget.alignCenter
                ? Alignment.center
                : AlignmentDirectional.centerStart,
            widthFactor: widget.alignCenter ? null : 1,
            child: Wrap(
              alignment: widget.alignCenter
                  ? WrapAlignment.center
                  : WrapAlignment.start,
              spacing: widget._scaled(10),
              runSpacing: widget._scaled(10),
              children: [
                for (final chip in widget.detailChips)
                  WorkoutDetailChip(
                    chip: chip,
                    scaleFactor: widget.scaleFactor,
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// Circular session timer widget (right column in landscape)
