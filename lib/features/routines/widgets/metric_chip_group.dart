import 'package:flutter/material.dart';

/// Widget for displaying a group of metric chips
class MetricChipGroup extends StatelessWidget {
  final List<String> items;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsets padding;
  final double spacing;

  const MetricChipGroup({
    super.key,
    required this.items,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.padding = const EdgeInsets.all(0),
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: spacing,
        runSpacing: 6.0,
        children: items
            .map(
              (item) => Chip(
                label: Text(
                  item,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            )
            .toList(),
      ),
    );
  }
}
