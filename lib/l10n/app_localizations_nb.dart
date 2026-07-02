// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get appTitle => 'Interval Cardio';

  @override
  String get settingsTitle => 'Innstillinger';

  @override
  String get language => 'Språk';

  @override
  String get system => 'System';

  @override
  String get voiceGuide => 'Stemmeguide';

  @override
  String get audioNavigator => 'Lydnavigatør';

  @override
  String get soundEffects => 'Lydeffekter';

  @override
  String get unitSetting => 'Enheter';

  @override
  String get kmh => 'km/t';

  @override
  String get mph => 'mph';

  @override
  String get themeMode => 'Utseende';

  @override
  String get light => 'Lys';

  @override
  String get dark => 'Mørk';

  @override
  String get smartwatchSync => 'Smartwatch Sync';

  @override
  String get connectSmartwatch => 'Koble til smartklokke';

  @override
  String get connect => 'Koble til';

  @override
  String get about => 'Om';

  @override
  String version(String version) {
    return 'Versjon $version';
  }

  @override
  String get comingSoon => 'Kommer snart';

  @override
  String get translationComingSoon =>
      'Oversettelse blir tilgjengelig i en framtidig oppdatering.';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Avbryt';

  @override
  String get done => 'Ferdig';

  @override
  String get delete => 'Slett';

  @override
  String get save => 'Lagre';

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
  String get unnamedRoutine => 'Rutine uten navn';

  @override
  String get difficulty => 'Vanskelighetsgrad';

  @override
  String difficultyColon(String difficulty) {
    return 'Vanskelighetsgrad : $difficulty';
  }

  @override
  String get easy => 'Lett';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get interval => 'Intervall';

  @override
  String get addInterval => 'Legg til intervall';

  @override
  String get quickTools => 'Hurtigverktøy';

  @override
  String get addDefault => 'Legg til standard';

  @override
  String get duplicateLast => 'Kopier siste';

  @override
  String get repeatPattern => 'Gjenta mønster';

  @override
  String get patternLength => 'Mønsterlengde';

  @override
  String get repeatCount => 'Antall kopier';

  @override
  String get noIntervals => 'Ingen intervaller';

  @override
  String get addIntervalPrompt => 'Legg til et intervall';

  @override
  String get intervalEdit => 'Rediger intervall';

  @override
  String get timeMinutes => 'Tid (minutter)';

  @override
  String get duration => 'Varighet';

  @override
  String get speed => 'Hastighet';

  @override
  String get speedKmh => 'Hastighet (km/t)';

  @override
  String get incline => 'Stigning';

  @override
  String get level => 'Nivå';

  @override
  String levelColon(int level) {
    return 'Nivå $level';
  }

  @override
  String get rpm => 'RPM';

  @override
  String get resistance => 'Motstand';

  @override
  String get resistanceLevel => 'Motstand (nivå)';

  @override
  String resistanceColon(int resistance) {
    return 'Motstand $resistance';
  }

  @override
  String get spm => 'SPM';

  @override
  String get spmSteps => 'SPM (steg/min)';

  @override
  String get saved => 'Lagret';

  @override
  String get deleted => 'Slettet';

  @override
  String get deleteRoutineTitle => 'Slett rutine';

  @override
  String get deleteRoutineMessage =>
      'Er du sikker på at du vil slette denne rutinen? Dette kan ikke angres.';

  @override
  String get deleteError => 'En feil oppstod ved sletting';

  @override
  String get nameRequired => 'Skriv inn et navn';

  @override
  String get nameMaxLength => 'Navnet må være 24 tegn eller mindre';

  @override
  String get minIntervalsRequired => 'Minst ett intervall er påkrevd';

  @override
  String get intervalMinDuration => 'Intervallvarighet må være minst 1 sekund';

  @override
  String get intervalMaxDuration =>
      'Intervallvarighet kan være maks 3 timer (10800 sekunder)';

  @override
  String get speedRange => 'Hastighet må være større enn 0 (0.5–25.0 km/t)';

  @override
  String get inclineRange => 'Stigning må være i området 0–15.0';

  @override
  String get rpmRange => 'RPM må være i området 30–200';

  @override
  String get resistanceRange => 'Motstand må være i området 1–20';

  @override
  String get levelRange => 'Nivå må være i området 1–20';

  @override
  String get spmRange => 'SPM må være i området 50–200';

  @override
  String get noRoutinesSaved => 'Ingen rutiner lagret';

  @override
  String get tapToCreate => 'Trykk for å opprette';

  @override
  String get tapButtonToCreate => 'Trykk på knappen for å opprette';

  @override
  String get premiumRoutineSettings => 'Premium rutineinnstillinger';

  @override
  String get viewMembership => 'Se Premium';

  @override
  String get freeLimitTitle => '2 gratis rutiner';

  @override
  String get freeLimitMessage => 'Få ubegrensede rutiner med Premium';

  @override
  String get treadmill => 'Tredemølle';

  @override
  String get cycle => 'Sykkel';

  @override
  String get stairmaster => 'Stairmaster';

  @override
  String get selectLanguage => 'Språk';

  @override
  String get selectTheme => 'Velg tema';

  @override
  String get selectDifficulty => 'Velg vanskelighetsgrad';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Gjenoppta';

  @override
  String get endWorkout => 'Avslutt økt';

  @override
  String get endWorkoutConfirm => 'Vil du avslutte treningen?';

  @override
  String get end => 'Avslutt';

  @override
  String get share => 'Del';

  @override
  String get rotate => 'Roter';

  @override
  String get paused => 'PAUSET';

  @override
  String get pausedTitle => 'Pauset';

  @override
  String get pausedSubtitle => 'Du kan fortsette eller avslutte treningen';

  @override
  String get endWorkoutConfirmationMessage =>
      'Hvis du avslutter nå, fullføres treningen og du går til oppsummeringen.';

  @override
  String get workoutComplete => 'Økt fullført';

  @override
  String get totalWorkoutTime => 'Total tid';

  @override
  String get totalDistance => 'Total distanse';

  @override
  String get totalTime => 'Total tid';

  @override
  String get averageRpm => 'Gjennomsnittlig RPM';

  @override
  String get averageLevel => 'Gjennomsnittlig nivå';

  @override
  String get holdToStop => 'Hold for å stoppe';

  @override
  String get continueWorkout => 'Fortsett';

  @override
  String get endWorkoutQuestion => 'Vil du avslutte treningen?';

  @override
  String get workoutPaused => 'Økten har blitt pauset';

  @override
  String get lvlIncline => 'Stigning';

  @override
  String get lvlResistance => 'Nivå motstand';

  @override
  String get premium => 'Premium';

  @override
  String get upgradeNow => 'Oppgrader nå';

  @override
  String get purchase => 'Kjøp';

  @override
  String get later => 'Senere';

  @override
  String get premiumActivated => 'Premium er aktivert';

  @override
  String get premiumMembership => 'Premium';

  @override
  String get benefitCycleStairmaster => 'Rutiner for sykkel og StairMaster';

  @override
  String get benefitVoiceGuide => 'Stemmeguide for hver økt';

  @override
  String get benefitUnlimitedRoutines => 'Ubegrenset lagring av rutiner';

  @override
  String get noAds => 'Ingen annonser';

  @override
  String get benefitFutureFeatures => 'Alle fremtidige funksjoner inkludert';

  @override
  String get voiceGuideBenefit1 => 'Lydbasert trenerveiledning';

  @override
  String get voiceGuideBenefit2 => 'Automatisk beskjed ved skifte av økt';

  @override
  String get voiceGuideBenefit3 => 'Fokuser håndfritt på treningen';

  @override
  String get routineLimitBenefit1 => 'Ubegrenset lagring av rutiner';

  @override
  String get routineLimitBenefit2 => 'Målrettede rutiner til dine mål';

  @override
  String get routineLimitBenefit3 =>
      'Full støtte for tredemølle, sykkel og StairMaster';

  @override
  String get premium_benefit_1 => 'Støtte for <red>sykkel & StairMaster</red>';

  @override
  String get premium_benefit_2 => '<red>Stemmeguide</red> under treningen';

  @override
  String get premium_benefit_3 => 'Gem rutiner <red>uten grenser</red>';

  @override
  String get premium_benefit_4 =>
      'Alle fremtidige funksjoner <red>inkludert på livstid</red>';

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
      'Lås opp stemmeguide, sykkel- og stairmaster-økter og ubegrensede rutiner';

  @override
  String get monthly => 'Månedlig';

  @override
  String get yearly => 'Årlig';

  @override
  String get lifetime => 'Livstid';

  @override
  String get freeTrial7Days => '7 dagers gratis prøveperiode';

  @override
  String get perMonth => '/måned';

  @override
  String get perYear => '/år';

  @override
  String get oneTime => 'Engangsgebyg';

  @override
  String savePercent(int percent) {
    return 'Spar $percent%';
  }

  @override
  String get bestValue => 'Best verdi';

  @override
  String get cancelAnytime => 'Avslutt når som helst';

  @override
  String get autoRenewableSubscription => 'Fornyes automatisk';

  @override
  String get terms => 'Vilkår';

  @override
  String get privacy => 'Personvern';

  @override
  String get restore => 'Gjenopprett';

  @override
  String get premiumTab => 'Premium';

  @override
  String get routineTab => 'Rutine';

  @override
  String get settingsTab => 'Innstillinger';

  @override
  String get myTab => 'Min';

  @override
  String get close => 'Lukk';

  @override
  String get premiumFeature => 'Kun Premium';

  @override
  String get usePremiumTest => 'Test Premium';

  @override
  String dateTimeFormat(int year, int month, int day, int hour, int minute) {
    return '$day/$month/$year $hour:$minute';
  }

  @override
  String get checkRoutineStart => 'Se og start';

  @override
  String get beginner => 'Nybegynner';

  @override
  String get intermediate => 'Middels';

  @override
  String get advanced => 'Avansert';

  @override
  String get viewRecommendedRoutines => 'Forslag →';

  @override
  String get recommendedRoutinesTreadmill => 'Tredemølle-forslag';

  @override
  String get recommendedRoutinesCycle => 'Sykkel-forslag';

  @override
  String get recommendedRoutinesStairmaster => 'Stairmaster-forslag';

  @override
  String get alreadySaved => 'Allerede lagret';

  @override
  String get routineSaved => 'Rutine lagret';

  @override
  String get checkRoutine => 'Se';

  @override
  String get saveRoutine => 'Lagre rutine';

  @override
  String get routineAlreadySaved => 'Rutinen er allerede lagret';

  @override
  String get noTemplatesFound => 'Ingen maler funnet';

  @override
  String get avg => 'Snitt';

  @override
  String get avgRpm => 'Snitt RPM';

  @override
  String get avgLevel => 'Snittnivå';

  @override
  String get templateTreadmillBeginner1Title => 'Nybegynner Tredemølle 1';

  @override
  String get templateTreadmillBeginner1Subtitle =>
      '1:1 gange og løping etter 3 min oppvarming';

  @override
  String get templateTreadmillBeginner2Title =>
      'Nybegynner Tredemølle 2 (Stigning)';

  @override
  String get templateTreadmillBeginner2Subtitle =>
      'Stigningsgang med lav leddbelastning';

  @override
  String get templateTreadmillIntermediate1Title => 'Viderekommen Tredemølle 1';

  @override
  String get templateTreadmillIntermediate1Subtitle =>
      '1:1 løpeintervall for fettforbrenning';

  @override
  String get templateTreadmillIntermediate2Title =>
      'Viderekommen Tredemølle 2 (Fart)';

  @override
  String get templateTreadmillIntermediate2Subtitle =>
      'Pyramide fartstrening løping';

  @override
  String get templateTreadmillAdvanced1Title => 'Avansert Tredemølle 1';

  @override
  String get templateTreadmillAdvanced1Subtitle =>
      'Høyintensiv kondisjonsøkt-intervall';

  @override
  String get templateTreadmillAdvanced2Title =>
      'Avansert Tredemølle 2 (Sprint)';

  @override
  String get templateTreadmillAdvanced2Subtitle =>
      'Korte sprintrepetisjoner med høy intensitet';

  @override
  String get templateCycleBeginner1Title => 'Nybegynner Sykkel 1';

  @override
  String get templateCycleBeginner1Subtitle =>
      'Pedaltreningsintroduksjon ved å justere RPM';

  @override
  String get templateCycleBeginner2Title => 'Nybegynner Sykkel 2 (Stabil)';

  @override
  String get templateCycleBeginner2Subtitle =>
      'Utholdenhetstrening ved konstant motstand';

  @override
  String get templateCycleIntermediate1Title => 'Viderekommen Sykkel 1';

  @override
  String get templateCycleIntermediate1Subtitle =>
      '1 min høyt tempo / 1 min restitusjon spinn';

  @override
  String get templateCycleIntermediate2Title => 'Viderekommen Sykkel 2 (Bakke)';

  @override
  String get templateCycleIntermediate2Subtitle =>
      'Bakkeklatring ved høy motstand';

  @override
  String get templateCycleAdvanced1Title => 'Avansert Sykkel 1';

  @override
  String get templateCycleAdvanced1Subtitle =>
      '30s styrkeintervaller ved høy motstand';

  @override
  String get templateCycleAdvanced2Title => 'Avansert Sykkel 2 (Tabata)';

  @override
  String get templateCycleAdvanced2Subtitle =>
      '20s/10s Tabata-sirkel for fettforbrenning';

  @override
  String get templateStairmasterBeginner1Title => 'Nybegynner Stairmaster 1';

  @override
  String get templateStairmasterBeginner1Subtitle =>
      'Sikker trappegang i tilpasningstempo';

  @override
  String get templateStairmasterBeginner2Title =>
      'Nybegynner Stairmaster 2 (Stabil)';

  @override
  String get templateStairmasterBeginner2Subtitle =>
      'Aerob trappesimulering i konstant tempo';

  @override
  String get templateStairmasterIntermediate1Title =>
      'Viderekommen Stairmaster 1 (Klatring)';

  @override
  String get templateStairmasterIntermediate1Subtitle =>
      '2 min klatring / 1 min restitusjon av setemuskler';

  @override
  String get templateStairmasterIntermediate2Title =>
      'Viderekommen Stairmaster 2';

  @override
  String get templateStairmasterIntermediate2Subtitle =>
      'Intervaller med vekselvis raskt/langsomt tempo';

  @override
  String get templateStairmasterAdvanced1Title => 'Avansert Stairmaster 1';

  @override
  String get templateStairmasterAdvanced1Subtitle =>
      'Intensiv 2-minutters blokktrening';

  @override
  String get templateStairmasterAdvanced2Title =>
      'Avansert Stairmaster 2 (Sprint)';

  @override
  String get templateStairmasterAdvanced2Subtitle =>
      '30s rask klatring / 60s restitusjon';

  @override
  String get historyTab => 'Historikk';

  @override
  String get calendarTab => 'Kalender';

  @override
  String get weightTab => 'Vekt';

  @override
  String get bike => 'Sykkel';

  @override
  String get thisWeek => 'Denne uken';

  @override
  String get trend => 'Vektutvikling';

  @override
  String get timeframe7D => '7D';

  @override
  String get timeframe30D => '30D';

  @override
  String get timeframe90D => '90D';

  @override
  String get timeframeAll => 'ALLE';

  @override
  String get history => 'Historikk';

  @override
  String get seeAll => 'Se alle';

  @override
  String get weightEntryDeleted => 'Vektregistrering slettet';

  @override
  String get weightUpdated => 'Vekt oppdatert';

  @override
  String get editWeight => 'Rediger vekt';

  @override
  String get recordWeight => 'Logg vekt';

  @override
  String get quickAdjust => 'Hurtigjustering';

  @override
  String get goalWeightSet => 'Målvekt satt';

  @override
  String get goalWeightRemoved => 'Målkvekt er deaktiveret';

  @override
  String get goalAchieved => 'Mål oppnådd!';

  @override
  String get goalMatchesCurrentWeight => 'Målet samsvarer med nåværende vekt';

  @override
  String get setGoal => 'Sett mål';

  @override
  String get suggested => 'Foreslått';

  @override
  String get removeGoal => 'Fjern mål';

  @override
  String get addOneMoreRecordToSeeTrend =>
      'Legg til 1 måling til for å se utviklingen';

  @override
  String get noWeightRecorded => 'Ingen vekt registrert ennå';

  @override
  String get startTrackingYourWeight => 'Logg vekt for å følge framgangen';

  @override
  String get treadmillSession => 'Tredemølleøkt';

  @override
  String get bikeSession => 'Sykkeløkt';

  @override
  String get stairmasterSession => 'Stairmaster-økt';

  @override
  String get treadmillWorkout => 'Tredemølletrening';

  @override
  String get bikeWorkout => 'Sykkeltrening';

  @override
  String get stairmasterWorkout => 'Stairmaster-trening';

  @override
  String get startAWorkoutToSeeItHere => 'Øktene dine vises her';

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
  String get sessions => 'Økter';

  @override
  String get distance => 'Distanse';

  @override
  String get today => 'I dag';

  @override
  String get yesterday => 'I går';

  @override
  String get noWorkoutsYet => 'Ingen økter ennå';

  @override
  String get startYourFirstWorkout =>
      'Start din første økt for å se historikken';

  @override
  String get goToRoutines => 'Gå til rutiner';

  @override
  String get weightRecorded => 'Vekt registrert';

  @override
  String get workout => 'økt';

  @override
  String get workouts => 'økter';

  @override
  String get goal => 'Mål';

  @override
  String get toGo => 'igjen';

  @override
  String get over => 'over';

  @override
  String get last => 'Siste';

  @override
  String get newLabel => 'Ny';

  @override
  String youNeed(String amount, String goal) {
    return 'Du trenger $amount for å nå $goal';
  }

  @override
  String youNeedPlus(String amount, String goal) {
    return 'Du trenger +$amount for å nå $goal';
  }

  @override
  String get current => 'Nåværende';

  @override
  String get premiumHeadline => 'Samme 30 minutter, ulike resultater';

  @override
  String get premiumSubheadlineNew =>
      'Ikke bare løp – tren på den fettforbrennende måten';

  @override
  String get mostPopular => 'Mest populær';

  @override
  String dailyPrice(int price) {
    return '$price per dag';
  }

  @override
  String get benefitVoiceCoaching => 'Premium Stemmecoaching System';

  @override
  String get benefitCycleStairmasterRoutines =>
      'Full Støtte for Alt Cardio-utstyr';

  @override
  String get benefitUnlimitedRoutinesNew => 'Ubegrenset Rutine-bibliotek';

  @override
  String get benefitWeightFeature => 'Smart Vektsporing & Analyse';

  @override
  String get benefitNoAdsFocus => 'Reklamefri Premium Opplevelse';

  @override
  String get benefitFutureFeaturesNew =>
      'Alle framtidige premiumfunksjoner inkludert';

  @override
  String get mostChosen => 'Toppvalg';

  @override
  String get canChangeAnytime => 'Bytt når som helst';

  @override
  String get startPremium => 'Få Premium';

  @override
  String get cancelAnytimeKeepAccess => 'Avslutt når som helst, behold tilgang';

  @override
  String workoutDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Trening $count dager 🔥',
      one: 'Trening 1 dag 🔥',
    );
    return '$_temp0';
  }

  @override
  String restDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hvil $count dager 🛏️',
      one: 'Hvil 1 dag 🛏️',
    );
    return '$_temp0';
  }

  @override
  String get workoutReminderTitle => 'Påminnelser';

  @override
  String get workoutReminderOff => 'Av';

  @override
  String get workoutReminderEveryDay => 'Hver dag';

  @override
  String get workoutReminderSelectTime => 'Velg tidspunkt';

  @override
  String get workoutReminderPermissionRequired =>
      'Varslingstillatelse er påkrevd.';

  @override
  String get workoutReminderTimeLabel => 'Tidspunkt';
}
