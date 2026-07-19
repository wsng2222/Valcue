import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/app_shadows.dart';

class AppBottomSheetFrame extends StatelessWidget {
  final Widget child;
  final BoxConstraints? constraints;
  final bool showHandle;

  const AppBottomSheetFrame({
    super.key,
    required this.child,
    this.constraints,
    this.showHandle = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;

    return Container(
      constraints: constraints,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.08)
              : appColors.border,
        ),
        boxShadow: AppShadows.elevatedSoft,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHandle) const AppBottomSheetHandle(),
          Flexible(fit: FlexFit.loose, child: child),
        ],
      ),
    );
  }
}

class AppBottomSheetHandle extends StatelessWidget {
  const AppBottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class AppCompactPickerSheetFrame extends StatelessWidget {
  final Widget child;
  final double height;

  const AppCompactPickerSheetFrame({
    super.key,
    required this.child,
    this.height = 260,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;

    return Container(
      height: height,
      padding: const EdgeInsets.only(top: 6),
      margin: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.08)
              : appColors.border,
        ),
        boxShadow: AppShadows.elevatedSoft,
      ),
      child: child,
    );
  }
}
