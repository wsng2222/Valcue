// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Interval Cardio';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get system => 'System';

  @override
  String get voiceGuide => 'Voice Guide';

  @override
  String get audioNavigator => 'Audio Navigator';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get unitSetting => 'Unit Setting';

  @override
  String get kmh => 'km/h';

  @override
  String get mph => 'mph';

  @override
  String get themeMode => 'Light/Dark Mode';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get smartwatchSync => 'Smartwatch Sync';

  @override
  String get connectSmartwatch => 'Connect to smartwatch';

  @override
  String get connect => 'Connect';

  @override
  String get about => 'About';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get translationComingSoon =>
      'Translation will be available in a future update.';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get done => 'Done';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get start => 'Start';

  @override
  String get editRoutine => 'Edit Routine';

  @override
  String get routineEdit => 'Routine Edit';

  @override
  String get name => 'Name';

  @override
  String get unnamedRoutine => 'Unnamed Routine';

  @override
  String get difficulty => 'Difficulty';

  @override
  String difficultyColon(String difficulty) {
    return 'Difficulty : $difficulty';
  }

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get interval => 'Interval';

  @override
  String get addInterval => 'Add Interval';

  @override
  String get noIntervals => 'No intervals';

  @override
  String get addIntervalPrompt => 'Add an interval';

  @override
  String get intervalEdit => 'Interval Edit';

  @override
  String get timeMinutes => 'Time (minutes)';

  @override
  String get duration => 'Duration';

  @override
  String get speed => 'Speed';

  @override
  String get speedKmh => 'Speed (km/h)';

  @override
  String get incline => 'Incline';

  @override
  String get level => 'Level';

  @override
  String levelColon(int level) {
    return 'Level $level';
  }

  @override
  String get rpm => 'RPM';

  @override
  String get resistance => 'Resistance';

  @override
  String get resistanceLevel => 'Resistance (Level)';

  @override
  String resistanceColon(int resistance) {
    return 'Resistance $resistance';
  }

  @override
  String get spm => 'SPM';

  @override
  String get spmSteps => 'SPM (steps/min)';

  @override
  String get saved => 'Saved';

  @override
  String get deleted => 'Deleted';

  @override
  String get deleteRoutineTitle => 'Delete Routine';

  @override
  String get deleteRoutineMessage =>
      'Are you sure you want to delete this routine? This cannot be undone.';

  @override
  String get deleteError => 'An error occurred while deleting';

  @override
  String get nameRequired => 'Please enter a name';

  @override
  String get nameMaxLength => 'Name must be 24 characters or less';

  @override
  String get minIntervalsRequired => 'At least one interval is required';

  @override
  String get intervalMinDuration =>
      'Interval duration must be at least 1 second';

  @override
  String get intervalMaxDuration =>
      'Interval duration must be at most 3 hours (10800 seconds)';

  @override
  String get speedRange => 'Speed must be greater than 0 (0.5-25.0 km/h)';

  @override
  String get inclineRange => 'Incline must be in range 0-15.0';

  @override
  String get rpmRange => 'RPM must be in range 30-200';

  @override
  String get resistanceRange => 'Resistance must be in range 1-20';

  @override
  String get levelRange => 'Level must be in range 1-20';

  @override
  String get spmRange => 'SPM must be in range 50-200';

  @override
  String get noRoutinesSaved => 'No routines saved';

  @override
  String get tapToCreate => 'Tap to create';

  @override
  String get tapButtonToCreate => 'Tap the button to create';

  @override
  String get premiumRoutineSettings => 'Premium Routine Settings';

  @override
  String get viewMembership => 'View Membership';

  @override
  String get freeLimitTitle => 'Free limit is 2 routines';

  @override
  String get freeLimitMessage =>
      'You can use unlimited routines with membership';

  @override
  String get treadmill => 'Treadmill';

  @override
  String get cycle => 'Cycle';

  @override
  String get stairmaster => 'Stairmaster';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get selectDifficulty => 'Select Difficulty';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get endWorkout => 'End Workout';

  @override
  String get endWorkoutConfirm => 'Do you want to end the workout?';

  @override
  String get end => 'End';

  @override
  String get rotate => 'Rotate';

  @override
  String get paused => 'PAUSED';

  @override
  String get pausedTitle => 'Paused';

  @override
  String get pausedSubtitle => 'You can continue or end the workout';

  @override
  String get endWorkoutConfirmationMessage =>
      'If you end now, the current workout will finish and you will move to the summary screen.';

  @override
  String get workoutComplete => 'Workout Complete';

  @override
  String get totalWorkoutTime => 'Total Time';

  @override
  String get totalDistance => 'Total distance';

  @override
  String get averageRpm => 'Average RPM';

  @override
  String get averageLevel => 'Average Level';

  @override
  String get holdToStop => 'Hold to Stop';

  @override
  String get continueWorkout => 'Continue';

  @override
  String get endWorkoutQuestion => 'Do you want to end the workout?';

  @override
  String get workoutPaused => 'Workout has been paused';

  @override
  String get lvlIncline => 'Incline';

  @override
  String get lvlResistance => 'Lvl Resistance';

  @override
  String get premium => 'Premium';

  @override
  String get upgradeNow => 'Upgrade Now';

  @override
  String get purchase => 'Purchase';

  @override
  String get later => 'Later';

  @override
  String get premiumActivated => 'Premium has been activated';

  @override
  String get premiumMembership => 'Premium Membership';

  @override
  String get benefitCycleStairmaster => 'Cycle, Stairmaster feature';

  @override
  String get benefitVoiceGuide => 'Session voice guide feature';

  @override
  String get benefitUnlimitedRoutines => 'Unlimited routine saves';

  @override
  String get noAds => 'No Ads';

  @override
  String get benefitFutureFeatures => 'Unlimited access to future features';

  @override
  String get voiceGuideBenefit1 => 'Voice guidance during workout';

  @override
  String get voiceGuideBenefit2 => 'Automatic session transition announcements';

  @override
  String get voiceGuideBenefit3 => 'Hands-free routine focus';

  @override
  String get routineLimitBenefit1 => 'Unlimited routine saves';

  @override
  String get routineLimitBenefit2 => 'Save routines for multiple goals';

  @override
  String get routineLimitBenefit3 =>
      'Use all machine types (treadmill/cycle/stairmaster)';

  @override
  String get premium_benefit_1 => '<red>Bike & StairMaster</red> workouts';

  @override
  String get premium_benefit_2 => 'Session <red>voice guide</red>';

  @override
  String get premium_benefit_3 => '<red>Unlimited</red> routine saves';

  @override
  String get premium_benefit_4 =>
      '<red>Unlimited access</red> to future features';

  @override
  String originalPrice(String price) {
    return '$price';
  }

  @override
  String monthlyPrice(String price) {
    return '$price/month';
  }

  @override
  String get premiumSubheadline =>
      'Unlock voice guidance, bike & stairmaster workouts, and unlimited routines';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get lifetime => 'Lifetime';

  @override
  String get freeTrial7Days => '7-day free trial';

  @override
  String get perMonth => '/month';

  @override
  String get perYear => '/year';

  @override
  String get oneTime => 'One time';

  @override
  String savePercent(int percent) {
    return 'Save $percent%';
  }

  @override
  String get bestValue => 'Best Value';

  @override
  String get cancelAnytime => 'Cancel anytime';

  @override
  String get autoRenewableSubscription => 'Auto-renewable subscription';

  @override
  String get terms => 'Terms';

  @override
  String get privacy => 'Privacy';

  @override
  String get restore => 'Restore';

  @override
  String get premiumTab => 'Premium';

  @override
  String get routineTab => 'Routine';

  @override
  String get settingsTab => 'Settings';

  @override
  String get myTab => 'My';

  @override
  String get close => 'Close';

  @override
  String get premiumFeature => 'Premium Feature';

  @override
  String get usePremiumTest => 'Use Premium (Test)';

  @override
  String dateTimeFormat(int year, int month, int day, int hour, int minute) {
    return '$month/$day/$year $hour:$minute';
  }

  @override
  String get checkRoutineStart => 'Check Routine / Start';

  @override
  String get beginner => 'Beginner';

  @override
  String get intermediate => 'Intermediate';

  @override
  String get advanced => 'Advanced';

  @override
  String get viewRecommendedRoutines => 'View Recommended Routines →';

  @override
  String get recommendedRoutinesTreadmill => 'Recommended Treadmill Routines';

  @override
  String get recommendedRoutinesCycle => 'Recommended Bike Routines';

  @override
  String get recommendedRoutinesStairmaster =>
      'Recommended Stairmaster Routines';

  @override
  String get alreadySaved => 'Already saved';

  @override
  String get routineSaved => 'Routine saved';

  @override
  String get checkRoutine => 'Check';

  @override
  String get saveRoutine => 'Save Routine';

  @override
  String get routineAlreadySaved => 'Routine already saved';

  @override
  String get noTemplatesFound => 'No templates found';

  @override
  String get avg => 'Avg';

  @override
  String get avgRpm => 'Avg RPM';

  @override
  String get avgLevel => 'Avg level';

  @override
  String get templateTreadmillBeginner1Title => 'Easy Start 20';

  @override
  String get templateTreadmillBeginner1Subtitle => 'Easy 1:1 intervals';

  @override
  String get templateTreadmillBeginner2Title => 'Incline Walk 25';

  @override
  String get templateTreadmillBeginner2Subtitle => 'Incline walk blocks';

  @override
  String get templateTreadmillIntermediate1Title => 'Classic 1:1 24';

  @override
  String get templateTreadmillIntermediate1Subtitle =>
      'Classic 1:1 run intervals';

  @override
  String get templateTreadmillIntermediate2Title => 'Speed Ladder 20';

  @override
  String get templateTreadmillIntermediate2Subtitle => 'Step-up speed ladder';

  @override
  String get templateTreadmillAdvanced1Title => '2:1 Burner 21';

  @override
  String get templateTreadmillAdvanced1Subtitle => '2:1 hard/easy intervals';

  @override
  String get templateTreadmillAdvanced2Title => 'Sprint Pop 18';

  @override
  String get templateTreadmillAdvanced2Subtitle => '20s sprint repeats';

  @override
  String get templateCycleBeginner1Title => 'Cadence Builder 20';

  @override
  String get templateCycleBeginner1Subtitle => '4 min warm-up + 1:1 cadence';

  @override
  String get templateCycleBeginner2Title => 'Steady Ride 25';

  @override
  String get templateCycleBeginner2Subtitle => 'Long steady block';

  @override
  String get templateCycleIntermediate1Title => 'Spin 1:1 24';

  @override
  String get templateCycleIntermediate1Subtitle => 'Classic 1:1 spin intervals';

  @override
  String get templateCycleIntermediate2Title => 'Hill Simulation 22';

  @override
  String get templateCycleIntermediate2Subtitle => 'Climb repeats';

  @override
  String get templateCycleAdvanced1Title => 'Power Intervals 20';

  @override
  String get templateCycleAdvanced1Subtitle => '30s power bursts';

  @override
  String get templateCycleAdvanced2Title => 'Tabata Mix 16';

  @override
  String get templateCycleAdvanced2Subtitle => '20s on / 10s off mix';

  @override
  String get templateStairmasterBeginner1Title => 'Easy Steps 20';

  @override
  String get templateStairmasterBeginner1Subtitle =>
      '4 min warm-up + 1:1 steps';

  @override
  String get templateStairmasterBeginner2Title => 'Long Easy 25';

  @override
  String get templateStairmasterBeginner2Subtitle => 'Long easy climb blocks';

  @override
  String get templateStairmasterIntermediate1Title => '2:1 Climb 21';

  @override
  String get templateStairmasterIntermediate1Subtitle => '2:1 climb repeats';

  @override
  String get templateStairmasterIntermediate2Title => 'Strong 1:1 24';

  @override
  String get templateStairmasterIntermediate2Subtitle => 'Strong 1:1 intervals';

  @override
  String get templateStairmasterAdvanced1Title => 'Hard Blocks 20';

  @override
  String get templateStairmasterAdvanced1Subtitle => '2-min hard blocks';

  @override
  String get templateStairmasterAdvanced2Title => 'Sprint Steps 18';

  @override
  String get templateStairmasterAdvanced2Subtitle =>
      '30s sprints + 60s recoveries';

  @override
  String get historyTab => 'History';

  @override
  String get calendarTab => 'Calendar';

  @override
  String get weightTab => 'Weight';

  @override
  String get bike => 'Bike';

  @override
  String get thisWeek => 'This week';

  @override
  String get trend => 'Trend';

  @override
  String get timeframe7D => '7D';

  @override
  String get timeframe30D => '30D';

  @override
  String get timeframe90D => '90D';

  @override
  String get timeframeAll => 'ALL';

  @override
  String get history => 'History';

  @override
  String get seeAll => 'See all';

  @override
  String get weightEntryDeleted => 'Weight entry deleted';

  @override
  String get weightUpdated => 'Weight updated';

  @override
  String get editWeight => 'Edit weight';

  @override
  String get recordWeight => 'Record weight';

  @override
  String get quickAdjust => 'Quick adjust';

  @override
  String get goalWeightSet => 'Goal weight set';

  @override
  String get goalWeightRemoved => 'Goal weight removed';

  @override
  String get goalAchieved => 'Goal achieved!';

  @override
  String get goalMatchesCurrentWeight => 'Goal matches current weight';

  @override
  String get setGoal => 'Set goal';

  @override
  String get suggested => 'Suggested';

  @override
  String get removeGoal => 'Remove Goal';

  @override
  String get addOneMoreRecordToSeeTrend =>
      'Add 1 more record to see your trend';

  @override
  String get noWeightRecorded => 'No weight recorded yet';

  @override
  String get startTrackingYourWeight =>
      'Start tracking your weight to see progress here';

  @override
  String get treadmillSession => 'Treadmill Session';

  @override
  String get bikeSession => 'Bike Session';

  @override
  String get stairmasterSession => 'Stairmaster Session';

  @override
  String get treadmillWorkout => 'Treadmill Workout';

  @override
  String get bikeWorkout => 'Bike Workout';

  @override
  String get stairmasterWorkout => 'Stairmaster Workout';

  @override
  String get startAWorkoutToSeeItHere => 'Start a workout to see it here';

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';

  @override
  String get sun => 'Sun';

  @override
  String get sessions => 'Sessions';

  @override
  String get distance => 'Distance';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get noWorkoutsYet => 'No workouts yet';

  @override
  String get startYourFirstWorkout =>
      'Start your first workout to see your history here';

  @override
  String get goToRoutines => 'Go to Routines';

  @override
  String get weightRecorded => 'Weight recorded';

  @override
  String get workout => 'workout';

  @override
  String get workouts => 'workouts';

  @override
  String get goal => 'Goal';

  @override
  String get toGo => 'to go';

  @override
  String get over => 'over';

  @override
  String get last => 'Last';

  @override
  String get newLabel => 'New';

  @override
  String youNeed(String amount, String goal) {
    return 'You need $amount to reach $goal';
  }

  @override
  String youNeedPlus(String amount, String goal) {
    return 'You need +$amount to reach $goal';
  }

  @override
  String get current => 'Current';

  @override
  String get premiumHeadline => 'Same 30 minutes, different results';

  @override
  String get premiumSubheadlineNew =>
      'Don\'t just run, exercise the fat-burning way';

  @override
  String get mostPopular => 'Most Popular';

  @override
  String dailyPrice(int price) {
    return '$price per day';
  }

  @override
  String get benefitVoiceCoaching => 'Premium Voice Coaching System';

  @override
  String get benefitCycleStairmasterRoutines =>
      'Full Support for All Cardio Equipment';

  @override
  String get benefitUnlimitedRoutinesNew => 'Unlimited Routine Library';

  @override
  String get benefitWeightFeature => 'Smart Weight Tracking & Analysis';

  @override
  String get benefitNoAdsFocus => 'Ad-Free Premium Experience';

  @override
  String get benefitFutureFeaturesNew => 'All future premium features included';

  @override
  String get mostChosen => 'Most chosen';

  @override
  String get canChangeAnytime => 'Can change anytime';

  @override
  String get startPremium => 'Start Premium';

  @override
  String get cancelAnytimeKeepAccess =>
      'Cancel anytime and keep access until period ends';

  @override
  String workoutDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Workout $count days 🔥',
      one: 'Workout 1 day 🔥',
    );
    return '$_temp0';
  }

  @override
  String restDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rest $count days 🛏️',
      one: 'Rest 1 day 🛏️',
    );
    return '$_temp0';
  }
}
