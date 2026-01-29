import 'package:flutter/material.dart';

/// Utility class for consistent bottom sheet and CTA button spacing
/// Properly handles Android system navigation bar insets
class BottomSheetUtils {
  /// Get bottom safe padding that respects system insets
  /// Minimum spacing: 12dp, plus any system navigation bar inset
  static EdgeInsets bottomSafePadding(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return EdgeInsets.only(bottom: 12 + bottomInset);
  }

  /// Get bottom safe padding for buttons in bottom sheets
  /// Uses slightly more spacing for button areas: 16dp + inset
  static EdgeInsets bottomButtonPadding(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return EdgeInsets.only(bottom: 16 + bottomInset);
  }

  /// Get just the system bottom inset (e.g., for SafeArea alternatives)
  static double getSystemBottomInset(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  /// Compact bottom padding for dense layouts (used in lists, etc.)
  static EdgeInsets compactBottomPadding(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return EdgeInsets.only(bottom: max(8, bottomInset));
  }
}

/// Helper to get max of two values
double max(double a, double b) => a > b ? a : b;
