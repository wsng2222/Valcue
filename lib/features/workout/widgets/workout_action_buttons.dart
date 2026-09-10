import 'package:flutter/material.dart' hide Interval;
import '../../../utils/app_shadows.dart';
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
    return Container(
      width: width,
      height: 56 * scaleFactor,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
        boxShadow: AppShadows.elevatedSoft,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16 * scaleFactor,
            fontWeight: FontWeight.w600,
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
    final isDark = theme.brightness == Brightness.dark;

    final appColors = theme.extension<AppColors>()!;
    // Default colors
    final bgColor = isDark
        ? appColors.surfaceElevated.withValues(alpha: 0.5)
        : theme.colorScheme.surface;
    final borderColor = appColors.border;

    return Opacity(
      opacity: onPressed == null ? 0.5 : 1.0,
      child: Container(
        width: 56 * scaleFactor,
        height: 56 * scaleFactor,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14 * scaleFactor),
          color: bgColor,
          border: Border.all(
            color: borderColor,
            width: 1.0,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14 * scaleFactor),
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
