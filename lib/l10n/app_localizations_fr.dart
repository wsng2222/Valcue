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
  String get unitSetting => 'Unités';

  @override
  String get kmh => 'km/h';

  @override
  String get mph => 'mph';

  @override
  String get themeMode => 'Apparence';

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
  String get viewMembership => 'Voir Premium';

  @override
  String get freeLimitTitle => '2 routines gratuites';

  @override
  String get freeLimitMessage =>
      'Passez à Premium pour des routines illimitées';

  @override
  String get treadmill => 'Tapis de Course';

  @override
  String get cycle => 'Vélo';

  @override
  String get stairmaster => 'Stepper';

  @override
  String get selectLanguage => 'Langues';

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
  String get share => 'Partager';

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
  String get workoutComplete => 'Entraînement terminé';

  @override
  String get totalWorkoutTime => 'Temps total';

  @override
  String get totalDistance => 'Distance totale';

  @override
  String get totalTime => 'Temps total';

  @override
  String get averageRpm => 'RPM Moyen';

  @override
  String get averageLevel => 'Niveau Moyen';

  @override
  String get holdToStop => 'Maintenir pour arrêter';

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
  String get premiumMembership => 'Premium';

  @override
  String get benefitCycleStairmaster => 'Séances vélo et stepper';

  @override
  String get benefitVoiceGuide => 'Guide vocal';

  @override
  String get benefitUnlimitedRoutines => 'Routines illimitées';

  @override
  String get noAds => 'Pas de Publicités';

  @override
  String get benefitFutureFeatures => 'Accès aux fonctionnalités futures';

  @override
  String get voiceGuideBenefit1 => 'Entraînement guidé par la voix';

  @override
  String get voiceGuideBenefit2 =>
      'Annonce automatique de changement de séance';

  @override
  String get voiceGuideBenefit3 =>
      'Concentrez-vous sur votre routine en mains libres';

  @override
  String get routineLimitBenefit1 => 'Sauvegarde illimitée des routines';

  @override
  String get routineLimitBenefit2 => 'Routines personnalisées par objectif';

  @override
  String get routineLimitBenefit3 => 'Support pour tapis, vélo et escalateur';

  @override
  String get premium_benefit_1 => 'Support pour <red>vélo et StairMaster</red>';

  @override
  String get premium_benefit_2 => '<red>Guidage vocal</red> pour chaque séance';

  @override
  String get premium_benefit_3 => 'Sauvegarde de routines <red>illimitée</red>';

  @override
  String get premium_benefit_4 =>
      'Fonctionnalités futures <red>incluses à vie</red>';

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
  String get freeTrial7Days => 'Essai gratuit de 7 jours';

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
  String get autoRenewableSubscription => 'Renouvellement auto';

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
  String get premiumFeature => 'Réservé Premium';

  @override
  String get usePremiumTest => 'Tester Premium';

  @override
  String dateTimeFormat(int year, int month, int day, int hour, int minute) {
    return '$day/$month/$year $hour:$minute';
  }

  @override
  String get checkRoutineStart => 'Aperçu & démarrer';

  @override
  String get beginner => 'Débutant';

  @override
  String get intermediate => 'Intermédiaire';

  @override
  String get advanced => 'Avancé';

  @override
  String get viewRecommendedRoutines => 'Sélection →';

  @override
  String get recommendedRoutinesTreadmill => 'Sélection tapis';

  @override
  String get recommendedRoutinesCycle => 'Sélection vélo';

  @override
  String get recommendedRoutinesStairmaster => 'Sélection stepper';

  @override
  String get alreadySaved => 'Déjà enregistré';

  @override
  String get routineSaved => 'Routine enregistrée';

  @override
  String get checkRoutine => 'Aperçu';

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
  String get templateTreadmillBeginner1Title => 'Tapis Débutant 1';

  @override
  String get templateTreadmillBeginner1Subtitle =>
      '1:1 marche et course après 3 min d\'échauffement';

  @override
  String get templateTreadmillBeginner2Title =>
      'Tapis Débutant 2 (Inclinaison)';

  @override
  String get templateTreadmillBeginner2Subtitle =>
      'Marche inclinée avec faible impact articulaire';

  @override
  String get templateTreadmillIntermediate1Title => 'Tapis Intermédiaire 1';

  @override
  String get templateTreadmillIntermediate1Subtitle =>
      'Intervalle de course 1:1 pour brûler les graisses';

  @override
  String get templateTreadmillIntermediate2Title =>
      'Tapis Intermédiaire 2 (Vitesse)';

  @override
  String get templateTreadmillIntermediate2Subtitle =>
      'Course progressive en pyramide de vitesse';

  @override
  String get templateTreadmillAdvanced1Title => 'Tapis Hors-pair 1';

  @override
  String get templateTreadmillAdvanced1Subtitle =>
      'Intervalle cardio de haute intensité';

  @override
  String get templateTreadmillAdvanced2Title => 'Tapis Hors-pair 2 (Sprint)';

  @override
  String get templateTreadmillAdvanced2Subtitle =>
      'Répétitions de sprints courts à haute intensité';

  @override
  String get templateCycleBeginner1Title => 'Vélo Débutant 1';

  @override
  String get templateCycleBeginner1Subtitle =>
      'Initiation au pédalage en ajustant les RPM';

  @override
  String get templateCycleBeginner2Title => 'Vélo Débutant 2 (Continu)';

  @override
  String get templateCycleBeginner2Subtitle =>
      'Entraînement d\'endurance à résistance fixe';

  @override
  String get templateCycleIntermediate1Title => 'Vélo Intermédiaire 1';

  @override
  String get templateCycleIntermediate1Subtitle =>
      '1 min haute vitesse / 1 min récupération';

  @override
  String get templateCycleIntermediate2Title =>
      'Vélo Intermédiaire 2 (Colline)';

  @override
  String get templateCycleIntermediate2Subtitle =>
      'Montée de colline à haute résistance';

  @override
  String get templateCycleAdvanced1Title => 'Vélo Hors-pair 1';

  @override
  String get templateCycleAdvanced1Subtitle =>
      'Intervalles de force de 30s à haute résistance';

  @override
  String get templateCycleAdvanced2Title => 'Vélo Hors-pair 2 (Tabata)';

  @override
  String get templateCycleAdvanced2Subtitle =>
      'Circuit Tabata 20s/10s pour brûler les graisses';

  @override
  String get templateStairmasterBeginner1Title => 'Escalateur Débutant 1';

  @override
  String get templateStairmasterBeginner1Subtitle =>
      'Marche sécurisée d\'adaptation à l\'escalateur';

  @override
  String get templateStairmasterBeginner2Title =>
      'Escalateur Débutant 2 (Continu)';

  @override
  String get templateStairmasterBeginner2Subtitle =>
      'Montée d\'escalier aérobie à rythme constant';

  @override
  String get templateStairmasterIntermediate1Title =>
      'Escalateur Intermédiaire 1 (Montée)';

  @override
  String get templateStairmasterIntermediate1Subtitle =>
      '2 min montée / 1 min récupération fessiers';

  @override
  String get templateStairmasterIntermediate2Title =>
      'Escalateur Intermédiaire 2';

  @override
  String get templateStairmasterIntermediate2Subtitle =>
      'Intervalles alternant rythmes rapide et lent';

  @override
  String get templateStairmasterAdvanced1Title => 'Escalateur Hors-pair 1';

  @override
  String get templateStairmasterAdvanced1Subtitle =>
      'Blocs d\'entraînement intenses de 2 min';

  @override
  String get templateStairmasterAdvanced2Title =>
      'Escalateur Hors-pair 2 (Sprint)';

  @override
  String get templateStairmasterAdvanced2Subtitle =>
      '30s montée rapide / 60s récupération';

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
  String get trend => 'Évolution du poids';

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
  String get recordWeight => 'Saisir le poids';

  @override
  String get quickAdjust => 'Ajustement rapide';

  @override
  String get goalWeightSet => 'Poids objectif défini';

  @override
  String get goalWeightRemoved => 'Poids cible désactivé';

  @override
  String get goalAchieved => 'Objectif atteint !';

  @override
  String get goalMatchesCurrentWeight =>
      'L\'objectif correspond au poids actuel';

  @override
  String get setGoal => 'Fixer l\'objectif';

  @override
  String get suggested => 'Suggéré';

  @override
  String get removeGoal => 'Retirer l\'objectif';

  @override
  String get addOneMoreRecordToSeeTrend =>
      'Ajoutez 1 mesure pour voir la tendance';

  @override
  String get noWeightRecorded => 'Aucun poids enregistré';

  @override
  String get startTrackingYourWeight =>
      'Notez votre poids pour suivre vos progrès';

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
  String get startAWorkoutToSeeItHere => 'Vos séances apparaîtront ici';

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
  String get benefitVoiceCoaching => 'Coaching vocal';

  @override
  String get benefitCycleStairmasterRoutines => 'Séances vélo et stepper';

  @override
  String get benefitUnlimitedRoutinesNew => 'Routines illimitées';

  @override
  String get benefitWeightFeature => 'Suivi du poids';

  @override
  String get benefitNoAdsFocus => 'Sans pub';

  @override
  String get benefitFutureFeaturesNew => 'Fonctions à venir incluses';

  @override
  String get mostChosen => 'Top choix';

  @override
  String get canChangeAnytime => 'Changez quand vous voulez';

  @override
  String get startPremium => 'Passez Premium';

  @override
  String get cancelAnytimeKeepAccess =>
      'Annulez quand vous voulez, gardez l\'accès';

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

  @override
  String get workoutReminderTitle => 'Rappels';

  @override
  String get workoutReminderOff => 'Désactivé';

  @override
  String get workoutReminderEveryDay => 'Tous les jours';

  @override
  String get workoutReminderSelectTime => 'Choisir l\'heure';

  @override
  String get workoutReminderPermissionRequired =>
      'L\'autorisation de notification est requise.';

  @override
  String get workoutReminderTimeLabel => 'Heure';
}
