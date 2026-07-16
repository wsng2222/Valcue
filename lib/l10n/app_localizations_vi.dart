// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Valcue';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get system => 'Hệ thống';

  @override
  String get voiceGuide => 'Hướng dẫn bằng giọng nói';

  @override
  String get audioNavigator => 'Trình điều hướng âm thanh';

  @override
  String get soundEffects => 'Hiệu ứng Âm thanh';

  @override
  String get unitSetting => 'Đơn vị';

  @override
  String get kmh => 'km/h';

  @override
  String get mph => 'mph';

  @override
  String get themeMode => 'Giao diện';

  @override
  String get light => 'Sáng';

  @override
  String get dark => 'Tối';

  @override
  String get smartwatchSync => 'Đồng bộ Smartwatch';

  @override
  String get connectSmartwatch => 'Kết nối với smartwatch';

  @override
  String get connect => 'Kết nối';

  @override
  String get about => 'Giới thiệu';

  @override
  String version(String version) {
    return 'Phiên bản $version';
  }

  @override
  String get comingSoon => 'Sắp ra mắt';

  @override
  String get translationComingSoon =>
      'Bản dịch sẽ có sẵn trong bản cập nhật tương lai.';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Hủy';

  @override
  String get done => 'Hoàn thành';

  @override
  String get delete => 'Xóa';

  @override
  String get save => 'Lưu';

  @override
  String get edit => 'Chỉnh sửa';

  @override
  String get start => 'Bắt đầu';

  @override
  String get editRoutine => 'Chỉnh sửa Thói quen';

  @override
  String get routineEdit => 'Chỉnh sửa Thói quen';

  @override
  String get name => 'Tên';

  @override
  String get unnamedRoutine => 'Thói quen Không tên';

  @override
  String get difficulty => 'Độ khó';

  @override
  String difficultyColon(String difficulty) {
    return 'Độ khó : $difficulty';
  }

  @override
  String get easy => 'Dễ';

  @override
  String get medium => 'Trung bình';

  @override
  String get hard => 'Khó';

  @override
  String get interval => 'Khoảng thời gian';

  @override
  String get addInterval => 'Thêm Khoảng thời gian';

  @override
  String get quickTools => 'Tác vụ nhanh';

  @override
  String get addDefault => 'Thêm mặc định';

  @override
  String get duplicateLast => 'Sao chép cuối';

  @override
  String get repeatPattern => 'Lặp mẫu';

  @override
  String get reorderIntervals => 'Sắp xếp lại thứ tự';

  @override
  String get reorderMode => 'Chế độ sắp xếp lại';

  @override
  String get reorderModeHint =>
      'Nhấn và giữ một thẻ để di chuyển thẻ đến vị trí bạn muốn.';

  @override
  String get patternLength => 'Độ dài mẫu';

  @override
  String get repeatCount => 'Số lần lặp';

  @override
  String get noIntervals => 'Không có khoảng thời gian';

  @override
  String get addIntervalPrompt => 'Thêm một khoảng thời gian';

  @override
  String get intervalEdit => 'Chỉnh sửa Khoảng thời gian';

  @override
  String get timeMinutes => 'Thời gian (phút)';

  @override
  String get duration => 'Thời lượng';

  @override
  String get speed => 'Tốc độ';

  @override
  String get speedKmh => 'Tốc độ (km/h)';

  @override
  String get incline => 'Độ dốc';

  @override
  String get level => 'Cấp độ';

  @override
  String levelColon(int level) {
    return 'Cấp độ $level';
  }

  @override
  String get rpm => 'RPM';

  @override
  String get rpmInfoDescription =>
      'RPM cho biết bàn đạp quay bao nhiêu vòng trong một phút. RPM càng cao nghĩa là bạn đang đạp với nhịp nhanh hơn.';

  @override
  String get resistance => 'Kháng cự';

  @override
  String get resistanceLevel => 'Kháng cự (Cấp độ)';

  @override
  String resistanceColon(int resistance) {
    return 'Kháng cự $resistance';
  }

  @override
  String get spm => 'SPM';

  @override
  String get spmSteps => 'SPM (bước/phút)';

  @override
  String get saved => 'Đã lưu';

  @override
  String get deleted => 'Đã xóa';

  @override
  String get deleteRoutineTitle => 'Xóa Thói quen';

  @override
  String get deleteRoutineMessage =>
      'Bạn có chắc chắn muốn xóa thói quen này không? Hành động này không thể hoàn tác.';

  @override
  String get deleteError => 'Đã xảy ra lỗi khi xóa';

  @override
  String get nameRequired => 'Vui lòng nhập tên';

  @override
  String get nameMaxLength => 'Tên phải có 24 ký tự trở xuống';

  @override
  String get minIntervalsRequired => 'Cần ít nhất một khoảng thời gian';

  @override
  String get intervalMinDuration =>
      'Thời lượng khoảng thời gian phải ít nhất 1 giây';

  @override
  String get intervalMaxDuration =>
      'Thời lượng khoảng thời gian tối đa là 3 giờ (10800 giây)';

  @override
  String get speedRange => 'Tốc độ phải lớn hơn 0 (0.5-25.0 km/h)';

  @override
  String get inclineRange => 'Độ dốc phải trong khoảng 0-15.0';

  @override
  String get rpmRange => 'RPM phải trong khoảng 30-200';

  @override
  String get resistanceRange => 'Kháng cự phải trong khoảng 1-20';

  @override
  String get levelRange => 'Cấp độ phải trong khoảng 1-20';

  @override
  String get spmRange => 'SPM phải trong khoảng 50-200';

  @override
  String get noRoutinesSaved => 'Không có thói quen đã lưu';

  @override
  String get tapToCreate => 'Chạm để tạo';

  @override
  String get tapButtonToCreate => 'Chạm vào nút để tạo';

  @override
  String get premiumRoutineSettings => 'Cài đặt Thói quen Cao cấp';

  @override
  String get viewMembership => 'Xem Premium';

  @override
  String get freeLimitTitle => 'Miễn phí 2 bài';

  @override
  String get freeLimitMessage => 'Nâng cấp Premium để dùng không giới hạn';

  @override
  String get treadmill => 'Máy chạy bộ';

  @override
  String get cycle => 'Xe đạp';

  @override
  String get stairmaster => 'Máy leo cầu thang';

  @override
  String get selectLanguage => 'Ngôn ngữ';

  @override
  String get selectTheme => 'Chọn Chủ đề';

  @override
  String get selectDifficulty => 'Chọn Độ khó';

  @override
  String get pause => 'Tạm dừng';

  @override
  String get resume => 'Tiếp tục';

  @override
  String get endWorkout => 'Kết thúc Thói quen';

  @override
  String get endWorkoutConfirm => 'Bạn có muốn kết thúc thói quen không?';

  @override
  String get end => 'Kết thúc';

  @override
  String get share => 'Chia sẻ';

  @override
  String get rotate => 'Xoay';

  @override
  String get paused => 'ĐÃ TẠM DỪNG';

  @override
  String get pausedTitle => 'Đã tạm dừng';

  @override
  String get pausedSubtitle => 'Bạn có thể tiếp tục hoặc kết thúc thói quen';

  @override
  String get endWorkoutConfirmationMessage =>
      'Nếu bạn kết thúc ngay bây giờ, thói quen hiện tại sẽ kết thúc và bạn sẽ chuyển sang màn hình tóm tắt.';

  @override
  String get workoutComplete => 'Hoàn thành bài tập';

  @override
  String get backgroundIntervalNotificationTitle => 'Bắt đầu hiệp mới';

  @override
  String get backgroundIntervalNotificationsTitle =>
      'Hướng dẫn tập luyện theo thời gian thực';

  @override
  String get backgroundIntervalNotificationsSubtitle =>
      'Xem thông tin bài tập và hướng dẫn từng hiệp theo thời gian thực khi dùng ứng dụng khác';

  @override
  String get liveActivityPreparing => 'Chuẩn bị';

  @override
  String get liveActivityInProgress => 'Đang tập luyện';

  @override
  String liveActivityIntervalFormat(int current, int total) {
    return 'Hiệp $current/$total';
  }

  @override
  String liveActivityDurationFormat(String duration) {
    return 'Trong $duration';
  }

  @override
  String get totalWorkoutTime => 'Tổng thời gian';

  @override
  String get totalDistance => 'Tổng khoảng cách';

  @override
  String get totalTime => 'Tổng thời gian';

  @override
  String get averageRpm => 'RPM Trung Bình';

  @override
  String get averageLevel => 'Mức Trung Bình';

  @override
  String get holdToStop => 'Giữ để dừng';

  @override
  String get continueWorkout => 'Tiếp tục';

  @override
  String get endWorkoutQuestion => 'Bạn có muốn kết thúc thói quen không?';

  @override
  String get workoutPaused => 'Thói quen đã được tạm dừng';

  @override
  String get lvlIncline => 'Độ dốc';

  @override
  String get lvlResistance => 'Cấp độ Kháng cự';

  @override
  String get premium => 'Cao cấp';

  @override
  String get upgradeNow => 'Nâng cấp Ngay';

  @override
  String get purchase => 'Mua';

  @override
  String get later => 'Để Sau';

  @override
  String get premiumActivated => 'Cao cấp đã được kích hoạt';

  @override
  String get premiumMembership => 'Premium';

  @override
  String get benefitCycleStairmaster => 'Bài tập đạp xe & leo cầu thang';

  @override
  String get benefitVoiceGuide => 'Hướng dẫn giọng nói theo từng phần';

  @override
  String get benefitUnlimitedRoutines => 'Lưu trữ bài tập không giới hạn';

  @override
  String get noAds => 'Không Có Quảng Cáo';

  @override
  String get benefitFutureFeatures => 'Bao gồm tất cả tính năng tương lai';

  @override
  String get voiceGuideBenefit1 => 'Hướng dẫn bằng giọng nói khi tập';

  @override
  String get voiceGuideBenefit2 => 'Thông báo tự động khi chuyển phần';

  @override
  String get voiceGuideBenefit3 => 'Tập trung hoàn toàn mà không cần chạm máy';

  @override
  String get routineLimitBenefit1 => 'Lưu trữ bài tập không giới hạn';

  @override
  String get routineLimitBenefit2 => 'Lưu bài tập tùy chỉnh theo mục tiêu';

  @override
  String get routineLimitBenefit3 =>
      'Hỗ trợ đầy đủ máy chạy bộ/xe đạp/máy leo cầu thang';

  @override
  String get premium_benefit_1 => 'Hỗ trợ <red>xe đạp & StairMaster</red>';

  @override
  String get premium_benefit_2 =>
      '<red>Hướng dẫn giọng nói</red> trong lúc tập';

  @override
  String get premium_benefit_3 => 'Lưu bài tập <red>không giới hạn</red>';

  @override
  String get premium_benefit_4 =>
      'Cập nhật tính năng tương lai <red>trọn đời</red>';

  @override
  String originalPrice(String price) {
    return '$price';
  }

  @override
  String monthlyPrice(String price) {
    return '$price/tháng';
  }

  @override
  String get premiumSubheadline =>
      'Mở khóa hướng dẫn bằng giọng nói, bài tập xe đạp và máy leo cầu thang, và thói quen không giới hạn';

  @override
  String get monthly => 'Hàng tháng';

  @override
  String get yearly => 'Hàng năm';

  @override
  String get lifetime => 'Suốt đời';

  @override
  String get freeTrial7Days => 'Dùng thử miễn phí 7 ngày';

  @override
  String get perMonth => '/tháng';

  @override
  String get perYear => '/năm';

  @override
  String get oneTime => 'Thanh toán một lần';

  @override
  String savePercent(int percent) {
    return 'Tiết kiệm $percent%';
  }

  @override
  String get bestValue => 'Giá trị tốt nhất';

  @override
  String get cancelAnytime => 'Hủy bất cứ lúc nào';

  @override
  String get autoRenewableSubscription => 'Tự gia hạn';

  @override
  String get terms => 'Điều khoản';

  @override
  String get privacy => 'Quyền riêng tư';

  @override
  String get restore => 'Khôi phục';

  @override
  String get premiumTab => 'Cao cấp';

  @override
  String get routineTab => 'Thói quen';

  @override
  String get settingsTab => 'Cài đặt';

  @override
  String get myTab => 'Tôi';

  @override
  String get close => 'Đóng';

  @override
  String get premiumFeature => 'Chỉ dành cho Premium';

  @override
  String get usePremiumTest => 'Dùng thử Premium';

  @override
  String dateTimeFormat(int year, int month, int day, int hour, int minute) {
    return '$day/$month/$year $hour:$minute';
  }

  @override
  String get checkRoutineStart => 'Xem và bắt đầu';

  @override
  String get beginner => 'Người mới bắt đầu';

  @override
  String get intermediate => 'Trung cấp';

  @override
  String get advanced => 'Nâng cao';

  @override
  String get viewRecommendedRoutines => 'Đề xuất →';

  @override
  String get recommendedRoutinesTreadmill => 'Gợi ý máy chạy';

  @override
  String get recommendedRoutinesCycle => 'Gợi ý xe đạp';

  @override
  String get recommendedRoutinesStairmaster => 'Gợi ý cầu thang';

  @override
  String get alreadySaved => 'Đã lưu';

  @override
  String get routineSaved => 'Thói quen đã được lưu';

  @override
  String get checkRoutine => 'Xem';

  @override
  String get saveRoutine => 'Lưu Thói quen';

  @override
  String get routineAlreadySaved => 'Thói quen đã được lưu';

  @override
  String get noTemplatesFound => 'Không tìm thấy mẫu';

  @override
  String get avg => 'TB';

  @override
  String get avgRpm => 'TB RPM';

  @override
  String get avgLevel => 'TB Cấp độ';

  @override
  String get templateTreadmillBeginner1Title => 'Máy Chạy Bộ Sơ Cấp 1';

  @override
  String get templateTreadmillBeginner1Subtitle =>
      '1:1 đi bộ và chạy sau 3 phút khởi động';

  @override
  String get templateTreadmillBeginner2Title => 'Máy Chạy Bộ Sơ Cấp 2 (Độ Dốc)';

  @override
  String get templateTreadmillBeginner2Subtitle =>
      'Đi bộ leo dốc giảm chấn thương khớp gối';

  @override
  String get templateTreadmillIntermediate1Title => 'Máy Chạy Bộ Trung Cấp 1';

  @override
  String get templateTreadmillIntermediate1Subtitle =>
      'Interval chạy 1:1 giúp đẩy nhanh đốt mỡ';

  @override
  String get templateTreadmillIntermediate2Title =>
      'Máy Chạy Bộ Trung Cấp 2 (Tốc Độ)';

  @override
  String get templateTreadmillIntermediate2Subtitle =>
      'Chạy tăng tốc dần theo dạng kim tự tháp';

  @override
  String get templateTreadmillAdvanced1Title => 'Máy Chạy Bộ Cao Cấp 1';

  @override
  String get templateTreadmillAdvanced1Subtitle =>
      'Đẩy giới hạn tim mạch với cường độ cao';

  @override
  String get templateTreadmillAdvanced2Title =>
      'Máy Chạy Bộ Cao Cấp 2 (Sprint)';

  @override
  String get templateTreadmillAdvanced2Subtitle =>
      'Lặp lại các quãng nước rút ngắn cường độ cao';

  @override
  String get templateCycleBeginner1Title => 'Xe Đạp Sơ Cấp 1';

  @override
  String get templateCycleBeginner1Subtitle =>
      'Làm quen nhịp đạp bằng cách điều chỉnh RPM';

  @override
  String get templateCycleBeginner2Title => 'Xe Đạp Sơ Cấp 2 (Ổn Định)';

  @override
  String get templateCycleBeginner2Subtitle =>
      'Đạp bền tăng sức bền ở mức kháng lực cố định';

  @override
  String get templateCycleIntermediate1Title => 'Xe Đạp Trung Cấp 1';

  @override
  String get templateCycleIntermediate1Subtitle =>
      '1 phút đạp nhanh / 1 phút đạp nhẹ phục hồi';

  @override
  String get templateCycleIntermediate2Title => 'Xe Đạp Trung Cấp 2 (Leo Dốc)';

  @override
  String get templateCycleIntermediate2Subtitle =>
      'Đạp leo dốc với lực cản cao rèn luyện cơ đùi';

  @override
  String get templateCycleAdvanced1Title => 'Xe Đạp Cao Cấp 1';

  @override
  String get templateCycleAdvanced1Subtitle =>
      'Interval đạp bùng nổ 30 giây ở mức cản cao';

  @override
  String get templateCycleAdvanced2Title => 'Xe Đạp Cao Cấp 2 (Tabata)';

  @override
  String get templateCycleAdvanced2Subtitle =>
      'Vòng lặp Tabata 20 giây/10 giây giúp săn chắc';

  @override
  String get templateStairmasterBeginner1Title => 'Máy Leo Thang Sơ Cấp 1';

  @override
  String get templateStairmasterBeginner1Subtitle =>
      'Đi bộ chậm làm quen nhịp leo thang an toàn';

  @override
  String get templateStairmasterBeginner2Title =>
      'Máy Leo Thang Sơ Cấp 2 (Ổn Định)';

  @override
  String get templateStairmasterBeginner2Subtitle =>
      'Leo thang nhịp nhàng liên tục rèn luyện sức bền';

  @override
  String get templateStairmasterIntermediate1Title =>
      'Máy Leo Thang Trung Cấp 1 (Leo Dốc)';

  @override
  String get templateStairmasterIntermediate1Subtitle =>
      'Leo 2 phút / 1 phút phục hồi săn chắc cơ mông';

  @override
  String get templateStairmasterIntermediate2Title =>
      'Máy Leo Thang Trung Cấp 2';

  @override
  String get templateStairmasterIntermediate2Subtitle =>
      'Interval nhịp tim luân phiên nhanh và chậm';

  @override
  String get templateStairmasterAdvanced1Title => 'Máy Leo Thang Cao Cấp 1';

  @override
  String get templateStairmasterAdvanced1Subtitle =>
      'Bài tập phân đoạn 2 phút cường độ cao';

  @override
  String get templateStairmasterAdvanced2Title =>
      'Máy Leo Thang Cao Cấp 2 (Sprint)';

  @override
  String get templateStairmasterAdvanced2Subtitle =>
      'Leo thang nhanh 30 giây / 60 giây phục hồi';

  @override
  String get historyTab => 'Lịch sử';

  @override
  String get calendarTab => 'Lịch';

  @override
  String get weightTab => 'Cân nặng';

  @override
  String get bike => 'Xe đạp';

  @override
  String get thisWeek => 'Tuần này';

  @override
  String get trend => 'Biến động cân nặng';

  @override
  String get timeframe7D => '7N';

  @override
  String get timeframe30D => '30N';

  @override
  String get timeframe90D => '90N';

  @override
  String get timeframeAll => 'TẤT CẢ';

  @override
  String get history => 'Lịch sử';

  @override
  String get seeAll => 'Xem tất cả';

  @override
  String get weightEntryDeleted => 'Mục nhập cân nặng đã bị xóa';

  @override
  String get weightUpdated => 'Cân nặng đã được cập nhật';

  @override
  String get editWeight => 'Chỉnh sửa cân nặng';

  @override
  String get recordWeight => 'Ghi lại cân nặng';

  @override
  String get quickAdjust => 'Điều chỉnh nhanh';

  @override
  String get goalWeightSet => 'Mục tiêu cân nặng đã được đặt';

  @override
  String get goalWeightRemoved => 'Đã hủy bỏ mục tiêu cân nặng';

  @override
  String get goalAchieved => 'Đã đạt được mục tiêu!';

  @override
  String get goalMatchesCurrentWeight => 'Mục tiêu khớp với cân nặng hiện tại';

  @override
  String get setGoal => 'Đặt mục tiêu';

  @override
  String get suggested => 'Đề xuất';

  @override
  String get removeGoal => 'Xóa mục tiêu';

  @override
  String get addOneMoreRecordToSeeTrend => 'Thêm 1 lần ghi nữa để xem xu hướng';

  @override
  String get noWeightRecorded => 'Chưa có dữ liệu cân nặng';

  @override
  String get startTrackingYourWeight => 'Ghi cân nặng để theo dõi tiến độ';

  @override
  String get treadmillSession => 'Phiên Máy chạy bộ';

  @override
  String get bikeSession => 'Phiên Xe đạp';

  @override
  String get stairmasterSession => 'Phiên Máy leo cầu thang';

  @override
  String get treadmillWorkout => 'Bài tập Máy chạy bộ';

  @override
  String get bikeWorkout => 'Bài tập Xe đạp';

  @override
  String get stairmasterWorkout => 'Bài tập Máy leo cầu thang';

  @override
  String get startAWorkoutToSeeItHere => 'Bài tập của bạn sẽ hiện ở đây';

  @override
  String get mon => 'T2';

  @override
  String get tue => 'T3';

  @override
  String get wed => 'T4';

  @override
  String get thu => 'T5';

  @override
  String get fri => 'T6';

  @override
  String get sat => 'T7';

  @override
  String get sun => 'CN';

  @override
  String get sessions => 'Phiên';

  @override
  String get distance => 'Khoảng cách';

  @override
  String get today => 'Hôm nay';

  @override
  String get yesterday => 'Hôm qua';

  @override
  String get noWorkoutsYet => 'Chưa có bài tập nào';

  @override
  String get startYourFirstWorkout =>
      'Bắt đầu bài tập đầu tiên của bạn để xem lịch sử ở đây';

  @override
  String get goToRoutines => 'Đi đến Thói quen';

  @override
  String get weightRecorded => 'Cân nặng đã được ghi lại';

  @override
  String get workout => 'bài tập';

  @override
  String get workouts => 'bài tập';

  @override
  String get goal => 'Mục tiêu';

  @override
  String get toGo => 'còn lại';

  @override
  String get over => 'vượt quá';

  @override
  String get last => 'Lần trước';

  @override
  String get newLabel => 'Mới';

  @override
  String youNeed(String amount, String goal) {
    return 'Bạn cần $amount để đạt $goal';
  }

  @override
  String youNeedPlus(String amount, String goal) {
    return 'Bạn cần +$amount để đạt $goal';
  }

  @override
  String get current => 'Hiện tại';

  @override
  String get premiumHeadline => 'Cùng 30 phút, kết quả khác nhau';

  @override
  String get premiumSubheadlineNew =>
      'Đừng chỉ chạy, hãy tập luyện theo cách đốt cháy chất béo';

  @override
  String get mostPopular => 'Phổ Biến Nhất';

  @override
  String dailyPrice(int price) {
    return '$price mỗi ngày';
  }

  @override
  String get benefitVoiceCoaching => 'Hệ Thống Huấn Luyện Giọng Nói Premium';

  @override
  String get benefitBackgroundIntervalNotifications =>
      'Thông báo chuyển hiệp khi dùng ứng dụng khác';

  @override
  String get benefitCycleStairmasterRoutines =>
      'Hỗ Trợ Đầy Đủ Tất Cả Thiết Bị Cardio';

  @override
  String get benefitUnlimitedRoutinesNew => 'Thư Viện Bài Tập Không Giới Hạn';

  @override
  String get benefitWeightFeature =>
      'Theo Dõi và Phân Tích Cân Nặng Thông Minh';

  @override
  String get benefitNoAdsFocus => 'Trải Nghiệm Premium Không Quảng Cáo';

  @override
  String get benefitFutureFeaturesNew =>
      'Tất cả các tính năng premium tương lai được bao gồm';

  @override
  String get mostChosen => 'Được chọn nhiều';

  @override
  String get canChangeAnytime => 'Đổi bất cứ lúc nào';

  @override
  String get startPremium => 'Lên Premium';

  @override
  String get cancelAnytimeKeepAccess =>
      'Hủy bất cứ lúc nào, vẫn dùng đến hết kỳ';

  @override
  String workoutDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tập luyện $count ngày 🔥',
      one: 'Tập luyện 1 ngày 🔥',
    );
    return '$_temp0';
  }

  @override
  String restDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ngày nghỉ $count ngày 🛏️',
      one: 'Ngày nghỉ 1 ngày 🛏️',
    );
    return '$_temp0';
  }

  @override
  String get workoutReminderTitle => 'Nhắc nhở';

  @override
  String get workoutReminderOff => 'Tắt';

  @override
  String get workoutReminderEveryDay => 'Mỗi ngày';

  @override
  String get workoutReminderSelectTime => 'Chọn giờ';

  @override
  String get workoutReminderPermissionRequired => 'Cần quyền thông báo.';

  @override
  String get workoutReminderTimeLabel => 'Giờ';
}
