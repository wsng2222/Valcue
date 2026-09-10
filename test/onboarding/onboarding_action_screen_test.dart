import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valcue/onboarding/screens/onboarding_action_screen.dart';

/// The health and backup screens share this layout. It once used a Spacer
/// inside a scroll view, which gives its child unbounded height - the whole
/// screen failed to lay out and rendered blank, with no way forward.
void main() {
  testWidgets('shows its text and both buttons', (tester) async {
    await _pump(tester);

    expect(find.text('Title here'), findsOneWidget);
    expect(find.text('Body here'), findsOneWidget);
    expect(find.text('Do it'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lays out on a short screen without overflowing',
      (tester) async {
    // A small phone in landscape is the case that used to break.
    await _pump(tester, size: const Size(360, 420));

    expect(find.text('Do it'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lays out on a tall screen too', (tester) async {
    await _pump(tester, size: const Size(430, 932));

    expect(find.text('Do it'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the skip button really moves on', (tester) async {
    var skipped = 0;
    await _pump(tester, onSkip: () => skipped++);

    await tester.tap(find.text('Not now'));
    await tester.pump();

    expect(skipped, 1);
  });

  testWidgets('both buttons are disabled while busy', (tester) async {
    // Otherwise a second tap starts a second permission prompt or sign-in.
    var primary = 0;
    var skipped = 0;
    await _pump(
      tester,
      isBusy: true,
      onPrimary: () => primary++,
      onSkip: () => skipped++,
    );

    await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
    await tester.tap(find.text('Not now'), warnIfMissed: false);
    await tester.pump();

    expect(primary, 0);
    expect(skipped, 0);
  });
}

Future<void> _pump(
  WidgetTester tester, {
  Size size = const Size(393, 852),
  bool isBusy = false,
  VoidCallback? onPrimary,
  VoidCallback? onSkip,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: OnboardingActionScreen(
          icon: Icons.favorite_outline,
          iconColor: Colors.red,
          title: 'Title here',
          body: 'Body here',
          primaryLabel: 'Do it',
          skipLabel: 'Not now',
          isBusy: isBusy,
          onPrimary: onPrimary ?? () {},
          onSkip: onSkip ?? () {},
        ),
      ),
    ),
  );
  await tester.pump();
}
