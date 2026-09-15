import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
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
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
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
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
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
              fontSize: 15,
              color: theme.extension<AppColors>()!.mutedText,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
