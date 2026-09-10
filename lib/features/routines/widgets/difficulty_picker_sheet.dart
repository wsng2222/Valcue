import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/cupertino.dart' hide Interval;
import 'package:valcue/l10n/app_localizations.dart';
import '../../../widgets/app_bottom_sheet.dart';
import '../../../utils/app_shadows.dart';

class DifficultyPickerSheet extends StatelessWidget {
  final String currentDifficulty;
  final Function(String) onSelected;

  const DifficultyPickerSheet({super.key, 
    required this.currentDifficulty,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final difficultyDisplayValues = [l10n.easy, l10n.medium, l10n.hard];
    final difficultyStorageValues = ['쉬움', '중간', '높음'];
    var initialIndex = difficultyStorageValues.indexOf(currentDifficulty);
    if (initialIndex < 0) {
      // Fallback if stored value doesn't match
      initialIndex = 0;
    }

    return Container(
      height: 260,
      padding: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: AppShadows.elevatedSoft,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const AppBottomSheetHandle(),
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                        minimumSize: const Size(0, 0),
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      AppLocalizations.of(context)!.selectDifficulty,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                        decoration: TextDecoration.none,
                        decorationColor: Colors.transparent,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                        minimumSize: const Size(0, 0),
                        child: Text(
                          AppLocalizations.of(context)!.done,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: initialIndex >= 0 ? initialIndex : 0,
                ),
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  // Map display index back to storage value
                  onSelected(difficultyStorageValues[index]);
                },
                children: difficultyDisplayValues.map((difficulty) {
                  return Center(
                    child: Text(
                      difficulty,
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
