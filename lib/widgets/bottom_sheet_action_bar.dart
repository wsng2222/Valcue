import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum BottomSheetPrimaryActionStyle { primary, destructive }

/// Shared two-action footer for bottom sheets.
///
/// The secondary action stays visually quiet while the primary action carries
/// the current flow forward. Both buttons share the same size and interaction
/// model so action bars remain consistent across sheets.
class BottomSheetActionBar extends StatelessWidget {
  final String secondaryLabel;
  final String primaryLabel;
  final VoidCallback? onSecondaryPressed;
  final VoidCallback? onPrimaryPressed;
  final BottomSheetPrimaryActionStyle primaryStyle;

  const BottomSheetActionBar({
    super.key,
    required this.secondaryLabel,
    required this.primaryLabel,
    required this.onSecondaryPressed,
    required this.onPrimaryPressed,
    this.primaryStyle = BottomSheetPrimaryActionStyle.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final isDark = theme.brightness == Brightness.dark;
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(999),
    );
    final isDestructive =
        primaryStyle == BottomSheetPrimaryActionStyle.destructive;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : appColors.border,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: OutlinedButton(
                    onPressed: onSecondaryPressed,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurface,
                      backgroundColor: appColors.surfaceElevated,
                      side: BorderSide(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : appColors.border,
                      ),
                      shape: buttonShape,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    child: Text(
                      secondaryLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: onPrimaryPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDestructive
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                      foregroundColor: isDestructive
                          ? theme.colorScheme.onError
                          : theme.colorScheme.onPrimary,
                      disabledBackgroundColor: appColors.surfaceElevated,
                      disabledForegroundColor: appColors.mutedText,
                      elevation: 0,
                      shape: buttonShape,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    child: Text(
                      primaryLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomSheetPrimaryActionBar extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final BottomSheetPrimaryActionStyle style;

  const BottomSheetPrimaryActionBar({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = BottomSheetPrimaryActionStyle.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final isDestructive = style == BottomSheetPrimaryActionStyle.destructive;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.08)
                : appColors.border,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDestructive
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
                foregroundColor: isDestructive
                    ? theme.colorScheme.onError
                    : theme.colorScheme.onPrimary,
                disabledBackgroundColor: appColors.surfaceElevated,
                disabledForegroundColor: appColors.mutedText,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
