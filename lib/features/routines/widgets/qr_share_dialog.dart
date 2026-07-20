import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:valcue/features/routines/models/routine.dart';
import 'package:valcue/features/routines/utils/routine_sharing.dart';
import 'package:valcue/l10n/app_localizations.dart';
import '../../../services/analytics_service.dart';
import '../../../widgets/app_dialog.dart';

class QrShareDialog extends StatefulWidget {
  final Routine routine;

  const QrShareDialog({super.key, required this.routine});

  static void show(BuildContext context, Routine routine) {
    showAppDialog<void>(
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
      AnalyticsService.instance.logEvent(
        'routine_shared',
        {
          'method': 'qr',
          'machine_type': widget.routine.machineType.name,
        },
      );
      if (mounted) {
        setState(() {
          _shareLink = link;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.unableToShareWorkout;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppDialog(
      title: l10n.shareViaQrCode,
      showCloseButton: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.routine.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
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
                  l10n.unableToShareWorkout,
                  style: TextStyle(color: theme.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (_shareLink != null)
            Center(
              child: Container(
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
            ),
          const SizedBox(height: 22),
          Text(
            l10n.qrShareInstruction,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
