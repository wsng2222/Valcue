// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Interval Cardio';

  @override
  String get settingsTitle => '设置';

  @override
  String get language => '语言';

  @override
  String get system => '系统';

  @override
  String get voiceGuide => '语音指南';

  @override
  String get audioNavigator => '音频导航器';

  @override
  String get soundEffects => '音效';

  @override
  String get unitSetting => '单位设置';

  @override
  String get kmh => 'km/h';

  @override
  String get mph => 'mph';

  @override
  String get themeMode => '浅色/深色模式';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get smartwatchSync => '智能手表同步';

  @override
  String get connectSmartwatch => '连接到智能手表';

  @override
  String get connect => '连接';

  @override
  String get about => '关于';

  @override
  String version(String version) {
    return '版本 $version';
  }

  @override
  String get comingSoon => '即将推出';

  @override
  String get translationComingSoon => '翻译将在未来的更新中提供。';

  @override
  String get ok => '确定';

  @override
  String get cancel => '取消';

  @override
  String get done => '完成';

  @override
  String get delete => '删除';

  @override
  String get save => '保存';

  @override
  String get edit => '编辑';

  @override
  String get start => '开始';

  @override
  String get editRoutine => '编辑例行程序';

  @override
  String get routineEdit => '编辑例行程序';

  @override
  String get name => '名称';

  @override
  String get unnamedRoutine => '未命名例行程序';

  @override
  String get difficulty => '难度';

  @override
  String difficultyColon(String difficulty) {
    return '难度 : $difficulty';
  }

  @override
  String get easy => '简单';

  @override
  String get medium => '中等';

  @override
  String get hard => '困难';

  @override
  String get interval => '间隔';

  @override
  String get addInterval => '添加间隔';

  @override
  String get noIntervals => '没有间隔';

  @override
  String get addIntervalPrompt => '添加间隔';

  @override
  String get intervalEdit => '编辑间隔';

  @override
  String get timeMinutes => '时间（分钟）';

  @override
  String get duration => '时间';

  @override
  String get speed => '速度';

  @override
  String get speedKmh => '速度（km/h）';

  @override
  String get incline => '坡度';

  @override
  String get level => '级别';

  @override
  String levelColon(int level) {
    return '级别 $level';
  }

  @override
  String get rpm => 'RPM';

  @override
  String get resistance => '阻力';

  @override
  String get resistanceLevel => '阻力（级别）';

  @override
  String resistanceColon(int resistance) {
    return '阻力 $resistance';
  }

  @override
  String get spm => 'SPM';

  @override
  String get spmSteps => 'SPM（步/分钟）';

  @override
  String get saved => '已保存';

  @override
  String get deleted => '已删除';

  @override
  String get deleteRoutineTitle => '删除例行程序';

  @override
  String get deleteRoutineMessage => '您确定要删除此例行程序吗？此操作无法撤销。';

  @override
  String get deleteError => '删除时发生错误';

  @override
  String get nameRequired => '请输入名称';

  @override
  String get nameMaxLength => '名称必须为24个字符或更少';

  @override
  String get minIntervalsRequired => '至少需要一个间隔';

  @override
  String get intervalMinDuration => '间隔时间必须至少为1秒';

  @override
  String get intervalMaxDuration => '间隔时间最多为3小时（10800秒）';

  @override
  String get speedRange => '速度必须大于0（0.5-25.0 km/h）';

  @override
  String get inclineRange => '坡度必须在0-15.0范围内';

  @override
  String get rpmRange => 'RPM必须在30-200范围内';

  @override
  String get resistanceRange => '阻力必须在1-20范围内';

  @override
  String get levelRange => '级别必须在1-20范围内';

  @override
  String get spmRange => 'SPM必须在50-200范围内';

  @override
  String get noRoutinesSaved => '没有保存的例行程序';

  @override
  String get tapToCreate => '点击创建';

  @override
  String get tapButtonToCreate => '点击按钮创建';

  @override
  String get premiumRoutineSettings => '高级例行程序设置';

  @override
  String get viewMembership => '查看会员资格';

  @override
  String get freeLimitTitle => '免费限制为2个例行程序';

  @override
  String get freeLimitMessage => '您可以使用会员资格获得无限例行程序';

  @override
  String get treadmill => '跑步机';

  @override
  String get cycle => '自行车';

  @override
  String get stairmaster => '爬楼机';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get selectTheme => '选择主题';

  @override
  String get selectDifficulty => '选择难度';

  @override
  String get pause => '暂停';

  @override
  String get resume => '继续';

  @override
  String get endWorkout => '结束训练';

  @override
  String get endWorkoutConfirm => '您要结束训练吗？';

  @override
  String get end => '结束';

  @override
  String get rotate => '旋转';

  @override
  String get paused => '已暂停';

  @override
  String get pausedTitle => '已暂停';

  @override
  String get pausedSubtitle => '您可以继续或结束训练';

  @override
  String get endWorkoutConfirmationMessage => '如果现在结束，当前训练将完成，您将转到摘要屏幕。';

  @override
  String get workoutComplete => 'Workout Complete';

  @override
  String get totalWorkoutTime => '总时间';

  @override
  String get totalDistance => '总距离';

  @override
  String get averageRpm => '平均RPM';

  @override
  String get averageLevel => '平均等级';

  @override
  String get holdToStop => 'Hold to Stop';

  @override
  String get continueWorkout => '继续';

  @override
  String get endWorkoutQuestion => '您要结束训练吗？';

  @override
  String get workoutPaused => '训练已暂停';

  @override
  String get lvlIncline => '坡度';

  @override
  String get lvlResistance => '级别阻力';

  @override
  String get premium => '高级版';

  @override
  String get upgradeNow => '立即升级';

  @override
  String get purchase => '购买';

  @override
  String get later => '稍后';

  @override
  String get premiumActivated => '高级版已激活';

  @override
  String get premiumMembership => '高级会员';

  @override
  String get benefitCycleStairmaster => '自行车、爬楼机功能';

  @override
  String get benefitVoiceGuide => '会话语音指南功能';

  @override
  String get benefitUnlimitedRoutines => '无限例行程序保存';

  @override
  String get noAds => '无广告';

  @override
  String get benefitFutureFeatures => '无限访问未来功能';

  @override
  String get voiceGuideBenefit1 => '训练期间的语音指导';

  @override
  String get voiceGuideBenefit2 => '自动会话转换提醒';

  @override
  String get voiceGuideBenefit3 => '免提专注例程';

  @override
  String get routineLimitBenefit1 => '无限例程保存';

  @override
  String get routineLimitBenefit2 => '保存多个目标的例程';

  @override
  String get routineLimitBenefit3 => '使用所有机器类型（跑步机/动感单车/爬楼机）';

  @override
  String get premium_benefit_1 => '支持<red>动感单车和爬楼机</red>训练';

  @override
  String get premium_benefit_2 => '训练时<red>语音指导</red>';

  @override
  String get premium_benefit_3 => '例程保存<red>无限</red>';

  @override
  String get premium_benefit_4 => '未来功能<red>无限访问</red>';

  @override
  String originalPrice(String price) {
    return '$price';
  }

  @override
  String monthlyPrice(String price) {
    return '$price/月';
  }

  @override
  String get premiumSubheadline => '解锁语音指导、自行车和爬楼机训练，以及无限例程';

  @override
  String get monthly => '月度';

  @override
  String get yearly => '年度';

  @override
  String get lifetime => '终身';

  @override
  String get freeTrial7Days => '7天免费试用';

  @override
  String get perMonth => '/月';

  @override
  String get perYear => '/年';

  @override
  String get oneTime => '一次性支付';

  @override
  String savePercent(int percent) {
    return '节省 $percent%';
  }

  @override
  String get bestValue => '最佳价值';

  @override
  String get cancelAnytime => '随时取消';

  @override
  String get autoRenewableSubscription => '自动续订订阅';

  @override
  String get terms => '条款';

  @override
  String get privacy => '隐私';

  @override
  String get restore => '恢复';

  @override
  String get premiumTab => '高级版';

  @override
  String get routineTab => '例行程序';

  @override
  String get settingsTab => '设置';

  @override
  String get myTab => '我的';

  @override
  String get close => '关闭';

  @override
  String get premiumFeature => '高级版功能';

  @override
  String get usePremiumTest => '使用高级版（测试）';

  @override
  String dateTimeFormat(int year, int month, int day, int hour, int minute) {
    return '$year年$month月$day日 $hour时$minute分';
  }

  @override
  String get checkRoutineStart => '检查例行程序 / 开始';

  @override
  String get beginner => '初级';

  @override
  String get intermediate => '中级';

  @override
  String get advanced => '高级';

  @override
  String get viewRecommendedRoutines => '查看推荐例程 →';

  @override
  String get recommendedRoutinesTreadmill => '推荐跑步机例程';

  @override
  String get recommendedRoutinesCycle => '推荐自行车例程';

  @override
  String get recommendedRoutinesStairmaster => '推荐爬楼机例程';

  @override
  String get alreadySaved => '已保存';

  @override
  String get routineSaved => '例程已保存';

  @override
  String get checkRoutine => '检查';

  @override
  String get saveRoutine => '保存例程';

  @override
  String get routineAlreadySaved => '例程已保存';

  @override
  String get noTemplatesFound => '未找到模板';

  @override
  String get avg => '平均';

  @override
  String get avgRpm => '平均 RPM';

  @override
  String get avgLevel => '平均等级';

  @override
  String get templateTreadmillBeginner1Title => '轻松起步20';

  @override
  String get templateTreadmillBeginner1Subtitle => '3分钟热身 + 1:1间歇';

  @override
  String get templateTreadmillBeginner2Title => '爬坡快走25';

  @override
  String get templateTreadmillBeginner2Subtitle => '坡度快走分段';

  @override
  String get templateTreadmillIntermediate1Title => '经典1:1 24';

  @override
  String get templateTreadmillIntermediate1Subtitle => '经典1:1间歇';

  @override
  String get templateTreadmillIntermediate2Title => '速度阶梯20';

  @override
  String get templateTreadmillIntermediate2Subtitle => '速度阶梯（逐步加速）';

  @override
  String get templateTreadmillAdvanced1Title => '燃脂2:1 21';

  @override
  String get templateTreadmillAdvanced1Subtitle => '2:1间歇（强/弱）';

  @override
  String get templateTreadmillAdvanced2Title => '冲刺爆发18';

  @override
  String get templateTreadmillAdvanced2Subtitle => '20秒冲刺重复';

  @override
  String get templateCycleBeginner1Title => '踏频训练20';

  @override
  String get templateCycleBeginner1Subtitle => '4分钟热身 + 1:1踏频';

  @override
  String get templateCycleBeginner2Title => '稳定骑行25';

  @override
  String get templateCycleBeginner2Subtitle => '长时间稳定区间';

  @override
  String get templateCycleIntermediate1Title => '骑行1:1 24';

  @override
  String get templateCycleIntermediate1Subtitle => '经典1:1间歇';

  @override
  String get templateCycleIntermediate2Title => '爬坡模拟22';

  @override
  String get templateCycleIntermediate2Subtitle => '爬坡重复';

  @override
  String get templateCycleAdvanced1Title => '力量间歇20';

  @override
  String get templateCycleAdvanced1Subtitle => '30秒力量爆发';

  @override
  String get templateCycleAdvanced2Title => 'Tabata混合16';

  @override
  String get templateCycleAdvanced2Subtitle => '20秒/10秒混合';

  @override
  String get templateStairmasterBeginner1Title => '轻松台阶20';

  @override
  String get templateStairmasterBeginner1Subtitle => '4分钟热身 + 1:1台阶';

  @override
  String get templateStairmasterBeginner2Title => '长时间轻松25';

  @override
  String get templateStairmasterBeginner2Subtitle => '长时间轻松区块';

  @override
  String get templateStairmasterIntermediate1Title => '2:1爬升21';

  @override
  String get templateStairmasterIntermediate1Subtitle => '2:1爬升重复';

  @override
  String get templateStairmasterIntermediate2Title => '强力1:1 24';

  @override
  String get templateStairmasterIntermediate2Subtitle => '强力1:1间歇';

  @override
  String get templateStairmasterAdvanced1Title => '高强度区块20';

  @override
  String get templateStairmasterAdvanced1Subtitle => '2分钟高强度区块';

  @override
  String get templateStairmasterAdvanced2Title => '冲刺台阶18';

  @override
  String get templateStairmasterAdvanced2Subtitle => '30秒冲刺 + 60秒恢复';

  @override
  String get historyTab => '记录';

  @override
  String get calendarTab => '日历';

  @override
  String get weightTab => '体重';

  @override
  String get bike => '自行车';

  @override
  String get thisWeek => '本周';

  @override
  String get trend => '趋势';

  @override
  String get timeframe7D => '7天';

  @override
  String get timeframe30D => '30天';

  @override
  String get timeframe90D => '90天';

  @override
  String get timeframeAll => '全部';

  @override
  String get history => '记录';

  @override
  String get seeAll => '查看全部';

  @override
  String get weightEntryDeleted => '体重记录已删除';

  @override
  String get weightUpdated => '体重已更新';

  @override
  String get editWeight => '编辑体重';

  @override
  String get recordWeight => '记录体重';

  @override
  String get quickAdjust => '快速调整';

  @override
  String get goalWeightSet => '目标体重已设置';

  @override
  String get goalWeightRemoved => '目标体重已移除';

  @override
  String get goalAchieved => '目标达成！';

  @override
  String get goalMatchesCurrentWeight => '目标与当前体重一致';

  @override
  String get setGoal => '设置目标';

  @override
  String get suggested => '建议';

  @override
  String get removeGoal => '移除目标';

  @override
  String get addOneMoreRecordToSeeTrend => '再添加1条记录以查看您的趋势';

  @override
  String get noWeightRecorded => '尚未记录体重';

  @override
  String get startTrackingYourWeight => '开始记录您的体重以在此查看进度';

  @override
  String get treadmillSession => '跑步机会话';

  @override
  String get bikeSession => '自行车会话';

  @override
  String get stairmasterSession => '爬楼机会话';

  @override
  String get treadmillWorkout => '跑步机训练';

  @override
  String get bikeWorkout => '自行车训练';

  @override
  String get stairmasterWorkout => '爬楼机训练';

  @override
  String get startAWorkoutToSeeItHere => '开始训练以在此查看';

  @override
  String get mon => '周一';

  @override
  String get tue => '周二';

  @override
  String get wed => '周三';

  @override
  String get thu => '周四';

  @override
  String get fri => '周五';

  @override
  String get sat => '周六';

  @override
  String get sun => '周日';

  @override
  String get sessions => '会话';

  @override
  String get distance => '距离';

  @override
  String get today => '今天';

  @override
  String get yesterday => '昨天';

  @override
  String get noWorkoutsYet => '还没有训练记录';

  @override
  String get startYourFirstWorkout => '开始您的第一次训练以在此查看您的记录';

  @override
  String get goToRoutines => '前往例程';

  @override
  String get weightRecorded => '体重已记录';

  @override
  String get workout => '训练';

  @override
  String get workouts => '训练';

  @override
  String get goal => '目标';

  @override
  String get toGo => '剩余';

  @override
  String get over => '超过';

  @override
  String get last => '上次';

  @override
  String get newLabel => '新的';

  @override
  String youNeed(String amount, String goal) {
    return '您需要$amount才能达到$goal';
  }

  @override
  String youNeedPlus(String amount, String goal) {
    return '您需要+$amount才能达到$goal';
  }

  @override
  String get current => '当前';

  @override
  String get premiumHeadline => '同样的30分钟，不同的结果';

  @override
  String get premiumSubheadlineNew => '不要只是跑步，以燃脂的方式运动';

  @override
  String get mostPopular => '最受欢迎';

  @override
  String dailyPrice(int price) {
    return '每天$price元';
  }

  @override
  String get benefitVoiceCoaching => '高级语音指导系统';

  @override
  String get benefitCycleStairmasterRoutines => '全面支持所有有氧器械';

  @override
  String get benefitUnlimitedRoutinesNew => '无限训练库';

  @override
  String get benefitWeightFeature => '智能体重追踪与分析';

  @override
  String get benefitNoAdsFocus => '无广告高级体验';

  @override
  String get benefitFutureFeaturesNew => '包含所有未来高级功能';

  @override
  String get mostChosen => '最常选择';

  @override
  String get canChangeAnytime => '可随时更改';

  @override
  String get startPremium => '开始高级版';

  @override
  String get cancelAnytimeKeepAccess => '随时可取消，在期间结束前仍可使用';

  @override
  String workoutDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '运动 $count 天 🔥',
      one: '运动 1 天 🔥',
    );
    return '$_temp0';
  }

  @override
  String restDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '休息 $count 天 🛏️',
      one: '休息 1 天 🛏️',
    );
    return '$_temp0';
  }
}
