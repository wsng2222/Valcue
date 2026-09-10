import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valcue/services/ad_service.dart';

const String _counterKey = 'flutter.ad_post_workout_counter';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('post-workout ad cadence', () {
    test('shows an ad on every third workout finish, not every one', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final adService = AdService();

      final decisions = <bool>[];
      for (var i = 0; i < 7; i++) {
        decisions.add(await adService.shouldShowPostWorkoutAd());
      }

      // Someone training back to back only meets an ad on finishes 3 and 6.
      expect(decisions, [false, false, true, false, false, true, false]);
    });

    test('resumes the cadence from the persisted counter', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{_counterKey: 2});
      final adService = AdService();

      expect(await adService.shouldShowPostWorkoutAd(), isTrue);
      expect(await adService.shouldShowPostWorkoutAd(), isFalse);
    });

    test('advances the counter even on a finish that shows no ad', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final adService = AdService();

      await adService.shouldShowPostWorkoutAd();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('ad_post_workout_counter'), 1);
    });

    test('skips the ad rather than throwing on a corrupt counter', () async {
      // A wrong-typed value would make getInt throw; a workout must still be
      // able to finish, so the failure has to resolve to "no ad".
      SharedPreferences.setMockInitialValues(
        <String, Object>{_counterKey: 'not-a-number'},
      );
      final adService = AdService();

      expect(await adService.shouldShowPostWorkoutAd(), isFalse);
    });
  });

  group('interstitial availability', () {
    test('is not ready before an ad has loaded', () {
      final adService = AdService();
      adService.dispose();

      expect(adService.isAdReady, isFalse);
    });

    test('showAd runs the continuation immediately when no ad is ready', () {
      final adService = AdService();
      adService.dispose();

      var continued = false;
      final wasShown = adService.showAd(onAdClosed: () => continued = true);

      // The workout must never be blocked by a missing ad.
      expect(wasShown, isFalse);
      expect(continued, isTrue);
    });
  });
}
