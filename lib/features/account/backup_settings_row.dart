import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_message.dart';
import '../settings/widgets/settings_section.dart';
import 'account_models.dart';
import 'account_service.dart';
import 'sign_in_sheet.dart';

/// The settings entry point for backup: signs people in, shows who is signed
/// in, and signs them out again.
class BackupSettingsRow extends StatefulWidget {
  const BackupSettingsRow({super.key, this.service});

  final AccountService? service;

  @override
  State<BackupSettingsRow> createState() => _BackupSettingsRowState();
}

class _BackupSettingsRowState extends State<BackupSettingsRow> {
  AccountService get _service => widget.service ?? AccountService.instance;

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
              onTap: isBackedUp ? _confirmSignOut : _signIn,
              trailing: isBackedUp
                  ? null
                  : const Icon(Icons.chevron_right, size: 20),
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
    await _service.signOut();
  }
}
