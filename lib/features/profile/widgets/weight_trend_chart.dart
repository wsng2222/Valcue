import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'package:valcue/l10n/localized_format.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/app_shadows.dart';
import '../models/weight_entry.dart';
import '../providers/weight_tracker_provider.dart';
import '../../../widgets/app_segmented_control.dart';

Color _weightSegmentSelectedBackground(BuildContext context) {
  return context.appColors.surfaceElevated;
}

SegmentedButtonThemeData _weightSegmentThemeData(
  BuildContext context,
  Color selectedBackground,
) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final selectedForeground = isDark ? Colors.white : Colors.black87;
  final borderColor = theme.colorScheme.outline.withValues(alpha: 0.35);

  return SegmentedButtonThemeData(
    style: SegmentedButton.styleFrom(
      selectedBackgroundColor: selectedBackground,
      selectedForegroundColor: selectedForeground,
      foregroundColor: theme.colorScheme.onSurface,
      backgroundColor: theme.colorScheme.surface,
      side: BorderSide(color: borderColor),
      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    ),
  );
}

class WeightTrendChart extends StatefulWidget {
  final int timeframe; // 0: 7D, 1: 30D, 2: 90D, 3: ALL

  const WeightTrendChart({super.key, required this.timeframe});

  @override
  State<WeightTrendChart> createState() => _WeightTrendChartState();
}

