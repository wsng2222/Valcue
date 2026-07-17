import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'package:valcue/theme/app_theme.dart';
import 'package:valcue/widgets/workout_reminder_time_picker_sheet.dart';

void main() {
  testWidgets('returns the selected reminder time from the shared sheet',
      (tester) async {
    TimeOfDay? picked;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  picked = await showWorkoutReminderTimePickerSheet(
                    context: context,
                    initialTime: const TimeOfDay(hour: 7, minute: 30),
                  );
                },
                child: const Text('open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('시간 선택'), findsOneWidget);
    expect(find.byType(CupertinoDatePicker), findsOneWidget);

    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();

    expect(picked, const TimeOfDay(hour: 7, minute: 30));
    expect(find.byType(CupertinoDatePicker), findsNothing);
  });
}
