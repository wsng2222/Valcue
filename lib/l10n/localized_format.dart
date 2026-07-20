import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Locale-aware formatting for values rendered by Flutter widgets.
class LocalizedFormat {
  const LocalizedFormat._();

  static String localeName(BuildContext context) =>
      Localizations.localeOf(context).toLanguageTag();

  static String decimal(
    BuildContext context,
    num value, {
    int decimalDigits = 1,
  }) {
    final formatter = NumberFormat.decimalPattern(localeName(context))
      ..minimumFractionDigits = decimalDigits
      ..maximumFractionDigits = decimalDigits;
    return formatter.format(value);
  }

  static String percent(
    BuildContext context,
    num value, {
    int decimalDigits = 0,
  }) {
    final formatter = NumberFormat.percentPattern(localeName(context))
      ..minimumFractionDigits = decimalDigits
      ..maximumFractionDigits = decimalDigits;
    return formatter.format(value);
  }

  /// Parses user-entered decimal values using the active locale. The alternate
  /// decimal separator is also accepted when no grouping separator is present,
  /// which keeps pasted values such as `72.5` usable in comma-decimal locales.
  static double? tryParseDecimal(BuildContext context, String input) {
    final locale = localeName(context);
    final formatter = NumberFormat.decimalPattern(locale);
    final decimalSeparator = formatter.symbols.DECIMAL_SEP;
    var normalized = input.trim().replaceAll(RegExp(r'[\u00a0\u202f\s]'), '');
    if (normalized.isEmpty) return null;
    if (decimalSeparator != '.' &&
        normalized.contains('.') &&
        !normalized.contains(decimalSeparator)) {
      normalized = normalized.replaceAll('.', decimalSeparator);
    } else if (decimalSeparator == '.' &&
        normalized.contains(',') &&
        !normalized.contains('.')) {
      normalized = normalized.replaceAll(',', '.');
    }
    return formatter.tryParse(normalized)?.toDouble();
  }

  static String date(BuildContext context, DateTime value) =>
      DateFormat.yMd(localeName(context)).format(value);

  static String mediumDate(BuildContext context, DateTime value) =>
      DateFormat.yMMMd(localeName(context)).format(value);

  static String longDate(BuildContext context, DateTime value) =>
      DateFormat.yMMMMd(localeName(context)).format(value);

  static String yearMonth(BuildContext context, DateTime value) =>
      DateFormat.yMMMM(localeName(context)).format(value);

  static String monthDay(BuildContext context, DateTime value) =>
      DateFormat.Md(localeName(context)).format(value);

  static String monthAbbreviation(BuildContext context, DateTime value) =>
      DateFormat.MMM(localeName(context)).format(value);

  static String abbreviatedMonthDay(BuildContext context, DateTime value) =>
      DateFormat.MMMd(localeName(context)).format(value);

  static String time(BuildContext context, DateTime value) =>
      DateFormat.Hm(localeName(context)).format(value);

  static String dateTime(BuildContext context, DateTime value) =>
      '${date(context, value)} · ${time(context, value)}';

  static String compactList(BuildContext context, Iterable<String> values) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final separator = switch (languageCode) {
      'ar' => '، ',
      'ja' || 'zh' => '、',
      _ => ', ',
    };
    return values.join(separator);
  }
}
