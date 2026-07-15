import 'package:flutter/material.dart';

class OnboardingTheme {
  // Colors (Light Mode)
  static const Color primaryRed = Color(0xFFFF2D2D);
  static const Color background = Colors.white;
  static const Color selectedPink = Color(0xFFFFF0F0);
  static const Color lightGrayFill = Color(0xFFF0F0F0);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkSelectedPink = Color(0xFF3D1D1D);
  static const Color darkGrayFill = Color(0xFF2C2C2E);

  // Layout & Spacing
  static const double horizontalPadding =
      20; // Increased from 18 for better modern feel
  static const double ctaHeight = 56; // Reduced from 64 for premium feel

  // Corner Radii (premium radius system)
  static const double radiusLarge = 24; // Large containers/cards
  static const double radiusMedium = 20; // Standard cards
  static const double radiusSmall = 14; // Small elements
  static const double radiusPill = 18; // Pills/chips

  // Shadows (modern, subtle)
  static final BoxShadow subtleShadow = BoxShadow(
    color: Colors.black.withValues(alpha: 0.08),
    blurRadius: 12,
    offset: const Offset(0, 4),
  );

  static final BoxShadow mediumShadow = BoxShadow(
    color: Colors.black.withValues(alpha: 0.10),
    blurRadius: 16,
    offset: const Offset(0, 6),
  );
}
