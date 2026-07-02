import 'package:flutter/material.dart';

/// Responsive design utilities for adapting UI to different screen sizes
class ResponsiveUtils {
  /// Screen size categories
  static const double smallPhone = 375; // iPhone SE
  static const double normalPhone = 414; // iPhone 11/12
  static const double largePhone = 480; // iPhone 14 Plus
  static const double tablet = 768;

  /// Get screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < smallPhone) {
      return ScreenSize.extraSmall;
    } else if (width < normalPhone) {
      return ScreenSize.small;
    } else if (width < largePhone) {
      return ScreenSize.normal;
    } else if (width < tablet) {
      return ScreenSize.large;
    } else {
      return ScreenSize.tablet;
    }
  }

  /// Get font scale factor based on screen width
  static double getFontScale(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < smallPhone) return 0.9;
    if (width < normalPhone) return 0.95;
    if (width < largePhone) return 1.0;
    if (width < tablet) return 1.05;
    return 1.1; // tablet
  }

  /// Get spacing scale factor
  static double getSpacingScale(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < smallPhone) return 0.85;
    if (width < normalPhone) return 0.9;
    if (width < largePhone) return 1.0;
    if (width < tablet) return 1.05;
    return 1.1;
  }

  /// Chip minimum width based on screen size
  static double getChipDurationMinWidth(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.extraSmall:
        return 65;
      case ScreenSize.small:
        return 70;
      case ScreenSize.normal:
        return 75;
      case ScreenSize.large:
        return 80;
      case ScreenSize.tablet:
        return 90;
    }
  }

  static double getChipField1MinWidth(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.extraSmall:
        return 85;
      case ScreenSize.small:
        return 90;
      case ScreenSize.normal:
        return 95;
      case ScreenSize.large:
        return 100;
      case ScreenSize.tablet:
        return 110;
    }
  }

  static double getChipField2MinWidth(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.extraSmall:
        return 100;
      case ScreenSize.small:
        return 105;
      case ScreenSize.normal:
        return 110;
      case ScreenSize.large:
        return 115;
      case ScreenSize.tablet:
        return 130;
    }
  }

  /// Chip padding based on screen size
  static EdgeInsets getChipPadding(BuildContext context) {
    final scale = getSpacingScale(context);
    final h = 16 * scale;
    final v = 10 * scale;
    return EdgeInsets.symmetric(horizontal: h, vertical: v);
  }

  /// Navbar height based on screen size
  static double getNavbarHeight(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.extraSmall:
      case ScreenSize.small:
        return 65.0;
      case ScreenSize.normal:
        return 70.0;
      case ScreenSize.large:
        return 75.0;
      case ScreenSize.tablet:
        return 80.0;
    }
  }

  /// Horizontal padding for screens
  static double getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < smallPhone) return 12;
    if (width < normalPhone) return 16;
    if (width < largePhone) return 20;
    if (width < tablet) return 24;
    return 32;
  }

  /// Vertical padding for screens
  static double getVerticalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < smallPhone) return 12;
    if (width < normalPhone) return 14;
    if (width < largePhone) return 16;
    if (width < tablet) return 18;
    return 24;
  }

  /// Bottom sheet max height percentage
  static double getBottomSheetMaxHeightPercent(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.tablet:
        return 0.7; // tablets show less
      default:
        return 0.9; // phones show more
    }
  }

  /// Get font size with responsive scaling
  static double scaleFontSize(double baseFontSize, BuildContext context) {
    return baseFontSize * getFontScale(context);
  }
}

enum ScreenSize {
  extraSmall, // < 375
  small, // 375 - 413
  normal, // 414 - 479
  large, // 480 - 767
  tablet, // >= 768
}
