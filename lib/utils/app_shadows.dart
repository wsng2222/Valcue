import 'package:flutter/material.dart';

/// Shared shadow styles for consistent Apple-like elevation across the app
class AppShadows {
  /// Elevated soft shadow for buttons, cards, and elevated components
  static List<BoxShadow> get elevatedSoft => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.10),
          blurRadius: 20,
          spreadRadius: 0.5,
          offset: const Offset(0, 7),
        ),
      ];

  /// Text shadow for large text elements
  static List<Shadow> get textSoft => [
        Shadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];
}
