import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/bounceable.dart';
import '../../widgets/secondary_outlined_button.dart';
import 'account_models.dart';
import 'account_service.dart';

/// Offers Apple, Google, or carrying on as a guest.
///
/// Returns the [SignInResult] once someone signs in, or null if the sheet was
/// dismissed. Apple is offered on iOS only - see [AccountService.supportsApple].
Future<SignInResult?> showSignInSheet(
  BuildContext context, {
  AccountService? service,
}) {
  return showModalBottomSheet<SignInResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _SignInSheet(
      service: service ?? AccountService.instance,
    ),
  );
}

class _SignInSheet extends StatefulWidget {
  const _SignInSheet({required this.service});

  final AccountService service;

  @override
  State<_SignInSheet> createState() => _SignInSheetState();
}

class _SignInSheetState extends State<_SignInSheet> {
  /// Which provider is mid-flight, so both buttons cannot be tapped at once.
  AccountKind? _busy;

  bool get _isBusy => _busy != null;

  Future<void> _run(
    AccountKind kind,
    Future<SignInResult> Function() signIn,
  ) async {
    if (_isBusy) return;
    setState(() => _busy = kind);

    final result = await signIn();

    if (!mounted) return;
    setState(() => _busy = null);

    // Backing out of the provider's own sheet is not a failure, so the sheet
    // stays open and says nothing.
    if (result.status == SignInStatus.cancelled) return;

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AppBottomSheetFrame(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          8,
          24,
          24 + MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 40,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.signInTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.signInDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            if (widget.service.supportsApple) ...[
              _ProviderButton(
                label: l10n.signInWithApple,
                icon: Icons.apple,
                isLoading: _busy == AccountKind.apple,
                isEnabled: !_isBusy,
                background: theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                foreground: theme.brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white,
                onPressed: () => _run(
                  AccountKind.apple,
                  widget.service.signInWithApple,
                ),
              ),
              const SizedBox(height: 10),
            ],
            _ProviderButton(
              label: l10n.signInWithGoogle,
              icon: Icons.g_mobiledata,
              isLoading: _busy == AccountKind.google,
              isEnabled: !_isBusy,
              background: theme.colorScheme.surface,
              foreground: theme.colorScheme.onSurface,
              borderColor: context.appColors.border,
              onPressed: () => _run(
                AccountKind.google,
                widget.service.signInWithGoogle,
              ),
            ),
            const SizedBox(height: 14),
            SecondaryOutlinedButton(
              onPressed: _isBusy ? null : () => Navigator.of(context).pop(),
              borderColor: Colors.transparent,
              child: Text(
                l10n.signInAsGuest,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderButton extends StatelessWidget {
  const _ProviderButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.isEnabled,
    required this.background,
    required this.foreground,
    required this.onPressed,
    this.borderColor,
  });

  final String label;
  final IconData icon;
  final bool isLoading;
  final bool isEnabled;
  final Color background;
  final Color foreground;
  final Color? borderColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Bounceable(
      onTap: isEnabled ? onPressed : null,
      child: Opacity(
        opacity: isEnabled || isLoading ? 1 : 0.5,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
            border: borderColor == null
                ? null
                : Border.all(color: borderColor!),
          ),
          alignment: Alignment.center,
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(foreground),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 24, color: foreground),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: foreground,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
