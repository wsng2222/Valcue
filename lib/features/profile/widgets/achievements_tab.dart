import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'package:valcue/l10n/localized_format.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../models/achievement.dart';
import '../models/achievement_translations.dart';
import '../providers/achievement_provider.dart';
import '../../../widgets/app_bottom_sheet.dart';

class AchievementsTab extends StatefulWidget {
  const AchievementsTab({super.key});

  @override
  State<AchievementsTab> createState() => _AchievementsTabState();
}

class _AchievementsTabState extends State<AchievementsTab> {
  int _filterIndex = 0; // 0: All, 1: Unlocked, 2: Locked

  // The summary card never changes while you browse, so it folds away as soon
  // as the list is scrolled down and comes back the moment you scroll up.
  bool _headerCollapsed = false;

  bool _handleScroll(ScrollNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }

    if (notification is UserScrollNotification) {
      final atTop = notification.metrics.pixels <= 0;
      if (notification.direction == ScrollDirection.reverse &&
          notification.metrics.pixels > 24 &&
          !_headerCollapsed) {
        setState(() => _headerCollapsed = true);
      } else if ((notification.direction == ScrollDirection.forward || atTop) &&
          _headerCollapsed) {
        setState(() => _headerCollapsed = false);
      }
    } else if (notification is ScrollUpdateNotification &&
        notification.metrics.pixels <= 0 &&
        _headerCollapsed) {
      // Bouncing back to the very top always restores the card.
      setState(() => _headerCollapsed = false);
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final langCode = Localizations.localeOf(context).languageCode;

    return Consumer<AchievementProvider>(
      builder: (context, provider, child) {
        final achievements = provider.achievements;
        if (achievements.isEmpty) {
          return Center(
            child: Text(
              AchievementTranslations.getUiString('no_achievements', langCode),
              style: TextStyle(color: appColors.mutedText),
            ),
          );
        }

        // Apply filters
        List<Achievement> filtered = achievements;
        if (_filterIndex == 1) {
          filtered = achievements.where((a) => a.isUnlocked).toList();
        } else if (_filterIndex == 2) {
          filtered = achievements.where((a) => !a.isUnlocked).toList();
        }

        // Count unlocked
        final unlockedCount = achievements.where((a) => a.isUnlocked).length;
        final totalCount = achievements.length;
        final completionRate =
            totalCount > 0 ? unlockedCount / totalCount : 0.0;

        // Custom User Title based on unlock count
        String userTitle = '';
        if (completionRate == 1.0) {
          userTitle =
              AchievementTranslations.getUiString('grand_master', langCode);
        } else if (completionRate >= 0.7) {
          userTitle =
              AchievementTranslations.getUiString('pace_master', langCode);
        } else if (completionRate >= 0.4) {
          userTitle =
              AchievementTranslations.getUiString('pro_runner', langCode);
        } else if (completionRate >= 0.1) {
          userTitle =
              AchievementTranslations.getUiString('active_beginner', langCode);
        } else {
          userTitle = AchievementTranslations.getUiString('trainee', langCode);
        }

        return Column(
          children: [
            const SizedBox(height: 16),
            // Premium Header stats card (folds away while the list scrolls)
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 240),
              sizeCurve: Curves.easeOutCubic,
              firstCurve: Curves.easeOut,
              secondCurve: Curves.easeOut,
              crossFadeState: _headerCollapsed
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              secondChild: const SizedBox(width: double.infinity),
              firstChild: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.08),
                            theme.colorScheme.secondary.withValues(alpha: 0.03),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.15),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Circular Progress
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 70,
                                height: 70,
                                child: CircularProgressIndicator(
                                  value: completionRate,
                                  strokeWidth: 6,
                                  backgroundColor: theme.colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.primary),
                                ),
                              ),
                              Text(
                                LocalizedFormat.percent(
                                    context, completionRate),
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userTitle,
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AchievementTranslations.getUiString(
                                    'unlocked_x_of_y',
                                    langCode,
                                    {
                                      'unlocked': LocalizedFormat.decimal(
                                        context,
                                        unlockedCount,
                                        decimalDigits: 0,
                                      ),
                                      'total': LocalizedFormat.decimal(
                                        context,
                                        totalCount,
                                        decimalDigits: 0,
                                      ),
                                    },
                                  ),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: appColors.mutedText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // completion text
                                Text(
                                  AchievementTranslations.getUiString(
                                      'collect_desc', langCode),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: appColors.mutedText
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // Elegant Pill Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _buildFilterButton(
                      0,
                      AchievementTranslations.getUiString(
                          'filter_all', langCode)),
                  const SizedBox(width: 8),
                  _buildFilterButton(
                      1,
                      AchievementTranslations.getUiString(
                          'filter_unlocked', langCode)),
                  const SizedBox(width: 8),
                  _buildFilterButton(
                      2,
                      AchievementTranslations.getUiString(
                          'filter_locked', langCode)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Premium Grid Layout
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        AchievementTranslations.getUiString(
                            'no_matching', langCode),
                        style: TextStyle(color: appColors.mutedText),
                      ),
                    )
                  : NotificationListener<ScrollNotification>(
                      onNotification: _handleScroll,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final ach = filtered[index];
                          return _buildAchievementListCard(
                              context, ach, appColors, langCode);
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterButton(int index, String label) {
    final theme = Theme.of(context);
    final isSelected = _filterIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterIndex = index;
        });
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.extension<AppColors>()!.border,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementListCard(
    BuildContext context,
    Achievement ach,
    AppColors appColors,
    String langCode,
  ) {
    final theme = Theme.of(context);
    final title = ach.getTitle(langCode);
    final desc = ach.getDescription(langCode);

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _showAchievementDetails(context, ach, langCode);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: ach.isUnlocked
              ? theme.colorScheme.surface
              : appColors.surfaceElevated.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ach.isUnlocked
                ? ach.gradientColors[0].withValues(alpha: 0.35)
                : appColors.border.withValues(alpha: 0.7),
            width: ach.isUnlocked ? 1.5 : 1.0,
          ),
          boxShadow: ach.isUnlocked
              ? [
                  BoxShadow(
                    color: ach.gradientColors[0].withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Badge icon circle
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: ach.isUnlocked
                        ? ach.gradientColors
                        : [Colors.grey.shade300, Colors.grey.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: ach.isUnlocked
                      ? [
                          BoxShadow(
                            color:
                                ach.gradientColors[0].withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Icon(
                  ach.isUnlocked ? ach.icon : Icons.lock_outline,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Texts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ach.isUnlocked
                                  ? theme.colorScheme.onSurface
                                  : appColors.mutedText,
                            ),
                          ),
                        ),
                        if (ach.isUnlocked && ach.unlockedAt != null)
                          Flexible(
                            child: Text(
                              _formatUnlockDateSimple(
                                  ach.unlockedAt!, langCode),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: appColors.mutedText,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: ach.isUnlocked
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.8)
                            : appColors.mutedText.withValues(alpha: 0.7),
                      ),
                    ),
                    if (!ach.isUnlocked) ...[
                      const SizedBox(height: 10),
                      // Progress Bar
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: ach.progress,
                                minHeight: 5,
                                backgroundColor: theme.colorScheme.primary
                                    .withValues(alpha: 0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _formatProgressShort(ach, langCode),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatUnlockDateSimple(DateTime dt, String langCode) {
    return LocalizedFormat.abbreviatedMonthDay(context, dt);
  }

  void _showAchievementDetails(
      BuildContext context, Achievement ach, String langCode) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final title = ach.getTitle(langCode);
    final desc = ach.getDescription(langCode);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return AppBottomSheetFrame(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 28),
                // Big icon with gradient glow
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: ach.isUnlocked
                          ? ach.gradientColors
                          : [Colors.grey.shade300, Colors.grey.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: ach.isUnlocked
                        ? [
                            BoxShadow(
                              color:
                                  ach.gradientColors[0].withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            )
                          ]
                        : null,
                  ),
                  child: Icon(
                    ach.isUnlocked ? ach.icon : Icons.lock_outline,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                // Description
                Text(
                  desc,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: appColors.mutedText,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                // Unlock detail card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: appColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: appColors.border),
                  ),
                  child: Column(
                    children: [
                      if (ach.isUnlocked && ach.unlockedAt != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                AchievementTranslations.getUiString(
                                    'unlock_date', langCode),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: appColors.mutedText, fontSize: 13),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                _formatUnlockDateDetailed(
                                    ach.unlockedAt!, langCode),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                AchievementTranslations.getUiString(
                                    'progress_label', langCode),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: appColors.mutedText, fontSize: 13),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                LocalizedFormat.percent(context, ach.progress),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ach.progress,
                            minHeight: 6,
                            backgroundColor: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                theme.colorScheme.primary),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                AchievementTranslations.getUiString(
                                    'current_value_label', langCode),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: appColors.mutedText, fontSize: 12),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                _formatProgressTextDetailed(ach, langCode),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                // Close button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      AchievementTranslations.getUiString('close', langCode),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatUnlockDateDetailed(DateTime dt, String langCode) {
    return LocalizedFormat.mediumDate(context, dt);
  }

  String _achievementValueWithUnit(
    String value,
    String unit,
    String langCode,
  ) {
    return const {'ja', 'ko', 'zh'}.contains(langCode)
        ? '$value$unit'
        : '$value $unit';
  }

  String _formatProgressShort(Achievement ach, String langCode) {
    final id = ach.id;
    if (id.startsWith('treadmill_dist_') ||
        id == 'treadmill_marathon' ||
        id.startsWith('cycle_dist_')) {
      final cur = ach.currentValue.toDouble();
      final target = ach.targetValue.toDouble();
      return '${LocalizedFormat.decimal(context, cur)} / ${LocalizedFormat.decimal(context, target, decimalDigits: 0)} km';
    }
    if (id.startsWith('treadmill_5k') ||
        id.startsWith('treadmill_10k') ||
        id.startsWith('treadmill_half_marathon')) {
      final cur = ach.currentValue.toDouble();
      final target = ach.targetValue.toDouble();
      return '${LocalizedFormat.decimal(context, cur)} / ${LocalizedFormat.decimal(context, target, decimalDigits: 0)} km';
    }
    if (id.startsWith('treadmill_speed_')) {
      return '${LocalizedFormat.decimal(context, ach.currentValue)} / ${LocalizedFormat.decimal(context, ach.targetValue, decimalDigits: 0)} km/h';
    }
    if (id.startsWith('cycle_rpm')) {
      return '${LocalizedFormat.decimal(context, ach.currentValue, decimalDigits: 0)}/${LocalizedFormat.decimal(context, ach.targetValue, decimalDigits: 0)}';
    }
    if (id.startsWith('stairmaster_level')) {
      return '${LocalizedFormat.decimal(context, ach.currentValue, decimalDigits: 0)}/${LocalizedFormat.decimal(context, ach.targetValue, decimalDigits: 0)}';
    }
    if (id.startsWith('duration_')) {
      final current = LocalizedFormat.decimal(
        context,
        ach.currentValue,
        decimalDigits: 0,
      );
      final target = LocalizedFormat.decimal(
        context,
        ach.targetValue,
        decimalDigits: 0,
      );
      final unit = AchievementTranslations.getUiString('min', langCode);
      return '$current/${_achievementValueWithUnit(target, unit, langCode)}';
    }
    if (id.startsWith('total_duration_') ||
        id.startsWith('stairmaster_time_')) {
      final current = LocalizedFormat.decimal(context, ach.currentValue);
      final target = LocalizedFormat.decimal(
        context,
        ach.targetValue,
        decimalDigits: 0,
      );
      final unit = AchievementTranslations.getUiString('hours', langCode);
      return '$current / ${_achievementValueWithUnit(target, unit, langCode)}';
    }
    return '${LocalizedFormat.decimal(context, ach.currentValue, decimalDigits: 0)}/${LocalizedFormat.decimal(context, ach.targetValue, decimalDigits: 0)}';
  }

  String _formatProgressTextDetailed(Achievement ach, String langCode) {
    final id = ach.id;
    if (id.startsWith('treadmill_dist_') ||
        id == 'treadmill_marathon' ||
        id.startsWith('cycle_dist_') ||
        id.startsWith('treadmill_5k') ||
        id.startsWith('treadmill_10k') ||
        id.startsWith('treadmill_half_marathon')) {
      final cur = LocalizedFormat.decimal(
        context,
        ach.currentValue,
        decimalDigits: 2,
      );
      final target = LocalizedFormat.decimal(
        context,
        ach.targetValue,
        decimalDigits: 0,
      );
      return '$cur km / $target km';
    }
    if (id.startsWith('treadmill_speed_')) {
      return '${LocalizedFormat.decimal(context, ach.currentValue, decimalDigits: 2)} km/h / ${LocalizedFormat.decimal(context, ach.targetValue, decimalDigits: 0)} km/h';
    }
    if (id.startsWith('cycle_rpm')) {
      final l10n = AppLocalizations.of(context)!;
      final current = LocalizedFormat.decimal(
        context,
        ach.currentValue,
        decimalDigits: 0,
      );
      final target = LocalizedFormat.decimal(
        context,
        ach.targetValue,
        decimalDigits: 0,
      );
      return '${l10n.rpmValue(current)} / ${l10n.rpmValue(target)}';
    }
    if (id.startsWith('stairmaster_level')) {
      final l10n = AppLocalizations.of(context)!;
      final current = LocalizedFormat.decimal(
        context,
        ach.currentValue,
        decimalDigits: 0,
      );
      final target = LocalizedFormat.decimal(
        context,
        ach.targetValue,
        decimalDigits: 0,
      );
      return '${l10n.levelColon(current)} / ${l10n.levelColon(target)}';
    }
    if (id.startsWith('duration_')) {
      final current = LocalizedFormat.decimal(
        context,
        ach.currentValue,
        decimalDigits: 0,
      );
      final target = LocalizedFormat.decimal(
        context,
        ach.targetValue,
        decimalDigits: 0,
      );
      final unit = AchievementTranslations.getUiString('min', langCode);
      return '${_achievementValueWithUnit(current, unit, langCode)} / '
          '${_achievementValueWithUnit(target, unit, langCode)}';
    }
    if (id.startsWith('total_duration_') ||
        id.startsWith('stairmaster_time_')) {
      final current = LocalizedFormat.decimal(context, ach.currentValue);
      final target = LocalizedFormat.decimal(
        context,
        ach.targetValue,
        decimalDigits: 0,
      );
      final unit = AchievementTranslations.getUiString('hours', langCode);
      return '${_achievementValueWithUnit(current, unit, langCode)} / '
          '${_achievementValueWithUnit(target, unit, langCode)}';
    }
    return '${LocalizedFormat.decimal(context, ach.currentValue, decimalDigits: 0)} / ${LocalizedFormat.decimal(context, ach.targetValue, decimalDigits: 0)}';
  }
}
