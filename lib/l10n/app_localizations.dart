import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nb.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('da'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nb'),
    Locale('nl'),
    Locale('pt'),
    Locale('ru'),
    Locale('th'),
    Locale('vi'),
    Locale('zh')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Interval Cardio'**
  String get appTitle;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// System language option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// Voice guide setting label
  ///
  /// In en, this message translates to:
  /// **'Voice Guide'**
  String get voiceGuide;

  /// Voice guide subtitle
  ///
  /// In en, this message translates to:
  /// **'Audio Navigator'**
  String get audioNavigator;

  /// Sound effects setting label
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// Unit setting label
  ///
  /// In en, this message translates to:
  /// **'Unit Setting'**
  String get unitSetting;

  /// Kilometers per hour unit
  ///
  /// In en, this message translates to:
  /// **'km/h'**
  String get kmh;

  /// Miles per hour unit
  ///
  /// In en, this message translates to:
  /// **'mph'**
  String get mph;

  /// Theme mode setting label
  ///
  /// In en, this message translates to:
  /// **'Light/Dark Mode'**
  String get themeMode;

  /// Light theme
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark theme
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Smartwatch sync setting label
  ///
  /// In en, this message translates to:
  /// **'Smartwatch Sync'**
  String get smartwatchSync;

  /// Smartwatch sync subtitle
  ///
  /// In en, this message translates to:
  /// **'Connect to smartwatch'**
  String get connectSmartwatch;

  /// Connect button
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// About setting label
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Version text
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// Coming soon message
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// Translation coming soon message
  ///
  /// In en, this message translates to:
  /// **'Translation will be available in a future update.'**
  String get translationComingSoon;

  /// OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Start button
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Edit routine button
  ///
  /// In en, this message translates to:
  /// **'Edit Routine'**
  String get editRoutine;

  /// Routine edit screen title
  ///
  /// In en, this message translates to:
  /// **'Routine Edit'**
  String get routineEdit;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Default routine name
  ///
  /// In en, this message translates to:
  /// **'Unnamed Routine'**
  String get unnamedRoutine;

  /// Difficulty label
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// Difficulty display
  ///
  /// In en, this message translates to:
  /// **'Difficulty : {difficulty}'**
  String difficultyColon(String difficulty);

  /// Easy difficulty
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// Medium difficulty
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// Hard difficulty
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// Interval label
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get interval;

  /// Add interval button
  ///
  /// In en, this message translates to:
  /// **'Add Interval'**
  String get addInterval;

  /// No intervals message
  ///
  /// In en, this message translates to:
  /// **'No intervals'**
  String get noIntervals;

  /// Prompt to add interval
  ///
  /// In en, this message translates to:
  /// **'Add an interval'**
  String get addIntervalPrompt;

  /// Interval edit screen title
  ///
  /// In en, this message translates to:
  /// **'Interval Edit'**
  String get intervalEdit;

  /// Time in minutes label
  ///
  /// In en, this message translates to:
  /// **'Time (minutes)'**
  String get timeMinutes;

  /// Duration label
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// Speed label
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// Speed in km/h label
  ///
  /// In en, this message translates to:
  /// **'Speed (km/h)'**
  String get speedKmh;

  /// Incline label
  ///
  /// In en, this message translates to:
  /// **'Incline'**
  String get incline;

  /// Level label
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// Level display
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String levelColon(int level);

  /// RPM label
  ///
  /// In en, this message translates to:
  /// **'RPM'**
  String get rpm;

  /// Resistance label
  ///
  /// In en, this message translates to:
  /// **'Resistance'**
  String get resistance;

  /// Resistance level label
  ///
  /// In en, this message translates to:
  /// **'Resistance (Level)'**
  String get resistanceLevel;

  /// Resistance display
  ///
  /// In en, this message translates to:
  /// **'Resistance {resistance}'**
  String resistanceColon(int resistance);

  /// SPM label
  ///
  /// In en, this message translates to:
  /// **'SPM'**
  String get spm;

  /// SPM steps per minute label
  ///
  /// In en, this message translates to:
  /// **'SPM (steps/min)'**
  String get spmSteps;

  /// Saved message
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// Deleted message
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get deleted;

  /// Delete routine dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Routine'**
  String get deleteRoutineTitle;

  /// Delete routine confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this routine? This cannot be undone.'**
  String get deleteRoutineMessage;

  /// Delete error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting'**
  String get deleteError;

  /// Name required validation
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get nameRequired;

  /// Name max length validation
  ///
  /// In en, this message translates to:
  /// **'Name must be 24 characters or less'**
  String get nameMaxLength;

  /// Minimum intervals required
  ///
  /// In en, this message translates to:
  /// **'At least one interval is required'**
  String get minIntervalsRequired;

  /// Interval minimum duration validation
  ///
  /// In en, this message translates to:
  /// **'Interval duration must be at least 1 second'**
  String get intervalMinDuration;

  /// Interval maximum duration validation
  ///
  /// In en, this message translates to:
  /// **'Interval duration must be at most 3 hours (10800 seconds)'**
  String get intervalMaxDuration;

  /// Speed range validation
  ///
  /// In en, this message translates to:
  /// **'Speed must be greater than 0 (0.5-25.0 km/h)'**
  String get speedRange;

  /// Incline range validation
  ///
  /// In en, this message translates to:
  /// **'Incline must be in range 0-15.0'**
  String get inclineRange;

  /// RPM range validation
  ///
  /// In en, this message translates to:
  /// **'RPM must be in range 30-200'**
  String get rpmRange;

  /// Resistance range validation
  ///
  /// In en, this message translates to:
  /// **'Resistance must be in range 1-20'**
  String get resistanceRange;

  /// Level range validation
  ///
  /// In en, this message translates to:
  /// **'Level must be in range 1-20'**
  String get levelRange;

  /// SPM range validation
  ///
  /// In en, this message translates to:
  /// **'SPM must be in range 50-200'**
  String get spmRange;

  /// Empty state message
  ///
  /// In en, this message translates to:
  /// **'No routines saved'**
  String get noRoutinesSaved;

  /// Tap to create prompt
  ///
  /// In en, this message translates to:
  /// **'Tap to create'**
  String get tapToCreate;

  /// Tap button to create prompt
  ///
  /// In en, this message translates to:
  /// **'Tap the button to create'**
  String get tapButtonToCreate;

  /// Premium routine settings label
  ///
  /// In en, this message translates to:
  /// **'Premium Routine Settings'**
  String get premiumRoutineSettings;

  /// View membership button
  ///
  /// In en, this message translates to:
  /// **'View Membership'**
  String get viewMembership;

  /// Free limit dialog title
  ///
  /// In en, this message translates to:
  /// **'Free limit is 2 routines'**
  String get freeLimitTitle;

  /// Free limit dialog message
  ///
  /// In en, this message translates to:
  /// **'You can use unlimited routines with membership'**
  String get freeLimitMessage;

  /// Treadmill machine type
  ///
  /// In en, this message translates to:
  /// **'Treadmill'**
  String get treadmill;

  /// Cycle machine type
  ///
  /// In en, this message translates to:
  /// **'Cycle'**
  String get cycle;

  /// Stairmaster machine type
  ///
  /// In en, this message translates to:
  /// **'Stairmaster'**
  String get stairmaster;

  /// Language selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Theme selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// Difficulty selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Difficulty'**
  String get selectDifficulty;

  /// Pause button
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// Resume button
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// End workout dialog title
  ///
  /// In en, this message translates to:
  /// **'End Workout'**
  String get endWorkout;

  /// End workout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Do you want to end the workout?'**
  String get endWorkoutConfirm;

  /// End button
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// Share button label
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Rotate button
  ///
  /// In en, this message translates to:
  /// **'Rotate'**
  String get rotate;

  /// Paused status text
  ///
  /// In en, this message translates to:
  /// **'PAUSED'**
  String get paused;

  /// Pause bottom sheet title
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get pausedTitle;

  /// Pause bottom sheet subtitle
  ///
  /// In en, this message translates to:
  /// **'You can continue or end the workout'**
  String get pausedSubtitle;

  /// End workout confirmation bottom sheet message
  ///
  /// In en, this message translates to:
  /// **'If you end now, the current workout will finish and you will move to the summary screen.'**
  String get endWorkoutConfirmationMessage;

  /// Workout complete title (always English)
  ///
  /// In en, this message translates to:
  /// **'Workout Complete'**
  String get workoutComplete;

  /// Total workout time label
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get totalWorkoutTime;

  /// Total distance label
  ///
  /// In en, this message translates to:
  /// **'Total distance'**
  String get totalDistance;

  /// Total time label for share card
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get totalTime;

  /// Label for average RPM in Bike workouts
  ///
  /// In en, this message translates to:
  /// **'Average RPM'**
  String get averageRpm;

  /// Label for average level in Stairmaster workouts
  ///
  /// In en, this message translates to:
  /// **'Average Level'**
  String get averageLevel;

  /// Hold to stop button text (always English)
  ///
  /// In en, this message translates to:
  /// **'Hold to Stop'**
  String get holdToStop;

  /// Continue workout button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueWorkout;

  /// End workout question
  ///
  /// In en, this message translates to:
  /// **'Do you want to end the workout?'**
  String get endWorkoutQuestion;

  /// Workout paused message
  ///
  /// In en, this message translates to:
  /// **'Workout has been paused'**
  String get workoutPaused;

  /// Incline label
  ///
  /// In en, this message translates to:
  /// **'Incline'**
  String get lvlIncline;

  /// Level Resistance label
  ///
  /// In en, this message translates to:
  /// **'Lvl Resistance'**
  String get lvlResistance;

  /// Premium label
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// Upgrade now title
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get upgradeNow;

  /// Purchase button
  ///
  /// In en, this message translates to:
  /// **'Purchase'**
  String get purchase;

  /// Later button
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// Premium activated message
  ///
  /// In en, this message translates to:
  /// **'Premium has been activated'**
  String get premiumActivated;

  /// Premium membership title
  ///
  /// In en, this message translates to:
  /// **'Premium Membership'**
  String get premiumMembership;

  /// Benefit: Cycle and Stairmaster feature
  ///
  /// In en, this message translates to:
  /// **'Cycle, Stairmaster feature'**
  String get benefitCycleStairmaster;

  /// Benefit: Voice guide feature
  ///
  /// In en, this message translates to:
  /// **'Session voice guide feature'**
  String get benefitVoiceGuide;

  /// Benefit: Unlimited routines
  ///
  /// In en, this message translates to:
  /// **'Unlimited routine saves'**
  String get benefitUnlimitedRoutines;

  /// Benefit: No ads
  ///
  /// In en, this message translates to:
  /// **'No Ads'**
  String get noAds;

  /// Benefit: Future features access
  ///
  /// In en, this message translates to:
  /// **'Unlimited access to future features'**
  String get benefitFutureFeatures;

  /// Voice guide benefit 1
  ///
  /// In en, this message translates to:
  /// **'Voice guidance during workout'**
  String get voiceGuideBenefit1;

  /// Voice guide benefit 2
  ///
  /// In en, this message translates to:
  /// **'Automatic session transition announcements'**
  String get voiceGuideBenefit2;

  /// Voice guide benefit 3
  ///
  /// In en, this message translates to:
  /// **'Hands-free routine focus'**
  String get voiceGuideBenefit3;

  /// Routine limit benefit 1
  ///
  /// In en, this message translates to:
  /// **'Unlimited routine saves'**
  String get routineLimitBenefit1;

  /// Routine limit benefit 2
  ///
  /// In en, this message translates to:
  /// **'Save routines for multiple goals'**
  String get routineLimitBenefit2;

  /// Routine limit benefit 3
  ///
  /// In en, this message translates to:
  /// **'Use all machine types (treadmill/cycle/stairmaster)'**
  String get routineLimitBenefit3;

  /// Premium benefit 1 with red emphasis
  ///
  /// In en, this message translates to:
  /// **'<red>Bike & StairMaster</red> workouts'**
  String get premium_benefit_1;

  /// Premium benefit 2 with red emphasis
  ///
  /// In en, this message translates to:
  /// **'Session <red>voice guide</red>'**
  String get premium_benefit_2;

  /// Premium benefit 3 with red emphasis
  ///
  /// In en, this message translates to:
  /// **'<red>Unlimited</red> routine saves'**
  String get premium_benefit_3;

  /// Premium benefit 4 with red emphasis
  ///
  /// In en, this message translates to:
  /// **'<red>Unlimited access</red> to future features'**
  String get premium_benefit_4;

  /// Original price
  ///
  /// In en, this message translates to:
  /// **'{price}'**
  String originalPrice(String price);

  /// Monthly price
  ///
  /// In en, this message translates to:
  /// **'{price}/month'**
  String monthlyPrice(String price);

  /// Premium subheadline describing what unlocks
  ///
  /// In en, this message translates to:
  /// **'Unlock voice guidance, bike & stairmaster workouts, and unlimited routines'**
  String get premiumSubheadline;

  /// Monthly plan label
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// Yearly plan label
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// Lifetime plan label
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get lifetime;

  /// 7-day free trial label
  ///
  /// In en, this message translates to:
  /// **'7-day free trial'**
  String get freeTrial7Days;

  /// Per month suffix
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get perMonth;

  /// Per year suffix
  ///
  /// In en, this message translates to:
  /// **'/year'**
  String get perYear;

  /// One time payment suffix
  ///
  /// In en, this message translates to:
  /// **'One time'**
  String get oneTime;

  /// Save percentage badge
  ///
  /// In en, this message translates to:
  /// **'Save {percent}%'**
  String savePercent(int percent);

  /// Best value badge
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get bestValue;

  /// Cancel anytime trust line
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime'**
  String get cancelAnytime;

  /// Auto-renewable subscription trust line
  ///
  /// In en, this message translates to:
  /// **'Auto-renewable subscription'**
  String get autoRenewableSubscription;

  /// Terms link
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// Privacy link
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// Restore purchases link
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// Premium tab label
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premiumTab;

  /// Routine tab label
  ///
  /// In en, this message translates to:
  /// **'Routine'**
  String get routineTab;

  /// Settings tab label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTab;

  /// My/Profile tab label
  ///
  /// In en, this message translates to:
  /// **'My'**
  String get myTab;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Premium feature label
  ///
  /// In en, this message translates to:
  /// **'Premium Feature'**
  String get premiumFeature;

  /// Use premium test button
  ///
  /// In en, this message translates to:
  /// **'Use Premium (Test)'**
  String get usePremiumTest;

  /// Date time format
  ///
  /// In en, this message translates to:
  /// **'{month}/{day}/{year} {hour}:{minute}'**
  String dateTimeFormat(int year, int month, int day, int hour, int minute);

  /// Button text to check routine and start
  ///
  /// In en, this message translates to:
  /// **'Check Routine / Start'**
  String get checkRoutineStart;

  /// No description provided for @beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// No description provided for @intermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @viewRecommendedRoutines.
  ///
  /// In en, this message translates to:
  /// **'Recommended →'**
  String get viewRecommendedRoutines;

  /// No description provided for @recommendedRoutinesTreadmill.
  ///
  /// In en, this message translates to:
  /// **'Recommended Treadmill Routines'**
  String get recommendedRoutinesTreadmill;

  /// No description provided for @recommendedRoutinesCycle.
  ///
  /// In en, this message translates to:
  /// **'Recommended Bike Routines'**
  String get recommendedRoutinesCycle;

  /// No description provided for @recommendedRoutinesStairmaster.
  ///
  /// In en, this message translates to:
  /// **'Recommended Stairmaster Routines'**
  String get recommendedRoutinesStairmaster;

  /// No description provided for @alreadySaved.
  ///
  /// In en, this message translates to:
  /// **'Already saved'**
  String get alreadySaved;

  /// No description provided for @routineSaved.
  ///
  /// In en, this message translates to:
  /// **'Routine saved'**
  String get routineSaved;

  /// No description provided for @checkRoutine.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get checkRoutine;

  /// No description provided for @saveRoutine.
  ///
  /// In en, this message translates to:
  /// **'Save Routine'**
  String get saveRoutine;

  /// No description provided for @routineAlreadySaved.
  ///
  /// In en, this message translates to:
  /// **'Routine already saved'**
  String get routineAlreadySaved;

  /// No description provided for @noTemplatesFound.
  ///
  /// In en, this message translates to:
  /// **'No templates found'**
  String get noTemplatesFound;

  /// No description provided for @avg.
  ///
  /// In en, this message translates to:
  /// **'Avg'**
  String get avg;

  /// No description provided for @avgRpm.
  ///
  /// In en, this message translates to:
  /// **'Avg RPM'**
  String get avgRpm;

  /// No description provided for @avgLevel.
  ///
  /// In en, this message translates to:
  /// **'Avg level'**
  String get avgLevel;

  /// No description provided for @templateTreadmillBeginner1Title.
  ///
  /// In en, this message translates to:
  /// **'Beginner Treadmill 1'**
  String get templateTreadmillBeginner1Title;

  /// No description provided for @templateTreadmillBeginner1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'1:1 walk and run after 3 min warm-up'**
  String get templateTreadmillBeginner1Subtitle;

  /// No description provided for @templateTreadmillBeginner2Title.
  ///
  /// In en, this message translates to:
  /// **'Beginner Treadmill 2 (Incline)'**
  String get templateTreadmillBeginner2Title;

  /// No description provided for @templateTreadmillBeginner2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Incline walking with low joint impact'**
  String get templateTreadmillBeginner2Subtitle;

  /// No description provided for @templateTreadmillIntermediate1Title.
  ///
  /// In en, this message translates to:
  /// **'Intermediate Treadmill 1'**
  String get templateTreadmillIntermediate1Title;

  /// No description provided for @templateTreadmillIntermediate1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'1:1 running interval for fat burning'**
  String get templateTreadmillIntermediate1Subtitle;

  /// No description provided for @templateTreadmillIntermediate2Title.
  ///
  /// In en, this message translates to:
  /// **'Intermediate Treadmill 2 (Speed)'**
  String get templateTreadmillIntermediate2Title;

  /// No description provided for @templateTreadmillIntermediate2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Pyramid speed building run'**
  String get templateTreadmillIntermediate2Subtitle;

  /// No description provided for @templateTreadmillAdvanced1Title.
  ///
  /// In en, this message translates to:
  /// **'Advanced Treadmill 1'**
  String get templateTreadmillAdvanced1Title;

  /// No description provided for @templateTreadmillAdvanced1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'High-intensity cardio blast interval'**
  String get templateTreadmillAdvanced1Subtitle;

  /// No description provided for @templateTreadmillAdvanced2Title.
  ///
  /// In en, this message translates to:
  /// **'Advanced Treadmill 2 (Sprint)'**
  String get templateTreadmillAdvanced2Title;

  /// No description provided for @templateTreadmillAdvanced2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Short high-intensity sprint repeats'**
  String get templateTreadmillAdvanced2Subtitle;

  /// No description provided for @templateCycleBeginner1Title.
  ///
  /// In en, this message translates to:
  /// **'Beginner Cycle 1'**
  String get templateCycleBeginner1Title;

  /// No description provided for @templateCycleBeginner1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Pedaling intro by adjusting RPM'**
  String get templateCycleBeginner1Subtitle;

  /// No description provided for @templateCycleBeginner2Title.
  ///
  /// In en, this message translates to:
  /// **'Beginner Cycle 2 (Steady)'**
  String get templateCycleBeginner2Title;

  /// No description provided for @templateCycleBeginner2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Constant resistance endurance ride'**
  String get templateCycleBeginner2Subtitle;

  /// No description provided for @templateCycleIntermediate1Title.
  ///
  /// In en, this message translates to:
  /// **'Intermediate Cycle 1'**
  String get templateCycleIntermediate1Title;

  /// No description provided for @templateCycleIntermediate1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'1 min high speed / 1 min recovery spin'**
  String get templateCycleIntermediate1Subtitle;

  /// No description provided for @templateCycleIntermediate2Title.
  ///
  /// In en, this message translates to:
  /// **'Intermediate Cycle 2 (Hill)'**
  String get templateCycleIntermediate2Title;

  /// No description provided for @templateCycleIntermediate2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'High resistance lower body hill climb'**
  String get templateCycleIntermediate2Subtitle;

  /// No description provided for @templateCycleAdvanced1Title.
  ///
  /// In en, this message translates to:
  /// **'Advanced Cycle 1'**
  String get templateCycleAdvanced1Title;

  /// No description provided for @templateCycleAdvanced1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'30s high resistance power intervals'**
  String get templateCycleAdvanced1Subtitle;

  /// No description provided for @templateCycleAdvanced2Title.
  ///
  /// In en, this message translates to:
  /// **'Advanced Cycle 2 (Tabata)'**
  String get templateCycleAdvanced2Title;

  /// No description provided for @templateCycleAdvanced2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'20s/10s Tabata circuit for fat burning'**
  String get templateCycleAdvanced2Subtitle;

  /// No description provided for @templateStairmasterBeginner1Title.
  ///
  /// In en, this message translates to:
  /// **'Beginner Stairmaster 1'**
  String get templateStairmasterBeginner1Title;

  /// No description provided for @templateStairmasterBeginner1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Safe adaptation pace stair walking'**
  String get templateStairmasterBeginner1Subtitle;

  /// No description provided for @templateStairmasterBeginner2Title.
  ///
  /// In en, this message translates to:
  /// **'Beginner Stairmaster 2 (Steady)'**
  String get templateStairmasterBeginner2Title;

  /// No description provided for @templateStairmasterBeginner2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Steady tempo aerobic stair climbing'**
  String get templateStairmasterBeginner2Subtitle;

  /// No description provided for @templateStairmasterIntermediate1Title.
  ///
  /// In en, this message translates to:
  /// **'Intermediate Stairmaster 1 (Climb)'**
  String get templateStairmasterIntermediate1Title;

  /// No description provided for @templateStairmasterIntermediate1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'2 min climb / 1 min recovery glute sculpt'**
  String get templateStairmasterIntermediate1Subtitle;

  /// No description provided for @templateStairmasterIntermediate2Title.
  ///
  /// In en, this message translates to:
  /// **'Intermediate Stairmaster 2'**
  String get templateStairmasterIntermediate2Title;

  /// No description provided for @templateStairmasterIntermediate2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Alternating fast and slow tempo intervals'**
  String get templateStairmasterIntermediate2Subtitle;

  /// No description provided for @templateStairmasterAdvanced1Title.
  ///
  /// In en, this message translates to:
  /// **'Advanced Stairmaster 1'**
  String get templateStairmasterAdvanced1Title;

  /// No description provided for @templateStairmasterAdvanced1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'High-intensity 2 min block training'**
  String get templateStairmasterAdvanced1Subtitle;

  /// No description provided for @templateStairmasterAdvanced2Title.
  ///
  /// In en, this message translates to:
  /// **'Advanced Stairmaster 2 (Sprint)'**
  String get templateStairmasterAdvanced2Title;

  /// No description provided for @templateStairmasterAdvanced2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'30s high speed climb / 60s recovery intervals'**
  String get templateStairmasterAdvanced2Subtitle;

  /// History tab label in My screen
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTab;

  /// Calendar tab label in My screen
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTab;

  /// Weight tab label in My screen
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightTab;

  /// Bike machine type
  ///
  /// In en, this message translates to:
  /// **'Bike'**
  String get bike;

  /// This week label
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// Trend label
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get trend;

  /// 7 days timeframe
  ///
  /// In en, this message translates to:
  /// **'7D'**
  String get timeframe7D;

  /// 30 days timeframe
  ///
  /// In en, this message translates to:
  /// **'30D'**
  String get timeframe30D;

  /// 90 days timeframe
  ///
  /// In en, this message translates to:
  /// **'90D'**
  String get timeframe90D;

  /// All timeframe
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get timeframeAll;

  /// History label
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// See all button
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// Weight entry deleted message
  ///
  /// In en, this message translates to:
  /// **'Weight entry deleted'**
  String get weightEntryDeleted;

  /// Weight updated message
  ///
  /// In en, this message translates to:
  /// **'Weight updated'**
  String get weightUpdated;

  /// Edit weight title
  ///
  /// In en, this message translates to:
  /// **'Edit weight'**
  String get editWeight;

  /// Record weight title
  ///
  /// In en, this message translates to:
  /// **'Record weight'**
  String get recordWeight;

  /// Quick adjust label
  ///
  /// In en, this message translates to:
  /// **'Quick adjust'**
  String get quickAdjust;

  /// Goal weight set message
  ///
  /// In en, this message translates to:
  /// **'Goal weight set'**
  String get goalWeightSet;

  /// Goal weight removed message
  ///
  /// In en, this message translates to:
  /// **'Goal weight removed'**
  String get goalWeightRemoved;

  /// Goal achieved message
  ///
  /// In en, this message translates to:
  /// **'Goal achieved!'**
  String get goalAchieved;

  /// Goal matches current weight message
  ///
  /// In en, this message translates to:
  /// **'Goal matches current weight'**
  String get goalMatchesCurrentWeight;

  /// Set goal title
  ///
  /// In en, this message translates to:
  /// **'Set goal'**
  String get setGoal;

  /// Suggested label
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get suggested;

  /// Remove goal button
  ///
  /// In en, this message translates to:
  /// **'Remove Goal'**
  String get removeGoal;

  /// Add one more record to see trend message
  ///
  /// In en, this message translates to:
  /// **'Add 1 more record to see your trend'**
  String get addOneMoreRecordToSeeTrend;

  /// No weight recorded yet message
  ///
  /// In en, this message translates to:
  /// **'No weight recorded yet'**
  String get noWeightRecorded;

  /// Start tracking your weight message
  ///
  /// In en, this message translates to:
  /// **'Start tracking your weight to see progress here'**
  String get startTrackingYourWeight;

  /// Treadmill session label
  ///
  /// In en, this message translates to:
  /// **'Treadmill Session'**
  String get treadmillSession;

  /// Bike session label
  ///
  /// In en, this message translates to:
  /// **'Bike Session'**
  String get bikeSession;

  /// Stairmaster session label
  ///
  /// In en, this message translates to:
  /// **'Stairmaster Session'**
  String get stairmasterSession;

  /// Treadmill workout label
  ///
  /// In en, this message translates to:
  /// **'Treadmill Workout'**
  String get treadmillWorkout;

  /// Bike workout label
  ///
  /// In en, this message translates to:
  /// **'Bike Workout'**
  String get bikeWorkout;

  /// Stairmaster workout label
  ///
  /// In en, this message translates to:
  /// **'Stairmaster Workout'**
  String get stairmasterWorkout;

  /// Start a workout to see it here message
  ///
  /// In en, this message translates to:
  /// **'Start a workout to see it here'**
  String get startAWorkoutToSeeItHere;

  /// Monday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// Tuesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// Wednesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// Thursday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// Friday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// Saturday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// Sunday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// Sessions label
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// Distance label
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// Today label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Yesterday label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No workouts yet message
  ///
  /// In en, this message translates to:
  /// **'No workouts yet'**
  String get noWorkoutsYet;

  /// Start your first workout message
  ///
  /// In en, this message translates to:
  /// **'Start your first workout to see your history here'**
  String get startYourFirstWorkout;

  /// Go to Routines button
  ///
  /// In en, this message translates to:
  /// **'Go to Routines'**
  String get goToRoutines;

  /// Weight recorded message
  ///
  /// In en, this message translates to:
  /// **'Weight recorded'**
  String get weightRecorded;

  /// Workout singular
  ///
  /// In en, this message translates to:
  /// **'workout'**
  String get workout;

  /// Workouts plural
  ///
  /// In en, this message translates to:
  /// **'workouts'**
  String get workouts;

  /// Goal label
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// To go label
  ///
  /// In en, this message translates to:
  /// **'to go'**
  String get toGo;

  /// Over label
  ///
  /// In en, this message translates to:
  /// **'over'**
  String get over;

  /// Last label
  ///
  /// In en, this message translates to:
  /// **'Last'**
  String get last;

  /// New label
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// You need amount to reach goal
  ///
  /// In en, this message translates to:
  /// **'You need {amount} to reach {goal}'**
  String youNeed(String amount, String goal);

  /// You need plus amount to reach goal
  ///
  /// In en, this message translates to:
  /// **'You need +{amount} to reach {goal}'**
  String youNeedPlus(String amount, String goal);

  /// Current label
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// Premium screen strong headline
  ///
  /// In en, this message translates to:
  /// **'Same 30 minutes, different results'**
  String get premiumHeadline;

  /// Premium screen subheadline
  ///
  /// In en, this message translates to:
  /// **'Don\'t just run, exercise the fat-burning way'**
  String get premiumSubheadlineNew;

  /// Most popular badge
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get mostPopular;

  /// Daily price display
  ///
  /// In en, this message translates to:
  /// **'{price} per day'**
  String dailyPrice(int price);

  /// Premium benefit: voice coaching
  ///
  /// In en, this message translates to:
  /// **'Premium Voice Coaching System'**
  String get benefitVoiceCoaching;

  /// Premium benefit: cycle and stairmaster routines
  ///
  /// In en, this message translates to:
  /// **'Full Support for All Cardio Equipment'**
  String get benefitCycleStairmasterRoutines;

  /// Premium benefit: unlimited routine storage
  ///
  /// In en, this message translates to:
  /// **'Unlimited Routine Library'**
  String get benefitUnlimitedRoutinesNew;

  /// Premium benefit: weight feature
  ///
  /// In en, this message translates to:
  /// **'Smart Weight Tracking & Analysis'**
  String get benefitWeightFeature;

  /// Premium benefit: no ads
  ///
  /// In en, this message translates to:
  /// **'Ad-Free Premium Experience'**
  String get benefitNoAdsFocus;

  /// Premium benefit: future features
  ///
  /// In en, this message translates to:
  /// **'All future premium features included'**
  String get benefitFutureFeaturesNew;

  /// Supporting line above CTA (when annual selected)
  ///
  /// In en, this message translates to:
  /// **'Most chosen'**
  String get mostChosen;

  /// Supporting line above CTA (when monthly selected)
  ///
  /// In en, this message translates to:
  /// **'Can change anytime'**
  String get canChangeAnytime;

  /// Premium purchase button text
  ///
  /// In en, this message translates to:
  /// **'Start Premium'**
  String get startPremium;

  /// Cancellation trust copy
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime and keep access until period ends'**
  String get cancelAnytimeKeepAccess;

  /// Workout days count in calendar statistics
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Workout 1 day 🔥} other{Workout {count} days 🔥}}'**
  String workoutDays(int count);

  /// Rest days count in calendar statistics
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Rest 1 day 🛏️} other{Rest {count} days 🛏️}}'**
  String restDays(int count);

  /// No description provided for @workoutReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout reminder'**
  String get workoutReminderTitle;

  /// No description provided for @workoutReminderOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get workoutReminderOff;

  /// No description provided for @workoutReminderEveryDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get workoutReminderEveryDay;

  /// No description provided for @workoutReminderSelectTime.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get workoutReminderSelectTime;

  /// No description provided for @workoutReminderPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Notification permission is required.'**
  String get workoutReminderPermissionRequired;

  /// No description provided for @workoutReminderTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get workoutReminderTimeLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'da',
        'de',
        'en',
        'es',
        'fr',
        'it',
        'ja',
        'ko',
        'nb',
        'nl',
        'pt',
        'ru',
        'th',
        'vi',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'nb':
      return AppLocalizationsNb();
    case 'nl':
      return AppLocalizationsNl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'th':
      return AppLocalizationsTh();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
