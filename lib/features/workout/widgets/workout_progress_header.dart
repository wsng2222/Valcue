import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart' hide Interval;
import '../../../theme/app_theme.dart';
import '../../../widgets/bidi_safe_text.dart';
import 'top_pill_progress_bar.dart';

class HeaderTimeSummary extends StatelessWidget {
  final String totalRemainingTimeFormatted;
  final int currentIntervalIndex;
  final int totalIntervals;
  final double scaleFactor;

  const HeaderTimeSummary({super.key, 
    required this.totalRemainingTimeFormatted,
    required this.currentIntervalIndex,
    required this.totalIntervals,
    required this.scaleFactor,
  });

  double _scaled(double base) => base * scaleFactor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: _scaled(40),
      child: Stack(
        alignment: Alignment.center,
        children: [
          BidiSafeText(
            totalRemainingTimeFormatted,
            style: TextStyle(
              fontSize: _scaled(26),
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.7,
              height: 1.0,
              fontFeatures: const [ui.FontFeature.tabularFigures()],
            ),
            forceLTR: true,
          ),
          PositionedDirectional(
            end: 0,
            child: _HeaderIntervalIndicator(
              currentIntervalIndex: currentIntervalIndex,
              totalIntervals: totalIntervals,
              scaleFactor: scaleFactor,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIntervalIndicator extends StatelessWidget {
  final int currentIntervalIndex;
  final int totalIntervals;
  final double scaleFactor;

  const _HeaderIntervalIndicator({
    required this.currentIntervalIndex,
    required this.totalIntervals,
    required this.scaleFactor,
  });

  double _scaled(double base) => base * scaleFactor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeTotal = totalIntervals < 1 ? 1 : totalIntervals;
    final currentStep =
        math.min(math.max(currentIntervalIndex + 1, 1), safeTotal);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _scaled(14),
        vertical: _scaled(8),
      ),
      decoration: BoxDecoration(
        color: context.appColors.subtle,
        borderRadius: BorderRadius.circular(_scaled(999)),
      ),
      child: BidiSafeText(
        '$currentStep/$safeTotal',
        style: TextStyle(
          fontSize: _scaled(15),
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
          letterSpacing: -0.2,
          fontFeatures: const [ui.FontFeature.tabularFigures()],
        ),
        forceLTR: true,
      ),
    );
  }
}

// Top routine progress header widget (reusable for landscape)
class TopRoutineProgressHeader extends StatelessWidget {
  final String totalRemainingTimeFormatted;
  final double progress;
  final int currentIntervalIndex;
  final int totalIntervals;
  final double scaleFactor;

  const TopRoutineProgressHeader({super.key, 
    required this.totalRemainingTimeFormatted,
    required this.progress,
    required this.currentIntervalIndex,
    required this.totalIntervals,
    required this.scaleFactor,
  });

  double _scaled(double base) => base * scaleFactor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            _scaled(32),
            _scaled(8),
            _scaled(32),
            _scaled(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HeaderTimeSummary(
                totalRemainingTimeFormatted: totalRemainingTimeFormatted,
                currentIntervalIndex: currentIntervalIndex,
                totalIntervals: totalIntervals,
                scaleFactor: scaleFactor,
              ),
              SizedBox(height: _scaled(10)),
              // Total routine remaining progress bar (thinner)
              Padding(
                padding:
                    EdgeInsetsDirectional.symmetric(horizontal: _scaled(8)),
                child: TopPillProgressBar(
                  progress: progress,
                  height: _scaled(10), // Reduced from 22 to 10 (10~12px range)
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Current value section widget (left column in landscape)
