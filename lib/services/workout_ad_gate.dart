import 'package:flutter/foundation.dart';

import 'ad_service.dart';

/// Where in the workout flow an interstitial would appear.
enum WorkoutAdPlacement {
  /// Just before a workout screen opens.
  beforeWorkout,

  /// On the way out of the finished screen, which is rate limited so a person
  /// training several times in a row isn't shown an ad after every session.
  afterWorkout,
}

/// The single place that decides whether a workout interstitial is shown.
///
/// Every entry point into a workout goes through [run] instead of calling
/// [AdService] directly, so the "premium never sees ads" rule lives in one
/// testable spot rather than being copied into each screen. [run] also
/// guarantees [onContinue] fires exactly once, whether the ad showed, was
/// skipped, or failed - the caller never has to navigate defensively.
class WorkoutAdGate {
  WorkoutAdGate({
    Future<bool> Function()? isPostWorkoutAdDue,
    bool Function({VoidCallback? onAdClosed})? presentAd,
  })  : _isPostWorkoutAdDue =
            isPostWorkoutAdDue ?? AdService().shouldShowPostWorkoutAd,
        _presentAd = presentAd ?? AdService().showAd;

  static final WorkoutAdGate instance = WorkoutAdGate();

  final Future<bool> Function() _isPostWorkoutAdDue;
  final bool Function({VoidCallback? onAdClosed}) _presentAd;

  /// Shows an interstitial if one is due for [placement], then runs
  /// [onContinue] exactly once.
  Future<void> run({
    required bool isPremium,
    required WorkoutAdPlacement placement,
    required VoidCallback onContinue,
  }) async {
    var hasContinued = false;
    void continueOnce() {
      if (hasContinued) return;
      hasContinued = true;
      onContinue();
    }

    if (isPremium) {
      continueOnce();
      return;
    }

    if (placement == WorkoutAdPlacement.afterWorkout &&
        !await _isPostWorkoutAdDue()) {
      continueOnce();
      return;
    }

    // presentAd already runs the callback when nothing can be shown, so
    // continueOnce absorbs the second call rather than navigating twice.
    if (!_presentAd(onAdClosed: continueOnce)) {
      continueOnce();
    }
  }
}
