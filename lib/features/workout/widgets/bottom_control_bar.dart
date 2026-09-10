import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/services.dart';
import 'package:valcue/l10n/app_localizations.dart';
import '../../../widgets/secondary_outlined_button.dart';

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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        top: _scaled(4),
        bottom: 0,
        start: _scaled(32),
        end: _scaled(32),
      ),
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: _scaled(320)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Center: Primary pause/resume button (pill shape)
              Container(
                height: _scaled(48),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      _scaled(24)), // >= 20 for premium look
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                      blurRadius: _scaled(8),
                      spreadRadius: 0,
                      offset: Offset(0, _scaled(2)),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: isResumingCountdown ? null : onPauseResume,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: _scaled(32),
                      vertical: _scaled(12),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_scaled(24)),
                    ),
                  ),
                  child: Text(
                    isPaused ? l10n.resume : l10n.pause,
                    style: TextStyle(
                      fontSize: _scaled(17),
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
              SizedBox(width: _scaled(10)),
              // Right: Rotate button (right of pause button)
              SecondaryOutlinedIconButton(
                onPressed: isResumingCountdown
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        onRotate();
                      },
                size: _scaled(44),
                iconColor: theme.colorScheme.onSurface,
                icon: Icon(
                  Icons.rotate_right,
                  size: _scaled(20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Countdown overlay widget with persistent background
