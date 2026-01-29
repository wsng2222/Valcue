import 'package:flutter/material.dart';
import 'package:interval_cardio/l10n/app_localizations.dart';
import '../../../app_shell/app_shell.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/bottom_sheet_utils.dart';

/// Reusable premium bottom sheet with consistent styling
/// Used for premium gates, membership promotions, etc.
class PremiumBottomSheet {
  static void show(
    BuildContext context, {
    required String title,
    String? description,
    required List<String> bulletItems,
    String? primaryButtonText,
    VoidCallback? onPrimary,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: theme.colorScheme.shadow.withValues(alpha: 0.4),
      isDismissible: true,
      builder: (context) => _PremiumBottomSheetContent(
        title: title,
        description: description,
        bulletItems: bulletItems,
        primaryButtonText: primaryButtonText ?? l10n.viewMembership,
        onPrimary: onPrimary ??
            () {
              Navigator.pop(context);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                AppShell.navigateToPremiumTab();
              });
            },
      ),
    );
  }
}

class _PremiumBottomSheetContent extends StatelessWidget {
  final String title;
  final String? description;
  final List<String> bulletItems;
  final String primaryButtonText;
  final VoidCallback onPrimary;

  const _PremiumBottomSheetContent({
    required this.title,
    this.description,
    required this.bulletItems,
    required this.primaryButtonText,
    required this.onPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            // Description (optional)
            if (description != null) ...[
              const SizedBox(height: 12),
              Text(
                description!,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.extension<AppColors>()!.mutedText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            // Benefits list
            ...bulletItems.asMap().entries.map((entry) {
              final isLast = entry.key == bulletItems.length - 1;
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                child: _buildBenefitItem(context, entry.value),
              );
            }),
            const SizedBox(height: 32),
            // Primary CTA Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPrimary,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  primaryButtonText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // Respects system bottom inset and adds minimal padding
            SizedBox(height: 12 + BottomSheetUtils.getSystemBottomInset(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
