import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../widgets/platform_icon.dart';

class SwipeRevealDelete extends StatefulWidget {
  final String itemId;
  final Widget child;
  final VoidCallback onDelete;
  final double? buttonDiameter;
  final double? actionWidth;

  const SwipeRevealDelete({
    super.key,
    required this.itemId,
    required this.child,
    required this.onDelete,
    this.buttonDiameter,
    this.actionWidth,
  });

  @override
  State<SwipeRevealDelete> createState() => _SwipeRevealDeleteState();
}

class _SwipeRevealDeleteState extends State<SwipeRevealDelete> {
  static const double _triggerOffset = 44;
  static final ValueNotifier<String?> _openItemId =
      ValueNotifier<String?>(null);
  double _dragOffset = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _openItemId.addListener(_handleOpenItemChanged);
  }

  @override
  void dispose() {
    _openItemId.removeListener(_handleOpenItemChanged);
    super.dispose();
  }

  void _handleOpenItemChanged() {
    if (!mounted) return;
    final openItemId = _openItemId.value;
    if (openItemId != widget.itemId && _dragOffset != 0) {
      setState(() {
        _dragOffset = 0;
      });
    }
  }

  void _handleDragUpdate(DragUpdateDetails details, double actionWidth) {
    if (_openItemId.value != widget.itemId) {
      _openItemId.value = widget.itemId;
    }
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final logicalDelta = isRtl ? -details.delta.dx : details.delta.dx;
    final nextOffset = (_dragOffset + logicalDelta).clamp(-actionWidth, 0.0);
    setState(() {
      _isDragging = true;
      _dragOffset = nextOffset;
    });
  }

  void _handleDragEnd(DragEndDetails details, double actionWidth) {
    final shouldOpen = _dragOffset.abs() > _triggerOffset;
    setState(() {
      _isDragging = false;
      _dragOffset = shouldOpen ? -actionWidth : 0;
    });
    _openItemId.value = shouldOpen ? widget.itemId : null;
  }

  void _close() {
    if (_dragOffset == 0) return;
    setState(() {
      _isDragging = false;
      _dragOffset = 0;
    });
    if (_openItemId.value == widget.itemId) {
      _openItemId.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonDiameter = widget.buttonDiameter ?? 52.0;
    final actionWidth = widget.actionWidth ?? (buttonDiameter + 20);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (details) =>
          _handleDragUpdate(details, actionWidth),
      onHorizontalDragEnd: (details) => _handleDragEnd(details, actionWidth),
      onTap: _close,
      child: Stack(
        children: [
          PositionedDirectional(
            top: 0,
            bottom: 0,
            end: 2,
            width: actionWidth,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Container(
                width: buttonDiameter,
                height: buttonDiameter,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: widget.onDelete,
                    child: Center(
                      child: PlatformIcon(
                        cupertino: CupertinoIcons.trash,
                        material: Icons.delete_outline,
                        color: Colors.white,
                        size: buttonDiameter * 0.42,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration:
                _isDragging ? Duration.zero : const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(
              _dragOffset.clamp(-actionWidth, 0.0) *
                  (Directionality.of(context) == TextDirection.rtl ? -1 : 1),
              0,
              0,
            ),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
