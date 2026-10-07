import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_settings/app_settings_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_message.dart';
import '../settings/widgets/settings_section.dart';
import 'account_models.dart';
import 'account_service.dart';
import 'backup_service.dart';
import 'profile_sheet.dart';
import 'sign_in_sheet.dart';

// Account-card colors from the Valcue design spec.
const Color _kSignedOutIconBg = Color(0xFFE3EBEF);
const Color _kSignedOutIconFg = Color(0xFF7A8B96);
const Color _kChevronBlue = Color(0xFF007AFF);
const Color _kBadgeBg = Color(0xFFD9F2EC);
const Color _kBadgeFg = Color(0xFF00806E);

/// Round 18px spinner sized to sit where a row's trailing control would.
class _RowSpinner extends StatelessWidget {
  const _RowSpinner();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

/// "Backed up" status pill. On a dark card the two spec colors swap roles -
/// the pale mint becomes the text and a wash of it becomes the fill - so the
/// badge stays legible instead of glaring like a light-mode sticker.
class _BackedUpBadge extends StatelessWidget {
  const _BackedUpBadge();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? _kBadgeBg.withValues(alpha: 0.18) : _kBadgeBg;
    final ink = isDark ? _kBadgeBg : _kBadgeFg;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_done, size: 15, color: ink),
          const SizedBox(width: 5),
          Text(
            AppLocalizations.of(context)!.backupActiveBadge,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// The profile card: avatar, name, and - once signed in - the address and a
/// badge saying the records are safe. Tapping it opens the profile editor.
/// Signing out and deleting the account are their own rows underneath, so
/// neither can happen by accidentally tapping here.
class _AccountIdentityRow extends StatelessWidget {
  const _AccountIdentityRow({this.accountName, this.email, this.trailing});

  /// The name the auth provider gave us, used only when no nickname is set.
  final String? accountName;
  final String? email;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<AppSettingsProvider>();

    final nickname = settings.profileName.trim();
    final fromAccount = accountName?.trim() ?? '';
    final displayName = nickname.isNotEmpty
        ? nickname
        : (fromAccount.isNotEmpty ? fromAccount : l10n.profileDefaultName);

    return Column(
      children: [
        InkWell(
          onTap: () => showProfileSheet(context),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            child: Row(
              children: [
                ProfileAvatar(
                  emoji: settings.avatarEmoji,
                  backgroundHex: settings.avatarBg,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (email != null && email!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          email!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: appColors.mutedText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // The badge only means anything once there is an account to
                // back up to, so a signed-out card just shows the chevron.
                if (trailing != null) ...[
                  trailing!,
                  const SizedBox(width: 6),
                ] else if (email != null && email!.isNotEmpty) ...[
                  const _BackedUpBadge(),
                  const SizedBox(width: 6),
                ],
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: appColors.mutedText,
                ),
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: appColors.border,
          indent: 18,
          endIndent: 18,
        ),
      ],
    );
  }
}

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

        if (!isBackedUp) {
          // Matches the design: signed out, this is only a sign-in row. The
          // profile card appears once there is an account to attach it to.
          return SettingsSection(
            children: [
              SettingsRow(
                icon: Icons.cloud_outlined,
                iconColor: _kSignedOutIconFg,
                iconBackground: _kSignedOutIconBg,
                title: l10n.backupSectionTitle,
                subtitle: l10n.backupGuestSubtitle,
                onTap: _isSyncing ? null : _signIn,
                trailing: _isSyncing
                    ? const _RowSpinner()
                    : const Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: _kChevronBlue,
                      ),
                showDivider: false,
              ),
            ],
          );
        }

        return SettingsSection(
          children: [
            _AccountIdentityRow(
              accountName: user?.displayName,
              email: user?.email,
              trailing: _isSyncing ? const _RowSpinner() : null,
            ),
            // Signing out leaves this phone's records alone, so it stays
            // neutral - the red chip below is reserved for the one action
            // that actually destroys something.
            SettingsRow(
              icon: Icons.logout,
              iconColor: _kSignedOutIconFg,
              iconBackground: _kSignedOutIconBg,
              title: l10n.signOut,
              onTap: _isSyncing ? null : _confirmSignOut,
            ),
            // Apple requires an in-app way to delete an account, so this
            // appears as soon as there is one to delete.
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

    // The backup goes before the credential. Deleting the credential first
    // would leave the records behind with nobody able to reach or remove
    // them.
    final status = await _service.deleteAccount(
      clearBackup: _backup.deleteEverythingBackedUp,
    );

    if (!mounted) return;
    setState(() => _isSyncing = false);

    if (status == DeleteAccountStatus.deleted ||
        status == DeleteAccountStatus.cancelled) {
      return;
    }
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
