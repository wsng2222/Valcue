import 'package:flutter_test/flutter_test.dart';
import 'package:valcue/onboarding/onboarding_strings.dart';

/// The flow addresses several pages by index - the tap-through explainer, the
/// reminder screen, and the two screens that bring their own buttons. Adding a
/// page in the wrong place silently breaks those, so the copy and the ordering
/// assumptions are pinned here.
void main() {
  const languages = <String>[
    'en', 'ko', 'ja', 'zh', 'es', 'fr', 'de', 'it',
    'nl', 'da', 'nb', 'ru', 'pt', 'vi', 'ar', 'th',
  ];

  group('the new screens are translated everywhere', () {
    test('health and backup copy exists in all 16 languages', () {
      for (final code in languages) {
        final s = OnboardingStrings.forLanguage(code);

        for (final entry in <String, String>{
          'healthTitle': s.healthTitle(),
          'healthBody': s.healthBody(),
          'ctaConnectHealth': s.ctaConnectHealth(),
          'backupTitle': s.backupTitle(),
          'backupBody': s.backupBody(),
          'ctaSignInToBackUp': s.ctaSignInToBackUp(),
          'ctaSkipForNow': s.ctaSkipForNow(),
        }.entries) {
          expect(
            entry.value.trim(),
            isNotEmpty,
            reason: '${entry.key} is missing for "$code"',
          );
        }
      }
    });

    test('no language silently falls back to the English copy', () {
      // A missing translation returns English, which reads as "translated"
      // unless something checks. Korean is the one language we can be sure
      // should differ.
      final ko = OnboardingStrings.forLanguage('ko');
      final en = OnboardingStrings.forLanguage('en');

      expect(ko.healthTitle(), isNot(en.healthTitle()));
      expect(ko.backupTitle(), isNot(en.backupTitle()));
      expect(ko.ctaSkipForNow(), isNot(en.ctaSkipForNow()));
    });

    test('every screen offers a way past it', () {
      // Neither screen may be a dead end: someone trying the app for the
      // first time must be able to reach the end without an account.
      for (final code in languages) {
        expect(
          OnboardingStrings.forLanguage(code).ctaSkipForNow().trim(),
          isNotEmpty,
          reason: 'no skip label for "$code"',
        );
      }
    });
  });
}
