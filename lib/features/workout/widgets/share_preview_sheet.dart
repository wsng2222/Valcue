import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;
import 'package:valcue/l10n/app_localizations.dart';
import '../../routines/models/routine.dart';
import '../../routines/models/machine_type.dart';
import '../../../widgets/app_bottom_sheet.dart';
import '../../../widgets/app_message.dart';
import '../../../utils/debug_log.dart';
import 'workout_share_card.dart';

class SharePreviewSheet extends StatefulWidget {
  final Routine routine;
  final int elapsedSeconds;
  final double? distanceMeters;
  final DateTime finishTime;
  final int currentIntervalIndex;
  final int elapsedSecondsInCurrentSession;
  final String? imagePath;

  const SharePreviewSheet({super.key, 
    required this.routine,
    required this.elapsedSeconds,
    this.distanceMeters,
    required this.finishTime,
    required this.currentIntervalIndex,
    required this.elapsedSecondsInCurrentSession,
    this.imagePath,
  });

  @override
  State<SharePreviewSheet> createState() => _SharePreviewSheetState();
}

class _SharePreviewSheetState extends State<SharePreviewSheet> {
  String _aspectRatio = '9:14'; // '9:14', '9:16', '1:1'
  final GlobalKey _cardKey = GlobalKey();
  bool _isSharing = false;

  double get _cardW => 360.0;
  double get _cardH {
    if (_aspectRatio == '9:16') return 640.0;
    if (_aspectRatio == '1:1') return 360.0;
    return 560.0; // '9:14'
  }

  Future<void> _shareCardImage() async {
    setState(() {
      _isSharing = true;
    });

    final shareErrorMessage =
        AppLocalizations.of(context)!.unableToShareWorkout;
    try {
      // Wait for layout/paint
      await Future.delayed(const Duration(milliseconds: 300));
      final renderObject = _cardKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        if (mounted) {
          setState(() {
            _isSharing = false;
          });
        }
        return;
      }

      final image = await renderObject.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        if (mounted) {
          setState(() {
            _isSharing = false;
          });
        }
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/workout_result_${_aspectRatio.replaceAll(':', '_')}.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      if (!mounted) return;

      // Get share origin bounds
      Rect? shareOrigin;
      final mediaQuery = MediaQuery.of(context);
      shareOrigin = Rect.fromLTWH(
        0,
        mediaQuery.size.height - 100,
        mediaQuery.size.width,
        100,
      );

      // Dismiss preview sheet
      if (mounted) {
        Navigator.pop(context);
      }

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        sharePositionOrigin: shareOrigin,
      );
    } catch (e) {
      debugLog('[SharePreviewSheet] Failed to share: $e');
      if (mounted) {
        showAppMessage(
          context,
          shareErrorMessage,
          type: AppMessageType.error,
        );
      }
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final machineTypeLabel = switch (widget.routine.machineType) {
      MachineType.treadmill => l10n.treadmill,
      MachineType.cycle => l10n.cycle,
      MachineType.stairmaster => l10n.stairmaster,
    };

    final defaultLabel = l10n.shareCardDefault;
    final storyLabel = l10n.shareCardStory;
    final squareLabel = l10n.shareCardSquare;

    return AppBottomSheetFrame(
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.customizeShareCard,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              // Card Preview Area
              Container(
                height: 320,
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.grey.shade300,
                  ),
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: RepaintBoundary(
                      key: _cardKey,
                      child: WorkoutShareCard(
                        routine: widget.routine,
                        elapsedSeconds: widget.elapsedSeconds,
                        distanceMeters: widget.distanceMeters,
                        finishTime: widget.finishTime,
                        currentIntervalIndex: widget.currentIntervalIndex,
                        elapsedSecondsInCurrentSession:
                            widget.elapsedSecondsInCurrentSession,
                        machineTypeLabel: machineTypeLabel,
                        totalTimeLabel: l10n.totalTime,
                        distanceLabel: l10n.totalDistance,
                        avgRpmLabel: l10n.averageRpm,
                        avgLevelLabel: l10n.averageLevel,
                        imagePath: widget.imagePath,
                        cardW: _cardW,
                        cardH: _cardH,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildRatioOption('9:14', defaultLabel),
                  const SizedBox(width: 8),
                  _buildRatioOption('9:16', storyLabel),
                  const SizedBox(width: 8),
                  _buildRatioOption('1:1', squareLabel),
                ],
              ),
              const SizedBox(height: 32),
              // Share Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSharing ? null : _shareCardImage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSharing
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          l10n.share,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatioOption(String ratio, String label) {
    final isSelected = _aspectRatio == ratio;
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _aspectRatio = ratio;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            border: Border.all(
              color:
                  isSelected ? theme.colorScheme.primary : theme.dividerColor,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
