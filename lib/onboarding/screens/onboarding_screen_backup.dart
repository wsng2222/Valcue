import 'dart:async';

import 'package:flutter/material.dart';

import '../../features/account/account_service.dart';
import '../../features/account/backup_service.dart';
import '../../features/account/sign_in_sheet.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/app_message.dart';
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
    this.backup,
  });

  final VoidCallback onNext;
  final AccountService? service;
  final BackupService? backup;

  @override
  State<OnboardingScreenBackup> createState() => _OnboardingScreenBackupState();
}

class _OnboardingScreenBackupState extends State<OnboardingScreenBackup> {
  bool _isSigningIn = false;

  AccountService get _service => widget.service ?? AccountService.instance;
  BackupService get _backup => widget.backup ?? BackupService.instance;

  Future<void> _signIn() async {
    if (_isSigningIn) return;
    setState(() => _isSigningIn = true);

    final result = await showSignInSheet(context, service: _service);

    if (!mounted) return;
    setState(() => _isSigningIn = false);

    // Dismissing the sheet leaves them here to decide, rather than pushing
    // them forward as if they had chosen something.
    if (result == null) return;

    final l10n = AppLocalizations.of(context)!;
    if (!result.isSuccess) {
      // Staying put lets them try again; moving on would read as success.
      showAppMessage(context, l10n.signInFailed, type: AppMessageType.error);
      return;
    }

    if (result.needsMerge) {
      showAppMessage(context, l10n.signInMergeNotice);
    }

    // Someone reinstalling expects their records back right away, not on the
    // next launch. Not awaited: onboarding should not wait on the network.
    unawaited(_backup.syncAfterSignIn());
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final s = OnboardingStrings.of(context);

    return OnboardingActionScreen(
      icon: Icons.account_circle_outlined,
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
