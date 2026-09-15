import 'package:flutter/material.dart' hide Interval;
import '../../../theme/app_theme.dart';

class WorkoutPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double width;
  final double scaleFactor;

  const WorkoutPrimaryButton({super.key, 
    required this.label,
    required this.onPressed,
    this.width = 150,
    this.scaleFactor = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 58 * scaleFactor,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18 * scaleFactor,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3 * scaleFactor,
          ),
        ),
      ),
    );
  }
}

// Secondary button (neutral/gray) - for Rotate
class WorkoutSecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double scaleFactor;

  const WorkoutSecondaryButton({super.key, 
    required this.onPressed,
    this.scaleFactor = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.extension<AppColors>()!.border;

    return Opacity(
      opacity: onPressed == null ? 0.5 : 1.0,
      child: Container(
        width: 58 * scaleFactor,
        height: 58 * scaleFactor,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18 * scaleFactor),
          border: Border.all(
            color: borderColor,
            width: 1.0,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(18 * scaleFactor),
            splashColor: theme.colorScheme.onSurface.withValues(alpha: 0.08),
            highlightColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            child: Icon(
              Icons.rotate_right,
              color: theme.colorScheme.onSurface,
              size: 24 * scaleFactor,
            ),
          ),
        ),
      ),
    );
  }
}
