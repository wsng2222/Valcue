import 'dart:ui';
import 'package:flutter/material.dart';

/// A reusable glass effect container component that provides Apple-like
/// liquid glass appearance with backdrop blur, tint, and edge highlights.
class GlassContainer extends StatelessWidget {
  /// The child widget to display inside the glass container.
  final Widget child;

  /// Sigma value for the backdrop blur effect (default: 20.0).
  final double blurSigma;

  /// Opacity of the tint overlay (0.0 to 1.0, default: 0.15).
  final double opacity;

  /// Border radius for the container (default: 35.0).
  final double borderRadius;

  /// Padding inside the container.
  final EdgeInsets padding;

  /// Whether to show the border highlight (default: true).
  final bool showBorder;

  /// Background color for the tint overlay (default: white for light mode).
  final Color? backgroundColor;

  /// Border color for the edge highlight (default: white with opacity).
  final Color? borderColor;

  /// Optional width constraint.
  final double? width;

  /// Optional height constraint.
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.blurSigma = 20.0,
    this.opacity = 0.15,
    this.borderRadius = 35.0,
    this.padding = EdgeInsets.zero,
    this.showBorder = true,
    this.backgroundColor,
    this.borderColor,
    this.width,
    this.height,
  });

  /// Light mode optimized glass container.
  static GlassContainer light({
    Key? key,
    required Widget child,
    double blurSigma = 21.0, // Tuned: 18-24 range
    double opacity = 0.15, // Tuned: 0.12-0.18 range
    double borderRadius = 35.0,
    EdgeInsets padding = EdgeInsets.zero,
    bool showBorder = true,
    double? width,
    double? height,
  }) {
    return GlassContainer(
      key: key,
      blurSigma: blurSigma,
      opacity: opacity,
      borderRadius: borderRadius,
      padding: padding,
      showBorder: showBorder,
      backgroundColor: Colors.white.withValues(alpha: opacity),
      borderColor: Colors.white
          .withValues(alpha: 0.35), // Slightly increased for better visibility
      width: width,
      height: height,
      child: child,
    );
  }

  /// Dark mode optimized glass container.
  static GlassContainer dark({
    Key? key,
    required Widget child,
    double blurSigma = 22.0, // Tuned: 18-24 range
    double opacity = 0.22, // Tuned: 0.18-0.26 range
    double borderRadius = 35.0,
    EdgeInsets padding = EdgeInsets.zero,
    bool showBorder = true,
    double? width,
    double? height,
  }) {
    return GlassContainer(
      key: key,
      blurSigma: blurSigma,
      opacity: opacity,
      borderRadius: borderRadius,
      padding: padding,
      showBorder: showBorder,
      backgroundColor: Colors.black.withValues(alpha: opacity),
      borderColor: Colors.white
          .withValues(alpha: 0.25), // Slightly increased for better visibility
      width: width,
      height: height,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    // Use high text scale factor as proxy for reduced transparency preference
    // High contrast mode or accessibility needs often prefer solid backgrounds
    final isReducedTransparency = mediaQuery.textScaler.scale(1.0) > 1.3 ||
        mediaQuery.boldText ||
        mediaQuery.highContrast;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    // Use provided colors or default based on theme
    final bgColor = backgroundColor ??
        (isDark
            ? Colors.black.withValues(alpha: opacity)
            : Colors.white.withValues(alpha: opacity));
    final borderClr = borderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.3));

    // Reduced transparency mode: use solid surface without blur
    if (isReducedTransparency) {
      return Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.grey.shade900.withValues(alpha: 0.95)
              : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(borderRadius),
          border: showBorder
              ? Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.1),
                  width: 1.0,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      );
    }

    // Full glass effect with blur
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(
                color: borderClr,
                width: 1.5,
              )
            : null,
        // Soft shadow for depth
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            // Subtle top highlight gradient overlay (specular line effect)
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: isDark ? 0.08 : 0.12),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.3],
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
