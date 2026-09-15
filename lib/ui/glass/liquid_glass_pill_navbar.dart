import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A solid pill-shaped bottom navigation bar with a grey capsule behind the
/// selected item.
class LiquidGlassPillNavBar extends StatelessWidget {
  /// The current selected index (0-based).
  final int currentIndex;

  /// Callback when an item is tapped.
  final ValueChanged<int> onTap;

  /// List of navigation items. Each item should have an icon and label.
  final List<LiquidGlassNavItem> items;

  /// Maximum width for the navigation bar (default: 640, centers on larger screens).
  final double maxWidth;

  /// Height of the navigation bar (default: 70).
  final double height;

  /// Bottom margin from safe area (default: 10).
  final double bottomMargin;

  const LiquidGlassPillNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.maxWidth = 300.0, // Reduced for tighter layout
    this.height = 70.0,
    this.bottomMargin = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = mediaQuery.padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        14,
        8,
        14,
        bottomInset > 0 ? bottomInset : 14,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            for (var index = 0; index < items.length; index++)
              Expanded(
                child: _NavItem(
                  item: items[index],
                  isSelected: currentIndex == index,
                  onTap: () => onTap(index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Individual navigation item for the pill navbar.
class LiquidGlassNavItem {
  /// Icon to display.
  final IconData icon;

  /// Label text to display below the icon.
  final String label;

  /// Optional semantic label for accessibility.
  final String? semanticLabel;

  /// Optional custom icon size.
  final double? iconSize;

  const LiquidGlassNavItem({
    required this.icon,
    required this.label,
    this.semanticLabel,
    this.iconSize,
  });
}

/// Internal widget for individual navigation items.
class _NavItem extends StatelessWidget {
  final LiquidGlassNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isSelected
        ? theme.colorScheme.primary
        : (isDark
            ? Colors.white.withValues(alpha: 0.85)
            : Colors.black.withValues(alpha: 0.85));

    return Semantics(
      label: item.semanticLabel ?? item.label,
      selected: isSelected,
      button: true,
      child: _BouncyTabItem(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 4),
          constraints: const BoxConstraints(minHeight: 54, minWidth: 44),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: isSelected ? 28 : 26, color: color),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: color,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BouncyTabItem extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _BouncyTabItem({
    required this.child,
    required this.onTap,
  });

  @override
  State<_BouncyTabItem> createState() => _BouncyTabItemState();
}

class _BouncyTabItemState extends State<_BouncyTabItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    if (mediaQuery.disableAnimations) {
      return GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: widget.child,
      );
    }

    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
