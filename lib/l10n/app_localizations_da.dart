// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get appTitle => 'Interval Cardio';

  @override
  String get settingsTitle => 'Indstillinger';

  @override
  String get language => 'Sprog';

  @override
  String get system => 'System';

  @override
  String get voiceGuide => 'Stemmeguide';

  @override
  String get audioNavigator => 'Lydnavigator';

  @override
  String get soundEffects => 'Lydeffekter';

  @override
  String get unitSetting => 'Enhedsindstilling';

  @override
  String get kmh => 'km/t';

  @override
  String get mph => 'mph';

  @override
  String get themeMode => 'Lys/mørk-tilstand';

  @override
  String get light => 'Lys';

  @override
  String get dark => 'Mørk';

  @override
  String get smartwatchSync => 'Smartwatch Sync';

  @override
  String get connectSmartwatch => 'Forbind til smartwatch';

  @override
  String get connect => 'Forbind';

  @override
  String get about => 'Om';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get comingSoon => 'Kommer snart';

  @override
  String get translationComingSoon =>
      'Oversættelse bliver tilgængelig i en fremtidig opdatering.';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annuller';

  @override
  String get done => 'Færdig';

  @override
  String get delete => 'Slet';

  @override
  String get save => 'Gem';

  @override
  String get edit => 'Rediger';

  @override
  String get start => 'Start';

  @override
  String get editRoutine => 'Rediger rutine';

  @override
  String get routineEdit => 'Rediger rutine';

  @override
  String get name => 'Navn';

  @override
  String get unnamedRoutine => 'Unavngiven rutine';

  @override
  String get difficulty => 'Sværhedsgrad';

  @override
  String difficultyColon(String difficulty) {
    return 'Sværhedsgrad : $difficulty';
  }

  @override
  String get easy => 'Let';

  @override
  String get medium => 'Mellem';

  @override
  String get hard => 'Hård';

  @override
  String get interval => 'Interval';

  @override
  String get addInterval => 'Tilføj interval';

  @override
  String get noIntervals => 'Ingen intervaller';

  @override
  String get addIntervalPrompt => 'Tilføj et interval';

  @override
  String get intervalEdit => 'Rediger interval';

  @override
  String get timeMinutes => 'Tid (minutter)';

  @override
  String get duration => 'Varighed';

  @override
  String get speed => 'Hastighed';

  @override
  String get speedKmh => 'Hastighed (km/t)';

  @override
  String get incline => 'Hældning';

  @override
  String get level => 'Niveau';

  @override
  String levelColon(int level) {
    return 'Niveau $level';
  }

  @override
  String get rpm => 'RPM';

  @override
  String get resistance => 'Modstand';

  @override
  String get resistanceLevel => 'Modstand (niveau)';

  @override
  String resistanceColon(int resistance) {
    return 'Modstand $resistance';
  }

  @override
  String get spm => 'SPM';

  @override
  String get spmSteps => 'SPM (trin/min)';

  @override
  String get saved => 'Gemt';

  @override
  String get deleted => 'Slettet';

  @override
  String get deleteRoutineTitle => 'Slet rutine';

  @override
  String get deleteRoutineMessage =>
      'Er du sikker på, at du vil slette denne rutine? Dette kan ikke fortrydes.';

  @override
  String get deleteError => 'Der opstod en fejl under sletning';

  @override
  String get nameRequired => 'Indtast et navn';

  @override
  String get nameMaxLength => 'Navnet skal være 24 tegn eller mindre';

  @override
  String get minIntervalsRequired => 'Mindst ét interval er påkrævet';

  @override
  String get intervalMinDuration =>
      'Intervalvarighed skal være mindst 1 sekund';

  @override
  String get intervalMaxDuration =>
      'Intervalvarighed må højst være 3 timer (10800 sekunder)';

  @override
  String get speedRange => 'Hastighed skal være større end 0 (0.5-25.0 km/t)';

  @override
  String get inclineRange => 'Hældning skal være i intervallet 0-15.0';

  @override
  String get rpmRange => 'RPM skal være i intervallet 30-200';

  @override
  String get resistanceRange => 'Modstand skal være i intervallet 1-20';

  @override
  String get levelRange => 'Niveau skal være i intervallet 1-20';

  @override
  String get spmRange => 'SPM skal være i intervallet 50-200';

  @override
  String get noRoutinesSaved => 'Ingen rutiner gemt';

  @override
  String get tapToCreate => 'Tryk for at oprette';

  @override
  String get tapButtonToCreate => 'Tryk på knappen for at oprette';

  @override
  String get premiumRoutineSettings => 'Premium rutineindstillinger';

  @override
  String get viewMembership => 'Se medlemskab';

  @override
  String get freeLimitTitle => 'Gratis grænse er 2 rutiner';

  @override
  String get freeLimitMessage =>
      'Med medlemskab kan du bruge ubegrænsede rutiner';

  @override
  String get treadmill => 'Løbebånd';

  @override
  String get cycle => 'Cykel';

  @override
  String get stairmaster => 'Stairmaster';

  @override
  String get selectLanguage => 'Vælg sprog';

  @override
  String get selectTheme => 'Vælg tema';

  @override
  String get selectDifficulty => 'Vælg sværhedsgrad';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Genoptag';

  @override
  String get endWorkout => 'Afslut træning';

  @override
  String get endWorkoutConfirm => 'Vil du afslutte træningen?';

  @override
  String get end => 'Afslut';

  @override
  String get rotate => 'Roter';

  @override
  String get paused => 'PAUSET';

  @override
  String get pausedTitle => 'Pauset';

  @override
  String get pausedSubtitle => 'Du kan fortsætte eller afslutte træningen';

  @override
  String get endWorkoutConfirmationMessage =>
      'Hvis du afslutter nu, afsluttes den aktuelle træning, og du går til opsummeringsskærmen.';

  @override
  String get workoutComplete => 'Træning fuldført';

  @override
  String get totalWorkoutTime => 'Samlet tid';

  @override
  String get totalDistance => 'Samlet distance';

  @override
  String get averageRpm => 'Gennemsnitlig RPM';

  @override
  String get averageLevel => 'Gennemsnitligt niveau';

  @override
  String get holdToStop => 'Hold for at stoppe';

  @override
  String get continueWorkout => 'Fortsæt';

  @override
  String get endWorkoutQuestion => 'Vil du afslutte træningen?';

  @override
  String get workoutPaused => 'Træningen er sat på pause';

  @override
  String get lvlIncline => 'Hældning';

  @override
  String get lvlResistance => 'Nivå modstand';

  @override
  String get premium => 'Premium';

  @override
  String get upgradeNow => 'Opgrader nu';

  @override
  String get purchase => 'Køb';

  @override
  String get later => 'Senere';

  @override
  String get premiumActivated => 'Premium er aktiveret';

  @override
  String get premiumMembership => 'Premium-medlemskab';

  @override
  String get benefitCycleStairmaster => 'Cykel- og Stairmaster-funktion';

  @override
  String get benefitVoiceGuide => 'Stemmeguide for session';

  @override
  String get benefitUnlimitedRoutines => 'Ubegrænset lagring af rutiner';

  @override
  String get noAds => 'Ingen annoncer';

  @override
  String get benefitFutureFeatures =>
      'Ubegrænset adgang til fremtidige funktioner';

  @override
  String get voiceGuideBenefit1 => 'Stemmevejledning under træning';

  @override
  String get voiceGuideBenefit2 => 'Automatiske annonceringer ved sessionskift';

  @override
  String get voiceGuideBenefit3 => 'Handsfree fokus på din rutine';

  @override
  String get routineLimitBenefit1 => 'Ubegrænset lagring af rutiner';

  @override
  String get routineLimitBenefit2 => 'Gem rutiner til flere mål';

  @override
  String get routineLimitBenefit3 =>
      'Brug alle maskintyper (løbebånd/cykel/stairmaster)';

  @override
  String get premium_benefit_1 => '<red>Cykel & StairMaster</red>-træning';

  @override
  String get premium_benefit_2 => 'Session <red>stemmeguide</red>';

  @override
  String get premium_benefit_3 => '<red>Ubegrænset</red> rutine-lagring';

  @override
  String get premium_benefit_4 =>
      '<red>Ubegrænset adgang</red> til fremtidige funktioner';

  @override
  String originalPrice(String price) {
    return '$price';
  }

  @override
  String monthlyPrice(String price) {
    return '$price/måned';
  }

  @override
  String get premiumSubheadline =>
      'Lås op for stemmeguide, cykel- & stairmastertræning og ubegrænsede rutiner';

  @override
  String get monthly => 'Månedligt';

  @override
  String get yearly => 'Årligt';

  @override
  String get lifetime => 'Livstid';

  @override
  String get freeTrial7Days => '7 dages gratis prøveperiode';

  @override
  String get perMonth => '/måned';

  @override
  String get perYear => '/år';

  @override
  String get oneTime => 'Engangsbetalin';

  @override
  String savePercent(int percent) {
    return 'Spar $percent%';
  }

  @override
  String get bestValue => 'Bedste værdi';

  @override
  String get cancelAnytime => 'Annuller når som helst';

  @override
  String get autoRenewableSubscription => 'Auto-fornyeligt abonnement';

  @override
  String get terms => 'Vilkår';

  @override
  String get privacy => 'Privatliv';

  @override
  String get restore => 'Gendan';

  @override
  String get premiumTab => 'Premium';

  @override
  String get routineTab => 'Rutine';

  @override
  String get settingsTab => 'Indstillinger';

  @override
  String get myTab => 'Min';

  @override
  String get close => 'Luk';

  @override
  String get premiumFeature => 'Premiumfunktion';

  @override
  String get usePremiumTest => 'Brug Premium (test)';

  @override
  String dateTimeFormat(int year, int month, int day, int hour, int minute) {
    return '$day/$month/$year $hour:$minute';
  }

  @override
  String get checkRoutineStart => 'Tjek rutine / Start';

  @override
  String get beginner => 'Begynder';

  @override
  String get intermediate => 'Mellem';

  @override
  String get advanced => 'Avanceret';

  @override
  String get viewRecommendedRoutines => 'Se anbefalede rutiner →';

  @override
  String get recommendedRoutinesTreadmill => 'Anbefalede løbebåndsrutiner';

  @override
  String get recommendedRoutinesCycle => 'Anbefalede cykelrutiner';

  @override
  String get recommendedRoutinesStairmaster => 'Anbefalede stairmaster-rutiner';

  @override
  String get alreadySaved => 'Allerede gemt';

  @override
  String get routineSaved => 'Rutine gemt';

  @override
  String get checkRoutine => 'Tjek';

  @override
  String get saveRoutine => 'Gem rutine';

  @override
  String get routineAlreadySaved => 'Rutinen er allerede gemt';

  @override
  String get noTemplatesFound => 'Ingen skabeloner fundet';

  @override
  String get avg => 'Gns.';

  @override
  String get avgRpm => 'Gns. RPM';

  @override
  String get avgLevel => 'Gns. niveau';

  @override
  String get templateTreadmillBeginner1Title => 'Let start 20';

  @override
  String get templateTreadmillBeginner1Subtitle => 'Let 1:1 intervaller';

  @override
  String get templateTreadmillBeginner2Title => 'Hældningsgang 25';

  @override
  String get templateTreadmillBeginner2Subtitle => 'Hældningsgang-blokke';

  @override
  String get templateTreadmillIntermediate1Title => 'Klassisk 1:1 24';

  @override
  String get templateTreadmillIntermediate1Subtitle =>
      'Klassiske 1:1 løbeintervaller';

  @override
  String get templateTreadmillIntermediate2Title => 'Hastighedsstige 20';

  @override
  String get templateTreadmillIntermediate2Subtitle =>
      'Trinvis hastighedsstige';

  @override
  String get templateTreadmillAdvanced1Title => '2:1 Burner 21';

  @override
  String get templateTreadmillAdvanced1Subtitle => '2:1 hård/let intervaller';

  @override
  String get templateTreadmillAdvanced2Title => 'Sprint Pop 18';

  @override
  String get templateTreadmillAdvanced2Subtitle => '20 s sprint-gentagelser';

  @override
  String get templateCycleBeginner1Title => 'Kadencebygger 20';

  @override
  String get templateCycleBeginner1Subtitle => '4 min opvarmning + 1:1 kadence';

  @override
  String get templateCycleBeginner2Title => 'Jævn tur 25';

  @override
  String get templateCycleBeginner2Subtitle => 'Lang, stabil blok';

  @override
  String get templateCycleIntermediate1Title => 'Spin 1:1 24';

  @override
  String get templateCycleIntermediate1Subtitle =>
      'Klassiske 1:1 spinintervaller';

  @override
  String get templateCycleIntermediate2Title => 'Bakkesimulering 22';

  @override
  String get templateCycleIntermediate2Subtitle => 'Klatregentagelser';

  @override
  String get templateCycleAdvanced1Title => 'Kraftintervaller 20';

  @override
  String get templateCycleAdvanced1Subtitle => '30 s power bursts';

  @override
  String get templateCycleAdvanced2Title => 'Tabata-mix 16';

  @override
  String get templateCycleAdvanced2Subtitle => '20 s på / 10 s af-mix';

  @override
  String get templateStairmasterBeginner1Title => 'Lettere trin 20';

  @override
  String get templateStairmasterBeginner1Subtitle =>
      '4 min opvarmning + 1:1 trin';

  @override
  String get templateStairmasterBeginner2Title => 'Lang let 25';

  @override
  String get templateStairmasterBeginner2Subtitle =>
      'Lange, lette klatreblokke';

  @override
  String get templateStairmasterIntermediate1Title => '2:1 Klatring 21';

  @override
  String get templateStairmasterIntermediate1Subtitle =>
      '2:1 klatre-gentagelser';

  @override
  String get templateStairmasterIntermediate2Title => 'Stærk 1:1 24';

  @override
  String get templateStairmasterIntermediate2Subtitle =>
      'Stærke 1:1 intervaller';

  @override
  String get templateStairmasterAdvanced1Title => 'Hårde blokke 20';

  @override
  String get templateStairmasterAdvanced1Subtitle => '2-min hårde blokke';

  @override
  String get templateStairmasterAdvanced2Title => 'Sprint Steps 18';

  @override
  String get templateStairmasterAdvanced2Subtitle =>
      '30 s sprinter + 60 s restitution';

  @override
  String get historyTab => 'Historik';

  @override
  String get calendarTab => 'Kalender';

  @override
  String get weightTab => 'Vægt';

  @override
  String get bike => 'Cykel';

  @override
  String get thisWeek => 'Denne uge';

  @override
  String get trend => 'Trend';

  @override
  String get timeframe7D => '7D';

  @override
  String get timeframe30D => '30D';

  @override
  String get timeframe90D => '90D';

  @override
  String get timeframeAll => 'ALLE';

  @override
  String get history => 'Historik';

  @override
  String get seeAll => 'Se alle';

  @override
  String get weightEntryDeleted => 'Vægtregistrering slettet';

  @override
  String get weightUpdated => 'Vægt opdateret';

  @override
  String get editWeight => 'Rediger vægt';

  @override
  String get recordWeight => 'Registrer vægt';

  @override
  String get quickAdjust => 'Hurtig justering';

  @override
  String get goalWeightSet => 'Målvægt sat';

  @override
  String get goalWeightRemoved => 'Målvægt fjernet';

  @override
  String get goalAchieved => 'Mål nået!';

  @override
  String get goalMatchesCurrentWeight => 'Målet matcher nuværende vægt';

  @override
  String get setGoal => 'Sæt mål';

  @override
  String get suggested => 'Foreslået';

  @override
  String get removeGoal => 'Fjern mål';

  @override
  String get addOneMoreRecordToSeeTrend =>
      'Tilføj 1 måling mere for at se din trend';

  @override
  String get noWeightRecorded => 'Ingen vægt registreret endnu';

  @override
  String get startTrackingYourWeight =>
      'Begynd at registrere din vægt for at se fremskridt her';

  @override
  String get treadmillSession => 'Løbebåndssession';

  @override
  String get bikeSession => 'Cykelsession';

  @override
  String get stairmasterSession => 'Stairmaster-session';

  @override
  String get treadmillWorkout => 'Løbebåndstræning';

  @override
  String get bikeWorkout => 'Cykeltræning';

  @override
  String get stairmasterWorkout => 'Stairmaster-træning';

  @override
  String get startAWorkoutToSeeItHere => 'Start en træning for at se den her';

  @override
  String get mon => 'man';

  @override
  String get tue => 'tir';

  @override
  String get wed => 'ons';

  @override
  String get thu => 'tor';

  @override
  String get fri => 'fre';

  @override
  String get sat => 'lør';

  @override
  String get sun => 'søn';

  @override
  String get sessions => 'Sessioner';

  @override
  String get distance => 'Distance';

  @override
  String get today => 'I dag';

  @override
  String get yesterday => 'I går';

  @override
  String get noWorkoutsYet => 'Ingen træninger endnu';

  @override
  String get startYourFirstWorkout =>
      'Start din første træning for at se din historik';

  @override
  String get goToRoutines => 'Gå til rutiner';

  @override
  String get weightRecorded => 'Vægt registreret';

  @override
  String get workout => 'træning';

  @override
  String get workouts => 'træninger';

  @override
  String get goal => 'Mål';

  @override
  String get toGo => 'tilbage';

  @override
  String get over => 'over';

  @override
  String get last => 'Sidste';

  @override
  String get newLabel => 'Ny';

  @override
  String youNeed(String amount, String goal) {
    return 'Du mangler $amount for at nå $goal';
  }

  @override
  String youNeedPlus(String amount, String goal) {
    return 'Du mangler +$amount for at nå $goal';
  }

  @override
  String get current => 'Nuværende';

  @override
  String get premiumHeadline => 'Samme 30 minutter, anderledes resultater';

  @override
  String get premiumSubheadlineNew =>
      'Løb ikke bare – træn på den fedtforbrændende måde';

  @override
  String get mostPopular => 'Mest populær';

  @override
  String dailyPrice(int price) {
    return '$price pr. dag';
  }

  @override
  String get benefitVoiceCoaching => 'Premium Stemmecoaching System';

  @override
  String get benefitCycleStairmasterRoutines =>
      'Fuld Support til Alt Cardio-udstyr';

  @override
  String get benefitUnlimitedRoutinesNew => 'Ubegrænset Rutine-bibliotek';

  @override
  String get benefitWeightFeature => 'Smart Vægtsporing & Analyse';

  @override
  String get benefitNoAdsFocus => 'Reklamefri Premium Oplevelse';

  @override
  String get benefitFutureFeaturesNew =>
      'Alle fremtidige premiumfunktioner inkluderet';

  @override
  String get mostChosen => 'Mest valgt';

  @override
  String get canChangeAnytime => 'Kan ændres når som helst';

  @override
  String get startPremium => 'Start Premium';

  @override
  String get cancelAnytimeKeepAccess =>
      'Annuller når som helst og behold adgang til periodens slutning';

  @override
  String workoutDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Træning $count dage 🔥',
      one: 'Træning 1 dag 🔥',
    );
    return '$_temp0';
  }

  @override
  String restDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hvil $count dage 🛏️',
      one: 'Hvil 1 dag 🛏️',
    );
    return '$_temp0';
  }
}
