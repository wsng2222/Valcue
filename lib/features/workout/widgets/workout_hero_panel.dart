import 'package:flutter/material.dart' hide Interval;

import '../../../theme/app_theme.dart';

class WorkoutHeroPanel extends StatelessWidget {
  final bool isPortrait;
  final double scaleFactor;
  final Widget mainSection;
  final Widget timerSection;

  const WorkoutHeroPanel({super.key, 
    required this.isPortrait,
    required this.scaleFactor,
    required this.mainSection,
    required this.timerSection,
  });

  double _scaled(double base) => base * scaleFactor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _scaled(isPortrait ? 4 : 8),
        vertical: _scaled(isPortrait ? 12 : 6),
      ),
      child: isPortrait
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                mainSection,
                SizedBox(height: _scaled(40)),
                timerSection,
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: _scaled(560)),
                  child: mainSection,
                ),
                SizedBox(width: _scaled(18)),
                timerSection,
              ],
            ),
    );
  }
}

class TimerSurface extends StatelessWidget {
  final bool isPortrait;
  final double scaleFactor;
  final Widget child;

  const TimerSurface({super.key, 
    required this.isPortrait,
    required this.scaleFactor,
    required this.child,
  });

  double _scaled(double base) => base * scaleFactor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: _scaled(isPortrait ? 0 : 8)),
      child: child,
    );
  }
}

class WorkoutDetailChipData {
  final IconData icon;
  final String text;
  final bool isAccent;

  const WorkoutDetailChipData({
    required this.icon,
    required this.text,
    this.isAccent = false,
  });
}

class WorkoutDetailChip extends StatelessWidget {
  final WorkoutDetailChipData chip;
  final double scaleFactor;

  const WorkoutDetailChip({super.key, 
    required this.chip,
    required this.scaleFactor,
  });

  double _scaled(double base) => base * scaleFactor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final chipColor = chip.isAccent ? appColors.tint : appColors.subtle;
    final contentColor =
        chip.isAccent ? theme.colorScheme.primary : appColors.mutedText;

    return Container(
      constraints: BoxConstraints(minHeight: _scaled(40)),
      padding: EdgeInsets.symmetric(
        horizontal: _scaled(16),
        vertical: _scaled(10),
      ),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(_scaled(999)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            chip.icon,
            size: _scaled(16),
            color: contentColor,
          ),
          SizedBox(width: _scaled(6)),
          Flexible(
            child: Text(
              chip.text,
              style: TextStyle(
                fontSize: _scaled(15),
                fontWeight: FontWeight.w700,
                color: contentColor,
                letterSpacing: -0.1,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
