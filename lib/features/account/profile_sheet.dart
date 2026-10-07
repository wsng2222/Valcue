import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app_settings/app_settings_model.dart';
import '../../app_settings/app_settings_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_bottom_sheet.dart';
import '../../widgets/valcue_ui.dart';

/// Parses a `#RRGGBB` swatch from settings. Falls back rather than throwing,
/// so a hand-edited or future-dated stored value can never crash the sheet.
Color avatarColorFromHex(String hex) {
  final cleaned = hex.replaceFirst('#', '').trim();
  final value = int.tryParse(cleaned, radix: 16);
  if (value == null || cleaned.length != 6) {
    return const Color(0xFFFFE1DF);
  }
  return Color(0xFF000000 | value);
}

/// Round avatar used on the settings account card and in the edit sheet.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.emoji,
    required this.backgroundHex,
    this.size = 46,
  });

  final String emoji;
  final String backgroundHex;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: avatarColorFromHex(backgroundHex),
        shape: BoxShape.circle,
      ),
      child: Text(emoji, style: TextStyle(fontSize: size * 0.5)),
    );
  }
}

Future<void> showProfileSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ProfileSheet(),
  );
}

class _ProfileSheet extends StatefulWidget {
  const _ProfileSheet();

  @override
  State<_ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<_ProfileSheet> {
  late final TextEditingController _nameController;
  late String _emoji;
  late String _bg;

  @override
  void initState() {
    super.initState();
    final settings = context.read<AppSettingsProvider>();
    _nameController = TextEditingController(text: settings.profileName);
    _emoji = settings.avatarEmoji;
    _bg = settings.avatarBg;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    await context.read<AppSettingsProvider>().updateProfile(
          profileName: _nameController.text.trim(),
          avatarEmoji: _emoji,
          avatarBg: _bg,
        );
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      top: false,
      child: Padding(
        // Lifts the sheet clear of the keyboard while the nickname is edited.
        padding:
            EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: AppBottomSheetFrame(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 6, 22, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      l10n.profileEditTitle,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ProfileAvatar(
                      emoji: _emoji,
                      backgroundHex: _bg,
                      size: 84,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _NicknameField(controller: _nameController),
                  const SizedBox(height: 20),
                  _SectionLabel(l10n.profileEmojiLabel),
                  const SizedBox(height: 10),
                  _EmojiGrid(
                    selected: _emoji,
                    onPick: (value) => setState(() => _emoji = value),
                  ),
                  const SizedBox(height: 20),
                  _SectionLabel(l10n.profileBackgroundLabel),
                  const SizedBox(height: 10),
                  _ColorRow(
                    selected: _bg,
                    onPick: (value) => setState(() => _bg = value),
                  ),
                  const SizedBox(height: 22),
                  PrimaryPillButton(
                    label: MaterialLocalizations.of(context).saveButtonLabel,
                    height: 56,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: context.appColors.mutedText,
      ),
    );
  }
}

class _NicknameField extends StatelessWidget {
  const _NicknameField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;

    return SizedBox(
      height: 52,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        maxLength: 12,
        inputFormatters: [LengthLimitingTextInputFormatter(12)],
        textInputAction: TextInputAction.done,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          counterText: '',
          hintText: AppLocalizations.of(context)!.profileNicknameHint,
          hintStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: appColors.mutedText,
          ),
          filled: true,
          fillColor: appColors.subtle,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: appColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: appColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: theme.colorScheme.primary),
          ),
        ),
      ),
    );
  }
}

class _EmojiGrid extends StatelessWidget {
  const _EmojiGrid({required this.selected, required this.onPick});

  final String selected;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;

    return GridView.count(
      crossAxisCount: 6,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final emoji in kAvatarEmojiOptions)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onPick(emoji),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: appColors.subtle,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: emoji == selected
                      ? theme.colorScheme.primary
                      : appColors.border,
                  width: emoji == selected ? 2 : 1,
                ),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
      ],
    );
  }
}

class _ColorRow extends StatelessWidget {
  const _ColorRow({required this.selected, required this.onPick});

  final String selected;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;

    return Row(
      children: [
        for (final hex in kAvatarBgOptions) ...[
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onPick(hex),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: avatarColorFromHex(hex),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hex == selected
                          ? theme.colorScheme.primary
                          : appColors.border,
                      width: hex == selected ? 3 : 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (hex != kAvatarBgOptions.last) const SizedBox(width: 10),
        ],
      ],
    );
  }
}
