import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valcue/services/workout_ad_gate.dart';

void main() {
  group('premium never sees an ad', () {
    for (final placement in WorkoutAdPlacement.values) {
      test('skips straight to the workout at $placement', () async {
        final ads = _FakeAdPresenter();
        var continued = 0;

        await _gate(ads).run(
          isPremium: true,
          placement: placement,
          onContinue: () => continued++,
        );

        expect(ads.presentCount, 0);
        expect(ads.dueChecks, 0);
        expect(continued, 1);
      });
    }
  });

  group('free users before a workout', () {
    test('shows an ad every time, with no cadence check', () async {
      final ads = _FakeAdPresenter(canShow: true);
      var continued = 0;

      await _gate(ads).run(
        isPremium: false,
        placement: WorkoutAdPlacement.beforeWorkout,
        onContinue: () => continued++,
      );

      expect(ads.presentCount, 1);
      expect(ads.dueChecks, 0);
      // The workout waits behind the ad until it is dismissed.
      expect(continued, 0);

      ads.dismiss();

      expect(continued, 1);
    });
  });

  group('free users after a workout', () {
    test('shows an ad when one is due', () async {
      final ads = _FakeAdPresenter(canShow: true);

      await _gate(ads, isDue: true).run(
        isPremium: false,
        placement: WorkoutAdPlacement.afterWorkout,
        onContinue: () {},
      );

      expect(ads.presentCount, 1);
    });

    test('stays quiet when the cadence says no', () async {
      final ads = _FakeAdPresenter(canShow: true);
      var continued = 0;

      await _gate(ads, isDue: false).run(
        isPremium: false,
        placement: WorkoutAdPlacement.afterWorkout,
        onContinue: () => continued++,
      );

      expect(ads.presentCount, 0);
      expect(continued, 1);
    });
  });

  group('the workout always opens, exactly once', () {
    test('once when no ad is loaded', () async {
      // The old inline code navigated from the ad callback AND from the
      // "wasn't shown" branch, pushing the workout screen twice.
      final ads = _FakeAdPresenter(canShow: false);
      var continued = 0;

      await _gate(ads).run(
        isPremium: false,
        placement: WorkoutAdPlacement.beforeWorkout,
        onContinue: () => continued++,
      );

      expect(continued, 1);
    });

    test('once when the ad shows and is then dismissed', () async {
      final ads = _FakeAdPresenter(canShow: true);
      var continued = 0;

      await _gate(ads).run(
        isPremium: false,
        placement: WorkoutAdPlacement.beforeWorkout,
        onContinue: () => continued++,
      );
      expect(continued, 0);

      ads.dismiss();

      expect(continued, 1);
    });

    test('once even if the ad reports dismissal more than once', () async {
      final ads = _FakeAdPresenter(canShow: true);
      var continued = 0;

      await _gate(ads).run(
        isPremium: false,
        placement: WorkoutAdPlacement.beforeWorkout,
        onContinue: () => continued++,
      );
      ads.dismiss();
      ads.dismiss();

      expect(continued, 1);
    });
  });
}

WorkoutAdGate _gate(_FakeAdPresenter ads, {bool isDue = true}) {
  return WorkoutAdGate(
    isPostWorkoutAdDue: () async {
      ads.dueChecks++;
      return isDue;
    },
    presentAd: ads.present,
  );
}

class _FakeAdPresenter {
  _FakeAdPresenter({this.canShow = false});

  final bool canShow;
  int presentCount = 0;
  int dueChecks = 0;
  VoidCallback? _onClosed;

  bool present({VoidCallback? onAdClosed}) {
    presentCount++;
    if (!canShow) {
      // Mirrors AdService: it runs the callback itself, then reports false.
      onAdClosed?.call();
      return false;
    }
    _onClosed = onAdClosed;
    return true;
  }

  void dismiss() => _onClosed?.call();
}
