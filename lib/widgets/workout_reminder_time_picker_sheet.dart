import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'app_bottom_sheet.dart';
import 'bottom_sheet_action_bar.dart';

Future<TimeOfDay?> showWorkoutReminderTimePickerSheet({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  final l10n = AppLocalizations.of(context)!;
  final theme = Theme.of(context);
  var draft = DateTime(
    2024,
    1,
    1,
    initialTime.hour,
    initialTime.minute,
  );

  return showModalBottomSheet<TimeOfDay>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: theme.colorScheme.shadow.withValues(alpha: 0.4),
    isScrollControlled: true,
    enableDrag: false,
    isDismissible: true,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (modalContext, setModalState) {
          return SafeArea(
            top: false,
            bottom: true,
            child: AppBottomSheetFrame(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
                    child: Text(
                      l10n.workoutReminderSelectTime,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 220,
                    child: CupertinoTheme(
                      data: CupertinoTheme.of(modalContext).copyWith(
                        brightness: theme.brightness,
                      ),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.time,
                        use24hFormat: false,
                        initialDateTime: draft,
                        onDateTimeChanged: (value) {
                          setModalState(() => draft = value);
                        },
                      ),
                    ),
                  ),
                  BottomSheetPrimaryActionBar(
                    label: l10n.done,
                    onPressed: () {
                      Navigator.of(sheetContext).pop(
                        TimeOfDay(hour: draft.hour, minute: draft.minute),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
