// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'Interval Cardio';

  @override
  String get settingsTitle => 'ตั้งค่า';

  @override
  String get language => 'ภาษา';

  @override
  String get system => 'ระบบ';

  @override
  String get voiceGuide => 'ไกด์เสียง';

  @override
  String get audioNavigator => 'ตัวนำทางเสียง';

  @override
  String get soundEffects => 'เอฟเฟกต์เสียง';

  @override
  String get unitSetting => 'การตั้งค่าหน่วย';

  @override
  String get kmh => 'กม./ชม.';

  @override
  String get mph => 'mph';

  @override
  String get themeMode => 'โหมดสว่าง/มืด';

  @override
  String get light => 'โหมดสว่าง';

  @override
  String get dark => 'โหมดมืด';

  @override
  String get smartwatchSync => 'Smartwatch Sync';

  @override
  String get connectSmartwatch => 'เชื่อมต่อสมาร์ทวอทช์';

  @override
  String get connect => 'เชื่อมต่อ';

  @override
  String get about => 'เกี่ยวกับ';

  @override
  String version(String version) {
    return 'เวอร์ชัน $version';
  }

  @override
  String get comingSoon => 'เร็วๆ นี้';

  @override
  String get translationComingSoon => 'จะมีคำแปลในอัปเดตถัดไป';

  @override
  String get ok => 'ตกลง';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get done => 'เสร็จสิ้น';

  @override
  String get delete => 'ลบ';

  @override
  String get save => 'บันทึก';

  @override
  String get edit => 'แก้ไข';

  @override
  String get start => 'เริ่ม';

  @override
  String get editRoutine => 'แก้ไขรูทีน';

  @override
  String get routineEdit => 'แก้ไขรูทีน';

  @override
  String get name => 'ชื่อ';

  @override
  String get unnamedRoutine => 'รูทีนไม่มีชื่อ';

  @override
  String get difficulty => 'ความยาก';

  @override
  String difficultyColon(String difficulty) {
    return 'ความยาก : $difficulty';
  }

  @override
  String get easy => 'ง่าย';

  @override
  String get medium => 'ปานกลาง';

  @override
  String get hard => 'ยาก';

  @override
  String get interval => 'อินเทอร์วัล';

  @override
  String get addInterval => 'เพิ่มอินเทอร์วัล';

  @override
  String get noIntervals => 'ไม่มีอินเทอร์วัล';

  @override
  String get addIntervalPrompt => 'เพิ่มอินเทอร์วัล';

  @override
  String get intervalEdit => 'แก้ไขอินเทอร์วัล';

  @override
  String get timeMinutes => 'เวลา (นาที)';

  @override
  String get duration => 'ระยะเวลา';

  @override
  String get speed => 'ความเร็ว';

  @override
  String get speedKmh => 'ความเร็ว (กม./ชม.)';

  @override
  String get incline => 'ความชัน';

  @override
  String get level => 'ระดับ';

  @override
  String levelColon(int level) {
    return 'ระดับ $level';
  }

  @override
  String get rpm => 'RPM';

  @override
  String get resistance => 'แรงต้าน';

  @override
  String get resistanceLevel => 'แรงต้าน (ระดับ)';

  @override
  String resistanceColon(int resistance) {
    return 'แรงต้าน $resistance';
  }

  @override
  String get spm => 'SPM';

  @override
  String get spmSteps => 'SPM (ก้าว/นาที)';

  @override
  String get saved => 'บันทึกแล้ว';

  @override
  String get deleted => 'ลบแล้ว';

  @override
  String get deleteRoutineTitle => 'ลบรูทีน';

  @override
  String get deleteRoutineMessage =>
      'คุณแน่ใจหรือไม่ว่าต้องการลบรูทีนนี้? การดำเนินการนี้ไม่สามารถยกเลิกได้';

  @override
  String get deleteError => 'เกิดข้อผิดพลาดขณะลบ';

  @override
  String get nameRequired => 'กรุณาใส่ชื่อ';

  @override
  String get nameMaxLength => 'ชื่อต้องยาวไม่เกิน 24 ตัวอักษร';

  @override
  String get minIntervalsRequired => 'ต้องมีอย่างน้อย 1 อินเทอร์วัล';

  @override
  String get intervalMinDuration => 'ระยะเวลาอินเทอร์วัลต้องอย่างน้อย 1 วินาที';

  @override
  String get intervalMaxDuration =>
      'ระยะเวลาอินเทอร์วัลต้องไม่เกิน 3 ชั่วโมง (10800 วินาที)';

  @override
  String get speedRange => 'ความเร็วต้องมากกว่า 0 (0.5–25.0 กม./ชม.)';

  @override
  String get inclineRange => 'ความชันต้องอยู่ในช่วง 0-15.0';

  @override
  String get rpmRange => 'RPM ต้องอยู่ในช่วง 30-200';

  @override
  String get resistanceRange => 'แรงต้านต้องอยู่ในช่วง 1-20';

  @override
  String get levelRange => 'ระดับต้องอยู่ในช่วง 1-20';

  @override
  String get spmRange => 'SPM ต้องอยู่ในช่วง 50-200';

  @override
  String get noRoutinesSaved => 'ยังไม่มีรูทีนที่บันทึกไว้';

  @override
  String get tapToCreate => 'แตะเพื่อสร้าง';

  @override
  String get tapButtonToCreate => 'แตะปุ่มเพื่อสร้าง';

  @override
  String get premiumRoutineSettings => 'การตั้งค่ารูทีนพรีเมียม';

  @override
  String get viewMembership => 'ดูสมาชิก';

  @override
  String get freeLimitTitle => 'ขีดจำกัดฟรีคือ 2 รูทีน';

  @override
  String get freeLimitMessage => 'สมาชิกช่วยให้ใช้รูทีนได้ไม่จำกัด';

  @override
  String get treadmill => 'ลู่วิ่ง';

  @override
  String get cycle => 'จักรยาน';

  @override
  String get stairmaster => 'Stairmaster';

  @override
  String get selectLanguage => 'เลือกภาษา';

  @override
  String get selectTheme => 'เลือกธีม';

  @override
  String get selectDifficulty => 'เลือกความยาก';

  @override
  String get pause => 'หยุดชั่วคราว';

  @override
  String get resume => 'ทำต่อ';

  @override
  String get endWorkout => 'จบการออกกำลังกาย';

  @override
  String get endWorkoutConfirm => 'ต้องการจบการออกกำลังกายหรือไม่?';

  @override
  String get end => 'จบ';

  @override
  String get rotate => 'หมุน';

  @override
  String get paused => 'หยุดชั่วคราว';

  @override
  String get pausedTitle => 'หยุดชั่วคราว';

  @override
  String get pausedSubtitle => 'คุณสามารถทำต่อหรือจบการออกกำลังกายได้';

  @override
  String get endWorkoutConfirmationMessage =>
      'หากจบตอนนี้ การออกกำลังกายปัจจุบันจะสิ้นสุด และคุณจะไปยังหน้าสรุปผล';

  @override
  String get workoutComplete => 'ออกกำลังกายเสร็จสิ้น';

  @override
  String get totalWorkoutTime => 'เวลารวม';

  @override
  String get totalDistance => 'ระยะทางรวม';

  @override
  String get averageRpm => 'RPM เฉลี่ย';

  @override
  String get averageLevel => 'ระดับเฉลี่ย';

  @override
  String get holdToStop => 'กดค้างเพื่อหยุด';

  @override
  String get continueWorkout => 'ทำต่อ';

  @override
  String get endWorkoutQuestion => 'ต้องการจบการออกกำลังกายหรือไม่?';

  @override
  String get workoutPaused => 'การออกกำลังกายถูกหยุดชั่วคราว';

  @override
  String get lvlIncline => 'ความชัน';

  @override
  String get lvlResistance => 'ระดับแรงต้าน';

  @override
  String get premium => 'พรีเมียม';

  @override
  String get upgradeNow => 'อัปเกรดตอนนี้';

  @override
  String get purchase => 'ซื้อ';

  @override
  String get later => 'ไว้ก่อน';

  @override
  String get premiumActivated => 'เปิดใช้งานพรีเมียมแล้ว';

  @override
  String get premiumMembership => 'สมาชิกพรีเมียม';

  @override
  String get benefitCycleStairmaster => 'ฟีเจอร์จักรยานและ Stairmaster';

  @override
  String get benefitVoiceGuide => 'ฟีเจอร์ไกด์เสียงของเซสชัน';

  @override
  String get benefitUnlimitedRoutines => 'บันทึกรูทีนได้ไม่จำกัด';

  @override
  String get noAds => 'ไม่มีโฆษณา';

  @override
  String get benefitFutureFeatures => 'เข้าถึงฟีเจอร์ใหม่ในอนาคตได้ไม่จำกัด';

  @override
  String get voiceGuideBenefit1 => 'ไกด์เสียงระหว่างออกกำลังกาย';

  @override
  String get voiceGuideBenefit2 => 'ประกาศเปลี่ยนเซสชันอัตโนมัติ';

  @override
  String get voiceGuideBenefit3 => 'โฟกัสรูทีนแบบไม่ต้องใช้มือ';

  @override
  String get routineLimitBenefit1 => 'บันทึกรูทีนได้ไม่จำกัด';

  @override
  String get routineLimitBenefit2 => 'บันทึกรูทีนสำหรับหลายเป้าหมาย';

  @override
  String get routineLimitBenefit3 =>
      'ใช้เครื่องทุกประเภท (ลู่วิ่ง/จักรยาน/Stairmaster)';

  @override
  String get premium_benefit_1 =>
      'ออกกำลังกาย <red>จักรยาน & StairMaster</red>';

  @override
  String get premium_benefit_2 => '<red>ไกด์เสียง</red>ของเซสชัน';

  @override
  String get premium_benefit_3 => 'บันทึกรูทีนได้ <red>ไม่จำกัด</red>';

  @override
  String get premium_benefit_4 =>
      '<red>เข้าถึงได้ไม่จำกัด</red>สำหรับฟีเจอร์ในอนาคต';

  @override
  String originalPrice(String price) {
    return '$price';
  }

  @override
  String monthlyPrice(String price) {
    return '$price/เดือน';
  }

  @override
  String get premiumSubheadline =>
      'ปลดล็อกไกด์เสียง ออกกำลังกายจักรยาน & Stairmaster และรูทีนไม่จำกัด';

  @override
  String get monthly => 'รายเดือน';

  @override
  String get yearly => 'รายปี';

  @override
  String get lifetime => 'ตลอดชีวิต';

  @override
  String get freeTrial7Days => 'ทดลองใช้ฟรี 7 วัน';

  @override
  String get perMonth => '/เดือน';

  @override
  String get perYear => '/ปี';

  @override
  String get oneTime => 'ครั้งเดียว';

  @override
  String savePercent(int percent) {
    return 'ประหยัด $percent%';
  }

  @override
  String get bestValue => 'คุ้มค่าที่สุด';

  @override
  String get cancelAnytime => 'ยกเลิกได้ทุกเมื่อ';

  @override
  String get autoRenewableSubscription => 'การสมัครสมาชิกต่ออายุอัตโนมัติ';

  @override
  String get terms => 'เงื่อนไข';

  @override
  String get privacy => 'ความเป็นส่วนตัว';

  @override
  String get restore => 'กู้คืน';

  @override
  String get premiumTab => 'พรีเมียม';

  @override
  String get routineTab => 'รูทีน';

  @override
  String get settingsTab => 'ตั้งค่า';

  @override
  String get myTab => 'ของฉัน';

  @override
  String get close => 'ปิด';

  @override
  String get premiumFeature => 'ฟีเจอร์พรีเมียม';

  @override
  String get usePremiumTest => 'ใช้พรีเมียม (ทดสอบ)';

  @override
  String dateTimeFormat(int year, int month, int day, int hour, int minute) {
    return '$day/$month/$year $hour:$minute';
  }

  @override
  String get checkRoutineStart => 'ตรวจสอบรูทีน / เริ่ม';

  @override
  String get beginner => 'ระดับเริ่มต้น';

  @override
  String get intermediate => 'ระดับกลาง';

  @override
  String get advanced => 'ขั้นสูง';

  @override
  String get viewRecommendedRoutines => 'ดูรูทีนแนะนำ →';

  @override
  String get recommendedRoutinesTreadmill => 'รูทีนลู่วิ่งแนะนำ';

  @override
  String get recommendedRoutinesCycle => 'รูทีนจักรยานแนะนำ';

  @override
  String get recommendedRoutinesStairmaster => 'รูทีน Stairmaster แนะนำ';

  @override
  String get alreadySaved => 'บันทึกแล้ว';

  @override
  String get routineSaved => 'บันทึกรูทีนแล้ว';

  @override
  String get checkRoutine => 'ตรวจสอบ';

  @override
  String get saveRoutine => 'บันทึกรูทีน';

  @override
  String get routineAlreadySaved => 'บันทึกรูทีนแล้ว';

  @override
  String get noTemplatesFound => 'ไม่พบเทมเพลต';

  @override
  String get avg => 'เฉลี่ย';

  @override
  String get avgRpm => 'RPM เฉลี่ย';

  @override
  String get avgLevel => 'ระดับเฉลี่ย';

  @override
  String get templateTreadmillBeginner1Title => 'เริ่มง่าย 20';

  @override
  String get templateTreadmillBeginner1Subtitle => 'อินเทอร์วัล 1:1 แบบง่าย';

  @override
  String get templateTreadmillBeginner2Title => 'เดินชัน 25';

  @override
  String get templateTreadmillBeginner2Subtitle => 'บล็อกเดินชัน';

  @override
  String get templateTreadmillIntermediate1Title => 'คลาสสิก 1:1 24';

  @override
  String get templateTreadmillIntermediate1Subtitle =>
      'อินเทอร์วัลวิ่ง 1:1 คลาสสิก';

  @override
  String get templateTreadmillIntermediate2Title => 'บันไดความเร็ว 20';

  @override
  String get templateTreadmillIntermediate2Subtitle => 'ไล่ระดับความเร็ว';

  @override
  String get templateTreadmillAdvanced1Title => '2:1 Burner 21';

  @override
  String get templateTreadmillAdvanced1Subtitle => 'อินเทอร์วัล 2:1 หนัก/เบา';

  @override
  String get templateTreadmillAdvanced2Title => 'Sprint Pop 18';

  @override
  String get templateTreadmillAdvanced2Subtitle => 'ทำซ้ำสปรินต์ 20 วิ';

  @override
  String get templateCycleBeginner1Title => 'สร้างเคเดนซ์ 20';

  @override
  String get templateCycleBeginner1Subtitle => 'วอร์มอัป 4 นาที + เคเดนซ์ 1:1';

  @override
  String get templateCycleBeginner2Title => 'ปั่นคงที่ 25';

  @override
  String get templateCycleBeginner2Subtitle => 'บล็อกคงที่ยาว';

  @override
  String get templateCycleIntermediate1Title => 'Spin 1:1 24';

  @override
  String get templateCycleIntermediate1Subtitle =>
      'อินเทอร์วัลปั่น 1:1 คลาสสิก';

  @override
  String get templateCycleIntermediate2Title => 'จำลองขึ้นเขา 22';

  @override
  String get templateCycleIntermediate2Subtitle => 'ทำซ้ำขึ้นเขา';

  @override
  String get templateCycleAdvanced1Title => 'อินเทอร์วัลพลัง 20';

  @override
  String get templateCycleAdvanced1Subtitle => 'พุ่งพลัง 30 วินาที';

  @override
  String get templateCycleAdvanced2Title => 'Tabata Mix 16';

  @override
  String get templateCycleAdvanced2Subtitle => 'ผสม 20 วิ on / 10 วิ off';

  @override
  String get templateStairmasterBeginner1Title => 'ก้าวง่าย 20';

  @override
  String get templateStairmasterBeginner1Subtitle =>
      'วอร์มอัป 4 นาที + ก้าว 1:1';

  @override
  String get templateStairmasterBeginner2Title => 'ยาวแบบง่าย 25';

  @override
  String get templateStairmasterBeginner2Subtitle => 'บล็อกไต่ระดับเบายาว';

  @override
  String get templateStairmasterIntermediate1Title => 'ไต่ระดับ 2:1 21';

  @override
  String get templateStairmasterIntermediate1Subtitle => 'ทำซ้ำไต่ระดับ 2:1';

  @override
  String get templateStairmasterIntermediate2Title => 'แข็งแรง 1:1 24';

  @override
  String get templateStairmasterIntermediate2Subtitle =>
      'อินเทอร์วัล 1:1 แข็งแรง';

  @override
  String get templateStairmasterAdvanced1Title => 'บล็อกหนัก 20';

  @override
  String get templateStairmasterAdvanced1Subtitle => 'บล็อกหนัก 2 นาที';

  @override
  String get templateStairmasterAdvanced2Title => 'Sprint Steps 18';

  @override
  String get templateStairmasterAdvanced2Subtitle =>
      'สปรินต์ 30 วิ + ฟื้นตัว 60 วิ';

  @override
  String get historyTab => 'ประวัติ';

  @override
  String get calendarTab => 'ปฏิทิน';

  @override
  String get weightTab => 'น้ำหนัก';

  @override
  String get bike => 'จักรยาน';

  @override
  String get thisWeek => 'สัปดาห์นี้';

  @override
  String get trend => 'แนวโน้ม';

  @override
  String get timeframe7D => '7 วัน';

  @override
  String get timeframe30D => '30 วัน';

  @override
  String get timeframe90D => '90 วัน';

  @override
  String get timeframeAll => 'ทั้งหมด';

  @override
  String get history => 'ประวัติ';

  @override
  String get seeAll => 'ดูทั้งหมด';

  @override
  String get weightEntryDeleted => 'ลบรายการน้ำหนักแล้ว';

  @override
  String get weightUpdated => 'อัปเดตน้ำหนักแล้ว';

  @override
  String get editWeight => 'แก้ไขน้ำหนัก';

  @override
  String get recordWeight => 'บันทึกน้ำหนัก';

  @override
  String get quickAdjust => 'ปรับด่วน';

  @override
  String get goalWeightSet => 'ตั้งเป้าหมายน้ำหนักแล้ว';

  @override
  String get goalWeightRemoved => 'ลบเป้าหมายน้ำหนักแล้ว';

  @override
  String get goalAchieved => 'บรรลุเป้าหมาย!';

  @override
  String get goalMatchesCurrentWeight => 'เป้าหมายตรงกับน้ำหนักปัจจุบัน';

  @override
  String get setGoal => 'ตั้งเป้าหมาย';

  @override
  String get suggested => 'แนะนำ';

  @override
  String get removeGoal => 'ลบเป้าหมาย';

  @override
  String get addOneMoreRecordToSeeTrend =>
      'เพิ่มอีก 1 รายการเพื่อดูแนวโน้มของคุณ';

  @override
  String get noWeightRecorded => 'ยังไม่มีการบันทึกน้ำหนัก';

  @override
  String get startTrackingYourWeight =>
      'เริ่มบันทึกน้ำหนักเพื่อดูความคืบหน้าที่นี่';

  @override
  String get treadmillSession => 'เซสชันลู่วิ่ง';

  @override
  String get bikeSession => 'เซสชันจักรยาน';

  @override
  String get stairmasterSession => 'เซสชัน Stairmaster';

  @override
  String get treadmillWorkout => 'ออกกำลังกายลู่วิ่ง';

  @override
  String get bikeWorkout => 'ออกกำลังกายจักรยาน';

  @override
  String get stairmasterWorkout => 'ออกกำลังกาย Stairmaster';

  @override
  String get startAWorkoutToSeeItHere => 'เริ่มออกกำลังกายเพื่อให้แสดงที่นี่';

  @override
  String get mon => 'จ.';

  @override
  String get tue => 'อ.';

  @override
  String get wed => 'พ.';

  @override
  String get thu => 'พฤ.';

  @override
  String get fri => 'ศ.';

  @override
  String get sat => 'ส.';

  @override
  String get sun => 'อา.';

  @override
  String get sessions => 'เซสชัน';

  @override
  String get distance => 'ระยะทาง';

  @override
  String get today => 'วันนี้';

  @override
  String get yesterday => 'เมื่อวาน';

  @override
  String get noWorkoutsYet => 'ยังไม่มีการออกกำลังกาย';

  @override
  String get startYourFirstWorkout =>
      'เริ่มการออกกำลังกายครั้งแรกเพื่อดูประวัติ';

  @override
  String get goToRoutines => 'ไปที่รูทีน';

  @override
  String get weightRecorded => 'บันทึกน้ำหนักแล้ว';

  @override
  String get workout => 'การออกกำลังกาย';

  @override
  String get workouts => 'การออกกำลังกาย';

  @override
  String get goal => 'เป้าหมาย';

  @override
  String get toGo => 'ที่เหลือ';

  @override
  String get over => 'เกิน';

  @override
  String get last => 'ล่าสุด';

  @override
  String get newLabel => 'ใหม่';

  @override
  String youNeed(String amount, String goal) {
    return 'คุณต้องการ $amount เพื่อถึง $goal';
  }

  @override
  String youNeedPlus(String amount, String goal) {
    return 'คุณต้องการ +$amount เพื่อถึง $goal';
  }

  @override
  String get current => 'ปัจจุบัน';

  @override
  String get premiumHeadline => '30 นาทีเท่าเดิม แต่ผลลัพธ์ต่างกัน';

  @override
  String get premiumSubheadlineNew => 'อย่าวิ่งเฉยๆ ออกกำลังกายแบบเผาผลาญไขมัน';

  @override
  String get mostPopular => 'ยอดนิยม';

  @override
  String dailyPrice(int price) {
    return '$price ต่อวัน';
  }

  @override
  String get benefitVoiceCoaching => 'ระบบโค้ชเสียงพรีเมียม';

  @override
  String get benefitCycleStairmasterRoutines =>
      'สนับสนุนอุปกรณ์คาร์ดิโอทั้งหมด';

  @override
  String get benefitUnlimitedRoutinesNew => 'ไลบรารีรูทีนไม่จำกัด';

  @override
  String get benefitWeightFeature => 'ติดตามและวิเคราะห์น้ำหนักแบบสมาร์ท';

  @override
  String get benefitNoAdsFocus => 'ประสบการณ์พรีเมียมไร้โฆษณา';

  @override
  String get benefitFutureFeaturesNew => 'รวมฟีเจอร์พรีเมียมในอนาคตทั้งหมด';

  @override
  String get mostChosen => 'เลือกมากที่สุด';

  @override
  String get canChangeAnytime => 'เปลี่ยนได้ทุกเมื่อ';

  @override
  String get startPremium => 'เริ่มพรีเมียม';

  @override
  String get cancelAnytimeKeepAccess =>
      'ยกเลิกได้ทุกเมื่อและใช้งานได้จนจบระยะเวลา';

  @override
  String workoutDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'การออกกำลังกาย $count วัน 🔥',
      one: 'การออกกำลังกาย 1 วัน 🔥',
    );
    return '$_temp0';
  }

  @override
  String restDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'วันพัก $count วัน 🛏️',
      one: 'วันพัก 1 วัน 🛏️',
    );
    return '$_temp0';
  }

  @override
  String get workoutReminderTitle => 'การแจ้งเตือนการออกกำลังกาย';

  @override
  String get workoutReminderOff => 'ปิด';

  @override
  String get workoutReminderEveryDay => 'ทุกวัน';

  @override
  String get workoutReminderSelectTime => 'เลือกเวลา';

  @override
  String get workoutReminderPermissionRequired => 'ต้องการสิทธิ์การแจ้งเตือน';

  @override
  String get workoutReminderTimeLabel => 'เวลา';
}
