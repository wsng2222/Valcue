// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Interval Cardio';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get language => 'Lingua';

  @override
  String get system => 'Sistema';

  @override
  String get voiceGuide => 'Guida vocale';

  @override
  String get audioNavigator => 'Navigatore audio';

  @override
  String get soundEffects => 'Effetti sonori';

  @override
  String get unitSetting => 'Unità';

  @override
  String get kmh => 'km/h';

  @override
  String get mph => 'mph';

  @override
  String get themeMode => 'Aspetto';

  @override
  String get light => 'Chiaro';

  @override
  String get dark => 'Scuro';

  @override
  String get smartwatchSync => 'Smartwatch Sync';

  @override
  String get connectSmartwatch => 'Connetti smartwatch';

  @override
  String get connect => 'Connetti';

  @override
  String get about => 'Informazioni';

  @override
  String version(String version) {
    return 'Versione $version';
  }

  @override
  String get comingSoon => 'In arrivo';

  @override
  String get translationComingSoon =>
      'La traduzione sarà disponibile in un aggiornamento futuro.';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annulla';

  @override
  String get done => 'Fatto';

  @override
  String get delete => 'Elimina';

  @override
  String get save => 'Salva';

  @override
  String get edit => 'Modifica';

  @override
  String get start => 'Avvia';

  @override
  String get editRoutine => 'Modifica routine';

  @override
  String get routineEdit => 'Modifica routine';

  @override
  String get name => 'Nome';

  @override
  String get unnamedRoutine => 'Routine senza nome';

  @override
  String get difficulty => 'Difficoltà';

  @override
  String difficultyColon(String difficulty) {
    return 'Difficoltà : $difficulty';
  }

  @override
  String get easy => 'Facile';

  @override
  String get medium => 'Medio';

  @override
  String get hard => 'Difficile';

  @override
  String get interval => 'Intervallo';

  @override
  String get addInterval => 'Aggiungi intervallo';

  @override
  String get noIntervals => 'Nessun intervallo';

  @override
  String get addIntervalPrompt => 'Aggiungi un intervallo';

  @override
  String get intervalEdit => 'Modifica intervallo';

  @override
  String get timeMinutes => 'Tempo (minuti)';

  @override
  String get duration => 'Durata';

  @override
  String get speed => 'Velocità';

  @override
  String get speedKmh => 'Velocità (km/h)';

  @override
  String get incline => 'Inclinazione';

  @override
  String get level => 'Livello';

  @override
  String levelColon(int level) {
    return 'Livello $level';
  }

  @override
  String get rpm => 'RPM';

  @override
  String get resistance => 'Resistenza';

  @override
  String get resistanceLevel => 'Resistenza (livello)';

  @override
  String resistanceColon(int resistance) {
    return 'Resistenza $resistance';
  }

  @override
  String get spm => 'SPM';

  @override
  String get spmSteps => 'SPM (passi/min)';

  @override
  String get saved => 'Salvato';

  @override
  String get deleted => 'Eliminato';

  @override
  String get deleteRoutineTitle => 'Elimina routine';

  @override
  String get deleteRoutineMessage =>
      'Sei sicuro di voler eliminare questa routine? Questa azione non può essere annullata.';

  @override
  String get deleteError => 'Si è verificato un errore durante l’eliminazione';

  @override
  String get nameRequired => 'Inserisci un nome';

  @override
  String get nameMaxLength => 'Il nome deve essere di 24 caratteri o meno';

  @override
  String get minIntervalsRequired => 'È richiesto almeno un intervallo';

  @override
  String get intervalMinDuration =>
      'La durata dell’intervallo deve essere almeno 1 secondo';

  @override
  String get intervalMaxDuration =>
      'La durata dell’intervallo deve essere al massimo 3 ore (10800 secondi)';

  @override
  String get speedRange =>
      'La velocità deve essere maggiore di 0 (0.5–25.0 km/h)';

  @override
  String get inclineRange => 'L’inclinazione deve essere compresa tra 0 e 15.0';

  @override
  String get rpmRange => 'Gli RPM devono essere compresi tra 30 e 200';

  @override
  String get resistanceRange => 'La resistenza deve essere compresa tra 1 e 20';

  @override
  String get levelRange => 'Il livello deve essere compreso tra 1 e 20';

  @override
  String get spmRange => 'SPM deve essere compreso tra 50 e 200';

  @override
  String get noRoutinesSaved => 'Nessuna routine salvata';

  @override
  String get tapToCreate => 'Tocca per creare';

  @override
  String get tapButtonToCreate => 'Tocca il pulsante per creare';

  @override
  String get premiumRoutineSettings => 'Impostazioni routine premium';

  @override
  String get viewMembership => 'Vedi Premium';

  @override
  String get freeLimitTitle => '2 routine gratis';

  @override
  String get freeLimitMessage => 'Passa a Premium per routine illimitate';

  @override
  String get treadmill => 'Tapis roulant';

  @override
  String get cycle => 'Cyclette';

  @override
  String get stairmaster => 'Stairmaster';

  @override
  String get selectLanguage => 'Lingue';

  @override
  String get selectTheme => 'Seleziona tema';

  @override
  String get selectDifficulty => 'Seleziona difficoltà';

  @override
  String get pause => 'Pausa';

  @override
  String get resume => 'Riprendi';

  @override
  String get endWorkout => 'Termina allenamento';

  @override
  String get endWorkoutConfirm => 'Vuoi terminare l’allenamento?';

  @override
  String get end => 'Termina';

  @override
  String get share => 'Condividi';

  @override
  String get rotate => 'Ruota';

  @override
  String get paused => 'IN PAUSA';

  @override
  String get pausedTitle => 'In pausa';

  @override
  String get pausedSubtitle => 'Puoi continuare o terminare l’allenamento';

  @override
  String get endWorkoutConfirmationMessage =>
      'Se termini ora, l’allenamento corrente finirà e passerai alla schermata di riepilogo.';

  @override
  String get workoutComplete => 'Allenamento completato';

  @override
  String get totalWorkoutTime => 'Tempo totale';

  @override
  String get totalDistance => 'Distanza totale';

  @override
  String get totalTime => 'Tempo totale';

  @override
  String get averageRpm => 'RPM medi';

  @override
  String get averageLevel => 'Livello medio';

  @override
  String get holdToStop => 'Tieni premuto per fermare';

  @override
  String get continueWorkout => 'Continua';

  @override
  String get endWorkoutQuestion => 'Vuoi terminare l’allenamento?';

  @override
  String get workoutPaused => 'L’allenamento è stato messo in pausa';

  @override
  String get lvlIncline => 'Inclinazione';

  @override
  String get lvlResistance => 'Liv. resistenza';

  @override
  String get premium => 'Premium';

  @override
  String get upgradeNow => 'Aggiorna ora';

  @override
  String get purchase => 'Acquista';

  @override
  String get later => 'Più tardi';

  @override
  String get premiumActivated => 'Premium è stato attivato';

  @override
  String get premiumMembership => 'Premium';

  @override
  String get benefitCycleStairmaster => 'Workout bici e StairMaster';

  @override
  String get benefitVoiceGuide => 'Guida vocale';

  @override
  String get benefitUnlimitedRoutines => 'Routine illimitate';

  @override
  String get noAds => 'Niente pubblicità';

  @override
  String get benefitFutureFeatures => 'Tutte le funzionalità future incluse';

  @override
  String get voiceGuideBenefit1 => 'Allenamento guidato dalla voce';

  @override
  String get voiceGuideBenefit2 => 'Annuncio automatico cambio sessione';

  @override
  String get voiceGuideBenefit3 => 'Concentrati sulla routine a mani libere';

  @override
  String get routineLimitBenefit1 => 'Salvataggio illimitato di routine';

  @override
  String get routineLimitBenefit2 => 'Routine personalizzate per obiettivo';

  @override
  String get routineLimitBenefit3 =>
      'Supporto per tapis roulant, bici e StairMaster';

  @override
  String get premium_benefit_1 => 'Supporto per <red>bici & StairMaster</red>';

  @override
  String get premium_benefit_2 => '<red>Guida vocale</red> per ogni sessione';

  @override
  String get premium_benefit_3 => 'Salvataggio routine <red>illimitato</red>';

  @override
  String get premium_benefit_4 =>
      'Tutte le funzioni future <red>incluse a vita</red>';

  @override
  String originalPrice(String price) {
    return '$price';
  }

  @override
  String monthlyPrice(String price) {
    return '$price/mese';
  }

  @override
  String get premiumSubheadline =>
      'Sblocca guida vocale, allenamenti bici & stairmaster e routine illimitate';

  @override
  String get monthly => 'Mensile';

  @override
  String get yearly => 'Annuale';

  @override
  String get lifetime => 'Vitalizio';

  @override
  String get freeTrial7Days => 'Prova gratuita di 7 giorni';

  @override
  String get perMonth => '/mese';

  @override
  String get perYear => '/anno';

  @override
  String get oneTime => 'Una tantum';

  @override
  String savePercent(int percent) {
    return 'Risparmia $percent%';
  }

  @override
  String get bestValue => 'Miglior valore';

  @override
  String get cancelAnytime => 'Annulla quando vuoi';

  @override
  String get autoRenewableSubscription => 'Rinnovo automatico';

  @override
  String get terms => 'Termini';

  @override
  String get privacy => 'Privacy';

  @override
  String get restore => 'Ripristina';

  @override
  String get premiumTab => 'Premium';

  @override
  String get routineTab => 'Routine';

  @override
  String get settingsTab => 'Impostazioni';

  @override
  String get myTab => 'Io';

  @override
  String get close => 'Chiudi';

  @override
  String get premiumFeature => 'Solo Premium';

  @override
  String get usePremiumTest => 'Test Premium';

  @override
  String dateTimeFormat(int year, int month, int day, int hour, int minute) {
    return '$day/$month/$year $hour:$minute';
  }

  @override
  String get checkRoutineStart => 'Anteprima e avvia';

  @override
  String get beginner => 'Principiante';

  @override
  String get intermediate => 'Intermedio';

  @override
  String get advanced => 'Avanzato';

  @override
  String get viewRecommendedRoutines => 'Scelte →';

  @override
  String get recommendedRoutinesTreadmill => 'Scelte tapis roulant';

  @override
  String get recommendedRoutinesCycle => 'Scelte bici';

  @override
  String get recommendedRoutinesStairmaster => 'Scelte StairMaster';

  @override
  String get alreadySaved => 'Già salvato';

  @override
  String get routineSaved => 'Routine salvata';

  @override
  String get checkRoutine => 'Anteprima';

  @override
  String get saveRoutine => 'Salva routine';

  @override
  String get routineAlreadySaved => 'Routine già salvata';

  @override
  String get noTemplatesFound => 'Nessun modello trovato';

  @override
  String get avg => 'Media';

  @override
  String get avgRpm => 'RPM medi';

  @override
  String get avgLevel => 'Livello medio';

  @override
  String get templateTreadmillBeginner1Title => 'Tapis Roulant Principiante 1';

  @override
  String get templateTreadmillBeginner1Subtitle =>
      '1:1 camminata e corsa dopo 3 min di riscaldamento';

  @override
  String get templateTreadmillBeginner2Title =>
      'Tapis Roulant Principiante 2 (Salita)';

  @override
  String get templateTreadmillBeginner2Subtitle =>
      'Camminata in salita a basso impatto articolare';

  @override
  String get templateTreadmillIntermediate1Title =>
      'Tapis Roulant Intermedio 1';

  @override
  String get templateTreadmillIntermediate1Subtitle =>
      'Intervallo di corsa 1:1 per bruciare grassi';

  @override
  String get templateTreadmillIntermediate2Title =>
      'Tapis Roulant Intermedio 2 (Velocità)';

  @override
  String get templateTreadmillIntermediate2Subtitle =>
      'Corsa a piramide con velocità crescente';

  @override
  String get templateTreadmillAdvanced1Title => 'Tapis Roulant Avanzato 1';

  @override
  String get templateTreadmillAdvanced1Subtitle =>
      'Intervallo cardio ad alta intensità';

  @override
  String get templateTreadmillAdvanced2Title =>
      'Tapis Roulant Avanzato 2 (Sprint)';

  @override
  String get templateTreadmillAdvanced2Subtitle =>
      'Brevi ripetizioni di sprint ad alta intensità';

  @override
  String get templateCycleBeginner1Title => 'Bici Principiante 1';

  @override
  String get templateCycleBeginner1Subtitle =>
      'Introduzione alla pedalata regolando gli RPM';

  @override
  String get templateCycleBeginner2Title => 'Bici Principiante 2 (Costante)';

  @override
  String get templateCycleBeginner2Subtitle =>
      'Allenamento di resistenza a carico fisso';

  @override
  String get templateCycleIntermediate1Title => 'Bici Intermedio 1';

  @override
  String get templateCycleIntermediate1Subtitle =>
      '1 min alta velocità / 1 min recupero spin';

  @override
  String get templateCycleIntermediate2Title => 'Bici Intermedio 2 (Collina)';

  @override
  String get templateCycleIntermediate2Subtitle =>
      'Salita in collina ad alta resistenza';

  @override
  String get templateCycleAdvanced1Title => 'Bici Avanzato 1';

  @override
  String get templateCycleAdvanced1Subtitle =>
      'Intervalli di forza da 30s ad alta resistenza';

  @override
  String get templateCycleAdvanced2Title => 'Bici Avanzato 2 (Tabata)';

  @override
  String get templateCycleAdvanced2Subtitle =>
      'Circuito Tabata 20s/10s per bruciare grassi';

  @override
  String get templateStairmasterBeginner1Title => 'Stairmaster Principiante 1';

  @override
  String get templateStairmasterBeginner1Subtitle =>
      'Camminata sicura di adattamento allo Stairmaster';

  @override
  String get templateStairmasterBeginner2Title =>
      'Stairmaster Principiante 2 (Costante)';

  @override
  String get templateStairmasterBeginner2Subtitle =>
      'Salita cardio a ritmo costante';

  @override
  String get templateStairmasterIntermediate1Title =>
      'Stairmaster Intermedio 1 (Salita)';

  @override
  String get templateStairmasterIntermediate1Subtitle =>
      '2 min salita / 1 min recupero glutei';

  @override
  String get templateStairmasterIntermediate2Title =>
      'Stairmaster Intermedio 2';

  @override
  String get templateStairmasterIntermediate2Subtitle =>
      'Intervalli a tempo alternato veloce/lento';

  @override
  String get templateStairmasterAdvanced1Title => 'Stairmaster Avanzato 1';

  @override
  String get templateStairmasterAdvanced1Subtitle =>
      'Allenamento intenso a blocchi di 2 min';

  @override
  String get templateStairmasterAdvanced2Title =>
      'Stairmaster Avanzato 2 (Sprint)';

  @override
  String get templateStairmasterAdvanced2Subtitle =>
      '30s salita rapida / 60s recupero';

  @override
  String get historyTab => 'Cronologia';

  @override
  String get calendarTab => 'Calendario';

  @override
  String get weightTab => 'Peso';

  @override
  String get bike => 'Bici';

  @override
  String get thisWeek => 'Questa settimana';

  @override
  String get trend => 'Andamento peso';

  @override
  String get timeframe7D => '7G';

  @override
  String get timeframe30D => '30G';

  @override
  String get timeframe90D => '90G';

  @override
  String get timeframeAll => 'TUTTO';

  @override
  String get history => 'Cronologia';

  @override
  String get seeAll => 'Vedi tutto';

  @override
  String get weightEntryDeleted => 'Registrazione peso eliminata';

  @override
  String get weightUpdated => 'Peso aggiornato';

  @override
  String get editWeight => 'Modifica peso';

  @override
  String get recordWeight => 'Registra peso';

  @override
  String get quickAdjust => 'Modifica rapida';

  @override
  String get goalWeightSet => 'Peso obiettivo impostato';

  @override
  String get goalWeightRemoved => 'Peso obiettivo disattivato';

  @override
  String get goalAchieved => 'Obiettivo raggiunto!';

  @override
  String get goalMatchesCurrentWeight =>
      'L’obiettivo coincide con il peso attuale';

  @override
  String get setGoal => 'Imposta obiettivo';

  @override
  String get suggested => 'Suggerito';

  @override
  String get removeGoal => 'Rimuovi obiettivo';

  @override
  String get addOneMoreRecordToSeeTrend =>
      'Aggiungi 1 misura per vedere l\'andamento';

  @override
  String get noWeightRecorded => 'Nessun peso registrato';

  @override
  String get startTrackingYourWeight =>
      'Registra il peso per seguire i progressi';

  @override
  String get treadmillSession => 'Sessione tapis roulant';

  @override
  String get bikeSession => 'Sessione bici';

  @override
  String get stairmasterSession => 'Sessione stairmaster';

  @override
  String get treadmillWorkout => 'Allenamento tapis roulant';

  @override
  String get bikeWorkout => 'Allenamento bici';

  @override
  String get stairmasterWorkout => 'Allenamento stairmaster';

  @override
  String get startAWorkoutToSeeItHere => 'I tuoi allenamenti appariranno qui';

  @override
  String get mon => 'lun';

  @override
  String get tue => 'mar';

  @override
  String get wed => 'mer';

  @override
  String get thu => 'gio';

  @override
  String get fri => 'ven';

  @override
  String get sat => 'sab';

  @override
  String get sun => 'dom';

  @override
  String get sessions => 'Sessioni';

  @override
  String get distance => 'Distanza';

  @override
  String get today => 'Oggi';

  @override
  String get yesterday => 'Ieri';

  @override
  String get noWorkoutsYet => 'Nessun allenamento ancora';

  @override
  String get startYourFirstWorkout =>
      'Avvia il tuo primo allenamento per vedere la cronologia';

  @override
  String get goToRoutines => 'Vai alle routine';

  @override
  String get weightRecorded => 'Peso registrato';

  @override
  String get workout => 'allenamento';

  @override
  String get workouts => 'allenamenti';

  @override
  String get goal => 'Obiettivo';

  @override
  String get toGo => 'rimanenti';

  @override
  String get over => 'oltre';

  @override
  String get last => 'Ultimo';

  @override
  String get newLabel => 'Nuovo';

  @override
  String youNeed(String amount, String goal) {
    return 'Ti mancano $amount per raggiungere $goal';
  }

  @override
  String youNeedPlus(String amount, String goal) {
    return 'Ti mancano +$amount per raggiungere $goal';
  }

  @override
  String get current => 'Attuale';

  @override
  String get premiumHeadline => 'Stessi 30 minuti, risultati diversi';

  @override
  String get premiumSubheadlineNew =>
      'Non correre e basta: allenati nel modo che brucia grassi';

  @override
  String get mostPopular => 'Più popolare';

  @override
  String dailyPrice(int price) {
    return '$price al giorno';
  }

  @override
  String get benefitVoiceCoaching => 'Coaching vocale';

  @override
  String get benefitCycleStairmasterRoutines => 'Workout bici e StairMaster';

  @override
  String get benefitUnlimitedRoutinesNew => 'Routine illimitate';

  @override
  String get benefitWeightFeature => 'Tracking peso';

  @override
  String get benefitNoAdsFocus => 'Senza pubblicità';

  @override
  String get benefitFutureFeaturesNew => 'Funzioni future incluse';

  @override
  String get mostChosen => 'Più scelto';

  @override
  String get canChangeAnytime => 'Cambia quando vuoi';

  @override
  String get startPremium => 'Passa a Premium';

  @override
  String get cancelAnytimeKeepAccess => 'Annulla quando vuoi, accesso attivo';

  @override
  String workoutDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Allenamento $count giorni 🔥',
      one: 'Allenamento 1 giorno 🔥',
    );
    return '$_temp0';
  }

  @override
  String restDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Riposo $count giorni 🛏️',
      one: 'Riposo 1 giorno 🛏️',
    );
    return '$_temp0';
  }

  @override
  String get workoutReminderTitle => 'Promemoria';

  @override
  String get workoutReminderOff => 'Disattivato';

  @override
  String get workoutReminderEveryDay => 'Ogni giorno';

  @override
  String get workoutReminderSelectTime => 'Seleziona orario';

  @override
  String get workoutReminderPermissionRequired =>
      'È necessario il permesso per le notifiche.';

  @override
  String get workoutReminderTimeLabel => 'Orario';
}
