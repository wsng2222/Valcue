import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valcue/features/account/account_models.dart';
import 'package:valcue/features/account/account_service.dart';
import 'package:valcue/features/account/backup_service.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'package:valcue/l10n/app_localizations_en.dart';
import 'package:valcue/onboarding/screens/onboarding_screen_backup.dart';
import 'package:valcue/theme/app_theme.dart';

/// Signing in during onboarding once moved on without syncing, so someone
/// reinstalling saw an empty app until the next launch - and a failed
/// sign-in moved on too, looking exactly like success.
void main() {
  final l10n = AppLocalizationsEn();

  testWidgets('a successful sign-in starts a sync and moves on',
      (tester) async {
    final backup = _FakeBackup();
    var nexts = 0;
    await _pump(
      tester,
      account: _FakeAccount(const SignInResult(SignInStatus.upgradedGuest)),
      backup: backup,
      onNext: () => nexts++,
    );

    await _signInWithGoogle(tester, l10n);

    expect(backup.syncs, 1);
    expect(nexts, 1);
  });

  testWidgets('a failed sign-in says so and stays put', (tester) async {
    final backup = _FakeBackup();
    var nexts = 0;
    await _pump(
      tester,
      account: _FakeAccount(const SignInResult(SignInStatus.failed)),
      backup: backup,
      onNext: () => nexts++,
    );

    await _signInWithGoogle(tester, l10n);

    expect(find.text(l10n.signInFailed), findsOneWidget);
    expect(backup.syncs, 0);
    expect(nexts, 0);
  });

  testWidgets('closing the sheet stays put without syncing', (tester) async {
    final backup = _FakeBackup();
    var nexts = 0;
    await _pump(
      tester,
      account: _FakeAccount(const SignInResult(SignInStatus.signedIn)),
      backup: backup,
      onNext: () => nexts++,
    );

    await tester.tap(find.byType(ElevatedButton));
    await _settle(tester);
    await tester.tap(find.text(l10n.signInAsGuest));
    await _settle(tester);

    expect(backup.syncs, 0);
    expect(nexts, 0);
  });
}

Future<void> _signInWithGoogle(
  WidgetTester tester,
  AppLocalizations l10n,
) async {
  await tester.tap(find.byType(ElevatedButton));
  await _settle(tester);
  await tester.tap(find.text(l10n.signInWithGoogle));
  await _settle(tester);
}

/// The sheet animates in and out; a fixed pump avoids waiting on anything
/// that might animate forever.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

Future<void> _pump(
  WidgetTester tester, {
  required AccountService account,
  required BackupService backup,
  required VoidCallback onNext,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.lightTheme,
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: OnboardingScreenBackup(
          onNext: onNext,
          service: account,
          backup: backup,
        ),
      ),
    ),
  );
  await tester.pump();
}

class _FakeAccount implements AccountService {
  _FakeAccount(this.result);

  final SignInResult result;

  @override
  bool get supportsApple => false;

  @override
  Future<SignInResult> signInWithGoogle() async => result;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBackup implements BackupService {
  int syncs = 0;

  @override
  final ValueNotifier<int> localRecordsChanged = ValueNotifier<int>(0);

  @override
  Future<BackupResult> syncAfterSignIn() async {
    syncs++;
    return const BackupResult(BackupStatus.synced);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
