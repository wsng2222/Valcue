// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Interval Cardio';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get language => 'Idioma';

  @override
  String get system => 'Sistema';

  @override
  String get voiceGuide => 'Guia de Voz';

  @override
  String get audioNavigator => 'Navegador de Áudio';

  @override
  String get soundEffects => 'Efeitos Sonoros';

  @override
  String get unitSetting => 'Unidades';

  @override
  String get kmh => 'km/h';

  @override
  String get mph => 'mph';

  @override
  String get themeMode => 'Aspeto';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Escuro';

  @override
  String get smartwatchSync => 'Sincronização de Smartwatch';

  @override
  String get connectSmartwatch => 'Conectar ao smartwatch';

  @override
  String get connect => 'Conectar';

  @override
  String get about => 'Sobre';

  @override
  String version(String version) {
    return 'Versão $version';
  }

  @override
  String get comingSoon => 'Em Breve';

  @override
  String get translationComingSoon =>
      'A tradução estará disponível em uma atualização futura.';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancelar';

  @override
  String get done => 'Concluído';

  @override
  String get delete => 'Excluir';

  @override
  String get save => 'Salvar';

  @override
  String get edit => 'Editar';

  @override
  String get start => 'Iniciar';

  @override
  String get editRoutine => 'Editar Rotina';

  @override
  String get routineEdit => 'Editar Rotina';

  @override
  String get name => 'Nome';

  @override
  String get unnamedRoutine => 'Rotina Sem Nome';

  @override
  String get difficulty => 'Dificuldade';

  @override
  String difficultyColon(String difficulty) {
    return 'Dificuldade : $difficulty';
  }

  @override
  String get easy => 'Fácil';

  @override
  String get medium => 'Médio';

  @override
  String get hard => 'Difícil';

  @override
  String get interval => 'Intervalo';

  @override
  String get addInterval => 'Adicionar Intervalo';

  @override
  String get quickTools => 'Ações rápidas';

  @override
  String get addDefault => 'Adicionar base';

  @override
  String get duplicateLast => 'Duplicar última';

  @override
  String get repeatPattern => 'Repetir padrão';

  @override
  String get reorderIntervals => 'Reordenar';

  @override
  String get reorderMode => 'Modo de reordenação';

  @override
  String get reorderModeHint =>
      'Pressione e segure um cartão para movê-lo para a posição desejada.';

  @override
  String get patternLength => 'Tamanho do padrão';

  @override
  String get repeatCount => 'Repetições';

  @override
  String get noIntervals => 'Sem intervalos';

  @override
  String get addIntervalPrompt => 'Adicionar um intervalo';

  @override
  String get intervalEdit => 'Editar Intervalo';

  @override
  String get timeMinutes => 'Tempo (minutos)';

  @override
  String get duration => 'Duração';

  @override
  String get speed => 'Velocidade';

  @override
  String get speedKmh => 'Velocidade (km/h)';

  @override
  String get incline => 'Inclinação';

  @override
  String get level => 'Nível';

  @override
  String levelColon(int level) {
    return 'Nível $level';
  }

  @override
  String get rpm => 'RPM';

  @override
  String get rpmInfoDescription =>
      'RPM mostra quantas vezes os pedais giram em um minuto. Um RPM mais alto significa que você está pedalando com uma cadência mais rápida.';

  @override
  String get resistance => 'Resistência';

  @override
  String get resistanceLevel => 'Resistência (Nível)';

  @override
  String resistanceColon(int resistance) {
    return 'Resistência $resistance';
  }

  @override
  String get spm => 'SPM';

  @override
  String get spmSteps => 'SPM (passos/min)';

  @override
  String get saved => 'Salvo';

  @override
  String get deleted => 'Excluído';

  @override
  String get deleteRoutineTitle => 'Excluir Rotina';

  @override
  String get deleteRoutineMessage =>
      'Tem certeza de que deseja excluir esta rotina? Isso não pode ser desfeito.';

  @override
  String get deleteError => 'Ocorreu um erro ao excluir';

  @override
  String get nameRequired => 'Por favor, insira um nome';

  @override
  String get nameMaxLength => 'O nome deve ter 24 caracteres ou menos';

  @override
  String get minIntervalsRequired => 'Pelo menos um intervalo é necessário';

  @override
  String get intervalMinDuration =>
      'A duração do intervalo deve ser de pelo menos 1 segundo';

  @override
  String get intervalMaxDuration =>
      'A duração do intervalo deve ser de no máximo 3 horas (10800 segundos)';

  @override
  String get speedRange => 'A velocidade deve ser maior que 0 (0.5-25.0 km/h)';

  @override
  String get inclineRange => 'A inclinação deve estar no intervalo 0-15.0';

  @override
  String get rpmRange => 'RPM deve estar no intervalo 30-200';

  @override
  String get resistanceRange => 'A resistência deve estar no intervalo 1-20';

  @override
  String get levelRange => 'O nível deve estar no intervalo 1-20';

  @override
  String get spmRange => 'SPM deve estar no intervalo 50-200';

  @override
  String get noRoutinesSaved => 'Nenhuma rotina salva';

  @override
  String get tapToCreate => 'Toque para criar';

  @override
  String get tapButtonToCreate => 'Toque no botão para criar';

  @override
  String get premiumRoutineSettings => 'Configurações de Rotina Premium';

  @override
  String get viewMembership => 'Ver Premium';

  @override
  String get freeLimitTitle => '2 rotinas grátis';

  @override
  String get freeLimitMessage => 'Passe a Premium para rotinas ilimitadas';

  @override
  String get treadmill => 'Esteira';

  @override
  String get cycle => 'Bicicleta';

  @override
  String get stairmaster => 'Escada';

  @override
  String get selectLanguage => 'Idiomas';

  @override
  String get selectTheme => 'Selecionar Tema';

  @override
  String get selectDifficulty => 'Selecionar Dificuldade';

  @override
  String get pause => 'Pausar';

  @override
  String get resume => 'Continuar';

  @override
  String get endWorkout => 'Finalizar Treino';

  @override
  String get endWorkoutConfirm => 'Você deseja finalizar o treino?';

  @override
  String get end => 'Finalizar';

  @override
  String get share => 'Compartilhar';

  @override
  String get rotate => 'Girar';

  @override
  String get paused => 'PAUSADO';

  @override
  String get pausedTitle => 'Pausado';

  @override
  String get pausedSubtitle => 'Você pode continuar ou finalizar o treino';

  @override
  String get endWorkoutConfirmationMessage =>
      'Se você finalizar agora, o treino atual terminará e você será direcionado para a tela de resumo.';

  @override
  String get workoutComplete => 'Treino concluído';

  @override
  String get totalWorkoutTime => 'Tempo total';

  @override
  String get totalDistance => 'Distância total';

  @override
  String get totalTime => 'Tempo total';

  @override
  String get averageRpm => 'RPM Médio';

  @override
  String get averageLevel => 'Nível Médio';

  @override
  String get holdToStop => 'Pressione para parar';

  @override
  String get continueWorkout => 'Continuar';

  @override
  String get endWorkoutQuestion => 'Você deseja finalizar o treino?';

  @override
  String get workoutPaused => 'O treino foi pausado';

  @override
  String get lvlIncline => 'Inclinação';

  @override
  String get lvlResistance => 'Nível Resistência';

  @override
  String get premium => 'Premium';

  @override
  String get upgradeNow => 'Atualizar Agora';

  @override
  String get purchase => 'Comprar';

  @override
  String get later => 'Mais Tarde';

  @override
  String get premiumActivated => 'Premium foi ativado';

  @override
  String get premiumMembership => 'Premium';

  @override
  String get benefitCycleStairmaster => 'Rotinas de bike e StairMaster';

  @override
  String get benefitVoiceGuide => 'Guia de voz para cada sessão';

  @override
  String get benefitUnlimitedRoutines => 'Salvamento ilimitado de rotinas';

  @override
  String get noAds => 'Sem Anúncios';

  @override
  String get benefitFutureFeatures => 'Acesso a todos os recursos futuros';

  @override
  String get voiceGuideBenefit1 => 'Treino guiado por voz';

  @override
  String get voiceGuideBenefit2 => 'Anúncio automático de mudança de sessão';

  @override
  String get voiceGuideBenefit3 => 'Foco no treino com as mãos livres';

  @override
  String get routineLimitBenefit1 => 'Salvamento ilimitado de rotinas';

  @override
  String get routineLimitBenefit2 => 'Rotinas personalizadas por objetivo';

  @override
  String get routineLimitBenefit3 => 'Suporte para esteira, bike e StairMaster';

  @override
  String get premium_benefit_1 => 'Suporte para <red>bike e StairMaster</red>';

  @override
  String get premium_benefit_2 => '<red>Guia de voz</red> nas sessões';

  @override
  String get premium_benefit_3 => 'Salvar rotinas <red>ilimitado</red>';

  @override
  String get premium_benefit_4 =>
      'Recursos futuros <red>incluídos de por vida</red>';

  @override
  String originalPrice(String price) {
    return '$price';
  }

  @override
  String monthlyPrice(String price) {
    return '$price/mês';
  }

  @override
  String get premiumSubheadline =>
      'Desbloqueie orientação por voz, treinos de bicicleta e escada, e rotinas ilimitadas';

  @override
  String get monthly => 'Mensal';

  @override
  String get yearly => 'Anual';

  @override
  String get lifetime => 'Vitalício';

  @override
  String get freeTrial7Days => 'Teste grátis por 7 dias';

  @override
  String get perMonth => '/mês';

  @override
  String get perYear => '/ano';

  @override
  String get oneTime => 'Pagamento único';

  @override
  String savePercent(int percent) {
    return 'Economize $percent%';
  }

  @override
  String get bestValue => 'Melhor Valor';

  @override
  String get cancelAnytime => 'Cancele a qualquer momento';

  @override
  String get autoRenewableSubscription => 'Renovação automática';

  @override
  String get terms => 'Termos';

  @override
  String get privacy => 'Privacidade';

  @override
  String get restore => 'Restaurar';

  @override
  String get premiumTab => 'Premium';

  @override
  String get routineTab => 'Rotina';

  @override
  String get settingsTab => 'Configurações';

  @override
  String get myTab => 'Eu';

  @override
  String get close => 'Fechar';

  @override
  String get premiumFeature => 'Só Premium';

  @override
  String get usePremiumTest => 'Testar Premium';

  @override
  String dateTimeFormat(int year, int month, int day, int hour, int minute) {
    return '$day/$month/$year $hour:$minute';
  }

  @override
  String get checkRoutineStart => 'Prévia e iniciar';

  @override
  String get beginner => 'Iniciante';

  @override
  String get intermediate => 'Intermediário';

  @override
  String get advanced => 'Avançado';

  @override
  String get viewRecommendedRoutines => 'Sugestões →';

  @override
  String get recommendedRoutinesTreadmill => 'Sugestões de passadeira';

  @override
  String get recommendedRoutinesCycle => 'Sugestões de bicicleta';

  @override
  String get recommendedRoutinesStairmaster => 'Sugestões de escadas';

  @override
  String get alreadySaved => 'Já salvo';

  @override
  String get routineSaved => 'Rotina salva';

  @override
  String get checkRoutine => 'Prévia';

  @override
  String get saveRoutine => 'Salvar Rotina';

  @override
  String get routineAlreadySaved => 'Rotina já salva';

  @override
  String get noTemplatesFound => 'Nenhum modelo encontrado';

  @override
  String get avg => 'Méd.';

  @override
  String get avgRpm => 'Méd. RPM';

  @override
  String get avgLevel => 'Méd. Nível';

  @override
  String get templateTreadmillBeginner1Title => 'Esteira Iniciante 1';

  @override
  String get templateTreadmillBeginner1Subtitle =>
      '1:1 caminhada e corrida após 3 min de aquecimento';

  @override
  String get templateTreadmillBeginner2Title =>
      'Esteira Iniciante 2 (Inclinação)';

  @override
  String get templateTreadmillBeginner2Subtitle =>
      'Caminhada inclinada com baixo impacto articular';

  @override
  String get templateTreadmillIntermediate1Title => 'Esteira Intermediário 1';

  @override
  String get templateTreadmillIntermediate1Subtitle =>
      'Intervalo de corrida 1:1 para queima de gordura';

  @override
  String get templateTreadmillIntermediate2Title =>
      'Esteira Intermediário 2 (Velocidade)';

  @override
  String get templateTreadmillIntermediate2Subtitle =>
      'Corrida piramidal com velocidade crescente';

  @override
  String get templateTreadmillAdvanced1Title => 'Esteira Avançado 1';

  @override
  String get templateTreadmillAdvanced1Subtitle =>
      'Intervalo cardio de alta intensidade';

  @override
  String get templateTreadmillAdvanced2Title => 'Esteira Avançado 2 (Sprint)';

  @override
  String get templateTreadmillAdvanced2Subtitle =>
      'Repetições curtas de sprint de alta intensidade';

  @override
  String get templateCycleBeginner1Title => 'Bike Iniciante 1';

  @override
  String get templateCycleBeginner1Subtitle =>
      'Iniciação ao pedal ajustando RPM';

  @override
  String get templateCycleBeginner2Title => 'Bike Iniciante 2 (Constante)';

  @override
  String get templateCycleBeginner2Subtitle =>
      'Treino de resistência a carga fixa';

  @override
  String get templateCycleIntermediate1Title => 'Bike Intermediário 1';

  @override
  String get templateCycleIntermediate1Subtitle =>
      '1 min alta velocidade / 1 min recuperação spin';

  @override
  String get templateCycleIntermediate2Title => 'Bike Intermediário 2 (Colina)';

  @override
  String get templateCycleIntermediate2Subtitle =>
      'Subida de colinas a alta resistência';

  @override
  String get templateCycleAdvanced1Title => 'Bike Avançado 1';

  @override
  String get templateCycleAdvanced1Subtitle =>
      'Intervalos de força de 30s a alta resistência';

  @override
  String get templateCycleAdvanced2Title => 'Bike Avançado 2 (Tabata)';

  @override
  String get templateCycleAdvanced2Subtitle =>
      'Circuito Tabata de 20s/10s para queima de gordura';

  @override
  String get templateStairmasterBeginner1Title => 'Stairmaster Iniciante 1';

  @override
  String get templateStairmasterBeginner1Subtitle =>
      'Caminhada segura de adaptação ao simulador';

  @override
  String get templateStairmasterBeginner2Title =>
      'Stairmaster Iniciante 2 (Constante)';

  @override
  String get templateStairmasterBeginner2Subtitle =>
      'Subida aeróbica em ritmo constante';

  @override
  String get templateStairmasterIntermediate1Title =>
      'Stairmaster Intermediário 1 (Subida)';

  @override
  String get templateStairmasterIntermediate1Subtitle =>
      '2 min subida / 1 min recuperação de glúteos';

  @override
  String get templateStairmasterIntermediate2Title =>
      'Stairmaster Intermediário 2';

  @override
  String get templateStairmasterIntermediate2Subtitle =>
      'Intervalos alternando ritmo rápido e lento';

  @override
  String get templateStairmasterAdvanced1Title => 'Stairmaster Avançado 1';

  @override
  String get templateStairmasterAdvanced1Subtitle =>
      'Treino intenso em blocos de 2 min';

  @override
  String get templateStairmasterAdvanced2Title =>
      'Stairmaster Avançado 2 (Sprint)';

  @override
  String get templateStairmasterAdvanced2Subtitle =>
      '30s subida rápida / 60s recuperação';

  @override
  String get historyTab => 'Histórico';

  @override
  String get calendarTab => 'Calendário';

  @override
  String get weightTab => 'Peso';

  @override
  String get bike => 'Bicicleta';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get trend => 'Evolução do peso';

  @override
  String get timeframe7D => '7D';

  @override
  String get timeframe30D => '30D';

  @override
  String get timeframe90D => '90D';

  @override
  String get timeframeAll => 'TUDO';

  @override
  String get history => 'Histórico';

  @override
  String get seeAll => 'Ver tudo';

  @override
  String get weightEntryDeleted => 'Entrada de peso excluída';

  @override
  String get weightUpdated => 'Peso atualizado';

  @override
  String get editWeight => 'Editar peso';

  @override
  String get recordWeight => 'Registrar peso';

  @override
  String get quickAdjust => 'Ajuste rápido';

  @override
  String get goalWeightSet => 'Peso objetivo definido';

  @override
  String get goalWeightRemoved => 'Peso objetivo desativado';

  @override
  String get goalAchieved => 'Objetivo alcançado!';

  @override
  String get goalMatchesCurrentWeight => 'O objetivo corresponde ao peso atual';

  @override
  String get setGoal => 'Definir meta';

  @override
  String get suggested => 'Sugerido';

  @override
  String get removeGoal => 'Remover meta';

  @override
  String get addOneMoreRecordToSeeTrend =>
      'Adicione mais 1 registo para ver a tendência';

  @override
  String get noWeightRecorded => 'Ainda não há peso registrado';

  @override
  String get startTrackingYourWeight =>
      'Registe o peso para acompanhar o progresso';

  @override
  String get treadmillSession => 'Sessão de Esteira';

  @override
  String get bikeSession => 'Sessão de Bicicleta';

  @override
  String get stairmasterSession => 'Sessão de Escada';

  @override
  String get treadmillWorkout => 'Treino de Esteira';

  @override
  String get bikeWorkout => 'Treino de Bicicleta';

  @override
  String get stairmasterWorkout => 'Treino de Escada';

  @override
  String get startAWorkoutToSeeItHere => 'Os seus treinos aparecem aqui';

  @override
  String get mon => 'Seg';

  @override
  String get tue => 'Ter';

  @override
  String get wed => 'Qua';

  @override
  String get thu => 'Qui';

  @override
  String get fri => 'Sex';

  @override
  String get sat => 'Sáb';

  @override
  String get sun => 'Dom';

  @override
  String get sessions => 'Sessões';

  @override
  String get distance => 'Distância';

  @override
  String get today => 'Hoje';

  @override
  String get yesterday => 'Ontem';

  @override
  String get noWorkoutsYet => 'Ainda não há treinos';

  @override
  String get startYourFirstWorkout =>
      'Comece seu primeiro treino para ver seu histórico aqui';

  @override
  String get goToRoutines => 'Ir para Rotinas';

  @override
  String get weightRecorded => 'Peso registrado';

  @override
  String get workout => 'treino';

  @override
  String get workouts => 'treinos';

  @override
  String get goal => 'Meta';

  @override
  String get toGo => 'restante';

  @override
  String get over => 'acima';

  @override
  String get last => 'Último';

  @override
  String get newLabel => 'Novo';

  @override
  String youNeed(String amount, String goal) {
    return 'Você precisa de $amount para atingir $goal';
  }

  @override
  String youNeedPlus(String amount, String goal) {
    return 'Você precisa de +$amount para atingir $goal';
  }

  @override
  String get current => 'Atual';

  @override
  String get premiumHeadline => 'Os mesmos 30 minutos, resultados diferentes';

  @override
  String get premiumSubheadlineNew =>
      'Não apenas corra, exercite-se de forma a queimar gordura';

  @override
  String get mostPopular => 'Mais Popular';

  @override
  String dailyPrice(int price) {
    return '$price por dia';
  }

  @override
  String get benefitVoiceCoaching => 'Sistema de Coaching por Voz Premium';

  @override
  String get benefitCycleStairmasterRoutines =>
      'Suporte Completo para Todos os Equipamentos Cardio';

  @override
  String get benefitUnlimitedRoutinesNew => 'Biblioteca de Rotinas Ilimitada';

  @override
  String get benefitWeightFeature =>
      'Rastreamento e Análise Inteligente de Peso';

  @override
  String get benefitNoAdsFocus => 'Experiência Premium sem Anúncios';

  @override
  String get benefitFutureFeaturesNew =>
      'Todos os recursos premium futuros incluídos';

  @override
  String get mostChosen => 'Mais escolhido';

  @override
  String get canChangeAnytime => 'Altere quando quiser';

  @override
  String get startPremium => 'Passar a Premium';

  @override
  String get cancelAnytimeKeepAccess =>
      'Cancele quando quiser e mantenha o acesso';

  @override
  String workoutDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Treino $count dias 🔥',
      one: 'Treino 1 dia 🔥',
    );
    return '$_temp0';
  }

  @override
  String restDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Descanso $count dias 🛏️',
      one: 'Descanso 1 dia 🛏️',
    );
    return '$_temp0';
  }

  @override
  String get workoutReminderTitle => 'Lembretes';

  @override
  String get workoutReminderOff => 'Desligado';

  @override
  String get workoutReminderEveryDay => 'Todo dia';

  @override
  String get workoutReminderSelectTime => 'Selecionar horário';

  @override
  String get workoutReminderPermissionRequired =>
      'Permissão de notificação necessária.';

  @override
  String get workoutReminderTimeLabel => 'Horário';
}
