
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/valcue_ui.dart';

/// iOS-like grouped settings section container
class SettingsSection extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const SettingsSection({
    super.key,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 4),
      decoration: valcueCardDecoration(context),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: children,
      ),
    );
  }
}

/// Individual settings row with icon, title, subtitle, and trailing widget
class SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color? iconBackground;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.iconColor,
    this.iconBackground,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;

    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      child: Row(
        children: [
          SettingsIconTile(
            icon: icon,
            color: iconColor,
            background: iconBackground,
          ),
          const SizedBox(width: 14),
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 13,
                      color: appColors.mutedText,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Trailing widget
          if (trailing != null) trailing!,
        ],
      ),
    );

    return Column(
      children: [
        onTap != null
            ? InkWell(
                onTap: onTap,
                child: content,
              )
            : content,
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: appColors.border,
            indent: 18,
            endIndent: 18,
          ),
      ],
    );
  }
}

/// Pastel rounded-square tile behind a settings icon.
class SettingsIconTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color? background;

  const SettingsIconTile({
    super.key,
    required this.icon,
    required this.color,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    // The spec's pastel chips are mixed against a white card, so they glare
    // as light-mode blocks on a dark one. Dark mode falls back to a
    // translucent wash of the icon's own color, which composites over
    // whatever card it lands on.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IconTile(
      icon: icon,
      background: (isDark ? null : background) ?? color.withValues(alpha: 0.15),
      foreground: color,
    );
  }
}

/// Header row for a settings card that hosts a segmented control below it.
class SettingsSegmentHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color? iconBackground;
  final String title;

  const SettingsSegmentHeader({
    super.key,
    required this.icon,
    required this.iconColor,
    this.iconBackground,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SettingsIconTile(icon: icon, color: iconColor, background: iconBackground),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
