import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../widgets/onboarding_theme.dart';

/// Shared layout for the onboarding screens that ask for one thing and let
/// people move past it: an icon, a short pitch, a primary button, and a
/// visibly lower-weight way to skip.
class OnboardingActionScreen extends StatelessWidget {
  const OnboardingActionScreen({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.skipLabel,
    required this.isBusy,
    required this.onPrimary,
    required this.onSkip,
    this.extra,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String primaryLabel;
  final String skipLabel;
  final bool isBusy;
  final VoidCallback onPrimary;
  final VoidCallback onSkip;

  /// Optional content between the pitch and the buttons.
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            // A scroll view gives its child unbounded height, and Spacer
            // below needs a bounded one. Without this the whole screen fails
            // to lay out and renders blank.
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Icon(icon, size: 56, color: iconColor),
                  const SizedBox(height: 22),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),
                  if (extra != null) ...[
                    const SizedBox(height: 24),
                    extra!,
                  ],
                  const Spacer(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: OnboardingTheme.ctaHeight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OnboardingTheme.primaryRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.buttonRadius),
                        ),
                        elevation: 0,
                      ),
                      onPressed: isBusy ? null : onPrimary,
                      child: isBusy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Text(
                              primaryLabel,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: isBusy ? null : onSkip,
                    child: Text(
                      skipLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
