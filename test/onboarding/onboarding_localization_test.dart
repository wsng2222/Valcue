import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valcue/onboarding/onboarding_strings.dart';

void main() {
  const languageCodes = [
    'en',
    'es',
    'fr',
    'de',
    'it',
    'nl',
    'da',
    'nb',
    'ru',
    'pt',
    'ja',
    'zh',
    'ko',
    'vi',
    'ar',
    'th',
  ];
  final locales = languageCodes.map(Locale.new).toList();

  testWidgets('new onboarding copy is translated in every app language', (
    tester,
  ) async {
    Future<List<String>> copyFor(String languageCode) async {
      late List<String> copy;
      late List<String> weekdays;
      await tester.pumpWidget(
        MaterialApp(
          key: ValueKey(languageCode),
          locale: Locale(languageCode),
          supportedLocales: locales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              final strings = OnboardingStrings.of(context);
              weekdays = MaterialLocalizations.of(context).narrowWeekdays;
              copy = [
                strings.aiIntroBody(),
                strings.aiGenerationSemantics(),
                strings.reminderBody(),
                strings.reminderDaysLabel(),
                strings.s6TitleSpans().map((span) => span.text).join(),
                strings.s7TitleSpans().map((span) => span.text).join(),
                strings.historyWeeklyConsistencyLabel(),
                strings.premiumBullet1(),
              ];
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(weekdays, hasLength(7));
      return copy;
    }

    final english = await copyFor('en');
    for (final languageCode in languageCodes.skip(1)) {
      final localized = await copyFor(languageCode);
      for (var index = 0; index < localized.length; index++) {
        expect(
          localized[index],
          isNot(equals(english[index])),
          reason: '$languageCode fell back to English at copy index $index',
        );
      }
    }
  });
}
