import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/services.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'workout_action_buttons.dart';

class BottomControlBar extends StatelessWidget {
  final bool isPaused;
  final bool isResumingCountdown;
  final VoidCallback onPauseResume;
  final VoidCallback onRotate;
  final double scaleFactor;

  const BottomControlBar({super.key, 
    required this.isPaused,
    required this.isResumingCountdown,
    required this.onPauseResume,
    required this.onRotate,
    required this.scaleFactor,
  });

  double _scaled(double base) => base * scaleFactor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: _scaled(4),
        start: _scaled(32),
        end: _scaled(32),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          WorkoutPrimaryButton(
            width: _scaled(260),
            label: isPaused ? l10n.resume : l10n.pause,
            onPressed: isResumingCountdown ? () {} : onPauseResume,
            scaleFactor: scaleFactor,
          ),
          SizedBox(width: _scaled(12)),
          WorkoutSecondaryButton(
            onPressed: isResumingCountdown
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    onRotate();
                  },
            scaleFactor: scaleFactor,
          ),
        ],
      ),
    );
  }
}

// Countdown overlay widget with persistent background
