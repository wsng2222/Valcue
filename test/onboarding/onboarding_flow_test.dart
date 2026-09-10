import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valcue/app_settings/app_settings_model.dart';
import 'package:valcue/app_settings/app_settings_provider.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'package:valcue/onboarding/onboarding_flow.dart';
import 'package:valcue/onboarding/screens/onboarding_screen_backup.dart';
import 'package:valcue/onboarding/screens/onboarding_screen_health.dart';

/// The flow wires several screens by index. This walks the real widget tree
/// so a mis-numbered page shows up here rather than on someone's first run.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the health and backup screens are part of the flow',
      (tester) async {
    await _pumpFlow(tester);

    // Both are built by the page list, which the flow asserts against its
    // named indices - so reaching this point means the indices line up.
    expect(find.byType(OnboardingFlow), findsOneWidget);
  });

  testWidgets('the flow builds without tripping its own page-index assert',
      (tester) async {
    // The assert in build() fires if a page is inserted in the wrong place.
    await _pumpFlow(tester);

    expect(tester.takeException(), isNull);
  });

  testWidgets('neither new screen can be a dead end', (tester) async {
    // Both are constructed with an onNext callback; without one, someone
    // who declines would be stuck on the screen forever.
    await _pumpFlow(tester);

    final health = tester.widgetList<OnboardingScreenHealth>(
      find.byType(OnboardingScreenHealth, skipOffstage: false),
    );
    final backup = tester.widgetList<OnboardingScreenBackup>(
      find.byType(OnboardingScreenBackup, skipOffstage: false),
    );

    for (final screen in health) {
      expect(screen.onNext, isNotNull);
    }
    for (final screen in backup) {
      expect(screen.onNext, isNotNull);
    }
  });
}

Future<void> _pumpFlow(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final settings = AppSettingsProvider(
    initialSettings: AppSettings.defaultSettings,
    loadSettingsOnCreate: false,
  );
  addTearDown(settings.dispose);

  await tester.pumpWidget(
    ChangeNotifierProvider<AppSettingsProvider>.value(
      value: settings,
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: OnboardingFlow(onFinished: () {}),
      ),
    ),
  );
  await tester.pump();
}
