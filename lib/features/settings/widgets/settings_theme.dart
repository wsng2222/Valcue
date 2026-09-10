
import 'package:flutter/material.dart';
import '../../../utils/app_shadows.dart';
import '../../../widgets/app_segmented_control.dart';

Color settingsSelectedSegmentBackground(BuildContext context) {
  return appSegmentedSelectedBackground(context);
}

Color settingsSegmentTrackBackground(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7);
}

List<BoxShadow>? settingsCardShadow(BuildContext context) {
  return AppShadows.elevatedSoft;
}

List<BoxShadow>? settingsSegmentThumbShadow(
  BuildContext context, {
  required double alpha,
  required double blurRadius,
  required Offset offset,
}) {
  return [
    BoxShadow(
      color: Theme.of(context).colorScheme.shadow.withValues(alpha: alpha),
      blurRadius: blurRadius,
      offset: offset,
    ),
  ];
}

SegmentedButtonThemeData settingsSegmentThemeData(
  BuildContext context,
  Color selectedBackground,
) {
  return appSegmentedThemeData(context, selectedBackground);
}
