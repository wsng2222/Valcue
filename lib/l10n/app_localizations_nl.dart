// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Interval Cardio';

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String get language => 'Taal';

  @override
  String get system => 'Systeem';

  @override
  String get voiceGuide => 'Spraakgids';

  @override
  String get audioNavigator => 'Audio-navigator';

  @override
  String get soundEffects => 'Geluidseffecten';

  @override
  String get unitSetting => 'Eenheidsinstelling';

  @override
  String get kmh => 'km/h';

  @override
  String get mph => 'mph';

  @override
  String get themeMode => 'Licht/donker-modus';

  @override
  String get light => 'Licht';

  @override
  String get dark => 'Donker';

  @override
  String get smartwatchSync => 'Smartwatch Sync';

  @override
  String get connectSmartwatch => 'Koppel met smartwatch';

  @override
  String get connect => 'Koppelen';

  @override
  String get about => 'Over';

  @override
  String version(String version) {
    return 'Versie $version';
  }

  @override
  String get comingSoon => 'Binnenkort';

  @override
  String get translationComingSoon =>
      'Vertaling wordt beschikbaar in een toekomstige update.';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annuleren';

  @override
  String get done => 'Gereed';

  @override
  String get delete => 'Verwijderen';

  @override
  String get save => 'Opslaan';

  @override
  String get edit => 'Bewerken';

  @override
  String get start => 'Start';

  @override
  String get editRoutine => 'Routine bewerken';

  @override
  String get routineEdit => 'Routine bewerken';

  @override
  String get name => 'Naam';

  @override
  String get unnamedRoutine => 'Naamloze routine';

  @override
  String get difficulty => 'Moeilijkheid';

  @override
  String difficultyColon(String difficulty) {
    return 'Moeilijkheid : $difficulty';
  }

  @override
  String get easy => 'Makkelijk';

  @override
  String get medium => 'Midden';

  @override
  String get hard => 'Zwaar';

  @override
  String get interval => 'Interval';

  @override
  String get addInterval => 'Interval toevoegen';

  @override
  String get noIntervals => 'Geen intervallen';

  @override
  String get addIntervalPrompt => 'Voeg een interval toe';

  @override
  String get intervalEdit => 'Interval bewerken';

  @override
  String get timeMinutes => 'Tijd (minuten)';

  @override
  String get duration => 'Duur';

  @override
  String get speed => 'Snelheid';

  @override
  String get speedKmh => 'Snelheid (km/h)';

  @override
  String get incline => 'Helling';

  @override
  String get level => 'Niveau';

  @override
  String levelColon(int level) {
    return 'Niveau $level';
  }

  @override
  String get rpm => 'RPM';

  @override
  String get resistance => 'Weerstand';

  @override
  String get resistanceLevel => 'Weerstand (niveau)';

  @override
  String resistanceColon(int resistance) {
    return 'Weerstand $resistance';
  }

  @override
  String get spm => 'SPM';

  @override
  String get spmSteps => 'SPM (stappen/min)';

  @override
  String get saved => 'Opgeslagen';

  @override
  String get deleted => 'Verwijderd';

  @override
  String get deleteRoutineTitle => 'Routine verwijderen';

  @override
  String get deleteRoutineMessage =>
      'Weet je zeker dat je deze routine wilt verwijderen? Dit kan niet ongedaan worden gemaakt.';

  @override
  String get deleteError => 'Er is een fout opgetreden bij het verwijderen';

  @override
  String get nameRequired => 'Voer een naam in';

  @override
  String get nameMaxLength => 'Naam moet 24 tekens of minder zijn';

  @override
  String get minIntervalsRequired => 'Minstens één interval is vereist';

  @override
  String get intervalMinDuration => 'Intervalduur moet minimaal 1 seconde zijn';

  @override
  String get intervalMaxDuration =>
      'Intervalduur mag maximaal 3 uur zijn (10800 seconden)';

  @override
  String get speedRange => 'Snelheid moet groter zijn dan 0 (0.5-25.0 km/h)';

  @override
  String get inclineRange => 'Helling moet tussen 0-15.0 liggen';

  @override
  String get rpmRange => 'RPM moet tussen 30-200 liggen';

  @override
  String get resistanceRange => 'Weerstand moet tussen 1-20 liggen';

  @override
  String get levelRange => 'Niveau moet tussen 1-20 liggen';

  @override
  String get spmRange => 'SPM moet tussen 50-200 liggen';

  @override
  String get noRoutinesSaved => 'Geen routines opgeslagen';

  @override
  String get tapToCreate => 'Tik om te maken';

  @override
  String get tapButtonToCreate => 'Tik op de knop om te maken';

  @override
  String get premiumRoutineSettings => 'Premium routine-instellingen';

  @override
  String get viewMembership => 'Lidmaatschap bekijken';

  @override
  String get freeLimitTitle => 'Gratis limiet is 2 routines';

  @override
  String get freeLimitMessage =>
      'Met lidmaatschap kun je onbeperkt routines gebruiken';

  @override
  String get treadmill => 'Loopband';

  @override
  String get cycle => 'Fiets';

  @override
  String get stairmaster => 'Stairmaster';

  @override
  String get selectLanguage => 'Taal kiezen';

  @override
  String get selectTheme => 'Thema kiezen';

  @override
  String get selectDifficulty => 'Moeilijkheid kiezen';

  @override
  String get pause => 'Pauze';

  @override
  String get resume => 'Hervatten';

  @override
  String get endWorkout => 'Workout beëindigen';

  @override
  String get endWorkoutConfirm => 'Wil je de workout beëindigen?';

  @override
  String get end => 'Stoppen';

  @override
  String get share => 'Delen';

  @override
  String get rotate => 'Draaien';

  @override
  String get paused => 'GEPAUZEERD';

  @override
  String get pausedTitle => 'Gepauzeerd';

  @override
  String get pausedSubtitle => 'Je kunt doorgaan of de workout beëindigen';

  @override
  String get endWorkoutConfirmationMessage =>
      'Als je nu stopt, wordt de huidige workout beëindigd en ga je naar het overzichtsscherm.';

  @override
  String get workoutComplete => 'Workout voltooid';

  @override
  String get totalWorkoutTime => 'Totale tijd';

  @override
  String get totalDistance => 'Totale afstand';

  @override
  String get totalTime => 'Totale tijd';

  @override
  String get averageRpm => 'Gemiddelde RPM';

  @override
  String get averageLevel => 'Gemiddeld niveau';

  @override
  String get holdToStop => 'Vasthouden om te stoppen';

  @override
  String get continueWorkout => 'Doorgaan';

  @override
  String get endWorkoutQuestion => 'Wil je de workout beëindigen?';

  @override
  String get workoutPaused => 'De workout is gepauzeerd';

  @override
  String get lvlIncline => 'Helling';

  @override
  String get lvlResistance => 'Niv. weerstand';

  @override
  String get premium => 'Premium';

  @override
  String get upgradeNow => 'Nu upgraden';

  @override
  String get purchase => 'Kopen';

  @override
  String get later => 'Later';

  @override
  String get premiumActivated => 'Premium is geactiveerd';

  @override
  String get premiumMembership => 'Premium lidmaatschap';

  @override
  String get benefitCycleStairmaster => 'Fiets-, Stairmaster-functie';

  @override
  String get benefitVoiceGuide => 'Sessiespraakgids-functie';

  @override
  String get benefitUnlimitedRoutines => 'Onbeperkt routines opslaan';

  @override
  String get noAds => 'Geen advertenties';

  @override
  String get benefitFutureFeatures =>
      'Onbeperkte toegang tot toekomstige functies';

  @override
  String get voiceGuideBenefit1 => 'Spraakbegeleiding tijdens workout';

  @override
  String get voiceGuideBenefit2 =>
      'Automatische aankondigingen bij sessiewissel';

  @override
  String get voiceGuideBenefit3 => 'Handsfree focus op je routine';

  @override
  String get routineLimitBenefit1 => 'Onbeperkt routines opslaan';

  @override
  String get routineLimitBenefit2 => 'Routines opslaan voor meerdere doelen';

  @override
  String get routineLimitBenefit3 =>
      'Gebruik alle typen apparaten (loopband/fiets/stairmaster)';

  @override
  String get premium_benefit_1 => '<red>Fiets & StairMaster</red>-workouts';

  @override
  String get premium_benefit_2 => 'Sessie <red>spraakgids</red>';

  @override
  String get premium_benefit_3 => '<red>Onbeperkt</red> routines opslaan';

  @override
  String get premium_benefit_4 =>
      '<red>Onbeperkte toegang</red> tot toekomstige functies';

  @override
  String originalPrice(String price) {
    return '$price';
  }

  @override
  String monthlyPrice(String price) {
    return '$price/maand';
  }

  @override
  String get premiumSubheadline =>
      'Ontgrendel spraakbegeleiding, fiets- & stairmasterworkouts en onbeperkte routines';

  @override
  String get monthly => 'Maandelijks';

  @override
  String get yearly => 'Jaarlijks';

  @override
  String get lifetime => 'Levenslang';

  @override
  String get freeTrial7Days => '7 dagen gratis proef';

  @override
  String get perMonth => '/maand';

  @override
  String get perYear => '/jaar';

  @override
  String get oneTime => 'Eenmalig';

  @override
  String savePercent(int percent) {
    return 'Bespaar $percent%';
  }

  @override
  String get bestValue => 'Beste waarde';

  @override
  String get cancelAnytime => 'Altijd opzegbaar';

  @override
  String get autoRenewableSubscription => 'Automatisch verlengbaar abonnement';

  @override
  String get terms => 'Voorwaarden';

  @override
  String get privacy => 'Privacy';

  @override
  String get restore => 'Herstellen';

  @override
  String get premiumTab => 'Premium';

  @override
  String get routineTab => 'Routine';

  @override
  String get settingsTab => 'Instellingen';

  @override
  String get myTab => 'Mijn';

  @override
  String get close => 'Sluiten';

  @override
  String get premiumFeature => 'Premiumfunctie';

  @override
  String get usePremiumTest => 'Premium gebruiken (test)';

  @override
  String dateTimeFormat(int year, int month, int day, int hour, int minute) {
    return '$day/$month/$year $hour:$minute';
  }

  @override
  String get checkRoutineStart => 'Routine bekijken / Starten';

  @override
  String get beginner => 'Beginner';

  @override
  String get intermediate => 'Gemiddeld';

  @override
  String get advanced => 'Geavanceerd';

  @override
  String get viewRecommendedRoutines => 'Aanbevolen routines bekijken →';

  @override
  String get recommendedRoutinesTreadmill => 'Aanbevolen loopbandroutines';

  @override
  String get recommendedRoutinesCycle => 'Aanbevolen fietsroutines';

  @override
  String get recommendedRoutinesStairmaster => 'Aanbevolen stairmasterroutines';

  @override
  String get alreadySaved => 'Al opgeslagen';

  @override
  String get routineSaved => 'Routine opgeslagen';

  @override
  String get checkRoutine => 'Bevestigen';

  @override
  String get saveRoutine => 'Routine opslaan';

  @override
  String get routineAlreadySaved => 'Routine al opgeslagen';

  @override
  String get noTemplatesFound => 'Geen sjablonen gevonden';

  @override
  String get avg => 'Gem.';

  @override
  String get avgRpm => 'Gem. RPM';

  @override
  String get avgLevel => 'Gem. niveau';

  @override
  String get templateTreadmillBeginner1Title => 'Makkelijke start 20';

  @override
  String get templateTreadmillBeginner1Subtitle => 'Makkelijke 1:1 intervallen';

  @override
  String get templateTreadmillBeginner2Title => 'Hellingwandeling 25';

  @override
  String get templateTreadmillBeginner2Subtitle => 'Hellingwandeling blokken';

  @override
  String get templateTreadmillIntermediate1Title => 'Klassiek 1:1 24';

  @override
  String get templateTreadmillIntermediate1Subtitle =>
      'Klassieke 1:1 hardloopintervallen';

  @override
  String get templateTreadmillIntermediate2Title => 'Snelheidsladder 20';

  @override
  String get templateTreadmillIntermediate2Subtitle =>
      'Stap-voor-stap snelheidsladder';

  @override
  String get templateTreadmillAdvanced1Title => '2:1 Burner 21';

  @override
  String get templateTreadmillAdvanced1Subtitle =>
      '2:1 zwaar/makkelijk intervallen';

  @override
  String get templateTreadmillAdvanced2Title => 'Sprint Pop 18';

  @override
  String get templateTreadmillAdvanced2Subtitle => '20 s sprint herhalingen';

  @override
  String get templateCycleBeginner1Title => 'Cadansbouwer 20';

  @override
  String get templateCycleBeginner1Subtitle => '4 min warming-up + 1:1 cadans';

  @override
  String get templateCycleBeginner2Title => 'Stabiele rit 25';

  @override
  String get templateCycleBeginner2Subtitle => 'Lang stabiel blok';

  @override
  String get templateCycleIntermediate1Title => 'Spin 1:1 24';

  @override
  String get templateCycleIntermediate1Subtitle =>
      'Klassieke 1:1 spinintervallen';

  @override
  String get templateCycleIntermediate2Title => 'Heuvelsimulatie 22';

  @override
  String get templateCycleIntermediate2Subtitle => 'Klimherhalingen';

  @override
  String get templateCycleAdvanced1Title => 'Krachtintervallen 20';

  @override
  String get templateCycleAdvanced1Subtitle => '30 s powerbursts';

  @override
  String get templateCycleAdvanced2Title => 'Tabata-mix 16';

  @override
  String get templateCycleAdvanced2Subtitle => '20 s aan / 10 s uit mix';

  @override
  String get templateStairmasterBeginner1Title => 'Makkelijke stappen 20';

  @override
  String get templateStairmasterBeginner1Subtitle =>
      '4 min warming-up + 1:1 stappen';

  @override
  String get templateStairmasterBeginner2Title => 'Lang makkelijk 25';

  @override
  String get templateStairmasterBeginner2Subtitle =>
      'Lange makkelijke klimblokken';

  @override
  String get templateStairmasterIntermediate1Title => '2:1 Klim 21';

  @override
  String get templateStairmasterIntermediate1Subtitle => '2:1 klimherhalingen';

  @override
  String get templateStairmasterIntermediate2Title => 'Sterk 1:1 24';

  @override
  String get templateStairmasterIntermediate2Subtitle =>
      'Sterke 1:1 intervallen';

  @override
  String get templateStairmasterAdvanced1Title => 'Zware blokken 20';

  @override
  String get templateStairmasterAdvanced1Subtitle => '2-min zware blokken';

  @override
  String get templateStairmasterAdvanced2Title => 'Sprint Steps 18';

  @override
  String get templateStairmasterAdvanced2Subtitle =>
      '30 s sprints + 60 s herstel';

  @override
  String get historyTab => 'Geschiedenis';

  @override
  String get calendarTab => 'Kalender';

  @override
  String get weightTab => 'Gewicht';

  @override
  String get bike => 'Fiets';

  @override
  String get thisWeek => 'Deze week';

  @override
  String get trend => 'Trend';

  @override
  String get timeframe7D => '7D';

  @override
  String get timeframe30D => '30D';

  @override
  String get timeframe90D => '90D';

  @override
  String get timeframeAll => 'ALLES';

  @override
  String get history => 'Geschiedenis';

  @override
  String get seeAll => 'Alles bekijken';

  @override
  String get weightEntryDeleted => 'Gewichtmeting verwijderd';

  @override
  String get weightUpdated => 'Gewicht bijgewerkt';

  @override
  String get editWeight => 'Gewicht bewerken';

  @override
  String get recordWeight => 'Gewicht registreren';

  @override
  String get quickAdjust => 'Snel aanpassen';

  @override
  String get goalWeightSet => 'Doelgewicht ingesteld';

  @override
  String get goalWeightRemoved => 'Doelgewicht verwijderd';

  @override
  String get goalAchieved => 'Doel bereikt!';

  @override
  String get goalMatchesCurrentWeight => 'Doel is gelijk aan huidig gewicht';

  @override
  String get setGoal => 'Doel instellen';

  @override
  String get suggested => 'Aanbevolen';

  @override
  String get removeGoal => 'Doel verwijderen';

  @override
  String get addOneMoreRecordToSeeTrend =>
      'Voeg nog 1 meting toe om je trend te zien';

  @override
  String get noWeightRecorded => 'Nog geen gewicht geregistreerd';

  @override
  String get startTrackingYourWeight =>
      'Begin je gewicht bij te houden om hier voortgang te zien';

  @override
  String get treadmillSession => 'Loopbandsessie';

  @override
  String get bikeSession => 'Fietssessie';

  @override
  String get stairmasterSession => 'Stairmaster-sessie';

  @override
  String get treadmillWorkout => 'Loopband-workout';

  @override
  String get bikeWorkout => 'Fietstraining';

  @override
  String get stairmasterWorkout => 'Stairmaster-workout';

  @override
  String get startAWorkoutToSeeItHere =>
      'Start een workout om het hier te zien';

  @override
  String get mon => 'ma';

  @override
  String get tue => 'di';

  @override
  String get wed => 'wo';

  @override
  String get thu => 'do';

  @override
  String get fri => 'vr';

  @override
  String get sat => 'za';

  @override
  String get sun => 'zo';

  @override
  String get sessions => 'Sessies';

  @override
  String get distance => 'Afstand';

  @override
  String get today => 'Vandaag';

  @override
  String get yesterday => 'Gisteren';

  @override
  String get noWorkoutsYet => 'Nog geen workouts';

  @override
  String get startYourFirstWorkout =>
      'Start je eerste workout om je geschiedenis te zien';

  @override
  String get goToRoutines => 'Naar routines';

  @override
  String get weightRecorded => 'Gewicht geregistreerd';

  @override
  String get workout => 'workout';

  @override
  String get workouts => 'workouts';

  @override
  String get goal => 'Doel';

  @override
  String get toGo => 'te gaan';

  @override
  String get over => 'over';

  @override
  String get last => 'Laatste';

  @override
  String get newLabel => 'Nieuw';

  @override
  String youNeed(String amount, String goal) {
    return 'Je hebt $amount nodig om $goal te bereiken';
  }

  @override
  String youNeedPlus(String amount, String goal) {
    return 'Je hebt +$amount nodig om $goal te bereiken';
  }

  @override
  String get current => 'Huidig';

  @override
  String get premiumHeadline => 'Dezelfde 30 minuten, andere resultaten';

  @override
  String get premiumSubheadlineNew =>
      'Ren niet zomaar, train op de vetverbrandingsmanier';

  @override
  String get mostPopular => 'Meest populair';

  @override
  String dailyPrice(int price) {
    return '$price per dag';
  }

  @override
  String get benefitVoiceCoaching => 'Premium Spraakcoaching Systeem';

  @override
  String get benefitCycleStairmasterRoutines =>
      'Volledige Ondersteuning voor Alle Cardio-apparatuur';

  @override
  String get benefitUnlimitedRoutinesNew => 'Onbeperkte Routine-bibliotheek';

  @override
  String get benefitWeightFeature => 'Slimme Gewichtstracking & Analyse';

  @override
  String get benefitNoAdsFocus => 'Advertentievrije Premium Ervaring';

  @override
  String get benefitFutureFeaturesNew =>
      'Alle toekomstige premiumfuncties inbegrepen';

  @override
  String get mostChosen => 'Meest gekozen';

  @override
  String get canChangeAnytime => 'Altijd te wijzigen';

  @override
  String get startPremium => 'Start Premium';

  @override
  String get cancelAnytimeKeepAccess =>
      'Altijd opzegbaar en toegang tot het einde van de periode';

  @override
  String workoutDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Training $count dagen 🔥',
      one: 'Training 1 dag 🔥',
    );
    return '$_temp0';
  }

  @override
  String restDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Rust $count dagen 🛏️',
      one: 'Rust 1 dag 🛏️',
    );
    return '$_temp0';
  }

  @override
  String get workoutReminderTitle => 'Workout herinnering';

  @override
  String get workoutReminderOff => 'Uit';

  @override
  String get workoutReminderEveryDay => 'Elke dag';

  @override
  String get workoutReminderSelectTime => 'Tijd kiezen';

  @override
  String get workoutReminderPermissionRequired =>
      'Meldingtoestemming is vereist.';

  @override
  String get workoutReminderTimeLabel => 'Tijd';
}