class _WeightTrendChartState extends State<WeightTrendChart> {
  late int _selectedTimeframe;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _selectedTimeframe = widget.timeframe;
  }

  void _updateHoveredIndex(double localX, double totalWidth, int entryCount) {
    if (entryCount < 2 || totalWidth <= 0) return;
    final availableWidth = totalWidth - 20.0;
    final painterX = (localX - 10.0).clamp(0.0, availableWidth);
    final stepX = availableWidth / (entryCount - 1);
    final calculatedIndex = (painterX / stepX).round().clamp(0, entryCount - 1);

    if (_hoveredIndex != calculatedIndex) {
      setState(() {
        _hoveredIndex = calculatedIndex;
      });
      HapticFeedback.selectionClick();
    }
  }

  void _clearHoveredIndex() {
    if (_hoveredIndex != null) {
      setState(() {
        _hoveredIndex = null;
      });
    }
  }

  Widget _buildTooltip(WeightEntry entry, double chartWidth, double chartHeight,
      int index, int entryCount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final availableWidth = chartWidth - 20.0;
    final stepX = availableWidth / (entryCount - 1);
    final pointX = 10.0 + index * stepX;

    const tooltipWidth = 100.0;
    final leftPos =
        (pointX - tooltipWidth / 2).clamp(4.0, chartWidth - tooltipWidth - 4.0);

    final formattedDate = LocalizedFormat.monthDay(context, entry.dateTime);

    return Positioned(
      left: leftPos,
      top: -46,
      child: Container(
        width: tooltipWidth,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: context.appColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${LocalizedFormat.decimal(context, entry.weightKg)} kg',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeightTrackerProvider>(
      builder: (context, provider, child) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final appColors = theme.extension<AppColors>()!;

        Widget buildHeader() {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  AppLocalizations.of(context)!.trend,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Flexible(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: PlatformInfo.isIOS
                      ? ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 240),
                          child: _TimeframeSelector(
                            selectedIndex: _selectedTimeframe,
                            onSelect: (index) {
                              setState(() {
                                _selectedTimeframe = index;
                              });
                            },
                          ),
                        )
                      : _TimeframeSelector(
                          selectedIndex: _selectedTimeframe,
                          onSelect: (index) {
                            setState(() {
                              _selectedTimeframe = index;
                            });
                          },
                        ),
                ),
              ),
            ],
          );
        }

        Widget buildTrendCard({required Widget body}) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : appColors.border,
                width: 1,
              ),
              boxShadow: AppShadows.elevatedSoft,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHeader(),
                const SizedBox(height: 16),
                body,
              ],
            ),
          );
        }

        // Filter entries by timeframe
        final now = DateTime.now();
        List<WeightEntry> chartEntries;
        switch (_selectedTimeframe) {
          case 0: // 7D
            final cutoff = now.subtract(const Duration(days: 7));
            chartEntries = provider.entries
                .where((e) => !e.dateTime.isBefore(cutoff))
                .toList()
                .reversed
                .toList();
            break;
          case 1: // 30D
            final cutoff = now.subtract(const Duration(days: 30));
            chartEntries = provider.entries
                .where((e) => !e.dateTime.isBefore(cutoff))
                .toList()
                .reversed
                .toList();
            break;
          case 2: // 90D
            final cutoff = now.subtract(const Duration(days: 90));
            chartEntries = provider.entries
                .where((e) => !e.dateTime.isBefore(cutoff))
                .toList()
                .reversed
                .toList();
            break;
          case 3: // ALL
          default:
            chartEntries = provider.entries.reversed.toList();
            break;
        }

        if (chartEntries.length < 2) {
          return buildTrendCard(
            body: SizedBox(
              height: 130,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.show_chart_rounded,
                      size: 34,
                      color: appColors.mutedText.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      AppLocalizations.of(context)!.addOneMoreRecordToSeeTrend,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: appColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final weights = chartEntries.map((e) => e.weightKg).toList();
        final minWeight = weights.reduce((a, b) => a < b ? a : b);
        final maxWeight = weights.reduce((a, b) => a > b ? a : b);
        final range = maxWeight - minWeight;
        final padding = range > 0 ? range * 0.1 : 1.0;

        return buildTrendCard(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(builder: (context, constraints) {
                final chartWidth = constraints.maxWidth;
                const chartHeight = 130.0;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onHorizontalDragStart: (details) {
                        _updateHoveredIndex(details.localPosition.dx,
                            chartWidth, chartEntries.length);
                      },
                      onHorizontalDragUpdate: (details) {
                        _updateHoveredIndex(details.localPosition.dx,
                            chartWidth, chartEntries.length);
                      },
                      onHorizontalDragEnd: (details) {
                        _clearHoveredIndex();
                      },
                      onHorizontalDragCancel: () {
                        _clearHoveredIndex();
                      },
                      onTapDown: (details) {
                        _updateHoveredIndex(details.localPosition.dx,
                            chartWidth, chartEntries.length);
                      },
                      onTapUp: (details) {
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) {
                            _clearHoveredIndex();
                          }
                        });
                      },
                      onTapCancel: () {
                        _clearHoveredIndex();
                      },
                      child: Container(
                        height: chartHeight,
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.03)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: CustomPaint(
                          painter: _WeightSparklinePainter(
                            entries: chartEntries,
                            minWeight: minWeight - padding,
                            maxWeight: maxWeight + padding,
                            color: theme.colorScheme.primary,
                            hoveredIndex: _hoveredIndex,
                            isDark: isDark,
                          ),
                          size: Size.infinite,
                        ),
                      ),
                    ),
                    if (_hoveredIndex != null &&
                        _hoveredIndex! < chartEntries.length)
                      _buildTooltip(chartEntries[_hoveredIndex!], chartWidth,
                          chartHeight, _hoveredIndex!, chartEntries.length),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _TimeframeSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _TimeframeSelector({
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final labels = [
      AppLocalizations.of(context)!.timeframe7D,
      AppLocalizations.of(context)!.timeframe30D,
      AppLocalizations.of(context)!.timeframe90D,
      AppLocalizations.of(context)!.timeframeAll,
    ];

    if (!PlatformInfo.isIOS) {
      final theme = Theme.of(context);
      final appColors = theme.extension<AppColors>()!;
      return Row(
        children: labels.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = selectedIndex == index;
          return Flexible(
            child: GestureDetector(
              onTap: () => onSelect(index),
              child: Container(
                margin: const EdgeInsetsDirectional.only(start: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : appColors.mutedText,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    final selectedBg = _weightSegmentSelectedBackground(context);
    final brightnessKey = Theme.of(context).brightness;

    return SegmentedButtonTheme(
      data: _weightSegmentThemeData(context, selectedBg),
      child: AppSegmentedControl(
        key: ValueKey('weight_timeframe_${brightnessKey.name}'),
        labels: labels,
        selectedIndex: selectedIndex,
        onValueChanged: onSelect,
        height: 32,
        shrinkWrap: true,
        color: selectedBg,
      ),
    );
  }
}

// Sparkline painter for weight trend
class _WeightSparklinePainter extends CustomPainter {
  final List<WeightEntry> entries;
  final double minWeight;
  final double maxWeight;
  final Color color;
  final int? hoveredIndex;
  final bool isDark;

  _WeightSparklinePainter({
    required this.entries,
    required this.minWeight,
    required this.maxWeight,
    required this.color,
    this.hoveredIndex,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty || entries.length == 1) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final stepX = size.width / (entries.length - 1);
    final weightRange = maxWeight - minWeight;

    // Draw horizontal grid bounds
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), gridPaint);
    canvas.drawLine(
        Offset(0, size.height), Offset(size.width, size.height), gridPaint);

    final points = <Offset>[];
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final x = (i * stepX).toDouble();
      final normalizedWeight =
          weightRange > 0 ? (entry.weightKg - minWeight) / weightRange : 0.5;
      final y = (size.height - (normalizedWeight * size.height)).toDouble();
      points.add(Offset(x, y));
    }

    final path = Path();
    final fillPath = Path();

    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      fillPath.moveTo(points.first.dx, size.height);
      fillPath.lineTo(points.first.dx, points.first.dy);

      // Straight segments between readings. A smoothed curve overshoots the
      // points it connects, inventing dips and peaks the user never weighed.
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
        fillPath.lineTo(points[i].dx, points[i].dy);
      }

      fillPath.lineTo(points.last.dx, size.height);
      fillPath.close();
    }

    // Draw gradient fill under the sparkline
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.22),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    // Draw main line path
    canvas.drawPath(path, paint);

    // Draw vertical guide line and hovered point indicator if active
    if (hoveredIndex != null && hoveredIndex! < entries.length) {
      final hX = (hoveredIndex! * stepX).toDouble();
      final hEntry = entries[hoveredIndex!];
      final hNormalizedWeight =
          weightRange > 0 ? (hEntry.weightKg - minWeight) / weightRange : 0.5;
      final hY = (size.height - (hNormalizedWeight * size.height)).toDouble();

      // Draw dashed vertical line
      final verticalLinePaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;

      const dashHeight = 4.0;
      const dashGap = 4.0;
      double startY = 0.0;
      while (startY < size.height) {
        canvas.drawLine(
          Offset(hX, startY),
          Offset(hX, (startY + dashHeight).clamp(0, size.height)),
          verticalLinePaint,
        );
        startY += dashHeight + dashGap;
      }

      // Draw circular indicator highlights
      final outerCirclePaint = Paint()
        ..color = color.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;
      final innerCirclePaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      final centerCirclePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(hX, hY), 8.0, outerCirclePaint);
      canvas.drawCircle(Offset(hX, hY), 5.0, innerCirclePaint);
      canvas.drawCircle(Offset(hX, hY), 2.5, centerCirclePaint);
    } else {
      // Draw standard dot on the final coordinate
      final lastIdx = entries.length - 1;
      final lX = (lastIdx * stepX).toDouble();
      final lEntry = entries[lastIdx];
      final lNormalizedWeight =
          weightRange > 0 ? (lEntry.weightKg - minWeight) / weightRange : 0.5;
      final lY = (size.height - (lNormalizedWeight * size.height)).toDouble();

      final pointPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(lX, lY), 4.0, pointPaint);
      canvas.drawCircle(Offset(lX, lY), 2.0, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_WeightSparklinePainter oldDelegate) {
    return oldDelegate.entries != entries ||
        oldDelegate.minWeight != minWeight ||
        oldDelegate.maxWeight != maxWeight ||
        oldDelegate.hoveredIndex != hoveredIndex;
  }
}

// Weight History List with swipe actions
