import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/app_shadows.dart';

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
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border.all(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.08)
                      : context.appColors.border,
                ),
                boxShadow: AppShadows.elevatedSoft,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          context.appColors.mutedText.withValues(alpha: 0.24),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
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
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(sheetContext).pop(
                            TimeOfDay(
                              hour: draft.hour,
                              minute: draft.minute,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          l10n.done,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
