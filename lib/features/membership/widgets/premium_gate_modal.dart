import 'package:flutter/material.dart';
import 'package:interval_cardio/l10n/app_localizations.dart';
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
          (l10n as dynamic).voiceGuideBenefit1 ?? '운동 중 음성 안내',
          (l10n as dynamic).voiceGuideBenefit2 ?? '세션 전환 자동 안내',
          (l10n as dynamic).voiceGuideBenefit3 ?? '핸즈프리로 루틴 집중',
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

