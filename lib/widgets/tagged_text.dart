import 'package:flutter/material.dart';

/// A widget that renders text with <red>...</red> tags as red TextSpans.
///
/// Supports multiple <red> segments in one string.
/// If tags are malformed or missing, renders the entire string as plain text.
/// Respects RTL/LTR directionality from context.
class TaggedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TaggedText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final spans = _parseTaggedText(text, style, primaryColor);

    return RichText(
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      text: TextSpan(
        style: style ?? DefaultTextStyle.of(context).style,
        children: spans,
      ),
    );
  }

  /// Parses a string containing <red>...</red> tags and returns TextSpans.
  ///
  /// Handles:
  /// - Multiple <red> segments
  /// - Malformed tags (no closing tag) - renders as plain text
  /// - Nested tags (not supported, will render incorrectly but won't crash)
  static List<TextSpan> _parseTaggedText(
      String text, TextStyle? baseStyle, Color highlightColor) {
    final spans = <TextSpan>[];
    int currentIndex = 0;
    const openTag = '<red>';
    const closeTag = '</red>';

    while (currentIndex < text.length) {
      // Find next opening tag
      final openIndex = text.indexOf(openTag, currentIndex);

      if (openIndex == -1) {
        // No more tags, add remaining text
        if (currentIndex < text.length) {
          spans.add(TextSpan(
            text: text.substring(currentIndex),
            style: baseStyle,
          ));
        }
        break;
      }

      // Add text before the opening tag
      if (openIndex > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, openIndex),
          style: baseStyle,
        ));
      }

      // Find corresponding closing tag
      final closeIndex = text.indexOf(closeTag, openIndex + openTag.length);

      if (closeIndex == -1) {
        // No closing tag found - malformed, render rest as plain text
        spans.add(TextSpan(
          text: text.substring(openIndex),
          style: baseStyle,
        ));
        break;
      }

      // Extract content between tags
      final contentStart = openIndex + openTag.length;
      final content = text.substring(contentStart, closeIndex);

      // Add red text span
      spans.add(TextSpan(
        text: content,
        style: (baseStyle ?? const TextStyle()).copyWith(
          color: highlightColor,
          fontWeight: FontWeight.w600,
        ),
      ));

      // Move past the closing tag
      currentIndex = closeIndex + closeTag.length;
    }

    // If no tags were found, return the whole text as a single span
    if (spans.isEmpty) {
      return [TextSpan(text: text, style: baseStyle)];
    }

    return spans;
  }
}
