// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Interval Cardio';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get language => 'Idioma';

  @override
  String get system => 'Sistema';

  @override
  String get voiceGuide => 'Guía de Voz';

  @override
  String get audioNavigator => 'Navegador de Audio';

  @override
  String get soundEffects => 'Efectos de Sonido';

  @override
  String get unitSetting => 'Configuración de Unidades';

  @override
  String get kmh => 'km/h';

  @override
  String get mph => 'mph';

  @override
  String get themeMode => 'Modo Claro/Oscuro';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get smartwatchSync => 'Sincronización de Smartwatch';

  @override
  String get connectSmartwatch => 'Conectar con smartwatch';

  @override
  String get connect => 'Conectar';

  @override
  String get about => 'Acerca de';

  @override
  String version(String version) {
    return 'Versión $version';
  }

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get translationComingSoon =>
      'La traducción estará disponible en una actualización futura.';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancelar';

  @override
  String get done => 'Hecho';

  @override
  String get delete => 'Eliminar';

  @override
  String get save => 'Guardar';

  @override
  String get edit => 'Editar';

  @override
  String get start => 'Iniciar';

  @override
  String get editRoutine => 'Editar Rutina';

  @override
  String get routineEdit => 'Editar Rutina';

  @override
  String get name => 'Nombre';

  @override
  String get unnamedRoutine => 'Rutina Sin Nombre';

  @override
  String get difficulty => 'Dificultad';

  @override
  String difficultyColon(String difficulty) {
    return 'Dificultad : $difficulty';
  }

  @override
  String get easy => 'Fácil';

  @override
  String get medium => 'Medio';

  @override
  String get hard => 'Difícil';

  @override
  String get interval => 'Intervalo';

  @override
  String get addInterval => 'Agregar Intervalo';

  @override
  String get noIntervals => 'No hay intervalos';

  @override
  String get addIntervalPrompt => 'Agregar un intervalo';

  @override
  String get intervalEdit => 'Editar Intervalo';

  @override
  String get timeMinutes => 'Tiempo (minutos)';

  @override
  String get duration => 'Duración';

  @override
  String get speed => 'Velocidad';

  @override
  String get speedKmh => 'Velocidad (km/h)';

  @override
  String get incline => 'Inclinación';

  @override
  String get level => 'Nivel';

  @override
  String levelColon(int level) {
    return 'Nivel $level';
  }

  @override
  String get rpm => 'RPM';

  @override
  String get resistance => 'Resistencia';

  @override
  String get resistanceLevel => 'Resistencia (Nivel)';

  @override
  String resistanceColon(int resistance) {
    return 'Resistencia $resistance';
  }

  @override
  String get spm => 'SPM';

  @override
  String get spmSteps => 'SPM (pasos/min)';

  @override
  String get saved => 'Guardado';

  @override
  String get deleted => 'Eliminado';

  @override
  String get deleteRoutineTitle => 'Eliminar Rutina';

  @override
  String get deleteRoutineMessage =>
      '¿Estás seguro de que quieres eliminar esta rutina? Esto no se puede deshacer.';

  @override
  String get deleteError => 'Ocurrió un error al eliminar';

  @override
  String get nameRequired => 'Por favor ingresa un nombre';

  @override
  String get nameMaxLength => 'El nombre debe tener 24 caracteres o menos';

  @override
  String get minIntervalsRequired => 'Se requiere al menos un intervalo';

  @override
  String get intervalMinDuration =>
      'La duración del intervalo debe ser de al menos 1 segundo';

  @override
  String get intervalMaxDuration =>
      'La duración del intervalo debe ser de máximo 3 horas (10800 segundos)';

  @override
  String get speedRange => 'La velocidad debe ser mayor que 0 (0.5-25.0 km/h)';

  @override
  String get inclineRange => 'La inclinación debe estar en el rango 0-15.0';

  @override
  String get rpmRange => 'RPM debe estar en el rango 30-200';

  @override
  String get resistanceRange => 'La resistencia debe estar en el rango 1-20';

  @override
  String get levelRange => 'El nivel debe estar en el rango 1-20';

  @override
  String get spmRange => 'SPM debe estar en el rango 50-200';

  @override
  String get noRoutinesSaved => 'No hay rutinas guardadas';

  @override
  String get tapToCreate => 'Toca para crear';

  @override
  String get tapButtonToCreate => 'Toca el botón para crear';

  @override
  String get premiumRoutineSettings => 'Configuración de Rutina Premium';

  @override
  String get viewMembership => 'Ver Membresía';

  @override
  String get freeLimitTitle => 'El límite gratuito es de 2 rutinas';

  @override
  String get freeLimitMessage => 'Puedes usar rutinas ilimitadas con membresía';

  @override
  String get treadmill => 'Cinta de Correr';

  @override
  String get cycle => 'Bicicleta';

  @override
  String get stairmaster => 'Escaladora';

  @override
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String get selectTheme => 'Seleccionar Tema';

  @override
  String get selectDifficulty => 'Seleccionar Dificultad';

  @override
  String get pause => 'Pausar';

  @override
  String get resume => 'Continuar';

  @override
  String get endWorkout => 'Finalizar Entrenamiento';

  @override
  String get endWorkoutConfirm => '¿Quieres finalizar el entrenamiento?';

  @override
  String get end => 'Finalizar';

  @override
  String get rotate => 'Rotar';

  @override
  String get paused => 'PAUSADO';

  @override
  String get pausedTitle => 'Pausado';

  @override
  String get pausedSubtitle => 'Puedes continuar o finalizar el entrenamiento';

  @override
  String get endWorkoutConfirmationMessage =>
      'Si finalizas ahora, el entrenamiento actual terminará y pasarás a la pantalla de resumen.';

  @override
  String get workoutComplete => 'Entrenamiento completo';

  @override
  String get totalWorkoutTime => 'Tiempo total';

  @override
  String get totalDistance => 'Distancia total';

  @override
  String get averageRpm => 'RPM Promedio';

  @override
  String get averageLevel => 'Nivel Promedio';

  @override
  String get holdToStop => 'Mantén para detener';

  @override
  String get continueWorkout => 'Continuar';

  @override
  String get endWorkoutQuestion => '¿Quieres finalizar el entrenamiento?';

  @override
  String get workoutPaused => 'El entrenamiento ha sido pausado';

  @override
  String get lvlIncline => 'Inclinación';

  @override
  String get lvlResistance => 'Nivel Resistencia';

  @override
  String get premium => 'Premium';

  @override
  String get upgradeNow => 'Actualizar Ahora';

  @override
  String get purchase => 'Comprar';

  @override
  String get later => 'Más Tarde';

  @override
  String get premiumActivated => 'Premium ha sido activado';

  @override
  String get premiumMembership => 'Membresía Premium';

  @override
  String get benefitCycleStairmaster =>
      'Funcionalidad de Bicicleta y Escaladora';

  @override
  String get benefitVoiceGuide => 'Funcionalidad de guía de voz de sesión';

  @override
  String get benefitUnlimitedRoutines => 'Guardado de rutinas ilimitado';

  @override
  String get noAds => 'Sin Anuncios';

  @override
  String get benefitFutureFeatures => 'Acceso ilimitado a funciones futuras';

  @override
  String get voiceGuideBenefit1 => 'Guía por voz durante el entrenamiento';

  @override
  String get voiceGuideBenefit2 =>
      'Anuncios automáticos de transición de sesión';

  @override
  String get voiceGuideBenefit3 => 'Enfoque en la rutina sin usar las manos';

  @override
  String get routineLimitBenefit1 => 'Guardado de rutinas ilimitado';

  @override
  String get routineLimitBenefit2 => 'Guardar rutinas para múltiples objetivos';

  @override
  String get routineLimitBenefit3 =>
      'Usar todos los tipos de máquinas (cinta/bicicleta/stepper)';

  @override
  String get premium_benefit_1 => 'Entrenos en <red>bici y StairMaster</red>';

  @override
  String get premium_benefit_2 => '<red>Guía por voz</red> en sesión';

  @override
  String get premium_benefit_3 => 'Guardado de rutinas <red>ilimitado</red>';

  @override
  String get premium_benefit_4 =>
      '<red>Acceso ilimitado</red> a funciones futuras';

  @override
  String originalPrice(String price) {
    return '$price';
  }

  @override
  String monthlyPrice(String price) {
    return '$price/mes';
  }

  @override
  String get premiumSubheadline =>
      'Desbloquea guía de voz, entrenamientos de bicicleta y escaladora, y rutinas ilimitadas';

  @override
  String get monthly => 'Mensual';

  @override
  String get yearly => 'Anual';

  @override
  String get lifetime => 'Vitalicio';

  @override
  String get freeTrial7Days => 'Prueba gratis de 7 días';

  @override
  String get perMonth => '/mes';

  @override
  String get perYear => '/año';

  @override
  String get oneTime => 'Única';

  @override
  String savePercent(int percent) {
    return 'Ahorra $percent%';
  }

  @override
  String get bestValue => 'Mejor Valor';

  @override
  String get cancelAnytime => 'Cancela en cualquier momento';

  @override
  String get autoRenewableSubscription =>
      'Suscripción renovable automáticamente';

  @override
  String get terms => 'Términos';

  @override
  String get privacy => 'Privacidad';

  @override
  String get restore => 'Restaurar';

  @override
  String get premiumTab => 'Premium';

  @override
  String get routineTab => 'Rutina';

  @override
  String get settingsTab => 'Configuración';

  @override
  String get myTab => 'Mi';

  @override
  String get close => 'Cerrar';

  @override
  String get premiumFeature => 'Función Premium';

  @override
  String get usePremiumTest => 'Usar Premium (Prueba)';

  @override
  String dateTimeFormat(int year, int month, int day, int hour, int minute) {
    return '$day/$month/$year $hour:$minute';
  }

  @override
  String get checkRoutineStart => 'Verificar Rutina / Iniciar';

  @override
  String get beginner => 'Principiante';

  @override
  String get intermediate => 'Intermedio';

  @override
  String get advanced => 'Avanzado';

  @override
  String get viewRecommendedRoutines => 'Ver Rutinas Recomendadas →';

  @override
  String get recommendedRoutinesTreadmill => 'Rutinas de Cinta Recomendadas';

  @override
  String get recommendedRoutinesCycle => 'Rutinas de Bicicleta Recomendadas';

  @override
  String get recommendedRoutinesStairmaster =>
      'Rutinas de Escaladora Recomendadas';

  @override
  String get alreadySaved => 'Ya guardado';

  @override
  String get routineSaved => 'Rutina guardada';

  @override
  String get checkRoutine => 'Verificar';

  @override
  String get saveRoutine => 'Guardar Rutina';

  @override
  String get routineAlreadySaved => 'La rutina ya está guardada';

  @override
  String get noTemplatesFound => 'No se encontraron plantillas';

  @override
  String get avg => 'Prom.';

  @override
  String get avgRpm => 'Prom. RPM';

  @override
  String get avgLevel => 'Prom. Nivel';

  @override
  String get templateTreadmillBeginner1Title => 'Inicio fácil 20';

  @override
  String get templateTreadmillBeginner1Subtitle =>
      'Calentamiento 3 min + intervalos 1:1';

  @override
  String get templateTreadmillBeginner2Title => 'Caminata con inclinación 25';

  @override
  String get templateTreadmillBeginner2Subtitle =>
      'Bloques de caminata en inclinación';

  @override
  String get templateTreadmillIntermediate1Title => 'Clásico 1:1 24';

  @override
  String get templateTreadmillIntermediate1Subtitle =>
      'Intervalos clásicos 1:1';

  @override
  String get templateTreadmillIntermediate2Title => 'Escalera de velocidad 20';

  @override
  String get templateTreadmillIntermediate2Subtitle =>
      'Escalera de velocidad (sube el ritmo)';

  @override
  String get templateTreadmillAdvanced1Title => 'Quemador 2:1 21';

  @override
  String get templateTreadmillAdvanced1Subtitle =>
      'Intervalos 2:1 (duro/suave)';

  @override
  String get templateTreadmillAdvanced2Title => 'Estallido sprint 18';

  @override
  String get templateTreadmillAdvanced2Subtitle =>
      'Repeticiones de sprint de 20 s';

  @override
  String get templateCycleBeginner1Title => 'Constructor de cadencia 20';

  @override
  String get templateCycleBeginner1Subtitle =>
      'Calentamiento 4 min + cadencia 1:1';

  @override
  String get templateCycleBeginner2Title => 'Pedaleo constante 25';

  @override
  String get templateCycleBeginner2Subtitle => 'Bloque largo y estable';

  @override
  String get templateCycleIntermediate1Title => 'Spinning 1:1 24';

  @override
  String get templateCycleIntermediate1Subtitle => 'Intervalos clásicos 1:1';

  @override
  String get templateCycleIntermediate2Title => 'Simulación de colina 22';

  @override
  String get templateCycleIntermediate2Subtitle => 'Repeticiones en subida';

  @override
  String get templateCycleAdvanced1Title => 'Intervalos de potencia 20';

  @override
  String get templateCycleAdvanced1Subtitle => 'Ráfagas de potencia de 30 s';

  @override
  String get templateCycleAdvanced2Title => 'Mezcla Tabata 16';

  @override
  String get templateCycleAdvanced2Subtitle => 'Mezcla 20s/10s';

  @override
  String get templateStairmasterBeginner1Title => 'Pasos fáciles 20';

  @override
  String get templateStairmasterBeginner1Subtitle =>
      'Calentamiento 4 min + pasos 1:1';

  @override
  String get templateStairmasterBeginner2Title => 'Largo y fácil 25';

  @override
  String get templateStairmasterBeginner2Subtitle => 'Bloques largos y fáciles';

  @override
  String get templateStairmasterIntermediate1Title => 'Subida 2:1 21';

  @override
  String get templateStairmasterIntermediate1Subtitle =>
      'Repeticiones de subida 2:1';

  @override
  String get templateStairmasterIntermediate2Title => 'Fuerte 1:1 24';

  @override
  String get templateStairmasterIntermediate2Subtitle =>
      'Intervalos fuertes 1:1';

  @override
  String get templateStairmasterAdvanced1Title => 'Bloques duros 20';

  @override
  String get templateStairmasterAdvanced1Subtitle => 'Bloques duros de 2 min';

  @override
  String get templateStairmasterAdvanced2Title => 'Pasos sprint 18';

  @override
  String get templateStairmasterAdvanced2Subtitle =>
      'Sprints 30 s + recuperación 60 s';

  @override
  String get historyTab => 'Historial';

  @override
  String get calendarTab => 'Calendario';

  @override
  String get weightTab => 'Peso';

  @override
  String get bike => 'Bicicleta';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get trend => 'Tendencia';

  @override
  String get timeframe7D => '7D';

  @override
  String get timeframe30D => '30D';

  @override
  String get timeframe90D => '90D';

  @override
  String get timeframeAll => 'Todo';

  @override
  String get history => 'Historial';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get weightEntryDeleted => 'Entrada de peso eliminada';

  @override
  String get weightUpdated => 'Peso actualizado';

  @override
  String get editWeight => 'Editar peso';

  @override
  String get recordWeight => 'Registrar peso';

  @override
  String get quickAdjust => 'Ajuste rápido';

  @override
  String get goalWeightSet => 'Peso objetivo establecido';

  @override
  String get goalWeightRemoved => 'Peso objetivo eliminado';

  @override
  String get goalAchieved => '¡Objetivo alcanzado!';

  @override
  String get goalMatchesCurrentWeight =>
      'El objetivo coincide con el peso actual';

  @override
  String get setGoal => 'Establecer objetivo';

  @override
  String get suggested => 'Sugerido';

  @override
  String get removeGoal => 'Eliminar Objetivo';

  @override
  String get addOneMoreRecordToSeeTrend =>
      'Agrega 1 registro más para ver tu tendencia';

  @override
  String get noWeightRecorded => 'Aún no se ha registrado peso';

  @override
  String get startTrackingYourWeight =>
      'Comienza a registrar tu peso para ver el progreso aquí';

  @override
  String get treadmillSession => 'Sesión de Cinta';

  @override
  String get bikeSession => 'Sesión de Bicicleta';

  @override
  String get stairmasterSession => 'Sesión de Escaladora';

  @override
  String get treadmillWorkout => 'Entrenamiento de Cinta';

  @override
  String get bikeWorkout => 'Entrenamiento de Bicicleta';

  @override
  String get stairmasterWorkout => 'Entrenamiento de Escaladora';

  @override
  String get startAWorkoutToSeeItHere =>
      'Comienza un entrenamiento para verlo aquí';

  @override
  String get mon => 'Lun';

  @override
  String get tue => 'Mar';

  @override
  String get wed => 'Mié';

  @override
  String get thu => 'Jue';

  @override
  String get fri => 'Vie';

  @override
  String get sat => 'Sáb';

  @override
  String get sun => 'Dom';

  @override
  String get sessions => 'Sesiones';

  @override
  String get distance => 'Distancia';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String get noWorkoutsYet => 'Aún no hay entrenamientos';

  @override
  String get startYourFirstWorkout =>
      'Comienza tu primer entrenamiento para ver tu historial aquí';

  @override
  String get goToRoutines => 'Ir a Rutinas';

  @override
  String get weightRecorded => 'Peso registrado';

  @override
  String get workout => 'entrenamiento';

  @override
  String get workouts => 'entrenamientos';

  @override
  String get goal => 'Objetivo';

  @override
  String get toGo => 'restante';

  @override
  String get over => 'sobre';

  @override
  String get last => 'Último';

  @override
  String get newLabel => 'Nuevo';

  @override
  String youNeed(String amount, String goal) {
    return 'Necesitas $amount para alcanzar $goal';
  }

  @override
  String youNeedPlus(String amount, String goal) {
    return 'Necesitas +$amount para alcanzar $goal';
  }

  @override
  String get current => 'Actual';

  @override
  String get premiumHeadline => 'Los mismos 30 minutos, resultados diferentes';

  @override
  String get premiumSubheadlineNew =>
      'No solo corras, ejercítate de forma que queme grasa';

  @override
  String get mostPopular => 'Más Popular';

  @override
  String dailyPrice(int price) {
    return '$price por día';
  }

  @override
  String get benefitVoiceCoaching => 'Sistema de Entrenamiento por Voz Premium';

  @override
  String get benefitCycleStairmasterRoutines =>
      'Soporte Completo para Todo Equipo Cardio';

  @override
  String get benefitUnlimitedRoutinesNew => 'Biblioteca de Rutinas Ilimitadas';

  @override
  String get benefitWeightFeature =>
      'Seguimiento y Análisis Inteligente de Peso';

  @override
  String get benefitNoAdsFocus => 'Experiencia Premium sin Anuncios';

  @override
  String get benefitFutureFeaturesNew =>
      'Todas las funciones premium futuras incluidas';

  @override
  String get mostChosen => 'Más elegido';

  @override
  String get canChangeAnytime => 'Puedes cambiar en cualquier momento';

  @override
  String get startPremium => 'Comenzar Premium';

  @override
  String get cancelAnytimeKeepAccess =>
      'Cancela en cualquier momento y mantén el acceso hasta el final del período';

  @override
  String workoutDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Entrenamiento $count días 🔥',
      one: 'Entrenamiento 1 día 🔥',
    );
    return '$_temp0';
  }

  @override
  String restDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Descanso $count días 🛏️',
      one: 'Descanso 1 día 🛏️',
    );
    return '$_temp0';
  }

  @override
  String get workoutReminderTitle => 'Recordatorio de entrenamiento';

  @override
  String get workoutReminderOff => 'Desactivado';

  @override
  String get workoutReminderEveryDay => 'Cada día';

  @override
  String get workoutReminderSelectTime => 'Seleccionar hora';

  @override
  String get workoutReminderPermissionRequired =>
      'Se requiere permiso de notificación.';

  @override
  String get workoutReminderTimeLabel => 'Hora';
}
