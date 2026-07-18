import 'package:flutter/material.dart';
import 'achievement_translations.dart';

class Achievement {
  final String id;
  final String titleKo;
  final String titleEn;
  final String descriptionKo;
  final String descriptionEn;
  final IconData icon;
  final List<Color> gradientColors;
  
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final double progress; // 0.0 to 1.0
  final num currentValue;
  final num targetValue;

  Achievement({
    required this.id,
    required this.titleKo,
    required this.titleEn,
    required this.descriptionKo,
    required this.descriptionEn,
    required this.icon,
    required this.gradientColors,
    required this.isUnlocked,
    this.unlockedAt,
    required this.progress,
    required this.currentValue,
    required this.targetValue,
  });

  String getTitle(String languageCode) {
    return AchievementTranslations.getTitle(id, languageCode);
  }

  String getDescription(String languageCode) {
    return AchievementTranslations.getDescription(id, languageCode);
  }

  Achievement copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
    double? progress,
    num? currentValue,
    num? targetValue,
  }) {
    return Achievement(
      id: id,
      titleKo: titleKo,
      titleEn: titleEn,
      descriptionKo: descriptionKo,
      descriptionEn: descriptionEn,
      icon: icon,
      gradientColors: gradientColors,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      currentValue: currentValue ?? this.currentValue,
      targetValue: targetValue ?? this.targetValue,
    );
  }
}
