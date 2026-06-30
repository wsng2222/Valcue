import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UnifiedScreenHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final double topSpacing;

  const UnifiedScreenHeader({
    super.key,
    required this.icon,
    required this.title,
    this.topSpacing = 40,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Column(
      children: [
        SizedBox(height: topSpacing),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 32,
            color: accent,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            color: theme.colorScheme.onSurface,
            letterSpacing: -1.0,
          ),
        ),
      ],
    );
  }
}
