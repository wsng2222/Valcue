import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_message.dart';
import '../settings/widgets/settings_section.dart';
import 'account_models.dart';
import 'account_service.dart';
import 'backup_service.dart';
import 'sign_in_sheet.dart';

/// The settings entry point for backup: signs people in, shows who is signed
/// in, and signs them out again.
class BackupSettingsRow extends StatefulWidget {
  const BackupSettingsRow({super.key, this.service, this.backup});

  final AccountService? service;
  final BackupService? backup;

  @override
  State<BackupSettingsRow> createState() => _BackupSettingsRowState();
}

class _BackupSettingsRowState extends State<BackupSettingsRow> {
  AccountService get _service => widget.service ?? AccountService.instance;
  BackupService get _backup => widget.backup ?? BackupService.instance;

  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Rebuilt on every auth change so the row never lags behind the real
    // state - signing in elsewhere, a token refresh, or a sign-out.
    return StreamBuilder<AccountUser?>(
      stream: _service.changes,
      initialData: _service.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isBackedUp = user?.canBackUp ?? false;

        return SettingsSection(
          children: [
            SettingsRow(
              icon: isBackedUp ? Icons.cloud_done_outlined : Icons.cloud_outlined,
              iconColor: isBackedUp ? Colors.teal : Colors.blueGrey,
              title: l10n.backupSectionTitle,
              subtitle: isBackedUp
                  ? (user?.email ?? l10n.backupSignedInSubtitle)
                  : l10n.backupGuestSubtitle,
              onTap: _isSyncing
                  ? null
                  : (isBackedUp ? _confirmSignOut : _signIn),
              trailing: _isSyncing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : (isBackedUp
                      ? null
                      : const Icon(Icons.chevron_right, size: 20)),
            ),
            // Apple requires an in-app way to delete an account, so this
            // appears as soon as there is one to delete.
            if (isBackedUp)
              SettingsRow(
                icon: Icons.person_remove_outlined,
                iconColor: Theme.of(context).colorScheme.error,
                title: l10n.deleteAccount,
                onTap: _isSyncing ? null : _confirmDeleteAccount,
                showDivider: false,
              ),
          ],
        );
      },
    );
  }

  Future<void> _signIn() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showSignInSheet(context, service: _service);
    if (!mounted || result == null) return;

    if (!result.isSuccess) {
      showAppMessage(context, l10n.signInFailed, type: AppMessageType.error);
      return;
    }

    // Warn before the backup step runs, so nobody is surprised when records
    // from an older phone appear alongside the ones on this one.
    if (result.needsMerge) {
      showAppMessage(context, l10n.signInMergeNotice);
    }

    await _sync(_backup.syncAfterSignIn);
  }

  /// Runs a sync and reports only failure - a successful sync should feel
  /// like nothing happened, because the records are simply all there.
  Future<void> _sync(Future<BackupResult> Function() run) async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);

    final result = await run();

    if (!mounted) return;
    setState(() => _isSyncing = false);

    if (result.status == BackupStatus.failed ||
        result.status == BackupStatus.unavailable) {
      final l10n = AppLocalizations.of(context)!;
      // Debug builds name the cause, so a failure can be diagnosed from the
      // screen instead of only from a console nobody is watching.
      final reason = kDebugMode && result.errorCode != null
          ? '${l10n.backupFailed} (${result.errorCode})'
          : l10n.backupFailed;
      showAppMessage(context, reason, type: AppMessageType.error);
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showAppDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: l10n.deleteAccountConfirmTitle,
        message: l10n.deleteAccountConfirmBody,
        icon: Icons.warning_amber_rounded,
        iconColor: Theme.of(context).colorScheme.error,
        actions: [
          AppDialogAction(
            label: l10n.deleteAccount,
            style: AppDialogActionStyle.destructive,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          AppDialogAction(
            label: MaterialLocalizations.of(context).cancelButtonLabel,
            style: AppDialogActionStyle.secondary,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSyncing = true);

    // The backup goes first. Deleting the credential first would leave the
    // records behind with nobody able to reach or remove them.
    final clearedBackup = await _backup.deleteEverythingBackedUp();
    final status = clearedBackup
        ? await _service.deleteAccount()
        : DeleteAccountStatus.failed;

    if (!mounted) return;
    setState(() => _isSyncing = false);

    if (status == DeleteAccountStatus.deleted) return;
    showAppMessage(
      context,
      status == DeleteAccountStatus.needsRecentSignIn
          ? l10n.deleteAccountNeedsRecentSignIn
          : l10n.deleteAccountFailed,
      type: AppMessageType.error,
    );
  }

  Future<void> _confirmSignOut() async {
    final l10n = AppLocalizations.of(context)!;
    final shouldSignOut = await showAppDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: l10n.signOutConfirmTitle,
        message: l10n.signOutConfirmBody,
        icon: Icons.logout,
        actions: [
          AppDialogAction(
            label: l10n.signOut,
            style: AppDialogActionStyle.destructive,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          AppDialogAction(
            label: MaterialLocalizations.of(context).cancelButtonLabel,
            style: AppDialogActionStyle.secondary,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );

    if (shouldSignOut != true) return;
    // Whatever was recorded since the last sync goes up first. Signing out
    // without it strands those records outside the backup.
    await _sync(_backup.syncNow);
    await _service.signOut();
  }
}
