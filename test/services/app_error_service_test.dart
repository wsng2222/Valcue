import 'package:flutter_test/flutter_test.dart';
import 'package:interval_cardio/services/app_error_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppErrorService.instance.clearReports();
  });

  test('records and loads recent error reports', () async {
    await AppErrorService.instance.recordError(
      StateError('boom'),
      StackTrace.current,
      source: 'test',
      fatal: true,
    );

    final reports = await AppErrorService.instance.loadReports();

    expect(reports, hasLength(1));
    expect(reports.single.source, 'test');
    expect(reports.single.fatal, isTrue);
    expect(reports.single.message, contains('boom'));
  });
}
