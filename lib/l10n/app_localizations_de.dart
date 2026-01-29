// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Interval Cardio';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get system => 'System';

  @override
  String get voiceGuide => 'Sprachführung';

  @override
  String get audioNavigator => 'Audio-Navigator';

  @override
  String get soundEffects => 'Soundeffekte';

  @override
  String get unitSetting => 'Einheiteneinstellung';

  @override
  String get kmh => 'km/h';

  @override
  String get mph => 'mph';

  @override
  String get themeMode => 'Hell/Dunkel-Modus';

  @override
  String get light => 'Hell';

  @override
  String get dark => 'Dunkel';

  @override
  String get smartwatchSync => 'Smartwatch-Synchronisation';

  @override
  String get connectSmartwatch => 'Mit Smartwatch verbinden';

  @override
  String get connect => 'Verbinden';

  @override
  String get about => 'Über';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get comingSoon => 'Demnächst';

  @override
  String get translationComingSoon =>
      'Die Übersetzung wird in einem zukünftigen Update verfügbar sein.';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get done => 'Fertig';

  @override
  String get delete => 'Löschen';

  @override
  String get save => 'Speichern';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get start => 'Starten';

  @override
  String get editRoutine => 'Routine Bearbeiten';

  @override
  String get routineEdit => 'Routine Bearbeiten';

  @override
  String get name => 'Name';

  @override
  String get unnamedRoutine => 'Unbenannte Routine';

  @override
  String get difficulty => 'Schwierigkeit';

  @override
  String difficultyColon(String difficulty) {
    return 'Schwierigkeit : $difficulty';
  }

  @override
  String get easy => 'Einfach';

  @override
  String get medium => 'Mittel';

  @override
  String get hard => 'Schwer';

  @override
  String get interval => 'Intervall';

  @override
  String get addInterval => 'Intervall Hinzufügen';

  @override
  String get noIntervals => 'Keine Intervalle';

  @override
  String get addIntervalPrompt => 'Ein Intervall hinzufügen';

  @override
  String get intervalEdit => 'Intervall Bearbeiten';

  @override
  String get timeMinutes => 'Zeit (Minuten)';

  @override
  String get duration => 'Dauer';

  @override
  String get speed => 'Geschwindigkeit';

  @override
  String get speedKmh => 'Geschwindigkeit (km/h)';

  @override
  String get incline => 'Steigung';

  @override
  String get level => 'Stufe';

  @override
  String levelColon(int level) {
    return 'Stufe $level';
  }

  @override
  String get rpm => 'RPM';

  @override
  String get resistance => 'Widerstand';

  @override
  String get resistanceLevel => 'Widerstand (Stufe)';

  @override
  String resistanceColon(int resistance) {
    return 'Widerstand $resistance';
  }

  @override
  String get spm => 'SPM';

  @override
  String get spmSteps => 'SPM (Schritte/min)';

  @override
  String get saved => 'Gespeichert';

  @override
  String get deleted => 'Gelöscht';

  @override
  String get deleteRoutineTitle => 'Routine Löschen';

  @override
  String get deleteRoutineMessage =>
      'Möchten Sie diese Routine wirklich löschen? Dies kann nicht rückgängig gemacht werden.';

  @override
  String get deleteError => 'Beim Löschen ist ein Fehler aufgetreten';

  @override
  String get nameRequired => 'Bitte geben Sie einen Namen ein';

  @override
  String get nameMaxLength => 'Der Name muss 24 Zeichen oder weniger haben';

  @override
  String get minIntervalsRequired =>
      'Mindestens ein Intervall ist erforderlich';

  @override
  String get intervalMinDuration =>
      'Die Intervall-Dauer muss mindestens 1 Sekunde betragen';

  @override
  String get intervalMaxDuration =>
      'Die Intervall-Dauer darf höchstens 3 Stunden (10800 Sekunden) betragen';

  @override
  String get speedRange =>
      'Die Geschwindigkeit muss größer als 0 sein (0.5-25.0 km/h)';

  @override
  String get inclineRange => 'Die Steigung muss im Bereich 0-15.0 liegen';

  @override
  String get rpmRange => 'RPM muss im Bereich 30-200 liegen';

  @override
  String get resistanceRange => 'Der Widerstand muss im Bereich 1-20 liegen';

  @override
  String get levelRange => 'Die Stufe muss im Bereich 1-20 liegen';

  @override
  String get spmRange => 'SPM muss im Bereich 50-200 liegen';

  @override
  String get noRoutinesSaved => 'Keine Routinen gespeichert';

  @override
  String get tapToCreate => 'Tippen zum Erstellen';

  @override
  String get tapButtonToCreate =>
      'Tippen Sie auf die Schaltfläche zum Erstellen';

  @override
  String get premiumRoutineSettings => 'Premium-Routinen-Einstellungen';

  @override
  String get viewMembership => 'Mitgliedschaft Anzeigen';

  @override
  String get freeLimitTitle => 'Das kostenlose Limit beträgt 2 Routinen';

  @override
  String get freeLimitMessage =>
      'Sie können mit Mitgliedschaft unbegrenzte Routinen verwenden';

  @override
  String get treadmill => 'Laufband';

  @override
  String get cycle => 'Fahrrad';

  @override
  String get stairmaster => 'Stepper';

  @override
  String get selectLanguage => 'Sprache Auswählen';

  @override
  String get selectTheme => 'Thema Auswählen';

  @override
  String get selectDifficulty => 'Schwierigkeit Auswählen';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Fortsetzen';

  @override
  String get endWorkout => 'Training Beenden';

  @override
  String get endWorkoutConfirm => 'Möchten Sie das Training beenden?';

  @override
  String get end => 'Beenden';

  @override
  String get rotate => 'Drehen';

  @override
  String get paused => 'PAUSIERT';

  @override
  String get pausedTitle => 'Pausiert';

  @override
  String get pausedSubtitle =>
      'Sie können fortfahren oder das Training beenden';

  @override
  String get endWorkoutConfirmationMessage =>
      'Wenn Sie jetzt beenden, wird das aktuelle Training beendet und Sie gelangen zum Zusammenfassungsbildschirm.';

  @override
  String get workoutComplete => 'Workout Complete';

  @override
  String get totalWorkoutTime => 'Gesamte Trainingszeit';

  @override
  String get totalDistance => 'Gesamte Distanz';

  @override
  String get averageRpm => 'Durchschnittliche RPM';

  @override
  String get averageLevel => 'Durchschnittliches Level';

  @override
  String get holdToStop => 'Hold to Stop';

  @override
  String get continueWorkout => 'Fortsetzen';

  @override
  String get endWorkoutQuestion => 'Möchten Sie das Training beenden?';

  @override
  String get workoutPaused => 'Das Training wurde pausiert';

  @override
  String get lvlIncline => 'Steigung';

  @override
  String get lvlResistance => 'Stufe Widerstand';

  @override
  String get premium => 'Premium';

  @override
  String get upgradeNow => 'Jetzt Upgraden';

  @override
  String get purchase => 'Kaufen';

  @override
  String get later => 'Später';

  @override
  String get premiumActivated => 'Premium wurde aktiviert';

  @override
  String get premiumMembership => 'Premium-Mitgliedschaft';

  @override
  String get benefitCycleStairmaster => 'Fahrrad- und Stepper-Funktion';

  @override
  String get benefitVoiceGuide => 'Sitzungs-Sprachführungs-Funktion';

  @override
  String get benefitUnlimitedRoutines => 'Unbegrenzte Routinen-Speicherung';

  @override
  String get noAds => 'Keine Werbung';

  @override
  String get benefitFutureFeatures =>
      'Unbegrenzter Zugang zu zukünftigen Funktionen';

  @override
  String get voiceGuideBenefit1 => 'Sprachführung während des Trainings';

  @override
  String get voiceGuideBenefit2 => 'Automatische Ansagen bei Sitzungswechsel';

  @override
  String get voiceGuideBenefit3 => 'Routine-Fokus ohne Hände';

  @override
  String get routineLimitBenefit1 => 'Unbegrenzte Routinen-Speicherung';

  @override
  String get routineLimitBenefit2 => 'Routinen für mehrere Ziele speichern';

  @override
  String get routineLimitBenefit3 =>
      'Alle Maschinentypen nutzen (Laufband/Fahrrad/Stepper)';

  @override
  String get premium_benefit_1 => 'Workouts mit <red>Bike & StairMaster</red>';

  @override
  String get premium_benefit_2 =>
      '<red>Sprachführung</red> während der Session';

  @override
  String get premium_benefit_3 => 'Routinen speichern: <red>unbegrenzt</red>';

  @override
  String get premium_benefit_4 =>
      '<red>Unbegrenzter Zugriff</red> auf zukünftige Features';

  @override
  String originalPrice(String price) {
    return '$price';
  }

  @override
  String monthlyPrice(String price) {
    return '$price/Monat';
  }

  @override
  String get premiumSubheadline =>
      'Schalten Sie Sprachführung, Fahrrad- und Stepper-Workouts und unbegrenzte Routinen frei';

  @override
  String get monthly => 'Monatlich';

  @override
  String get yearly => 'Jährlich';

  @override
  String get lifetime => 'Lebenslang';

  @override
  String get perMonth => '/Monat';

  @override
  String get perYear => '/Jahr';

  @override
  String get oneTime => 'Einmalige Zahlung';

  @override
  String savePercent(int percent) {
    return 'Sparen Sie $percent%';
  }

  @override
  String get bestValue => 'Bester Wert';

  @override
  String get cancelAnytime => 'Jederzeit kündbar';

  @override
  String get autoRenewableSubscription => 'Automatisch erneuerbares Abonnement';

  @override
  String get terms => 'Bedingungen';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get restore => 'Wiederherstellen';

  @override
  String get premiumTab => 'Premium';

  @override
  String get routineTab => 'Routine';

  @override
  String get settingsTab => 'Einstellungen';

  @override
  String get myTab => 'Ich';

  @override
  String get close => 'Schließen';

  @override
  String get premiumFeature => 'Premium-Funktion';

  @override
  String get usePremiumTest => 'Premium Verwenden (Test)';

  @override
  String dateTimeFormat(int year, int month, int day, int hour, int minute) {
    return '$day.$month.$year $hour:$minute';
  }

  @override
  String get checkRoutineStart => 'Routine Prüfen / Starten';

  @override
  String get beginner => 'Anfänger';

  @override
  String get intermediate => 'Fortgeschritten';

  @override
  String get advanced => 'Experte';

  @override
  String get viewRecommendedRoutines => 'Empfohlene Routinen ansehen →';

  @override
  String get recommendedRoutinesTreadmill => 'Empfohlene Laufband-Routinen';

  @override
  String get recommendedRoutinesCycle => 'Empfohlene Fahrrad-Routinen';

  @override
  String get recommendedRoutinesStairmaster => 'Empfohlene Stepper-Routinen';

  @override
  String get alreadySaved => 'Bereits gespeichert';

  @override
  String get routineSaved => 'Routine gespeichert';

  @override
  String get checkRoutine => 'Prüfen';

  @override
  String get saveRoutine => 'Routine Speichern';

  @override
  String get routineAlreadySaved => 'Routine bereits gespeichert';

  @override
  String get noTemplatesFound => 'Keine Vorlagen gefunden';

  @override
  String get avg => 'Ø';

  @override
  String get avgRpm => 'Ø RPM';

  @override
  String get avgLevel => 'Ø Stufe';

  @override
  String get templateTreadmillBeginner1Title => 'Leichter Start 20';

  @override
  String get templateTreadmillBeginner1Subtitle =>
      '3 Min Aufwärmen + 1:1 Intervalle';

  @override
  String get templateTreadmillBeginner2Title => 'Steigungs-Walk 25';

  @override
  String get templateTreadmillBeginner2Subtitle => 'Steigungs-Walk in Blöcken';

  @override
  String get templateTreadmillIntermediate1Title => 'Klassisch 1:1 24';

  @override
  String get templateTreadmillIntermediate1Subtitle =>
      'Klassische 1:1 Intervalle';

  @override
  String get templateTreadmillIntermediate2Title => 'Tempo-Leiter 20';

  @override
  String get templateTreadmillIntermediate2Subtitle =>
      'Tempo-Leiter (schrittweise schneller)';

  @override
  String get templateTreadmillAdvanced1Title => '2:1 Brenner 21';

  @override
  String get templateTreadmillAdvanced1Subtitle =>
      '2:1 Intervalle (hart/leicht)';

  @override
  String get templateTreadmillAdvanced2Title => 'Sprint-Boost 18';

  @override
  String get templateTreadmillAdvanced2Subtitle => '20s Sprint-Wiederholungen';

  @override
  String get templateCycleBeginner1Title => 'Kadenz-Builder 20';

  @override
  String get templateCycleBeginner1Subtitle => '4 Min Aufwärmen + Kadenz 1:1';

  @override
  String get templateCycleBeginner2Title => 'Konstante Fahrt 25';

  @override
  String get templateCycleBeginner2Subtitle => 'Langer gleichmäßiger Block';

  @override
  String get templateCycleIntermediate1Title => 'Spin 1:1 24';

  @override
  String get templateCycleIntermediate1Subtitle =>
      'Klassische 1:1 Spin-Intervalle';

  @override
  String get templateCycleIntermediate2Title => 'Bergsimulation 22';

  @override
  String get templateCycleIntermediate2Subtitle => 'Berg-Wiederholungen';

  @override
  String get templateCycleAdvanced1Title => 'Power-Intervalle 20';

  @override
  String get templateCycleAdvanced1Subtitle => '30s Power-Bursts';

  @override
  String get templateCycleAdvanced2Title => 'Tabata Mix 16';

  @override
  String get templateCycleAdvanced2Subtitle => 'Mix 20s/10s';

  @override
  String get templateStairmasterBeginner1Title => 'Leichte Stufen 20';

  @override
  String get templateStairmasterBeginner1Subtitle =>
      '4 Min Aufwärmen + 1:1 Stufen';

  @override
  String get templateStairmasterBeginner2Title => 'Lang & leicht 25';

  @override
  String get templateStairmasterBeginner2Subtitle => 'Lange leichte Blöcke';

  @override
  String get templateStairmasterIntermediate1Title => '2:1 Anstieg 21';

  @override
  String get templateStairmasterIntermediate1Subtitle =>
      '2:1 Anstiegs-Wiederholungen';

  @override
  String get templateStairmasterIntermediate2Title => 'Stark 1:1 24';

  @override
  String get templateStairmasterIntermediate2Subtitle =>
      'Starke 1:1 Intervalle';

  @override
  String get templateStairmasterAdvanced1Title => 'Harte Blöcke 20';

  @override
  String get templateStairmasterAdvanced1Subtitle => '2-Minuten harte Blöcke';

  @override
  String get templateStairmasterAdvanced2Title => 'Sprint-Stufen 18';

  @override
  String get templateStairmasterAdvanced2Subtitle =>
      '30s Sprints + 60s Erholung';

  @override
  String get historyTab => 'Verlauf';

  @override
  String get calendarTab => 'Kalender';

  @override
  String get weightTab => 'Gewicht';

  @override
  String get bike => 'Fahrrad';

  @override
  String get thisWeek => 'Diese Woche';

  @override
  String get trend => 'Trend';

  @override
  String get timeframe7D => '7T';

  @override
  String get timeframe30D => '30T';

  @override
  String get timeframe90D => '90T';

  @override
  String get timeframeAll => 'ALLE';

  @override
  String get history => 'Verlauf';

  @override
  String get seeAll => 'Alle anzeigen';

  @override
  String get weightEntryDeleted => 'Gewichtseintrag gelöscht';

  @override
  String get weightUpdated => 'Gewicht aktualisiert';

  @override
  String get editWeight => 'Gewicht bearbeiten';

  @override
  String get recordWeight => 'Gewicht aufzeichnen';

  @override
  String get quickAdjust => 'Schnellanpassung';

  @override
  String get goalWeightSet => 'Zielgewicht festgelegt';

  @override
  String get goalWeightRemoved => 'Zielgewicht entfernt';

  @override
  String get goalAchieved => 'Ziel erreicht!';

  @override
  String get goalMatchesCurrentWeight =>
      'Ziel entspricht dem aktuellen Gewicht';

  @override
  String get setGoal => 'Ziel festlegen';

  @override
  String get suggested => 'Vorgeschlagen';

  @override
  String get removeGoal => 'Ziel Entfernen';

  @override
  String get addOneMoreRecordToSeeTrend =>
      'Fügen Sie 1 weiteren Eintrag hinzu, um Ihren Trend zu sehen';

  @override
  String get noWeightRecorded => 'Noch kein Gewicht aufgezeichnet';

  @override
  String get startTrackingYourWeight =>
      'Beginnen Sie mit der Gewichtsverfolgung, um den Fortschritt hier zu sehen';

  @override
  String get treadmillSession => 'Laufband-Session';

  @override
  String get bikeSession => 'Fahrrad-Session';

  @override
  String get stairmasterSession => 'Stepper-Session';

  @override
  String get treadmillWorkout => 'Laufband-Training';

  @override
  String get bikeWorkout => 'Fahrrad-Training';

  @override
  String get stairmasterWorkout => 'Stepper-Training';

  @override
  String get startAWorkoutToSeeItHere =>
      'Starten Sie ein Training, um es hier zu sehen';

  @override
  String get mon => 'Mo';

  @override
  String get tue => 'Di';

  @override
  String get wed => 'Mi';

  @override
  String get thu => 'Do';

  @override
  String get fri => 'Fr';

  @override
  String get sat => 'Sa';

  @override
  String get sun => 'So';

  @override
  String get sessions => 'Sitzungen';

  @override
  String get distance => 'Distanz';

  @override
  String get today => 'Heute';

  @override
  String get yesterday => 'Gestern';

  @override
  String get noWorkoutsYet => 'Noch keine Trainings';

  @override
  String get startYourFirstWorkout =>
      'Beginnen Sie Ihr erstes Training, um Ihren Verlauf hier zu sehen';

  @override
  String get goToRoutines => 'Zu Routinen gehen';

  @override
  String get weightRecorded => 'Gewicht aufgezeichnet';

  @override
  String get workout => 'Training';

  @override
  String get workouts => 'Trainings';

  @override
  String get goal => 'Ziel';

  @override
  String get toGo => 'verbleibend';

  @override
  String get over => 'überschritten';

  @override
  String get last => 'Letzte';

  @override
  String get newLabel => 'Neu';

  @override
  String youNeed(String amount, String goal) {
    return 'Sie benötigen $amount, um $goal zu erreichen';
  }

  @override
  String youNeedPlus(String amount, String goal) {
    return 'Sie benötigen +$amount, um $goal zu erreichen';
  }

  @override
  String get current => 'Aktuell';

  @override
  String get premiumHeadline => 'Gleiche 30 Minuten, andere Ergebnisse';

  @override
  String get premiumSubheadlineNew =>
      'Laufen Sie nicht einfach, trainieren Sie fettverbrennend';

  @override
  String get mostPopular => 'Am Beliebtesten';

  @override
  String dailyPrice(int price) {
    return '$price pro Tag';
  }

  @override
  String get benefitVoiceCoaching => 'Premium-Sprachcoaching-System';

  @override
  String get benefitCycleStairmasterRoutines =>
      'Vollständige Unterstützung für Alle Cardio-Geräte';

  @override
  String get benefitUnlimitedRoutinesNew => 'Unbegrenzte Routinenbibliothek';

  @override
  String get benefitWeightFeature =>
      'Intelligente Gewichtsverfolgung & Analyse';

  @override
  String get benefitNoAdsFocus => 'Werbefreies Premium-Erlebnis';

  @override
  String get benefitFutureFeaturesNew =>
      'Alle zukünftigen Premium-Funktionen enthalten';

  @override
  String get mostChosen => 'Am häufigsten gewählt';

  @override
  String get canChangeAnytime => 'Kann jederzeit geändert werden';

  @override
  String get startPremium => 'Premium starten';

  @override
  String get cancelAnytimeKeepAccess =>
      'Jederzeit kündbar und Zugriff bis zum Periodenende';

  @override
  String workoutDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Training $count Tage 🔥',
      one: 'Training 1 Tag 🔥',
    );
    return '$_temp0';
  }

  @override
  String restDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ruhe $count Tage 🛏️',
      one: 'Ruhe 1 Tag 🛏️',
    );
    return '$_temp0';
  }
}
