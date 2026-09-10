import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valcue/app_settings/app_settings_model.dart';
import 'package:valcue/app_settings/app_settings_provider.dart';
import 'package:valcue/features/settings/screens/settings_screen.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'package:valcue/onboarding/onboarding_flow.dart';
import 'package:valcue/theme/app_theme.dart';

/// Tapping the About row replays the first-run walkthrough. The row also
/// still hides the store-screenshot tool, now behind a long press, so both
/// gestures are checked together.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('tapping About opens the walkthrough again', (tester) async {
    await _pumpSettings(tester);

    await tester.tap(_aboutRow(), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(OnboardingGate), findsOneWidget);
  });

  testWidgets('a single tap does not open the screenshot tool',
      (tester) async {
    // It used to take 30 taps. Now one tap navigates, so the counter can
    // never reach 30 - the tool has to live on a different gesture.
    await _pumpSettings(tester);

    await tester.tap(_aboutRow(), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(OnboardingGate), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a long press does not open the walkthrough', (tester) async {
    await _pumpSettings(tester);

    await tester.longPress(_aboutRow(), warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(OnboardingGate), findsNothing);
  });
}

Finder _aboutRow() {
  return find
      .ancestor(
        of: find.byIcon(Icons.info_outline),
        matching: find.byType(GestureDetector),
      )
      .first;
}

Future<void> _pumpSettings(WidgetTester tester) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  addTearDown(() => debugDefaultTargetPlatformOverride = null);

  SharedPreferences.setMockInitialValues(<String, Object>{});
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
  await tester.scrollUntilVisible(
    find.byIcon(Icons.info_outline),
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pump();
}
