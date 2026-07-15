import 'package:flutter/material.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'dart:async';

class HoldToStopButton extends StatefulWidget {
  final VoidCallback onStopConfirmed;

  const HoldToStopButton({
    super.key,
    required this.onStopConfirmed,
  });

  @override
  State<HoldToStopButton> createState() => _HoldToStopButtonState();
}

class _HoldToStopButtonState extends State<HoldToStopButton> {
  bool _isHolding = false;
  double _holdProgress = 0.0;
  Timer? _holdTimer;
  static const double _holdDuration = 1.2; // seconds

  void _startHold() {
    setState(() {
      _isHolding = true;
      _holdProgress = 0.0;
    });

    final startTime = DateTime.now();
    _holdTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      final elapsed =
          DateTime.now().difference(startTime).inMilliseconds / 1000.0;
      final progress = (elapsed / _holdDuration).clamp(0.0, 1.0);

      setState(() {
        _holdProgress = progress;
      });

      if (progress >= 1.0) {
        timer.cancel();
        _showConfirmDialog();
      }
    });
  }

  void _cancelHold() {
    _holdTimer?.cancel();
    setState(() {
      _isHolding = false;
      _holdProgress = 0.0;
    });
  }

  void _showConfirmDialog() {
    _holdTimer?.cancel();
    setState(() {
      _isHolding = false;
      _holdProgress = 0.0;
    });

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => SafeArea(
        top: false,
        bottom: false,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.endWorkoutQuestion,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        side: BorderSide(color: theme.dividerColor),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.continueWorkout,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onStopConfirmed();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.end,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTapDown: (_) => _startHold(),
      onTapUp: (_) => _cancelHold(),
      onTapCancel: () => _cancelHold(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_isHolding)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: _holdProgress,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.onPrimary.withValues(alpha: 0.3),
                    ),
                    minHeight: double.infinity,
                  ),
                ),
              ),
            Text(
              AppLocalizations.of(context)!.holdToStop,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
