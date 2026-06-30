// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Interval Cardio';

  @override
  String get settingsTitle => '設定';

  @override
  String get language => '言語';

  @override
  String get system => 'システム';

  @override
  String get voiceGuide => '音声ガイド';

  @override
  String get audioNavigator => 'オーディオナビゲーター';

  @override
  String get soundEffects => 'サウンド効果';

  @override
  String get unitSetting => '単位設定';

  @override
  String get kmh => 'km/h';

  @override
  String get mph => 'mph';

  @override
  String get themeMode => 'ライト/ダークモード';

  @override
  String get light => 'ライト';

  @override
  String get dark => 'ダーク';

  @override
  String get smartwatchSync => 'スマートウォッチ同期';

  @override
  String get connectSmartwatch => 'スマートウォッチに接続';

  @override
  String get connect => '接続';

  @override
  String get about => 'について';

  @override
  String version(String version) {
    return 'バージョン $version';
  }

  @override
  String get comingSoon => '近日公開';

  @override
  String get translationComingSoon => '翻訳は今後のアップデートで利用可能になります。';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'キャンセル';

  @override
  String get done => '完了';

  @override
  String get delete => '削除';

  @override
  String get save => '保存';

  @override
  String get edit => '編集';

  @override
  String get start => '開始';

  @override
  String get editRoutine => 'ルーティンを編集';

  @override
  String get routineEdit => 'ルーティン編集';

  @override
  String get name => '名前';

  @override
  String get unnamedRoutine => '名前のないルーティン';

  @override
  String get difficulty => '難易度';

  @override
  String difficultyColon(String difficulty) {
    return '難易度 : $difficulty';
  }

  @override
  String get easy => '簡単';

  @override
  String get medium => '中程度';

  @override
  String get hard => '難しい';

  @override
  String get interval => 'インターバル';

  @override
  String get addInterval => 'インターバルを追加';

  @override
  String get noIntervals => 'インターバルがありません';

  @override
  String get addIntervalPrompt => 'インターバルを追加してください';

  @override
  String get intervalEdit => 'インターバル編集';

  @override
  String get timeMinutes => '時間（分）';

  @override
  String get duration => '時間';

  @override
  String get speed => '速度';

  @override
  String get speedKmh => '速度（km/h）';

  @override
  String get incline => '傾斜';

  @override
  String get level => 'レベル';

  @override
  String levelColon(int level) {
    return 'レベル $level';
  }

  @override
  String get rpm => 'RPM';

  @override
  String get resistance => '抵抗';

  @override
  String get resistanceLevel => '抵抗（レベル）';

  @override
  String resistanceColon(int resistance) {
    return '抵抗 $resistance';
  }

  @override
  String get spm => 'SPM';

  @override
  String get spmSteps => 'SPM（ステップ/分）';

  @override
  String get saved => '保存済み';

  @override
  String get deleted => '削除されました';

  @override
  String get deleteRoutineTitle => 'ルーティンを削除';

  @override
  String get deleteRoutineMessage => 'このルーティンを削除してもよろしいですか？この操作は元に戻せません。';

  @override
  String get deleteError => '削除中にエラーが発生しました';

  @override
  String get nameRequired => '名前を入力してください';

  @override
  String get nameMaxLength => '名前は24文字以下である必要があります';

  @override
  String get minIntervalsRequired => '少なくとも1つのインターバルが必要です';

  @override
  String get intervalMinDuration => 'インターバルの時間は少なくとも1秒である必要があります';

  @override
  String get intervalMaxDuration => 'インターバルの時間は最大3時間（10800秒）まで可能です';

  @override
  String get speedRange => '速度は0より大きい値である必要があります（0.5-25.0 km/h）';

  @override
  String get inclineRange => '傾斜は0-15.0の範囲である必要があります';

  @override
  String get rpmRange => 'RPMは30-200の範囲である必要があります';

  @override
  String get resistanceRange => '抵抗は1-20の範囲である必要があります';

  @override
  String get levelRange => 'レベルは1-20の範囲である必要があります';

  @override
  String get spmRange => 'SPMは50-200の範囲である必要があります';

  @override
  String get noRoutinesSaved => '保存されたルーティンがありません';

  @override
  String get tapToCreate => 'タップして作成';

  @override
  String get tapButtonToCreate => 'ボタンをタップして作成';

  @override
  String get premiumRoutineSettings => 'プレミアムルーティン設定';

  @override
  String get viewMembership => 'メンバーシップを表示';

  @override
  String get freeLimitTitle => '無料制限は2つのルーティンまで';

  @override
  String get freeLimitMessage => 'メンバーシップで無制限のルーティンを使用できます';

  @override
  String get treadmill => 'ランニングマシン';

  @override
  String get cycle => 'サイクル';

  @override
  String get stairmaster => 'ステアマスター';

  @override
  String get selectLanguage => '言語を選択';

  @override
  String get selectTheme => 'テーマを選択';

  @override
  String get selectDifficulty => '難易度を選択';

  @override
  String get pause => '一時停止';

  @override
  String get resume => '再開';

  @override
  String get endWorkout => 'ワークアウト終了';

  @override
  String get endWorkoutConfirm => 'ワークアウトを終了しますか？';

  @override
  String get end => '終了';

  @override
  String get share => '共有';

  @override
  String get rotate => '回転';

  @override
  String get paused => '一時停止中';

  @override
  String get pausedTitle => '一時停止中';

  @override
  String get pausedSubtitle => '続けるか、ワークアウトを終了できます';

  @override
  String get endWorkoutConfirmationMessage =>
      '終了すると、現在進行中のワークアウトが終了し、要約画面に移動します。';

  @override
  String get workoutComplete => 'ワークアウト完了';

  @override
  String get totalWorkoutTime => '合計時間';

  @override
  String get totalDistance => '総距離';

  @override
  String get totalTime => '合計時間';

  @override
  String get averageRpm => '平均RPM';

  @override
  String get averageLevel => '平均レベル';

  @override
  String get holdToStop => '長押しで停止';

  @override
  String get continueWorkout => '続ける';

  @override
  String get endWorkoutQuestion => 'ワークアウトを終了しますか？';

  @override
  String get workoutPaused => 'ワークアウトが一時停止されました';

  @override
  String get lvlIncline => '傾斜';

  @override
  String get lvlResistance => 'レベル抵抗';

  @override
  String get premium => 'プレミアム';

  @override
  String get upgradeNow => '今すぐアップグレード';

  @override
  String get purchase => '購入';

  @override
  String get later => '後で';

  @override
  String get premiumActivated => 'プレミアムが有効になりました';

  @override
  String get premiumMembership => 'プレミアムメンバーシップ';

  @override
  String get benefitCycleStairmaster => 'サイクル、ステアマスター機能';

  @override
  String get benefitVoiceGuide => 'セッション音声ガイド機能';

  @override
  String get benefitUnlimitedRoutines => '無制限のルーティン保存';

  @override
  String get noAds => '広告なし';

  @override
  String get benefitFutureFeatures => '将来の機能への無制限アクセス';

  @override
  String get voiceGuideBenefit1 => 'ワークアウト中の音声ガイド';

  @override
  String get voiceGuideBenefit2 => 'セッション遷移の自動アナウンス';

  @override
  String get voiceGuideBenefit3 => 'ハンズフリーでルーティンに集中';

  @override
  String get routineLimitBenefit1 => '無制限のルーティン保存';

  @override
  String get routineLimitBenefit2 => '複数の目標別ルーティン保存';

  @override
  String get routineLimitBenefit3 => 'すべてのマシンタイプを使用（ランニングマシン/バイク/ステアマスター）';

  @override
  String get premium_benefit_1 => '<red>バイク＆StairMaster</red>対応';

  @override
  String get premium_benefit_2 => 'セッション <red>音声ガイド</red>';

  @override
  String get premium_benefit_3 => 'ルーティン保存数 <red>無制限</red>';

  @override
  String get premium_benefit_4 => '今後の機能に <red>無制限アクセス</red>';

  @override
  String originalPrice(String price) {
    return '$price';
  }

  @override
  String monthlyPrice(String price) {
    return '$price/月';
  }

  @override
  String get premiumSubheadline => '音声ガイド、バイクとステアマスターのワークアウト、無制限のルーティンのロック解除';

  @override
  String get monthly => '月額';

  @override
  String get yearly => '年額';

  @override
  String get lifetime => '生涯';

  @override
  String get freeTrial7Days => '7日間無料トライアル';

  @override
  String get perMonth => '/月';

  @override
  String get perYear => '/年';

  @override
  String get oneTime => '1回限りの支払い';

  @override
  String savePercent(int percent) {
    return '$percent% 節約';
  }

  @override
  String get bestValue => 'ベストバリュー';

  @override
  String get cancelAnytime => 'いつでもキャンセル可能';

  @override
  String get autoRenewableSubscription => '自動更新サブスクリプション';

  @override
  String get terms => '利用規約';

  @override
  String get privacy => 'プライバシー';

  @override
  String get restore => '復元';

  @override
  String get premiumTab => 'プレミアム';

  @override
  String get routineTab => 'ルーティン';

  @override
  String get settingsTab => '設定';

  @override
  String get myTab => 'マイ';

  @override
  String get close => '閉じる';

  @override
  String get premiumFeature => 'プレミアム機能です';

  @override
  String get usePremiumTest => 'プレミアムを使用する（テスト）';

  @override
  String dateTimeFormat(int year, int month, int day, int hour, int minute) {
    return '$year年$month月$day日 $hour時$minute分';
  }

  @override
  String get checkRoutineStart => 'ルーティンを確認 / 開始';

  @override
  String get beginner => '初級';

  @override
  String get intermediate => '中級';

  @override
  String get advanced => '上級';

  @override
  String get viewRecommendedRoutines => 'おすすめ →';

  @override
  String get recommendedRoutinesTreadmill => 'おすすめランニングマシンルーティン';

  @override
  String get recommendedRoutinesCycle => 'おすすめバイクルーティン';

  @override
  String get recommendedRoutinesStairmaster => 'おすすめステアマスタールーティン';

  @override
  String get alreadySaved => '既に保存済み';

  @override
  String get routineSaved => 'ルーティンが保存されました';

  @override
  String get checkRoutine => '確認';

  @override
  String get saveRoutine => 'ルーティンを保存';

  @override
  String get routineAlreadySaved => 'ルーティンは既に保存されています';

  @override
  String get noTemplatesFound => 'テンプレートが見つかりません';

  @override
  String get avg => '平均';

  @override
  String get avgRpm => '平均 RPM';

  @override
  String get avgLevel => '平均レベル';

  @override
  String get templateTreadmillBeginner1Title => 'イージースタート20';

  @override
  String get templateTreadmillBeginner1Subtitle => '3分ウォームアップ＋1:1インターバル';

  @override
  String get templateTreadmillBeginner2Title => '傾斜ウォーク25';

  @override
  String get templateTreadmillBeginner2Subtitle => '傾斜ウォークのブロック';

  @override
  String get templateTreadmillIntermediate1Title => 'クラシック1:1 24';

  @override
  String get templateTreadmillIntermediate1Subtitle => 'クラシックな1:1インターバル';

  @override
  String get templateTreadmillIntermediate2Title => 'スピードラダー20';

  @override
  String get templateTreadmillIntermediate2Subtitle => 'スピードラダー（徐々に加速）';

  @override
  String get templateTreadmillAdvanced1Title => '2:1バーナー21';

  @override
  String get templateTreadmillAdvanced1Subtitle => '2:1インターバル（きつい/楽）';

  @override
  String get templateTreadmillAdvanced2Title => 'スプリントポップ18';

  @override
  String get templateTreadmillAdvanced2Subtitle => '20秒スプリント反復';

  @override
  String get templateCycleBeginner1Title => 'ケイデンスビルダー20';

  @override
  String get templateCycleBeginner1Subtitle => '4分ウォームアップ＋ケイデンス1:1';

  @override
  String get templateCycleBeginner2Title => 'ステディライド25';

  @override
  String get templateCycleBeginner2Subtitle => '長めの一定ブロック';

  @override
  String get templateCycleIntermediate1Title => 'スピン1:1 24';

  @override
  String get templateCycleIntermediate1Subtitle => 'クラシックな1:1スピンインターバル';

  @override
  String get templateCycleIntermediate2Title => 'ヒルシミュレーション22';

  @override
  String get templateCycleIntermediate2Subtitle => '登りの反復';

  @override
  String get templateCycleAdvanced1Title => 'パワーインターバル20';

  @override
  String get templateCycleAdvanced1Subtitle => '30秒パワーバースト';

  @override
  String get templateCycleAdvanced2Title => 'タバタミックス16';

  @override
  String get templateCycleAdvanced2Subtitle => '20秒/10秒ミックス';

  @override
  String get templateStairmasterBeginner1Title => 'イージーステップ20';

  @override
  String get templateStairmasterBeginner1Subtitle => '4分ウォームアップ＋1:1ステップ';

  @override
  String get templateStairmasterBeginner2Title => 'ロングイージー25';

  @override
  String get templateStairmasterBeginner2Subtitle => '長めのイージーブロック';

  @override
  String get templateStairmasterIntermediate1Title => '2:1クライム21';

  @override
  String get templateStairmasterIntermediate1Subtitle => '2:1クライム反復';

  @override
  String get templateStairmasterIntermediate2Title => 'ストロング1:1 24';

  @override
  String get templateStairmasterIntermediate2Subtitle => '強めの1:1インターバル';

  @override
  String get templateStairmasterAdvanced1Title => 'ハードブロック20';

  @override
  String get templateStairmasterAdvanced1Subtitle => '2分ハードブロック';

  @override
  String get templateStairmasterAdvanced2Title => 'スプリントステップ18';

  @override
  String get templateStairmasterAdvanced2Subtitle => '30秒スプリント＋60秒回復';

  @override
  String get historyTab => '記録';

  @override
  String get calendarTab => 'カレンダー';

  @override
  String get weightTab => '体重';

  @override
  String get bike => 'サイクル';

  @override
  String get thisWeek => '今週';

  @override
  String get trend => '傾向';

  @override
  String get timeframe7D => '7日';

  @override
  String get timeframe30D => '30日';

  @override
  String get timeframe90D => '90日';

  @override
  String get timeframeAll => 'すべて';

  @override
  String get history => '記録';

  @override
  String get seeAll => 'すべて表示';

  @override
  String get weightEntryDeleted => '体重記録が削除されました';

  @override
  String get weightUpdated => '体重が更新されました';

  @override
  String get editWeight => '体重を編集';

  @override
  String get recordWeight => '体重を記録';

  @override
  String get quickAdjust => 'クイック調整';

  @override
  String get goalWeightSet => '目標体重が設定されました';

  @override
  String get goalWeightRemoved => '目標体重が削除されました';

  @override
  String get goalAchieved => '目標達成！';

  @override
  String get goalMatchesCurrentWeight => '目標が現在の体重と一致します';

  @override
  String get setGoal => '目標を設定';

  @override
  String get suggested => '推奨';

  @override
  String get removeGoal => '目標を削除';

  @override
  String get addOneMoreRecordToSeeTrend => '傾向を表示するには、もう1つ記録を追加してください';

  @override
  String get noWeightRecorded => 'まだ体重が記録されていません';

  @override
  String get startTrackingYourWeight => '体重を記録して、ここで進捗を確認してください';

  @override
  String get treadmillSession => 'ランニングマシンセッション';

  @override
  String get bikeSession => 'サイクルセッション';

  @override
  String get stairmasterSession => 'ステアマスターセッション';

  @override
  String get treadmillWorkout => 'ランニングマシン運動';

  @override
  String get bikeWorkout => 'サイクル運動';

  @override
  String get stairmasterWorkout => 'ステアマスター運動';

  @override
  String get startAWorkoutToSeeItHere => '運動を開始すると、ここに表示されます';

  @override
  String get mon => '月';

  @override
  String get tue => '火';

  @override
  String get wed => '水';

  @override
  String get thu => '木';

  @override
  String get fri => '金';

  @override
  String get sat => '土';

  @override
  String get sun => '日';

  @override
  String get sessions => 'セッション';

  @override
  String get distance => '距離';

  @override
  String get today => '今日';

  @override
  String get yesterday => '昨日';

  @override
  String get noWorkoutsYet => 'まだワークアウトがありません';

  @override
  String get startYourFirstWorkout => '最初のワークアウトを開始して、ここで履歴を確認してください';

  @override
  String get goToRoutines => 'ルーティンへ移動';

  @override
  String get weightRecorded => '体重が記録されました';

  @override
  String get workout => 'ワークアウト';

  @override
  String get workouts => 'ワークアウト';

  @override
  String get goal => '目標';

  @override
  String get toGo => '残り';

  @override
  String get over => '超過';

  @override
  String get last => '前回';

  @override
  String get newLabel => '新しい';

  @override
  String youNeed(String amount, String goal) {
    return '$goalに到達するには$amount必要です';
  }

  @override
  String youNeedPlus(String amount, String goal) {
    return '$goalに到達するには+$amount必要です';
  }

  @override
  String get current => '現在';

  @override
  String get premiumHeadline => '同じ30分、違う結果';

  @override
  String get premiumSubheadlineNew => 'ただ走るのではなく、脂肪燃焼の方法で運動する';

  @override
  String get mostPopular => '最も人気';

  @override
  String dailyPrice(int price) {
    return '1日$price円';
  }

  @override
  String get benefitVoiceCoaching => 'プレミアム音声コーチングシステム';

  @override
  String get benefitCycleStairmasterRoutines => 'すべての有酸素機器に完全対応';

  @override
  String get benefitUnlimitedRoutinesNew => '無制限ルーティンライブラリ';

  @override
  String get benefitWeightFeature => 'スマート体重追跡＆分析';

  @override
  String get benefitNoAdsFocus => '広告なしのプレミアム体験';

  @override
  String get benefitFutureFeaturesNew => '今後のプレミアム機能すべて含む';

  @override
  String get mostChosen => '最も選ばれている';

  @override
  String get canChangeAnytime => 'いつでも変更可能';

  @override
  String get startPremium => 'プレミアムを開始';

  @override
  String get cancelAnytimeKeepAccess => 'いつでもキャンセル可能で、期間終了までアクセス可能';

  @override
  String workoutDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'トレーニング $count 日 🔥',
      one: 'トレーニング 1 日 🔥',
    );
    return '$_temp0';
  }

  @override
  String restDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '休息 $count 日 🛏️',
      one: '休息 1 日 🛏️',
    );
    return '$_temp0';
  }

  @override
  String get workoutReminderTitle => 'ワークアウト通知';

  @override
  String get workoutReminderOff => 'オフ';

  @override
  String get workoutReminderEveryDay => '毎日';

  @override
  String get workoutReminderSelectTime => '時刻を選択';

  @override
  String get workoutReminderPermissionRequired => '通知権限が必要です。';

  @override
  String get workoutReminderTimeLabel => '時刻';
}
