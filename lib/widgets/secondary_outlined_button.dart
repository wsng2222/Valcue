import 'package:flutter/material.dart';

/// Secondary outlined button with no shadow, only border
/// Used for cancel/edit buttons in bottom sheets
class SecondaryOutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;

  const SecondaryOutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width,
    this.padding,
    this.borderRadius = 14.0,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Default colors
    final bgColor = backgroundColor ??
        (isDark
            ? const Color(0xFF2C2C2E).withValues(alpha: 0.5)
            : Colors.white);
    final fgColor = foregroundColor ?? theme.colorScheme.onSurface;
    final border = borderColor ?? const Color(0xFFD0D0D0);

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(
              color: border,
              width: 1.0,
            ),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.pressed)) {
                return Colors.black.withValues(alpha: 0.08);
              }
              return null;
            },
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Secondary outlined icon button with no shadow, only border
/// Used for small icon buttons (e.g., rotate button in workout screen)
class SecondaryOutlinedIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? borderColor;

  const SecondaryOutlinedIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = 44.0,
    this.backgroundColor,
    this.iconColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Default colors
    final bgColor = backgroundColor ??
        (isDark
            ? const Color(0xFF2C2C2E).withValues(alpha: 0.5)
            : Colors.grey.shade100);
    final iconClr = iconColor ?? theme.colorScheme.onSurface;
    final border = borderColor ?? const Color(0xFFD0D0D0);

    return Opacity(
      opacity: onPressed == null ? 0.5 : 1.0,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor,
          border: Border.all(
            color: border,
            width: 1.0,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(size / 2),
            splashColor: Colors.black.withValues(alpha: 0.08),
            highlightColor: Colors.black.withValues(alpha: 0.05),
            child: Center(
              child: IconTheme(
                data: IconThemeData(color: iconClr),
                child: DefaultTextStyle(
                  style: TextStyle(color: iconClr),
                  child: icon,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
