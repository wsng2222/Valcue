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
  String get unitSetting => 'Enhetsinnstilling';

  @override
  String get kmh => 'km/t';

  @override
  String get mph => 'mph';

  @override
  String get themeMode => 'Lys/mørk-modus';

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
  String get viewMembership => 'Se medlemskap';

  @override
  String get freeLimitTitle => 'Gratisgrensen er 2 rutiner';

  @override
  String get freeLimitMessage =>
      'Med medlemskap kan du bruke ubegrenset med rutiner';

  @override
  String get treadmill => 'Tredemølle';

  @override
  String get cycle => 'Sykkel';

  @override
  String get stairmaster => 'Stairmaster';

  @override
  String get selectLanguage => 'Velg språk';

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
  String get totalWorkoutTime => 'Total treningstid';

  @override
  String get totalDistance => 'Total distanse';

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
  String get premiumMembership => 'Premium-medlemskap';

  @override
  String get benefitCycleStairmaster => 'Sykkel- og Stairmaster-funksjon';

  @override
  String get benefitVoiceGuide => 'Stemmeguide for økt';

  @override
  String get benefitUnlimitedRoutines => 'Ubegrenset lagring av rutiner';

  @override
  String get noAds => 'Ingen annonser';

  @override
  String get benefitFutureFeatures =>
      'Ubegrenset tilgang til framtidige funksjoner';

  @override
  String get voiceGuideBenefit1 => 'Stemmeveiledning under trening';

  @override
  String get voiceGuideBenefit2 => 'Automatiske annonseringer ved øktbytte';

  @override
  String get voiceGuideBenefit3 => 'Handsfree fokus på rutinen';

  @override
  String get routineLimitBenefit1 => 'Ubegrenset lagring av rutiner';

  @override
  String get routineLimitBenefit2 => 'Lagre rutiner for flere mål';

  @override
  String get routineLimitBenefit3 =>
      'Bruk alle maskintyper (tredemølle/sykkel/stairmaster)';

  @override
  String get premium_benefit_1 => '<red>Sykkel & StairMaster</red>-økter';

  @override
  String get premium_benefit_2 => 'Økt <red>stemmeguide</red>';

  @override
  String get premium_benefit_3 => '<red>Ubegrenset</red> rutine-lagring';

  @override
  String get premium_benefit_4 =>
      '<red>Ubegrenset tilgang</red> til framtidige funksjoner';

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
  String get autoRenewableSubscription => 'Automatisk fornybart abonnement';

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
  String get premiumFeature => 'Premiumfunksjon';

  @override
  String get usePremiumTest => 'Bruk Premium (test)';

  @override
  String dateTimeFormat(int year, int month, int day, int hour, int minute) {
    return '$day/$month/$year $hour:$minute';
  }

  @override
  String get checkRoutineStart => 'Sjekk rutine / Start';

  @override
  String get beginner => 'Nybegynner';

  @override
  String get intermediate => 'Middels';

  @override
  String get advanced => 'Avansert';

  @override
  String get viewRecommendedRoutines => 'Se anbefalte rutiner →';

  @override
  String get recommendedRoutinesTreadmill => 'Anbefalte tredemølle-rutiner';

  @override
  String get recommendedRoutinesCycle => 'Anbefalte sykkelrutiner';

  @override
  String get recommendedRoutinesStairmaster => 'Anbefalte stairmaster-rutiner';

  @override
  String get alreadySaved => 'Allerede lagret';

  @override
  String get routineSaved => 'Rutine lagret';

  @override
  String get checkRoutine => 'Sjekk';

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
  String get templateTreadmillBeginner1Title => 'Enkel start 20';

  @override
  String get templateTreadmillBeginner1Subtitle => 'Lette 1:1 intervaller';

  @override
  String get templateTreadmillBeginner2Title => 'Stigning-gange 25';

  @override
  String get templateTreadmillBeginner2Subtitle => 'Stigning-gange blokker';

  @override
  String get templateTreadmillIntermediate1Title => 'Klassisk 1:1 24';

  @override
  String get templateTreadmillIntermediate1Subtitle =>
      'Klassiske 1:1 løpeintervaller';

  @override
  String get templateTreadmillIntermediate2Title => 'Fartsstige 20';

  @override
  String get templateTreadmillIntermediate2Subtitle => 'Trinnvis fartsstige';

  @override
  String get templateTreadmillAdvanced1Title => '2:1 Burner 21';

  @override
  String get templateTreadmillAdvanced1Subtitle => '2:1 hard/lett intervaller';

  @override
  String get templateTreadmillAdvanced2Title => 'Sprint Pop 18';

  @override
  String get templateTreadmillAdvanced2Subtitle => '20 s sprintrepetisjoner';

  @override
  String get templateCycleBeginner1Title => 'Kadensbygger 20';

  @override
  String get templateCycleBeginner1Subtitle => '4 min oppvarming + 1:1 kadens';

  @override
  String get templateCycleBeginner2Title => 'Jevn tur 25';

  @override
  String get templateCycleBeginner2Subtitle => 'Lang jevn blokk';

  @override
  String get templateCycleIntermediate1Title => 'Spinn 1:1 24';

  @override
  String get templateCycleIntermediate1Subtitle =>
      'Klassiske 1:1 spinnintervaller';

  @override
  String get templateCycleIntermediate2Title => 'Bakkesimulering 22';

  @override
  String get templateCycleIntermediate2Subtitle => 'Klatrerepetisjoner';

  @override
  String get templateCycleAdvanced1Title => 'Kraftintervaller 20';

  @override
  String get templateCycleAdvanced1Subtitle => '30 s kraftøkter';

  @override
  String get templateCycleAdvanced2Title => 'Tabata-miks 16';

  @override
  String get templateCycleAdvanced2Subtitle => '20 s på / 10 s av-miks';

  @override
  String get templateStairmasterBeginner1Title => 'Enkle trinn 20';

  @override
  String get templateStairmasterBeginner1Subtitle =>
      '4 min oppvarming + 1:1 trinn';

  @override
  String get templateStairmasterBeginner2Title => 'Lang lett 25';

  @override
  String get templateStairmasterBeginner2Subtitle =>
      'Lange lette klatreblokker';

  @override
  String get templateStairmasterIntermediate1Title => '2:1 Klatring 21';

  @override
  String get templateStairmasterIntermediate1Subtitle =>
      '2:1 klatrerepetisjoner';

  @override
  String get templateStairmasterIntermediate2Title => 'Sterk 1:1 24';

  @override
  String get templateStairmasterIntermediate2Subtitle =>
      'Sterke 1:1 intervaller';

  @override
  String get templateStairmasterAdvanced1Title => 'Harde blokker 20';

  @override
  String get templateStairmasterAdvanced1Subtitle => '2-min harde blokker';

  @override
  String get templateStairmasterAdvanced2Title => 'Sprint Steps 18';

  @override
  String get templateStairmasterAdvanced2Subtitle =>
      '30 s spurter + 60 s hvile';

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
  String get recordWeight => 'Registrer vekt';

  @override
  String get quickAdjust => 'Hurtigjustering';

  @override
  String get goalWeightSet => 'Målvekt satt';

  @override
  String get goalWeightRemoved => 'Målvekt fjernet';

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
      'Legg til 1 måling til for å se trenden din';

  @override
  String get noWeightRecorded => 'Ingen vekt registrert ennå';

  @override
  String get startTrackingYourWeight =>
      'Begynn å registrere vekten din for å se fremgang her';

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
  String get startAWorkoutToSeeItHere => 'Start en økt for å se den her';

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
  String get benefitWeightFeature => 'Smart Weight Tracking & Analysis';

  @override
  String get benefitNoAdsFocus => 'Reklamefri Premium Opplevelse';

  @override
  String get benefitFutureFeaturesNew =>
      'Alle framtidige premiumfunksjoner inkludert';

  @override
  String get mostChosen => 'Mest valgt';

  @override
  String get canChangeAnytime => 'Kan endres når som helst';

  @override
  String get startPremium => 'Start Premium';

  @override
  String get cancelAnytimeKeepAccess =>
      'Avslutt når som helst og behold tilgang til perioden ut';

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
}
