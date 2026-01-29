// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Interval Cardio';

  @override
  String get settingsTitle => '설정';

  @override
  String get language => '언어';

  @override
  String get system => '시스템';

  @override
  String get voiceGuide => '음성 가이드';

  @override
  String get audioNavigator => '오디오 네비게이터';

  @override
  String get soundEffects => '사운드 효과';

  @override
  String get unitSetting => '단위 설정';

  @override
  String get kmh => 'km/h';

  @override
  String get mph => 'mph';

  @override
  String get themeMode => '라이트 다크 모드';

  @override
  String get light => '라이트';

  @override
  String get dark => '다크';

  @override
  String get smartwatchSync => '스마트워치 Sync';

  @override
  String get connectSmartwatch => '스마트워치와 연결합니다';

  @override
  String get connect => '연결';

  @override
  String get about => 'About';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get comingSoon => '준비 중';

  @override
  String get translationComingSoon => '번역은 추후 업데이트 예정입니다.';

  @override
  String get ok => '확인';

  @override
  String get cancel => '취소';

  @override
  String get done => '완료';

  @override
  String get delete => '삭제';

  @override
  String get save => '저장';

  @override
  String get edit => '수정';

  @override
  String get start => '시작';

  @override
  String get editRoutine => '루틴 수정';

  @override
  String get routineEdit => '루틴 편집';

  @override
  String get name => '이름';

  @override
  String get unnamedRoutine => '이름 없는 루틴';

  @override
  String get difficulty => '난이도';

  @override
  String difficultyColon(String difficulty) {
    return '난이도 : $difficulty';
  }

  @override
  String get easy => '쉬움';

  @override
  String get medium => '중간';

  @override
  String get hard => '높음';

  @override
  String get interval => '인터벌';

  @override
  String get addInterval => '인터벌 추가';

  @override
  String get noIntervals => '인터벌이 없습니다';

  @override
  String get addIntervalPrompt => '인터벌을 추가하세요';

  @override
  String get intervalEdit => '인터벌 편집';

  @override
  String get timeMinutes => '시간(분)';

  @override
  String get duration => '시간';

  @override
  String get speed => '속도';

  @override
  String get speedKmh => '속도(km/h)';

  @override
  String get incline => '경사도';

  @override
  String get level => '레벨';

  @override
  String levelColon(int level) {
    return '레벨 $level';
  }

  @override
  String get rpm => 'RPM';

  @override
  String get resistance => '저항';

  @override
  String get resistanceLevel => '저항(레벨)';

  @override
  String resistanceColon(int resistance) {
    return '저항 $resistance';
  }

  @override
  String get spm => 'SPM';

  @override
  String get spmSteps => 'SPM(steps/min)';

  @override
  String get saved => '저장됨';

  @override
  String get deleted => '삭제됨';

  @override
  String get deleteRoutineTitle => '루틴 삭제';

  @override
  String get deleteRoutineMessage => '이 루틴을 삭제할까요? 삭제하면 되돌릴 수 없어요.';

  @override
  String get deleteError => '삭제 중 오류가 발생했습니다';

  @override
  String get nameRequired => '이름을 입력해주세요';

  @override
  String get nameMaxLength => '이름은 24자 이하여야 합니다';

  @override
  String get minIntervalsRequired => '최소 하나의 인터벌이 필요합니다';

  @override
  String get intervalMinDuration => '인터벌 시간은 최소 1초 이상이어야 합니다';

  @override
  String get intervalMaxDuration => '인터벌 시간은 최대 3시간(10800초)까지 가능합니다';

  @override
  String get speedRange => '속도는 0보다 큰 값이어야 합니다 (0.5-25.0 km/h)';

  @override
  String get inclineRange => '경사도는 0-15.0 범위여야 합니다';

  @override
  String get rpmRange => 'RPM은 30-200 범위여야 합니다';

  @override
  String get resistanceRange => '저항은 1-20 범위여야 합니다';

  @override
  String get levelRange => '레벨은 1-20 범위여야 합니다';

  @override
  String get spmRange => 'SPM은 50-200 범위여야 합니다';

  @override
  String get noRoutinesSaved => '저장된 루틴이 없습니다';

  @override
  String get tapToCreate => '화면을 터치해 생성하기';

  @override
  String get tapButtonToCreate => '버튼을 터치해 생성하기';

  @override
  String get premiumRoutineSettings => '프리미엄 루틴 설정';

  @override
  String get viewMembership => '멤버십 보기';

  @override
  String get freeLimitTitle => '무료는 루틴 2개까지';

  @override
  String get freeLimitMessage => '멤버십으로 무제한 루틴을 사용할 수 있어요';

  @override
  String get treadmill => '러닝머신';

  @override
  String get cycle => '사이클';

  @override
  String get stairmaster => '천국의 계단';

  @override
  String get selectLanguage => '언어 선택';

  @override
  String get selectTheme => '테마 선택';

  @override
  String get selectDifficulty => '난이도 선택';

  @override
  String get pause => '일시중지';

  @override
  String get resume => '계속하기';

  @override
  String get endWorkout => '운동 종료';

  @override
  String get endWorkoutConfirm => '운동을 종료하시겠습니까?';

  @override
  String get end => '종료';

  @override
  String get rotate => '회전';

  @override
  String get paused => '일시중지됨';

  @override
  String get pausedTitle => '일시정지됨';

  @override
  String get pausedSubtitle => '계속하거나 운동을 종료할 수 있어요';

  @override
  String get endWorkoutConfirmationMessage =>
      '종료하면 현재 진행 중인 운동이 끝나고 요약 화면으로 이동해요.';

  @override
  String get workoutComplete => 'Workout Complete';

  @override
  String get totalWorkoutTime => '총 운동 시간';

  @override
  String get totalDistance => '총 거리';

  @override
  String get averageRpm => '평균 RPM';

  @override
  String get averageLevel => '평균 레벨';

  @override
  String get holdToStop => 'Hold to Stop';

  @override
  String get continueWorkout => '계속';

  @override
  String get endWorkoutQuestion => '운동을 종료할까요?';

  @override
  String get workoutPaused => '운동이 일시중지되었습니다';

  @override
  String get lvlIncline => '경사도';

  @override
  String get lvlResistance => '저항';

  @override
  String get premium => '프리미엄';

  @override
  String get upgradeNow => '지금 당장 업그레이드 하기';

  @override
  String get purchase => '구매하기';

  @override
  String get later => '나중에';

  @override
  String get premiumActivated => '프리미엄이 활성화되었습니다';

  @override
  String get premiumMembership => '프리미엄 멤버십';

  @override
  String get benefitCycleStairmaster => '사이클, 천국의 계단 기능';

  @override
  String get benefitVoiceGuide => '세션 음성 가이드 기능';

  @override
  String get benefitUnlimitedRoutines => '루틴 저장 수 무제한';

  @override
  String get noAds => '광고 없음';

  @override
  String get benefitFutureFeatures => '추후 기능 무제한 접근 가능';

  @override
  String get voiceGuideBenefit1 => '운동 중 음성 안내';

  @override
  String get voiceGuideBenefit2 => '세션 전환 자동 안내';

  @override
  String get voiceGuideBenefit3 => '핸즈프리로 루틴 집중';

  @override
  String get routineLimitBenefit1 => '루틴 저장 수 무제한';

  @override
  String get routineLimitBenefit2 => '여러 목표별 루틴 저장';

  @override
  String get routineLimitBenefit3 => '러닝머신/사이클/천국의 계단 루틴 모두 사용';

  @override
  String get premium_benefit_1 => '<red>사이클, 천국의 계단</red> 기능';

  @override
  String get premium_benefit_2 => '세션 <red>음성 가이드</red> 기능';

  @override
  String get premium_benefit_3 => '루틴 저장 수 <red>무제한</red>';

  @override
  String get premium_benefit_4 => '추후 기능 <red>무제한 접근</red> 가능';

  @override
  String originalPrice(String price) {
    return '$price';
  }

  @override
  String monthlyPrice(String price) {
    return '$price/월';
  }

  @override
  String get premiumSubheadline => '음성 가이드, 사이클 및 천국의 계단 운동, 무제한 루틴 잠금 해제';

  @override
  String get monthly => '월간';

  @override
  String get yearly => '연간';

  @override
  String get lifetime => '평생';

  @override
  String get perMonth => '/월';

  @override
  String get perYear => '/년';

  @override
  String get oneTime => '일회성';

  @override
  String savePercent(int percent) {
    return '$percent% 절약';
  }

  @override
  String get bestValue => '최고의 가치';

  @override
  String get cancelAnytime => '언제든지 취소 가능';

  @override
  String get autoRenewableSubscription => '자동 갱신 구독';

  @override
  String get terms => '약관';

  @override
  String get privacy => '개인정보처리방침';

  @override
  String get restore => '복원';

  @override
  String get premiumTab => '프리미엄';

  @override
  String get routineTab => '루틴';

  @override
  String get settingsTab => '설정';

  @override
  String get myTab => '나';

  @override
  String get close => '닫기';

  @override
  String get premiumFeature => '프리미엄 기능입니다';

  @override
  String get usePremiumTest => '프리미엄 사용하기(테스트)';

  @override
  String dateTimeFormat(int year, int month, int day, int hour, int minute) {
    return '$year년 $month월 $day일 $hour시 $minute분';
  }

  @override
  String get checkRoutineStart => '루틴 확인 / 시작';

  @override
  String get beginner => '초급';

  @override
  String get intermediate => '중급';

  @override
  String get advanced => '고급';

  @override
  String get viewRecommendedRoutines => '추천 루틴 보러가기 →';

  @override
  String get recommendedRoutinesTreadmill => '러닝머신 추천 루틴';

  @override
  String get recommendedRoutinesCycle => '사이클 추천 루틴';

  @override
  String get recommendedRoutinesStairmaster => '천국의 계단 추천 루틴';

  @override
  String get alreadySaved => '이미 저장되었습니다';

  @override
  String get routineSaved => '루틴이 저장되었습니다';

  @override
  String get checkRoutine => '확인';

  @override
  String get saveRoutine => '루틴 저장';

  @override
  String get routineAlreadySaved => '이미 저장된 루틴이야';

  @override
  String get noTemplatesFound => '템플릿을 찾을 수 없습니다';

  @override
  String get avg => '평균';

  @override
  String get avgRpm => '평균 RPM';

  @override
  String get avgLevel => '평균 레벨';

  @override
  String get templateTreadmillBeginner1Title => '이지 스타트 20';

  @override
  String get templateTreadmillBeginner1Subtitle => '3분 워밍업 + 1:1 인터벌';

  @override
  String get templateTreadmillBeginner2Title => '인클라인 워크 25';

  @override
  String get templateTreadmillBeginner2Subtitle => '경사 워킹 블록 반복';

  @override
  String get templateTreadmillIntermediate1Title => '클래식 1:1 24';

  @override
  String get templateTreadmillIntermediate1Subtitle => '1:1 클래식 인터벌';

  @override
  String get templateTreadmillIntermediate2Title => '스피드 래더 20';

  @override
  String get templateTreadmillIntermediate2Subtitle => '스피드 래더(점점 빨라짐)';

  @override
  String get templateTreadmillAdvanced1Title => '2:1 버너 21';

  @override
  String get templateTreadmillAdvanced1Subtitle => '2:1 고강도 인터벌';

  @override
  String get templateTreadmillAdvanced2Title => '스프린트 팝 18';

  @override
  String get templateTreadmillAdvanced2Subtitle => '20초 스프린트 반복';

  @override
  String get templateCycleBeginner1Title => '케이던스 빌더 20';

  @override
  String get templateCycleBeginner1Subtitle => '4분 워밍업 + 1:1 케이던스';

  @override
  String get templateCycleBeginner2Title => '스테디 라이드 25';

  @override
  String get templateCycleBeginner2Subtitle => '롱 스테디 라이딩';

  @override
  String get templateCycleIntermediate1Title => '스핀 1:1 24';

  @override
  String get templateCycleIntermediate1Subtitle => '1:1 스핀 인터벌';

  @override
  String get templateCycleIntermediate2Title => '힐 시뮬레이션 22';

  @override
  String get templateCycleIntermediate2Subtitle => '힐 반복 블록';

  @override
  String get templateCycleAdvanced1Title => '파워 인터벌 20';

  @override
  String get templateCycleAdvanced1Subtitle => '30초 파워 버스트';

  @override
  String get templateCycleAdvanced2Title => '타바타 믹스 16';

  @override
  String get templateCycleAdvanced2Subtitle => '20초/10초 타바타 믹스';

  @override
  String get templateStairmasterBeginner1Title => '이지 스텝스 20';

  @override
  String get templateStairmasterBeginner1Subtitle => '4분 워밍업 + 1:1 스텝';

  @override
  String get templateStairmasterBeginner2Title => '롱 이지 25';

  @override
  String get templateStairmasterBeginner2Subtitle => '롱 이지 블록';

  @override
  String get templateStairmasterIntermediate1Title => '2:1 클라임 21';

  @override
  String get templateStairmasterIntermediate1Subtitle => '2:1 클라임 반복';

  @override
  String get templateStairmasterIntermediate2Title => '스트롱 1:1 24';

  @override
  String get templateStairmasterIntermediate2Subtitle => '1:1 스트롱 인터벌';

  @override
  String get templateStairmasterAdvanced1Title => '하드 블록 20';

  @override
  String get templateStairmasterAdvanced1Subtitle => '2분 하드 블록';

  @override
  String get templateStairmasterAdvanced2Title => '스프린트 스텝스 18';

  @override
  String get templateStairmasterAdvanced2Subtitle => '30초 스프린트 + 60초 회복';

  @override
  String get historyTab => '기록';

  @override
  String get calendarTab => '캘린더';

  @override
  String get weightTab => '체중';

  @override
  String get bike => '사이클';

  @override
  String get thisWeek => '이번 주';

  @override
  String get trend => '추세';

  @override
  String get timeframe7D => '7일';

  @override
  String get timeframe30D => '30일';

  @override
  String get timeframe90D => '90일';

  @override
  String get timeframeAll => '전체';

  @override
  String get history => '기록';

  @override
  String get seeAll => '전체 보기';

  @override
  String get weightEntryDeleted => '체중 기록이 삭제되었습니다';

  @override
  String get weightUpdated => '체중이 업데이트되었습니다';

  @override
  String get editWeight => '체중 수정';

  @override
  String get recordWeight => '체중 기록';

  @override
  String get quickAdjust => '빠른 조정';

  @override
  String get goalWeightSet => '목표 체중이 설정되었습니다';

  @override
  String get goalWeightRemoved => '목표 체중이 제거되었습니다';

  @override
  String get goalAchieved => '목표 달성!';

  @override
  String get goalMatchesCurrentWeight => '목표가 현재 체중과 일치합니다';

  @override
  String get setGoal => '목표 설정';

  @override
  String get suggested => '추천';

  @override
  String get removeGoal => '목표 제거';

  @override
  String get addOneMoreRecordToSeeTrend => '추세를 보려면 1개 더 기록하세요';

  @override
  String get noWeightRecorded => '아직 체중이 기록되지 않았습니다';

  @override
  String get startTrackingYourWeight => '체중을 기록하여 진행 상황을 확인하세요';

  @override
  String get treadmillSession => '러닝머신 세션';

  @override
  String get bikeSession => '사이클 세션';

  @override
  String get stairmasterSession => '천국의 계단 세션';

  @override
  String get treadmillWorkout => '러닝머신 운동';

  @override
  String get bikeWorkout => '사이클 운동';

  @override
  String get stairmasterWorkout => '천국의 계단 운동';

  @override
  String get startAWorkoutToSeeItHere => '운동을 시작하면 여기에 표시됩니다';

  @override
  String get mon => '월';

  @override
  String get tue => '화';

  @override
  String get wed => '수';

  @override
  String get thu => '목';

  @override
  String get fri => '금';

  @override
  String get sat => '토';

  @override
  String get sun => '일';

  @override
  String get sessions => '세션';

  @override
  String get distance => '거리';

  @override
  String get today => '오늘';

  @override
  String get yesterday => '어제';

  @override
  String get noWorkoutsYet => '아직 운동 기록이 없습니다';

  @override
  String get startYourFirstWorkout => '첫 운동을 시작하여 기록을 확인하세요';

  @override
  String get goToRoutines => '루틴으로 이동';

  @override
  String get weightRecorded => '체중이 기록되었습니다';

  @override
  String get workout => '운동';

  @override
  String get workouts => '운동';

  @override
  String get goal => '목표';

  @override
  String get toGo => '남음';

  @override
  String get over => '초과';

  @override
  String get last => '이전';

  @override
  String get newLabel => '새로운';

  @override
  String youNeed(String amount, String goal) {
    return '$amount만큼 더 해야 $goal에 도달합니다';
  }

  @override
  String youNeedPlus(String amount, String goal) {
    return '+$amount만큼 더 해야 $goal에 도달합니다';
  }

  @override
  String get current => '현재';

  @override
  String get premiumHeadline => '같은 30분, 결과는 다르게';

  @override
  String get premiumSubheadlineNew => '그냥 뛰지 말고, 살 빠지는 방식으로 운동해';

  @override
  String get mostPopular => '가장 인기';

  @override
  String dailyPrice(int price) {
    return '하루 $price원';
  }

  @override
  String get benefitVoiceCoaching => '프리미엄 음성 코칭 시스템';

  @override
  String get benefitCycleStairmasterRoutines => '모든 유산소 기구 완벽 지원';

  @override
  String get benefitUnlimitedRoutinesNew => '무제한 루틴 라이브러리';

  @override
  String get benefitWeightFeature => '스마트 체중 추적 & 분석';

  @override
  String get benefitNoAdsFocus => '광고 없는 프리미엄 경험';

  @override
  String get benefitFutureFeaturesNew => '추후 프리미엄 기능 전체 포함';

  @override
  String get mostChosen => '가장 많이 선택됨';

  @override
  String get canChangeAnytime => '언제든지 변경 가능';

  @override
  String get startPremium => '프리미엄 시작하기';

  @override
  String get cancelAnytimeKeepAccess => '결제 후 바로 해지해도 기간 끝까지 이용 가능';

  @override
  String workoutDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '운동 $count일 🔥',
      one: '운동 1일 🔥',
    );
    return '$_temp0';
  }

  @override
  String restDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '휴식 $count일 🛏️',
      one: '휴식 1일 🛏️',
    );
    return '$_temp0';
  }
}
