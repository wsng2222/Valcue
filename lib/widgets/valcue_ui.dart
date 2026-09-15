import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../utils/app_shadows.dart';

/// Shared building blocks for the Valcue visual language: bordered white
/// cards, grey chips, tinted icon tiles and the italic tab title header.

/// Horizontal gutter used by every tab screen.
const double kScreenGutter = 22;

/// Corner radius for content cards.
const double kCardRadius = 16;

BoxDecoration valcueCardDecoration(
  BuildContext context, {
  double radius = kCardRadius,
  Color? color,
  bool shadow = true,
}) {
  final theme = Theme.of(context);
  return BoxDecoration(
    color: color ?? theme.colorScheme.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: context.appColors.border),
    boxShadow: shadow ? AppShadows.elevatedSoft : null,
  );
}

class ValcueCard extends StatelessWidget {
  const ValcueCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: valcueCardDecoration(context),
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: card,
    );
  }
}

/// Italic tab title with a tinted round icon, e.g. "루틴" / "설정".
class TabTitleHeader extends StatelessWidget {
  const TabTitleHeader({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: appColors.tint,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lato(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.96,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Grey rounded chip with an optional leading icon.
class ValcueChip extends StatelessWidget {
  const ValcueChip({
    super.key,
    required this.text,
    this.icon,
    this.fillIcon = false,
    this.muted = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
    this.fontSize = 15,
  });

  final String text;
  final IconData? icon;
  final bool fillIcon;
  final bool muted;
  final EdgeInsetsGeometry padding;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final textColor = muted ? appColors.mutedText : theme.colorScheme.onSurface;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: appColors.subtle,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 1, color: appColors.mutedText),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 36x36 rounded-square icon tile used in settings rows.
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.background,
    required this.foreground,
    this.icon,
    this.child,
    this.size = 36,
  });

  final Color background;
  final Color foreground;
  final IconData? icon;
  final Widget? child;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: child ?? Icon(icon, size: 20, color: foreground),
    );
  }
}

/// Solid red pill CTA. Italic variant matches "루틴 확인 / 시작".
class PrimaryPillButton extends StatelessWidget {
  const PrimaryPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 58,
    this.fontSize = 18,
    this.italic = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double fontSize;
  final bool italic;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final style = italic
        ? GoogleFonts.lato(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: -0.3,
          )
        : TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          );
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(padding: EdgeInsets.zero),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: fontSize + 2),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hairline-bordered transparent pill, e.g. "루틴 수정" / "운동 종료".
class OutlinePillButton extends StatelessWidget {
  const OutlinePillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 56,
    this.fontSize = 17,
    this.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double fontSize;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: theme.colorScheme.onSurface,
          side: BorderSide(color: context.appColors.border),
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 8)],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
