// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Interval Cardio';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get system => 'Système';

  @override
  String get voiceGuide => 'Guide Vocal';

  @override
  String get audioNavigator => 'Navigateur Audio';

  @override
  String get soundEffects => 'Effets Sonores';

  @override
  String get unitSetting => 'Réglage des Unités';

  @override
  String get kmh => 'km/h';

  @override
  String get mph => 'mph';

  @override
  String get themeMode => 'Mode Clair/Sombre';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get smartwatchSync => 'Synchronisation Smartwatch';

  @override
  String get connectSmartwatch => 'Se connecter à la smartwatch';

  @override
  String get connect => 'Connecter';

  @override
  String get about => 'À propos';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get comingSoon => 'Bientôt disponible';

  @override
  String get translationComingSoon =>
      'La traduction sera disponible dans une mise à jour future.';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annuler';

  @override
  String get done => 'Terminé';

  @override
  String get delete => 'Supprimer';

  @override
  String get save => 'Enregistrer';

  @override
  String get edit => 'Modifier';

  @override
  String get start => 'Démarrer';

  @override
  String get editRoutine => 'Modifier la Routine';

  @override
  String get routineEdit => 'Modifier la Routine';

  @override
  String get name => 'Nom';

  @override
  String get unnamedRoutine => 'Routine Sans Nom';

  @override
  String get difficulty => 'Difficulté';

  @override
  String difficultyColon(String difficulty) {
    return 'Difficulté : $difficulty';
  }

  @override
  String get easy => 'Facile';

  @override
  String get medium => 'Moyen';

  @override
  String get hard => 'Difficile';

  @override
  String get interval => 'Intervalle';

  @override
  String get addInterval => 'Ajouter un Intervalle';

  @override
  String get noIntervals => 'Aucun intervalle';

  @override
  String get addIntervalPrompt => 'Ajouter un intervalle';

  @override
  String get intervalEdit => 'Modifier l\'Intervalle';

  @override
  String get timeMinutes => 'Temps (minutes)';

  @override
  String get duration => 'Durée';

  @override
  String get speed => 'Vitesse';

  @override
  String get speedKmh => 'Vitesse (km/h)';

  @override
  String get incline => 'Inclinaison';

  @override
  String get level => 'Niveau';

  @override
  String levelColon(int level) {
    return 'Niveau $level';
  }

  @override
  String get rpm => 'RPM';

  @override
  String get resistance => 'Résistance';

  @override
  String get resistanceLevel => 'Résistance (Niveau)';

  @override
  String resistanceColon(int resistance) {
    return 'Résistance $resistance';
  }

  @override
  String get spm => 'SPM';

  @override
  String get spmSteps => 'SPM (pas/min)';

  @override
  String get saved => 'Enregistré';

  @override
  String get deleted => 'Supprimé';

  @override
  String get deleteRoutineTitle => 'Supprimer la Routine';

  @override
  String get deleteRoutineMessage =>
      'Êtes-vous sûr de vouloir supprimer cette routine ? Cette action est irréversible.';

  @override
  String get deleteError => 'Une erreur s\'est produite lors de la suppression';

  @override
  String get nameRequired => 'Veuillez entrer un nom';

  @override
  String get nameMaxLength => 'Le nom doit contenir 24 caractères ou moins';

  @override
  String get minIntervalsRequired => 'Au moins un intervalle est requis';

  @override
  String get intervalMinDuration =>
      'La durée de l\'intervalle doit être d\'au moins 1 seconde';

  @override
  String get intervalMaxDuration =>
      'La durée de l\'intervalle doit être d\'au plus 3 heures (10800 secondes)';

  @override
  String get speedRange =>
      'La vitesse doit être supérieure à 0 (0.5-25.0 km/h)';

  @override
  String get inclineRange => 'L\'inclinaison doit être dans la plage 0-15.0';

  @override
  String get rpmRange => 'RPM doit être dans la plage 30-200';

  @override
  String get resistanceRange => 'La résistance doit être dans la plage 1-20';

  @override
  String get levelRange => 'Le niveau doit être dans la plage 1-20';

  @override
  String get spmRange => 'SPM doit être dans la plage 50-200';

  @override
  String get noRoutinesSaved => 'Aucune routine enregistrée';

  @override
  String get tapToCreate => 'Appuyez pour créer';

  @override
  String get tapButtonToCreate => 'Appuyez sur le bouton pour créer';

  @override
  String get premiumRoutineSettings => 'Paramètres de Routine Premium';

  @override
  String get viewMembership => 'Voir l\'Abonnement';

  @override
  String get freeLimitTitle => 'La limite gratuite est de 2 routines';

  @override
  String get freeLimitMessage =>
      'Vous pouvez utiliser des routines illimitées avec l\'abonnement';

  @override
  String get treadmill => 'Tapis de Course';

  @override
  String get cycle => 'Vélo';

  @override
  String get stairmaster => 'Stepper';

  @override
  String get selectLanguage => 'Sélectionner la Langue';

  @override
  String get selectTheme => 'Sélectionner le Thème';

  @override
  String get selectDifficulty => 'Sélectionner la Difficulté';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Reprendre';

  @override
  String get endWorkout => 'Terminer l\'Entraînement';

  @override
  String get endWorkoutConfirm => 'Voulez-vous terminer l\'entraînement?';

  @override
  String get end => 'Terminer';

  @override
  String get rotate => 'Tourner';

  @override
  String get paused => 'EN PAUSE';

  @override
  String get pausedTitle => 'En pause';

  @override
  String get pausedSubtitle =>
      'Vous pouvez continuer ou terminer l\'entraînement';

  @override
  String get endWorkoutConfirmationMessage =>
      'Si vous terminez maintenant, l\'entraînement en cours se terminera et vous passerez à l\'écran de résumé.';

  @override
  String get workoutComplete => 'Workout Complete';

  @override
  String get totalWorkoutTime => 'Temps Total d\'Entraînement';

  @override
  String get totalDistance => 'Distance totale';

  @override
  String get averageRpm => 'RPM Moyen';

  @override
  String get averageLevel => 'Niveau Moyen';

  @override
  String get holdToStop => 'Hold to Stop';

  @override
  String get continueWorkout => 'Continuer';

  @override
  String get endWorkoutQuestion => 'Voulez-vous terminer l\'entraînement?';

  @override
  String get workoutPaused => 'L\'entraînement a été mis en pause';

  @override
  String get lvlIncline => 'Inclinaison';

  @override
  String get lvlResistance => 'Niveau Résistance';

  @override
  String get premium => 'Premium';

  @override
  String get upgradeNow => 'Mettre à Niveau Maintenant';

  @override
  String get purchase => 'Acheter';

  @override
  String get later => 'Plus Tard';

  @override
  String get premiumActivated => 'Premium a été activé';

  @override
  String get premiumMembership => 'Abonnement Premium';

  @override
  String get benefitCycleStairmaster => 'Fonctionnalité Vélo et Stepper';

  @override
  String get benefitVoiceGuide => 'Fonctionnalité de guide vocal de session';

  @override
  String get benefitUnlimitedRoutines => 'Sauvegarde de routines illimitée';

  @override
  String get noAds => 'Pas de Publicités';

  @override
  String get benefitFutureFeatures =>
      'Accès illimité aux fonctionnalités futures';

  @override
  String get voiceGuideBenefit1 => 'Guidage vocal pendant l\'entraînement';

  @override
  String get voiceGuideBenefit2 =>
      'Annonces automatiques de transition de session';

  @override
  String get voiceGuideBenefit3 =>
      'Concentration sur la routine sans les mains';

  @override
  String get routineLimitBenefit1 => 'Sauvegarde de routines illimitée';

  @override
  String get routineLimitBenefit2 =>
      'Sauvegarder des routines pour plusieurs objectifs';

  @override
  String get routineLimitBenefit3 =>
      'Utiliser tous les types de machines (tapis/velo/stepper)';

  @override
  String get premium_benefit_1 => 'Entraînements <red>vélo & StairMaster</red>';

  @override
  String get premium_benefit_2 => '<red>Guide vocal</red> pendant la séance';

  @override
  String get premium_benefit_3 =>
      'Sauvegarde des routines <red>illimitée</red>';

  @override
  String get premium_benefit_4 =>
      '<red>Accès illimité</red> aux futures fonctionnalités';

  @override
  String originalPrice(String price) {
    return '$price';
  }

  @override
  String monthlyPrice(String price) {
    return '$price/mois';
  }

  @override
  String get premiumSubheadline =>
      'Débloquez le guide vocal, les entraînements vélo et stepper, et les routines illimitées';

  @override
  String get monthly => 'Mensuel';

  @override
  String get yearly => 'Annuel';

  @override
  String get lifetime => 'Illimité';

  @override
  String get perMonth => '/mois';

  @override
  String get perYear => '/an';

  @override
  String get oneTime => 'Paiement unique';

  @override
  String savePercent(int percent) {
    return 'Économisez $percent%';
  }

  @override
  String get bestValue => 'Meilleure Valeur';

  @override
  String get cancelAnytime => 'Annuler à tout moment';

  @override
  String get autoRenewableSubscription =>
      'Abonnement renouvelable automatiquement';

  @override
  String get terms => 'Conditions';

  @override
  String get privacy => 'Confidentialité';

  @override
  String get restore => 'Restaurer';

  @override
  String get premiumTab => 'Premium';

  @override
  String get routineTab => 'Routine';

  @override
  String get settingsTab => 'Paramètres';

  @override
  String get myTab => 'Moi';

  @override
  String get close => 'Fermer';

  @override
  String get premiumFeature => 'Fonctionnalité Premium';

  @override
  String get usePremiumTest => 'Utiliser Premium (Test)';

  @override
  String dateTimeFormat(int year, int month, int day, int hour, int minute) {
    return '$day/$month/$year $hour:$minute';
  }

  @override
  String get checkRoutineStart => 'Vérifier Routine / Démarrer';

  @override
  String get beginner => 'Débutant';

  @override
  String get intermediate => 'Intermédiaire';

  @override
  String get advanced => 'Avancé';

  @override
  String get viewRecommendedRoutines => 'Voir les Routines Recommandées →';

  @override
  String get recommendedRoutinesTreadmill =>
      'Routines de Tapis Roulant Recommandées';

  @override
  String get recommendedRoutinesCycle => 'Routines de Vélo Recommandées';

  @override
  String get recommendedRoutinesStairmaster =>
      'Routines d\'Escalier Recommandées';

  @override
  String get alreadySaved => 'Déjà enregistré';

  @override
  String get routineSaved => 'Routine enregistrée';

  @override
  String get checkRoutine => 'Vérifier';

  @override
  String get saveRoutine => 'Enregistrer Routine';

  @override
  String get routineAlreadySaved => 'La routine est déjà enregistrée';

  @override
  String get noTemplatesFound => 'Aucun modèle trouvé';

  @override
  String get avg => 'Moy.';

  @override
  String get avgRpm => 'Moy. RPM';

  @override
  String get avgLevel => 'Moy. Niveau';

  @override
  String get templateTreadmillBeginner1Title => 'Démarrage facile 20';

  @override
  String get templateTreadmillBeginner1Subtitle =>
      'Échauffement 3 min + intervalles 1:1';

  @override
  String get templateTreadmillBeginner2Title => 'Marche en pente 25';

  @override
  String get templateTreadmillBeginner2Subtitle => 'Blocs de marche en pente';

  @override
  String get templateTreadmillIntermediate1Title => 'Classique 1:1 24';

  @override
  String get templateTreadmillIntermediate1Subtitle =>
      'Intervalles classiques 1:1';

  @override
  String get templateTreadmillIntermediate2Title => 'Échelle de vitesse 20';

  @override
  String get templateTreadmillIntermediate2Subtitle =>
      'Échelle de vitesse (accélère progressivement)';

  @override
  String get templateTreadmillAdvanced1Title => 'Brûleur 2:1 21';

  @override
  String get templateTreadmillAdvanced1Subtitle =>
      'Intervalles 2:1 (dur/facile)';

  @override
  String get templateTreadmillAdvanced2Title => 'Sprint pop 18';

  @override
  String get templateTreadmillAdvanced2Subtitle => 'Répétitions de sprint 20 s';

  @override
  String get templateCycleBeginner1Title => 'Progression cadence 20';

  @override
  String get templateCycleBeginner1Subtitle =>
      'Échauffement 4 min + cadence 1:1';

  @override
  String get templateCycleBeginner2Title => 'Sortie régulière 25';

  @override
  String get templateCycleBeginner2Subtitle => 'Long bloc régulier';

  @override
  String get templateCycleIntermediate1Title => 'Spin 1:1 24';

  @override
  String get templateCycleIntermediate1Subtitle => 'Intervalles classiques 1:1';

  @override
  String get templateCycleIntermediate2Title => 'Simulation de côte 22';

  @override
  String get templateCycleIntermediate2Subtitle => 'Répétitions en montée';

  @override
  String get templateCycleAdvanced1Title => 'Intervalles puissance 20';

  @override
  String get templateCycleAdvanced1Subtitle => 'Rafales de puissance 30 s';

  @override
  String get templateCycleAdvanced2Title => 'Mix Tabata 16';

  @override
  String get templateCycleAdvanced2Subtitle => 'Mix 20s/10s';

  @override
  String get templateStairmasterBeginner1Title => 'Pas faciles 20';

  @override
  String get templateStairmasterBeginner1Subtitle =>
      'Échauffement 4 min + pas 1:1';

  @override
  String get templateStairmasterBeginner2Title => 'Long facile 25';

  @override
  String get templateStairmasterBeginner2Subtitle => 'Longs blocs faciles';

  @override
  String get templateStairmasterIntermediate1Title => 'Montée 2:1 21';

  @override
  String get templateStairmasterIntermediate1Subtitle =>
      'Répétitions de montée 2:1';

  @override
  String get templateStairmasterIntermediate2Title => 'Fort 1:1 24';

  @override
  String get templateStairmasterIntermediate2Subtitle =>
      'Intervalles forts 1:1';

  @override
  String get templateStairmasterAdvanced1Title => 'Blocs durs 20';

  @override
  String get templateStairmasterAdvanced1Subtitle => 'Blocs durs de 2 min';

  @override
  String get templateStairmasterAdvanced2Title => 'Pas sprint 18';

  @override
  String get templateStairmasterAdvanced2Subtitle =>
      'Sprints 30 s + récup 60 s';

  @override
  String get historyTab => 'Historique';

  @override
  String get calendarTab => 'Calendrier';

  @override
  String get weightTab => 'Poids';

  @override
  String get bike => 'Vélo';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get trend => 'Tendance';

  @override
  String get timeframe7D => '7J';

  @override
  String get timeframe30D => '30J';

  @override
  String get timeframe90D => '90J';

  @override
  String get timeframeAll => 'TOUT';

  @override
  String get history => 'Historique';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get weightEntryDeleted => 'Entrée de poids supprimée';

  @override
  String get weightUpdated => 'Poids mis à jour';

  @override
  String get editWeight => 'Modifier le poids';

  @override
  String get recordWeight => 'Enregistrer le poids';

  @override
  String get quickAdjust => 'Ajustement rapide';

  @override
  String get goalWeightSet => 'Poids objectif défini';

  @override
  String get goalWeightRemoved => 'Poids objectif supprimé';

  @override
  String get goalAchieved => 'Objectif atteint !';

  @override
  String get goalMatchesCurrentWeight =>
      'L\'objectif correspond au poids actuel';

  @override
  String get setGoal => 'Définir l\'objectif';

  @override
  String get suggested => 'Suggéré';

  @override
  String get removeGoal => 'Supprimer l\'Objectif';

  @override
  String get addOneMoreRecordToSeeTrend =>
      'Ajoutez 1 enregistrement de plus pour voir votre tendance';

  @override
  String get noWeightRecorded => 'Aucun poids enregistré pour le moment';

  @override
  String get startTrackingYourWeight =>
      'Commencez à suivre votre poids pour voir les progrès ici';

  @override
  String get treadmillSession => 'Session Tapis de Course';

  @override
  String get bikeSession => 'Session Vélo';

  @override
  String get stairmasterSession => 'Session Stepper';

  @override
  String get treadmillWorkout => 'Entraînement Tapis de Course';

  @override
  String get bikeWorkout => 'Entraînement Vélo';

  @override
  String get stairmasterWorkout => 'Entraînement Stepper';

  @override
  String get startAWorkoutToSeeItHere =>
      'Commencez un entraînement pour le voir ici';

  @override
  String get mon => 'Lun';

  @override
  String get tue => 'Mar';

  @override
  String get wed => 'Mer';

  @override
  String get thu => 'Jeu';

  @override
  String get fri => 'Ven';

  @override
  String get sat => 'Sam';

  @override
  String get sun => 'Dim';

  @override
  String get sessions => 'Séances';

  @override
  String get distance => 'Distance';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get yesterday => 'Hier';

  @override
  String get noWorkoutsYet => 'Aucun entraînement pour le moment';

  @override
  String get startYourFirstWorkout =>
      'Commencez votre premier entraînement pour voir votre historique ici';

  @override
  String get goToRoutines => 'Aller aux Routines';

  @override
  String get weightRecorded => 'Poids enregistré';

  @override
  String get workout => 'entraînement';

  @override
  String get workouts => 'entraînements';

  @override
  String get goal => 'Objectif';

  @override
  String get toGo => 'restant';

  @override
  String get over => 'dépassé';

  @override
  String get last => 'Dernier';

  @override
  String get newLabel => 'Nouveau';

  @override
  String youNeed(String amount, String goal) {
    return 'Il vous faut $amount pour atteindre $goal';
  }

  @override
  String youNeedPlus(String amount, String goal) {
    return 'Il vous faut +$amount pour atteindre $goal';
  }

  @override
  String get current => 'Actuel';

  @override
  String get premiumHeadline =>
      'Les mêmes 30 minutes, des résultats différents';

  @override
  String get premiumSubheadlineNew =>
      'Ne courez pas simplement, faites de l\'exercice pour brûler les graisses';

  @override
  String get mostPopular => 'Le Plus Populaire';

  @override
  String dailyPrice(int price) {
    return '$price par jour';
  }

  @override
  String get benefitVoiceCoaching => 'Système de Coaching Vocal Premium';

  @override
  String get benefitCycleStairmasterRoutines =>
      'Support Complet pour Tous les Équipements Cardio';

  @override
  String get benefitUnlimitedRoutinesNew =>
      'Bibliothèque de Routines Illimitée';

  @override
  String get benefitWeightFeature => 'Suivi et Analyse Intelligents du Poids';

  @override
  String get benefitNoAdsFocus => 'Expérience Premium sans Publicité';

  @override
  String get benefitFutureFeaturesNew =>
      'Toutes les fonctionnalités premium futures incluses';

  @override
  String get mostChosen => 'Le plus choisi';

  @override
  String get canChangeAnytime => 'Peut être modifié à tout moment';

  @override
  String get startPremium => 'Commencer Premium';

  @override
  String get cancelAnytimeKeepAccess =>
      'Annulez à tout moment et gardez l\'accès jusqu\'à la fin de la période';

  @override
  String workoutDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Entraînement $count jours 🔥',
      one: 'Entraînement 1 jour 🔥',
    );
    return '$_temp0';
  }

  @override
  String restDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Repos $count jours 🛏️',
      one: 'Repos 1 jour 🛏️',
    );
    return '$_temp0';
  }
}
