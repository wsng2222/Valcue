import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valcue/app_settings/app_settings_model.dart';
import 'package:valcue/app_settings/app_settings_provider.dart';
import 'package:valcue/features/settings/screens/settings_screen.dart';
import 'package:valcue/features/workout/widgets/flashing_metric_text.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'package:valcue/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('selects and previews the largest workout display preset',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final provider = AppSettingsProvider(
        initialSettings: AppSettings.defaultSettings,
        loadSettingsOnCreate: false,
      );
      addTearDown(provider.dispose);

      await tester.pumpWidget(
        ChangeNotifierProvider<AppSettingsProvider>.value(
          value: provider,
          child: MaterialApp(
            theme: ThemeData(
              extensions: const [
                AppColors(
                  surfaceElevated: Colors.white,
                  border: Color(0xFFE5E5EA),
                  mutedText: Color(0xFF8E8E93),
                  danger: Color(0xFFFF3B30),
                  dangerText: Color(0xFFFF3B30),
                ),
              ],
            ),
            locale: const Locale('en'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Workout Screen Size'), findsOneWidget);
      expect(find.text('Default'), findsOneWidget);
      expect(find.text('9.5 km/h'), findsNothing);

      await tester.tap(find.text('Workout Screen Size'));
      await tester.pumpAndSettle();

      expect(find.text('9.5 km/h'), findsOneWidget);
      expect(find.text('02:15'), findsOneWidget);
      expect(find.text('04:15'), findsOneWidget);
      expect(
        tester.getSize(
          find.byKey(const ValueKey('workout-display-size-back')),
        ),
        const Size.square(44),
      );
      final standardMetricSize = tester
          .widget<FlashingMetricText>(find.byType(FlashingMetricText))
          .style
          .fontSize!;

      await tester.tap(find.text('Largest'));
      await tester.pump();

      expect(provider.workoutDisplaySize, WorkoutDisplaySize.extraLarge);
      final largestMetricSize = tester
          .widget<FlashingMetricText>(find.byType(FlashingMetricText))
          .style
          .fontSize!;
      expect(largestMetricSize, greaterThan(standardMetricSize));
      final timerRect = tester.getRect(
        find.byKey(const ValueKey('workout-session-timer')),
      );
      final selectorRect = tester.getRect(
        find.byKey(const ValueKey('workout-display-size-selector-card')),
      );
      expect(selectorRect.height, lessThan(120));
      expect(timerRect.bottom, lessThanOrEqualTo(selectorRect.top));
      expect(tester.takeException(), isNull);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
