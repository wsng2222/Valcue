// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Interval Cardio';

  @override
  String get settingsTitle => 'إعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get system => 'النظام';

  @override
  String get voiceGuide => 'الدليل الصوتي';

  @override
  String get audioNavigator => 'مستكشف الصوت';

  @override
  String get soundEffects => 'تأثيرات صوتية';

  @override
  String get unitSetting => 'إعداد الوحدة';

  @override
  String get kmh => 'كم/ساعة';

  @override
  String get mph => 'ميل/ساعة';

  @override
  String get themeMode => 'الوضع الفاتح/الداكن';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get smartwatchSync => 'مزامنة الساعة الذكية';

  @override
  String get connectSmartwatch => 'الاتصال بالساعة الذكية';

  @override
  String get connect => 'اتصال';

  @override
  String get about => 'حول';

  @override
  String version(String version) {
    return 'الإصدار $version';
  }

  @override
  String get comingSoon => 'قريباً';

  @override
  String get translationComingSoon => 'ستكون الترجمة متاحة في تحديث مستقبلي.';

  @override
  String get ok => 'موافق';

  @override
  String get cancel => 'إلغاء';

  @override
  String get done => 'تم';

  @override
  String get delete => 'حذف';

  @override
  String get save => 'حفظ';

  @override
  String get edit => 'تعديل';

  @override
  String get start => 'بدء';

  @override
  String get editRoutine => 'تعديل الروتين';

  @override
  String get routineEdit => 'تعديل الروتين';

  @override
  String get name => 'الاسم';

  @override
  String get unnamedRoutine => 'روتين بدون اسم';

  @override
  String get difficulty => 'الصعوبة';

  @override
  String difficultyColon(String difficulty) {
    return 'الصعوبة : $difficulty';
  }

  @override
  String get easy => 'سهل';

  @override
  String get medium => 'متوسط';

  @override
  String get hard => 'صعب';

  @override
  String get interval => 'الفترة';

  @override
  String get addInterval => 'إضافة فترة';

  @override
  String get noIntervals => 'لا توجد فترات';

  @override
  String get addIntervalPrompt => 'إضافة فترة';

  @override
  String get intervalEdit => 'تعديل الفترة';

  @override
  String get timeMinutes => 'الوقت (بالدقائق)';

  @override
  String get duration => 'المدة';

  @override
  String get speed => 'السرعة';

  @override
  String get speedKmh => 'السرعة (كم/ساعة)';

  @override
  String get incline => 'الميل';

  @override
  String get level => 'المستوى';

  @override
  String levelColon(int level) {
    return 'المستوى $level';
  }

  @override
  String get rpm => 'دورة/دقيقة';

  @override
  String get resistance => 'المقاومة';

  @override
  String get resistanceLevel => 'المقاومة (المستوى)';

  @override
  String resistanceColon(int resistance) {
    return 'المقاومة $resistance';
  }

  @override
  String get spm => 'خطوة/دقيقة';

  @override
  String get spmSteps => 'خطوة/دقيقة (خطوات/دقيقة)';

  @override
  String get saved => 'محفوظ';

  @override
  String get deleted => 'تم الحذف';

  @override
  String get deleteRoutineTitle => 'حذف الروتين';

  @override
  String get deleteRoutineMessage =>
      'هل أنت متأكد من أنك تريد حذف هذا الروتين؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get deleteError => 'حدث خطأ أثناء الحذف';

  @override
  String get nameRequired => 'الرجاء إدخال اسم';

  @override
  String get nameMaxLength => 'يجب أن يكون الاسم 24 حرفاً أو أقل';

  @override
  String get minIntervalsRequired => 'مطلوب فترة واحدة على الأقل';

  @override
  String get intervalMinDuration =>
      'يجب أن تكون مدة الفترة ثانية واحدة على الأقل';

  @override
  String get intervalMaxDuration =>
      'يجب أن تكون مدة الفترة 3 ساعات كحد أقصى (10800 ثانية)';

  @override
  String get speedRange => 'يجب أن تكون السرعة أكبر من 0 (0.5-25.0 كم/ساعة)';

  @override
  String get inclineRange => 'يجب أن يكون الميل في النطاق 0-15.0';

  @override
  String get rpmRange => 'يجب أن تكون دورة/دقيقة في النطاق 30-200';

  @override
  String get resistanceRange => 'يجب أن تكون المقاومة في النطاق 1-20';

  @override
  String get levelRange => 'يجب أن يكون المستوى في النطاق 1-20';

  @override
  String get spmRange => 'يجب أن تكون خطوة/دقيقة في النطاق 50-200';

  @override
  String get noRoutinesSaved => 'لا توجد روتينات محفوظة';

  @override
  String get tapToCreate => 'اضغط للإنشاء';

  @override
  String get tapButtonToCreate => 'اضغط على الزر للإنشاء';

  @override
  String get premiumRoutineSettings => 'إعدادات الروتين المميز';

  @override
  String get viewMembership => 'عرض العضوية';

  @override
  String get freeLimitTitle => 'الحد المجاني هو 2 روتينات';

  @override
  String get freeLimitMessage => 'يمكنك استخدام روتينات غير محدودة مع العضوية';

  @override
  String get treadmill => 'جهاز الجري';

  @override
  String get cycle => 'الدراجة';

  @override
  String get stairmaster => 'السلم';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get selectTheme => 'اختر المظهر';

  @override
  String get selectDifficulty => 'اختر الصعوبة';

  @override
  String get pause => 'إيقاف مؤقت';

  @override
  String get resume => 'متابعة';

  @override
  String get endWorkout => 'إنهاء التمرين';

  @override
  String get endWorkoutConfirm => 'هل تريد إنهاء التمرين؟';

  @override
  String get end => 'إنهاء';

  @override
  String get rotate => 'تدوير';

  @override
  String get paused => 'متوقف مؤقتاً';

  @override
  String get pausedTitle => 'متوقف مؤقتاً';

  @override
  String get pausedSubtitle => 'يمكنك المتابعة أو إنهاء التمرين';

  @override
  String get endWorkoutConfirmationMessage =>
      'إذا أنهيت الآن، سينتهي التمرين الحالي وستنتقل إلى شاشة الملخص.';

  @override
  String get workoutComplete => 'اكتمل التمرين';

  @override
  String get totalWorkoutTime => 'إجمالي الوقت';

  @override
  String get totalDistance => 'إجمالي المسافة';

  @override
  String get averageRpm => 'متوسط RPM';

  @override
  String get averageLevel => 'المستوى المتوسط';

  @override
  String get holdToStop => 'اضغط مطولاً للإيقاف';

  @override
  String get continueWorkout => 'متابعة';

  @override
  String get endWorkoutQuestion => 'هل تريد إنهاء التمرين؟';

  @override
  String get workoutPaused => 'تم إيقاف التمرين مؤقتاً';

  @override
  String get lvlIncline => 'الميل';

  @override
  String get lvlResistance => 'المستوى المقاومة';

  @override
  String get premium => 'بريميوم';

  @override
  String get upgradeNow => 'ترقية الآن';

  @override
  String get purchase => 'شراء';

  @override
  String get later => 'لاحقاً';

  @override
  String get premiumActivated => 'تم تفعيل بريميوم';

  @override
  String get premiumMembership => 'عضوية بريميوم';

  @override
  String get benefitCycleStairmaster => 'ميزة الدراجة والسلالم';

  @override
  String get benefitVoiceGuide => 'ميزة دليل الصوت للجلسة';

  @override
  String get benefitUnlimitedRoutines => 'حفظ روتين غير محدود';

  @override
  String get noAds => 'بدون إعلانات';

  @override
  String get benefitFutureFeatures => 'وصول غير محدود للميزات المستقبلية';

  @override
  String get voiceGuideBenefit1 => 'إرشاد صوتي أثناء التمرين';

  @override
  String get voiceGuideBenefit2 => 'إعلانات تلقائية لانتقالات الجلسات';

  @override
  String get voiceGuideBenefit3 => 'التركيز على الروتين بدون استخدام اليدين';

  @override
  String get routineLimitBenefit1 => 'حفظ روتين غير محدود';

  @override
  String get routineLimitBenefit2 => 'حفظ روتين لعدة أهداف';

  @override
  String get routineLimitBenefit3 =>
      'استخدام جميع أنواع المعدات (الجري/الدراجة/السلالم)';

  @override
  String get premium_benefit_1 => 'تمارين <red>الدراجة وStairMaster</red>';

  @override
  String get premium_benefit_2 => '<red>إرشاد صوتي</red> أثناء الجلسة';

  @override
  String get premium_benefit_3 => 'حفظ الروتين <red>غير محدود</red>';

  @override
  String get premium_benefit_4 =>
      '<red>وصول غير محدود</red> إلى الميزات القادمة';

  @override
  String originalPrice(String price) {
    return '$price';
  }

  @override
  String monthlyPrice(String price) {
    return '$price/شهر';
  }

  @override
  String get premiumSubheadline =>
      'فتح قفل الإرشاد الصوتي، وتمارين الدراجة والسلالم، والروتينات غير المحدودة';

  @override
  String get monthly => 'شهري';

  @override
  String get yearly => 'سنوي';

  @override
  String get lifetime => 'مدى الحياة';

  @override
  String get freeTrial7Days => 'تجربة مجانية لمدة 7 أيام';

  @override
  String get perMonth => '/شهر';

  @override
  String get perYear => '/سنة';

  @override
  String get oneTime => 'دفع واحد';

  @override
  String savePercent(int percent) {
    return 'وفر $percent%';
  }

  @override
  String get bestValue => 'أفضل قيمة';

  @override
  String get cancelAnytime => 'إلغاء في أي وقت';

  @override
  String get autoRenewableSubscription => 'اشتراك قابل للتجديد تلقائياً';

  @override
  String get terms => 'الشروط';

  @override
  String get privacy => 'الخصوصية';

  @override
  String get restore => 'استعادة';

  @override
  String get premiumTab => 'بريميوم';

  @override
  String get routineTab => 'الروتين';

  @override
  String get settingsTab => 'الإعدادات';

  @override
  String get myTab => 'أنا';

  @override
  String get close => 'إغلاق';

  @override
  String get premiumFeature => 'ميزة بريميوم';

  @override
  String get usePremiumTest => 'استخدام بريميوم (اختبار)';

  @override
  String dateTimeFormat(int year, int month, int day, int hour, int minute) {
    return '$day/$month/$year $hour:$minute';
  }

  @override
  String get checkRoutineStart => 'التحقق من الروتين / البدء';

  @override
  String get beginner => 'مبتدئ';

  @override
  String get intermediate => 'متوسط';

  @override
  String get advanced => 'متقدم';

  @override
  String get viewRecommendedRoutines => 'عرض الروتينات الموصى بها →';

  @override
  String get recommendedRoutinesTreadmill => 'روتينات المشي الموصى بها';

  @override
  String get recommendedRoutinesCycle => 'روتينات الدراجة الموصى بها';

  @override
  String get recommendedRoutinesStairmaster => 'روتينات السلم الموصى بها';

  @override
  String get alreadySaved => 'محفوظ بالفعل';

  @override
  String get routineSaved => 'تم حفظ الروتين';

  @override
  String get checkRoutine => 'التحقق';

  @override
  String get saveRoutine => 'حفظ الروتين';

  @override
  String get routineAlreadySaved => 'الروتين محفوظ بالفعل';

  @override
  String get noTemplatesFound => 'لم يتم العثور على قوالب';

  @override
  String get avg => 'المتوسط';

  @override
  String get avgRpm => 'المتوسط RPM';

  @override
  String get avgLevel => 'المتوسط المستوى';

  @override
  String get templateTreadmillBeginner1Title => 'بداية سهلة 20';

  @override
  String get templateTreadmillBeginner1Subtitle => 'إحماء 3 دقائق + فترات 1:1';

  @override
  String get templateTreadmillBeginner2Title => 'مشي مائل 25';

  @override
  String get templateTreadmillBeginner2Subtitle => 'كتل مشي مائل';

  @override
  String get templateTreadmillIntermediate1Title => 'كلاسيكي 1:1 24';

  @override
  String get templateTreadmillIntermediate1Subtitle => 'فترات كلاسيكية 1:1';

  @override
  String get templateTreadmillIntermediate2Title => 'سلم السرعة 20';

  @override
  String get templateTreadmillIntermediate2Subtitle =>
      'سلم السرعة (تسارع تدريجيًا)';

  @override
  String get templateTreadmillAdvanced1Title => 'حارق 2:1 21';

  @override
  String get templateTreadmillAdvanced1Subtitle => 'فترات 2:1 (قوي/خفيف)';

  @override
  String get templateTreadmillAdvanced2Title => 'اندفاع العدو 18';

  @override
  String get templateTreadmillAdvanced2Subtitle => 'تكرارات عدو 20 ثانية';

  @override
  String get templateCycleBeginner1Title => 'بناء الكادنس 20';

  @override
  String get templateCycleBeginner1Subtitle => 'إحماء 4 دقائق + كادنس 1:1';

  @override
  String get templateCycleBeginner2Title => 'قيادة ثابتة 25';

  @override
  String get templateCycleBeginner2Subtitle => 'كتلة ثابتة طويلة';

  @override
  String get templateCycleIntermediate1Title => 'سبين 1:1 24';

  @override
  String get templateCycleIntermediate1Subtitle => 'فترات سبين كلاسيكية 1:1';

  @override
  String get templateCycleIntermediate2Title => 'محاكاة التلال 22';

  @override
  String get templateCycleIntermediate2Subtitle => 'تكرارات الصعود';

  @override
  String get templateCycleAdvanced1Title => 'فترات القوة 20';

  @override
  String get templateCycleAdvanced1Subtitle => 'اندفاعات قوة لمدة 30 ثانية';

  @override
  String get templateCycleAdvanced2Title => 'تاباتا ميكس 16';

  @override
  String get templateCycleAdvanced2Subtitle => 'ميكس 20ث/10ث';

  @override
  String get templateStairmasterBeginner1Title => 'خطوات سهلة 20';

  @override
  String get templateStairmasterBeginner1Subtitle =>
      'إحماء 4 دقائق + خطوات 1:1';

  @override
  String get templateStairmasterBeginner2Title => 'طويل وخفيف 25';

  @override
  String get templateStairmasterBeginner2Subtitle => 'كتل طويلة وخفيفة';

  @override
  String get templateStairmasterIntermediate1Title => 'صعود 2:1 21';

  @override
  String get templateStairmasterIntermediate1Subtitle => 'تكرارات صعود 2:1';

  @override
  String get templateStairmasterIntermediate2Title => 'قوي 1:1 24';

  @override
  String get templateStairmasterIntermediate2Subtitle => 'فترات قوية 1:1';

  @override
  String get templateStairmasterAdvanced1Title => 'كتل صعبة 20';

  @override
  String get templateStairmasterAdvanced1Subtitle => 'كتل صعبة لمدة دقيقتين';

  @override
  String get templateStairmasterAdvanced2Title => 'خطوات سبرينت 18';

  @override
  String get templateStairmasterAdvanced2Subtitle => 'سبرينت 30ث + تعافٍ 60ث';

  @override
  String get historyTab => 'السجل';

  @override
  String get calendarTab => 'التقويم';

  @override
  String get weightTab => 'الوزن';

  @override
  String get bike => 'الدراجة';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get trend => 'الاتجاه';

  @override
  String get timeframe7D => '7أ';

  @override
  String get timeframe30D => '30أ';

  @override
  String get timeframe90D => '90أ';

  @override
  String get timeframeAll => 'الكل';

  @override
  String get history => 'السجل';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get weightEntryDeleted => 'تم حذف إدخال الوزن';

  @override
  String get weightUpdated => 'تم تحديث الوزن';

  @override
  String get editWeight => 'تعديل الوزن';

  @override
  String get recordWeight => 'تسجيل الوزن';

  @override
  String get quickAdjust => 'تعديل سريع';

  @override
  String get goalWeightSet => 'تم تعيين الوزن المستهدف';

  @override
  String get goalWeightRemoved => 'تم إزالة الوزن المستهدف';

  @override
  String get goalAchieved => 'تم تحقيق الهدف!';

  @override
  String get goalMatchesCurrentWeight => 'الهدف يطابق الوزن الحالي';

  @override
  String get setGoal => 'تعيين الهدف';

  @override
  String get suggested => 'مقترح';

  @override
  String get removeGoal => 'إزالة الهدف';

  @override
  String get addOneMoreRecordToSeeTrend => 'أضف سجلًا واحدًا آخر لرؤية اتجاهك';

  @override
  String get noWeightRecorded => 'لم يتم تسجيل الوزن بعد';

  @override
  String get startTrackingYourWeight => 'ابدأ في تتبع وزنك لرؤية التقدم هنا';

  @override
  String get treadmillSession => 'جلسة جهاز الجري';

  @override
  String get bikeSession => 'جلسة الدراجة';

  @override
  String get stairmasterSession => 'جلسة السلم';

  @override
  String get treadmillWorkout => 'تمرين جهاز الجري';

  @override
  String get bikeWorkout => 'تمرين الدراجة';

  @override
  String get stairmasterWorkout => 'تمرين السلم';

  @override
  String get startAWorkoutToSeeItHere => 'ابدأ تمرينًا لرؤيته هنا';

  @override
  String get mon => 'الاثنين';

  @override
  String get tue => 'الثلاثاء';

  @override
  String get wed => 'الأربعاء';

  @override
  String get thu => 'الخميس';

  @override
  String get fri => 'الجمعة';

  @override
  String get sat => 'السبت';

  @override
  String get sun => 'الأحد';

  @override
  String get sessions => 'الجلسات';

  @override
  String get distance => 'المسافة';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String get noWorkoutsYet => 'لا توجد تمارين بعد';

  @override
  String get startYourFirstWorkout => 'ابدأ تمرينك الأول لرؤية سجلك هنا';

  @override
  String get goToRoutines => 'الانتقال إلى الروتينات';

  @override
  String get weightRecorded => 'تم تسجيل الوزن';

  @override
  String get workout => 'تمرين';

  @override
  String get workouts => 'تمارين';

  @override
  String get goal => 'الهدف';

  @override
  String get toGo => 'متبقي';

  @override
  String get over => 'تجاوز';

  @override
  String get last => 'آخر';

  @override
  String get newLabel => 'جديد';

  @override
  String youNeed(String amount, String goal) {
    return 'تحتاج $amount للوصول إلى $goal';
  }

  @override
  String youNeedPlus(String amount, String goal) {
    return 'تحتاج +$amount للوصول إلى $goal';
  }

  @override
  String get current => 'الحالي';

  @override
  String get premiumHeadline => 'نفس 30 دقيقة، نتائج مختلفة';

  @override
  String get premiumSubheadlineNew => 'لا تجري فقط، تمرن بطريقة حرق الدهون';

  @override
  String get mostPopular => 'الأكثر شعبية';

  @override
  String dailyPrice(int price) {
    return '$price في اليوم';
  }

  @override
  String get benefitVoiceCoaching => 'نظام التدريب الصوتي المتميز';

  @override
  String get benefitCycleStairmasterRoutines => 'دعم كامل لجميع أجهزة الكارديو';

  @override
  String get benefitUnlimitedRoutinesNew => 'مكتبة تمارين غير محدودة';

  @override
  String get benefitWeightFeature => 'تتبع وتحليل ذكي للوزن';

  @override
  String get benefitNoAdsFocus => 'تجربة متميزة بدون إعلانات';

  @override
  String get benefitFutureFeaturesNew => 'جميع ميزات Premium المستقبلية متضمنة';

  @override
  String get mostChosen => 'الأكثر اختيارًا';

  @override
  String get canChangeAnytime => 'يمكن التغيير في أي وقت';

  @override
  String get startPremium => 'بدء Premium';

  @override
  String get cancelAnytimeKeepAccess =>
      'ألغِ في أي وقت واحتفظ بالوصول حتى نهاية الفترة';

  @override
  String workoutDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'التمرين $count أيام 🔥',
      one: 'التمرين 1 يوم 🔥',
    );
    return '$_temp0';
  }

  @override
  String restDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'الراحة $count أيام 🛏️',
      one: 'الراحة 1 يوم 🛏️',
    );
    return '$_temp0';
  }

  @override
  String get workoutReminderTitle => 'تذكير بالتمرين';

  @override
  String get workoutReminderOff => 'إيقاف';

  @override
  String get workoutReminderEveryDay => 'كل يوم';

  @override
  String get workoutReminderSelectTime => 'اختر الوقت';

  @override
  String get workoutReminderPermissionRequired => 'يلزم منح إذن الإشعارات.';

  @override
  String get workoutReminderTimeLabel => 'الوقت';
}
