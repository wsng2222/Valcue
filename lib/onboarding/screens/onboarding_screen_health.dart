import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_settings/app_settings_provider.dart';
import '../onboarding_strings.dart';
import '../widgets/onboarding_theme.dart';
import 'onboarding_action_screen.dart';

/// Offers to mirror finished workouts into Apple Health / Health Connect.
///
/// Declining moves on exactly like accepting: this is worth asking once, but
/// never worth blocking someone's first run over.
class OnboardingScreenHealth extends StatefulWidget {
  const OnboardingScreenHealth({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  State<OnboardingScreenHealth> createState() => _OnboardingScreenHealthState();
}

class _OnboardingScreenHealthState extends State<OnboardingScreenHealth> {
  bool _isConnecting = false;

  Future<void> _connect() async {
    if (_isConnecting) return;
    setState(() => _isConnecting = true);

    // The health store may refuse. Either way onboarding continues - the
    // setting is still there to turn on later.
    await context.read<AppSettingsProvider>().updateHealthSync(true);

    if (!mounted) return;
    setState(() => _isConnecting = false);
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final s = OnboardingStrings.of(context);

    return OnboardingActionScreen(
      icon: Icons.favorite_outline,
      iconColor: OnboardingTheme.primaryRed,
      title: s.healthTitle(),
      body: s.healthBody(),
      primaryLabel: s.ctaConnectHealth(),
      skipLabel: s.ctaSkipForNow(),
      isBusy: _isConnecting,
      onPrimary: _connect,
      onSkip: widget.onNext,
    );
  }
}
