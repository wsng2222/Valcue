import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'package:valcue/l10n/localized_format.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/valcue_ui.dart';
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
            const SizedBox(height: 18),
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
                    padding: const EdgeInsets.symmetric(horizontal: 22.0),
                    child: Container(
                      padding: const EdgeInsets.all(18.0),
                      decoration: BoxDecoration(
                        color: appColors.tint,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          // Circular Progress
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 72,
                                height: 72,
                                child: CircularProgressIndicator(
                                  value: completionRate,
                                  strokeWidth: 6,
                                  backgroundColor: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.06),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.primary),
                                ),
                              ),
                              Text(
                                LocalizedFormat.percent(
                                    context, completionRate),
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userTitle,
                                  style: TextStyle(
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
                                    fontSize: 15,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // completion text
                                Text(
                                  AchievementTranslations.getUiString(
                                      'collect_desc', langCode),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: appColors.mutedText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
            // Elegant Pill Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
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
            const SizedBox(height: 14),
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
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.extension<AppColors>()!.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.extension<AppColors>()!.mutedText,
            fontWeight: FontWeight.w700,
            fontSize: 14,
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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: valcueCardDecoration(context),
        child: Row(
          children: [
            // Badge icon circle
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ach.isUnlocked
                    ? const Color(0xFFFFB100)
                    : appColors.subtle,
              ),
              child: Icon(
                ach.isUnlocked ? ach.icon : Icons.lock,
                color: ach.isUnlocked ? Colors.white : appColors.mutedText,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            // Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: ach.isUnlocked
                          ? theme.colorScheme.onSurface
                          : appColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: appColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: ach.isUnlocked ? 1.0 : ach.progress,
                      minHeight: 6,
                      backgroundColor: appColors.subtle,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Fixed width so every row's progress bar ends at the same x,
            // whether the trailing label is a date or a short count.
            SizedBox(
              width: 56,
              child: Text(
                ach.isUnlocked && ach.unlockedAt != null
                    ? _formatUnlockDateSimple(ach.unlockedAt!, langCode)
                    : _formatProgressShort(ach, langCode),
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
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
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
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
