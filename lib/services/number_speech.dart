import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Locale-aware number → TTS-friendly string formatting.
///
/// - Korean (`ko`) supports "영 점 오" style decimal reading.
/// - Other locales default to normal number formatting (e.g. "8.5") and can be
///   extended later.
class NumberSpeech {
  static String numberToSpeechString(
    Locale locale,
    num value, {
    int? fixedFractionDigits,
  }) {
    if (locale.languageCode == 'ko') {
      return _koNumberToSpeech(value, fixedFractionDigits: fixedFractionDigits);
    }

    return _defaultNumberToSpeech(
      locale,
      value,
      fixedFractionDigits: fixedFractionDigits,
    );
  }

  static String _defaultNumberToSpeech(
    Locale locale,
    num value, {
    int? fixedFractionDigits,
  }) {
    try {
      final tag = locale.toLanguageTag();
      final nf = NumberFormat.decimalPattern(tag);
      if (fixedFractionDigits != null) {
        nf.minimumFractionDigits = fixedFractionDigits;
        nf.maximumFractionDigits = fixedFractionDigits;
      }
      return nf.format(value);
    } catch (_) {
      if (value is double && fixedFractionDigits != null) {
        return value.toStringAsFixed(fixedFractionDigits);
      }
      return value.toString();
    }
  }

  static String _koNumberToSpeech(
    num value, {
    int? fixedFractionDigits,
  }) {
    // Handle negative values (unlikely for this app but safe).
    final isNegative = value < 0;
    final abs = value.abs();

    // Int path.
    if (abs is int) {
      final spoken = _koIntToSino(abs);
      return isNegative ? '마이너스 $spoken' : spoken;
    }

    // Decimal path.
    final d = abs.toDouble();
    final fractionDigits = fixedFractionDigits ?? _inferFractionDigits(d);
    final fixed = d.toStringAsFixed(fractionDigits); // e.g. "10.0"
    final parts = fixed.split('.');
    final intPart = int.tryParse(parts[0]) ?? 0;
    final fracPart = parts.length > 1 ? parts[1] : '';

    final intSpoken = _koIntToSino(intPart);
    if (fracPart.isEmpty) {
      return isNegative ? '마이너스 $intSpoken' : intSpoken;
    }

    final digitsSpoken = fracPart
        .split('')
        .map((c) => _koDigit(c))
        .where((s) => s.isNotEmpty)
        .join(' ');

    final spoken = '$intSpoken 점 $digitsSpoken'.trim();
    return isNegative ? '마이너스 $spoken' : spoken;
  }

  static int _inferFractionDigits(double value) {
    // Default to 1 decimal for most workout metrics (0.5 steps).
    // If the number looks like an integer, still keep 1 digit to read "점 영".
    return 1;
  }

  static String _koDigit(String digitChar) {
    switch (digitChar) {
      case '0':
        return '영';
      case '1':
        return '일';
      case '2':
        return '이';
      case '3':
        return '삼';
      case '4':
        return '사';
      case '5':
        return '오';
      case '6':
        return '육';
      case '7':
        return '칠';
      case '8':
        return '팔';
      case '9':
        return '구';
      default:
        return '';
    }
  }

  /// Sino-Korean number reading for integers.
  ///
  /// Examples:
  /// - 0 -> "영"
  /// - 5 -> "오"
  /// - 10 -> "십"
  /// - 25 -> "이십오"
  static String _koIntToSino(int n) {
    if (n == 0) return '영';
    if (n < 0) return '마이너스 ${_koIntToSino(-n)}';

    const digits = <String>[
      '',
      '일',
      '이',
      '삼',
      '사',
      '오',
      '육',
      '칠',
      '팔',
      '구',
    ];

    const smallUnits = <String>['', '십', '백', '천'];
    const bigUnits = <String>['', '만', '억', '조']; // enough for our range

    String chunkToSpeech(int chunk) {
      // chunk: 0..9999
      final parts = <String>[];
      final d0 = chunk % 10;
      final d1 = (chunk ~/ 10) % 10;
      final d2 = (chunk ~/ 100) % 10;
      final d3 = (chunk ~/ 1000) % 10;
      final ds = [d0, d1, d2, d3];

      for (int i = 3; i >= 0; i--) {
        final digit = ds[i];
        if (digit == 0) continue;

        final unit = smallUnits[i];
        if (i == 1 || i == 2 || i == 3) {
          // For 십/백/천, omit "일" prefix (e.g. 10 = 십, 100 = 백).
          if (digit == 1) {
            parts.add(unit);
          } else {
            parts.add('${digits[digit]}$unit');
          }
        } else {
          parts.add(digits[digit]);
        }
      }
      return parts.join('');
    }

    final chunks = <int>[];
    int temp = n;
    while (temp > 0) {
      chunks.add(temp % 10000);
      temp ~/= 10000;
    }

    final out = <String>[];
    for (int i = chunks.length - 1; i >= 0; i--) {
      final chunk = chunks[i];
      if (chunk == 0) continue;
      final spoken = chunkToSpeech(chunk);
      final unit = bigUnits[i];
      out.add('$spoken$unit');
    }

    return out.join('');
  }
}

