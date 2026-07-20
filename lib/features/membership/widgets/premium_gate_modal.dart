import 'package:flutter/material.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'premium_bottom_sheet.dart';
import '../models/premium_feature.dart';

/// Reusable premium gate modal that shows feature-specific benefits
class PremiumGateModal {
  static void show(BuildContext context, PremiumFeature feature) {
    final l10n = AppLocalizations.of(context)!;

    List<String> benefits;
    switch (feature) {
      case PremiumFeature.voiceGuide:
        benefits = [
          l10n.voiceGuideBenefit1,
          l10n.voiceGuideBenefit2,
          l10n.voiceGuideBenefit3,
        ];
        break;
      case PremiumFeature.backgroundIntervalNotifications:
        benefits = [
          l10n.benefitBackgroundIntervalNotifications,
          l10n.voiceGuideBenefit2,
          l10n.voiceGuideBenefit3,
        ];
        break;
      case PremiumFeature.unlimitedRoutines:
        benefits = [
          l10n.benefitUnlimitedRoutines,
          l10n.benefitCycleStairmaster,
          l10n.benefitVoiceGuide,
        ];
        break;
      case PremiumFeature.bike:
      case PremiumFeature.stairmaster:
        benefits = [
          l10n.benefitCycleStairmaster,
          l10n.benefitVoiceGuide,
          l10n.benefitUnlimitedRoutines,
        ];
        break;
    }

    PremiumBottomSheet.show(
      context,
      title: l10n.premiumMembership,
      bulletItems: benefits,
    );
  }
}
