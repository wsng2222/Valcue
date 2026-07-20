import 'package:flutter/material.dart';

/// A text widget that can isolate machine-readable values in LTR direction.
///
/// Normal localized sentences always keep the ambient direction. Callers opt
/// in with [forceLTR] only for direction-independent values such as timers,
/// ratios, and metric readouts. Inferring direction from a single Latin letter
/// or digit would incorrectly flip an entire Arabic sentence.
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

  /// Whether this value is direction-independent and must render LTR.
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

  /// Kept as a small, testable policy helper.
  static bool shouldRenderLTR(String text, {bool forceLTR = false}) {
    return forceLTR;
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
