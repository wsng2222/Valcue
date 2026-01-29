import 'package:flutter/material.dart';

/// A text widget that ensures LTR rendering for values containing digits,
/// colons, decimals, slashes, or Latin letters, while respecting RTL for other text.
///
/// This prevents bidirectional text flips in Arabic UI for:
/// - Timers: "00:34"
/// - Numbers: "12.5"
/// - Units: "km/h", "mph", "RPM"
/// - Mixed: "5/10", "A-Z"
class BidiSafeText extends StatelessWidget {
  /// The text to display
  final String text;

  /// The text style
  final TextStyle? style;

  /// Text alignment
  final TextAlign? textAlign;

  /// Maximum number of lines
  final int? maxLines;

  /// Text overflow handling
  final TextOverflow? overflow;

  /// Whether to force LTR even if no LTR characters are detected
  final bool forceLTR;

  const BidiSafeText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.forceLTR = false,
  });

  /// Detects if the string contains any LTR characters that should stay LTR:
  /// - Digits: 0-9
  /// - Time separators: :
  /// - Decimal points: .
  /// - Slashes: /
  /// - Latin letters: A-Z, a-z
  static bool _containsLTRCharacters(String text) {
    final ltrPattern = RegExp(r'[0-9:./A-Za-z]');
    return ltrPattern.hasMatch(text);
  }

  /// Determines if the text should be rendered LTR
  static bool shouldRenderLTR(String text, {bool forceLTR = false}) {
    if (forceLTR) return true;
    return _containsLTRCharacters(text);
  }

  @override
  Widget build(BuildContext context) {
    final shouldLTR = shouldRenderLTR(text, forceLTR: forceLTR);

    final textWidget = Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );

    // If the text contains LTR characters, wrap it in Directionality to force LTR
    if (shouldLTR) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: textWidget,
      );
    }

    // Otherwise, use ambient Directionality (will be RTL in Arabic, LTR in others)
    return textWidget;
  }
}
