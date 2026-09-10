import 'package:flutter/material.dart';

import '../../features/account/account_service.dart';
import '../../features/account/sign_in_sheet.dart';
import '../onboarding_strings.dart';
import '../widgets/onboarding_theme.dart';
import 'onboarding_action_screen.dart';

/// Offers to sign in so records survive a new phone.
///
/// Skipping is a first-class choice - people are here to try the app, not to
/// make an account - so declining moves on with no warning and no nagging.
class OnboardingScreenBackup extends StatefulWidget {
  const OnboardingScreenBackup({
    super.key,
    required this.onNext,
    this.service,
  });

  final VoidCallback onNext;
  final AccountService? service;

  @override
  State<OnboardingScreenBackup> createState() => _OnboardingScreenBackupState();
}

class _OnboardingScreenBackupState extends State<OnboardingScreenBackup> {
  bool _isSigningIn = false;

  AccountService get _service => widget.service ?? AccountService.instance;

  Future<void> _signIn() async {
    if (_isSigningIn) return;
    setState(() => _isSigningIn = true);

    final result = await showSignInSheet(context, service: _service);

    if (!mounted) return;
    setState(() => _isSigningIn = false);

    // Dismissing the sheet leaves them here to decide, rather than pushing
    // them forward as if they had chosen something.
    if (result == null) return;
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final s = OnboardingStrings.of(context);

    return OnboardingActionScreen(
      icon: Icons.cloud_upload_outlined,
      iconColor: OnboardingTheme.primaryRed,
      title: s.backupTitle(),
      body: s.backupBody(),
      primaryLabel: s.ctaSignInToBackUp(),
      skipLabel: s.ctaSkipForNow(),
      isBusy: _isSigningIn,
      onPrimary: _signIn,
      onSkip: widget.onNext,
    );
  }
}
