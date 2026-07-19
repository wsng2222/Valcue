import 'package:flutter/material.dart';

enum AppMessageType { info, success, error }

void showAppMessage(
  BuildContext context,
  String message, {
  AppMessageType type = AppMessageType.info,
  Duration? duration,
}) {
  final theme = Theme.of(context);
  final (icon, color) = switch (type) {
    AppMessageType.info => (Icons.info_outline_rounded, Colors.white),
    AppMessageType.success => (
        Icons.check_circle_outline_rounded,
        const Color(0xFF5BD38D)
      ),
    AppMessageType.error => (
        Icons.error_outline_rounded,
        theme.colorScheme.error
      ),
  };

  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: duration ??
            (type == AppMessageType.error
                ? const Duration(seconds: 3)
                : const Duration(seconds: 2)),
        content: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}
