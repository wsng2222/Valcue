import 'package:flutter/widgets.dart';

/// Canonical catalog for every locale exposed by the app.
///
/// Persistence continues to use the stable base language [code], while
/// [locale] pins the regional conventions used for dates, numbers, speech,
/// and other locale-sensitive presentation.
class SupportedAppLanguage {
  const SupportedAppLanguage({
    required this.code,
    required this.locale,
    required this.nativeName,
  });

  final String code;
  final Locale locale;
  final String nativeName;

  static const all = <SupportedAppLanguage>[
    SupportedAppLanguage(
      code: 'en',
      locale: Locale('en', 'US'),
      nativeName: 'English (US)',
    ),
    SupportedAppLanguage(
      code: 'es',
      locale: Locale('es', 'ES'),
      nativeName: 'Español (España)',
    ),
    SupportedAppLanguage(
      code: 'fr',
      locale: Locale('fr', 'FR'),
      nativeName: 'Français',
    ),
    SupportedAppLanguage(
      code: 'de',
      locale: Locale('de', 'DE'),
      nativeName: 'Deutsch',
    ),
    SupportedAppLanguage(
      code: 'it',
      locale: Locale('it', 'IT'),
      nativeName: 'Italiano',
    ),
    SupportedAppLanguage(
      code: 'nl',
      locale: Locale('nl', 'NL'),
      nativeName: 'Nederlands',
    ),
    SupportedAppLanguage(
      code: 'da',
      locale: Locale('da', 'DK'),
      nativeName: 'Dansk',
    ),
    SupportedAppLanguage(
      code: 'nb',
      locale: Locale('nb', 'NO'),
      nativeName: 'Norsk bokmål',
    ),
    SupportedAppLanguage(
      code: 'ru',
      locale: Locale('ru', 'RU'),
      nativeName: 'Русский',
    ),
    SupportedAppLanguage(
      code: 'pt',
      locale: Locale('pt', 'BR'),
      nativeName: 'Português (Brasil)',
    ),
    SupportedAppLanguage(
      code: 'ja',
      locale: Locale('ja', 'JP'),
      nativeName: '日本語',
    ),
    SupportedAppLanguage(
      code: 'zh',
      locale: Locale('zh', 'CN'),
      nativeName: '简体中文',
    ),
    SupportedAppLanguage(
      code: 'ko',
      locale: Locale('ko', 'KR'),
      nativeName: '한국어',
    ),
    SupportedAppLanguage(
      code: 'vi',
      locale: Locale('vi', 'VN'),
      nativeName: 'Tiếng Việt',
    ),
    SupportedAppLanguage(
      code: 'ar',
      locale: Locale('ar', 'SA'),
      nativeName: 'العربية',
    ),
    SupportedAppLanguage(
      code: 'th',
      locale: Locale('th', 'TH'),
      nativeName: 'ไทย',
    ),
  ];

  static final codes = Set<String>.unmodifiable(
    all.map((language) => language.code),
  );

  static final codesInDisplayOrder = List<String>.unmodifiable(
    all.map((language) => language.code),
  );

  static final locales = List<Locale>.unmodifiable(
    all.map((language) => language.locale),
  );

  static bool supports(String languageCode) => codes.contains(languageCode);

  static SupportedAppLanguage fromCode(String languageCode) {
    return all.firstWhere(
      (language) => language.code == languageCode,
      orElse: () => all.first,
    );
  }
}
