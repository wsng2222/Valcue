import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:valcue/features/routines/models/routine.dart';
import 'package:valcue/features/routines/utils/routine_sharing.dart';

class QrShareDialog extends StatefulWidget {
  final Routine routine;

  const QrShareDialog({super.key, required this.routine});

  static void show(BuildContext context, Routine routine) {
    showDialog(
      context: context,
      builder: (context) => QrShareDialog(routine: routine),
    );
  }

  @override
  State<QrShareDialog> createState() => _QrShareDialogState();
}

class _QrShareDialogState extends State<QrShareDialog> {
  String? _shareLink;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generateLink();
  }

  Future<void> _generateLink() async {
    try {
      final link = await RoutineSharing.generateShareLink(widget.routine);
      if (mounted) {
        setState(() {
          _shareLink = link;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isKorean = Localizations.localeOf(context).languageCode == 'ko';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48), // Spacer to balance the close button
                Expanded(
                  child: Text(
                    isKorean ? 'QR 코드로 공유' : 'Share via QR Code',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.routine.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage != null)
              SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    'Error: $_errorMessage',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (_shareLink != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: _shareLink!,
                  version: QrVersions.auto,
                  size: 200.0,
                  gapless: false,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              isKorean
                  ? '상대방의 Valcue 앱에서 QR 스캔을 켜고\n이 코드를 비추면 즉시 가져올 수 있습니다.'
                  : 'Scan this QR code from another Valcue app\nto import this routine instantly.',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
