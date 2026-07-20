import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/routine.dart';
import '../storage/routine_provider.dart';
import '../../../app_settings/app_settings_provider.dart';
import '../models/machine_type.dart';
import '../models/interval.dart';
import 'package:valcue/l10n/app_localizations.dart';
import 'package:valcue/l10n/localized_format.dart';
import '../../../services/analytics_service.dart';
import '../../../widgets/app_dialog.dart';
import '../../../widgets/app_message.dart';
import 'routine_link_codec.dart';

class RoutineSharing {
  /// Legacy self-contained links. Keep parsing these so previously shared
  /// routines continue to work.
  static const String linkPrefix = 'valcue://share?';
  static const String shortLinkPrefix = 'valcue://r/';

  static bool isShareLink(String value) {
    return value.startsWith(RoutineLinkCodec.prefix) ||
        value.startsWith(shortLinkPrefix) ||
        value.startsWith(linkPrefix);
  }

  static String? extractShareLink(String value) {
    final trimmed = value.trim();
    if (isShareLink(trimmed) && !trimmed.contains(RegExp(r'\s'))) {
      return trimmed;
    }
    final match = RegExp(
      r'(?:^|\s)(v:[a-zA-Z0-9_-]+|valcue://r/[a-zA-Z0-9]+|valcue://share\?[^\s]+)',
    ).firstMatch(value);
    return match?.group(1);
  }

  static Interval _deserializeInterval(String str, int index) {
    final fields = str.split('/');

    int duration = int.tryParse(fields.isNotEmpty ? fields[0] : '') ?? 300;
    double? speed = fields.length > 1 && fields[1].isNotEmpty
        ? double.tryParse(fields[1])
        : null;
    double? grade = fields.length > 2 && fields[2].isNotEmpty
        ? double.tryParse(fields[2])
        : null;
    int? rpm = fields.length > 3 && fields[3].isNotEmpty
        ? int.tryParse(fields[3])
        : null;
    int? resistance = fields.length > 4 && fields[4].isNotEmpty
        ? int.tryParse(fields[4])
        : null;
    int? level = fields.length > 5 && fields[5].isNotEmpty
        ? int.tryParse(fields[5])
        : null;
    String? groupId =
        fields.length > 6 && fields[6].isNotEmpty ? fields[6] : null;
    int? repeatCount = fields.length > 7 && fields[7].isNotEmpty
        ? int.tryParse(fields[7])
        : null;

    return Interval(
      id: 'imported_interval_${DateTime.now().millisecondsSinceEpoch}_$index',
      durationSeconds: duration,
      speedKmh: speed,
      grade: grade,
      rpm: rpm,
      resistance: resistance,
      level: level,
      groupId: groupId,
      repeatCount: repeatCount,
    );
  }

  static Routine? _deserializeV3(String text) {
    final lines = text.split('\n');
    if (lines.length < 3) return null;

    final metaList = jsonDecode(lines[1]) as List;
    final name = metaList[0] as String;
    String diff = metaList[1] as String;
    String machineTypeStr = metaList[2] as String;

    if (diff == 'e') {
      diff = '쉬움';
    } else if (diff == 'm') {
      diff = '중간';
    } else if (diff == 'h') {
      diff = '높음';
    }

    if (machineTypeStr == 't') {
      machineTypeStr = 'treadmill';
    } else if (machineTypeStr == 'c') {
      machineTypeStr = 'cycle';
    } else if (machineTypeStr == 's') {
      machineTypeStr = 'stairmaster';
    }

    final intervalsStr = lines[2];
    final intervalsList = intervalsStr.isEmpty
        ? <Interval>[]
        : intervalsStr.split(',').asMap().entries.map((entry) {
            return _deserializeInterval(entry.value, entry.key);
          }).toList();

    return Routine(
      id: 'imported_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      difficulty: diff,
      machineType: MachineType.fromJson(machineTypeStr),
      intervals: intervalsList,
    );
  }

  static Map<String, dynamic> _fromCompressedMap(
      Map<String, dynamic> compressed) {
    if (!compressed.containsKey('v')) {
      return compressed;
    }

    String diff = compressed['d'] as String;
    if (diff == 'e') {
      diff = '쉬움';
    } else if (diff == 'm') {
      diff = '중간';
    } else if (diff == 'h') {
      diff = '높음';
    }

    String machineTypeStr = compressed['m'] as String;
    if (machineTypeStr == 't') {
      machineTypeStr = 'treadmill';
    } else if (machineTypeStr == 'c') {
      machineTypeStr = 'cycle';
    } else if (machineTypeStr == 's') {
      machineTypeStr = 'stairmaster';
    }

    final intervalsList = compressed['i'] as List;
    final List<Map<String, dynamic>> intervals = [];

    for (int i = 0; i < intervalsList.length; i++) {
      final map = intervalsList[i] as Map<String, dynamic>;
      final intervalJson = <String, dynamic>{
        'id': 'imported_interval_${DateTime.now().millisecondsSinceEpoch}_$i',
        'durationSeconds': map['d'] as int,
      };
      if (map.containsKey('s')) intervalJson['speedKmh'] = map['s'];
      if (map.containsKey('g')) intervalJson['grade'] = map['g'];
      if (map.containsKey('r')) intervalJson['rpm'] = map['r'];
      if (map.containsKey('e')) intervalJson['resistance'] = map['e'];
      if (map.containsKey('l')) intervalJson['level'] = map['l'];
      if (map.containsKey('gId')) intervalJson['groupId'] = map['gId'];
      if (map.containsKey('rc')) intervalJson['repeatCount'] = map['rc'];
      intervals.add(intervalJson);
    }

    return {
      'name': compressed['n'] as String,
      'difficulty': diff,
      'machineType': machineTypeStr,
      'intervals': intervals,
    };
  }

  /// Generates the shortest self-contained link supported by the app. No
  /// server, account, quota, or network connection is required.
  static Future<String> generateShareLink(Routine routine) async {
    return RoutineLinkCodec.encode(routine);
  }

  /// Parses a sharing link and returns a new Routine object. Returns null if invalid.
  static Future<Routine?> parseShareLink(String link) async {
    if (!isShareLink(link)) return null;

    if (link.startsWith(RoutineLinkCodec.prefix)) {
      return RoutineLinkCodec.decode(link);
    }

    String? routineParam;
    String? idParam;
    if (link.startsWith(shortLinkPrefix)) {
      final candidate = link.substring(shortLinkPrefix.length);
      if (!RegExp(r'^[a-zA-Z0-9]{6}$').hasMatch(candidate)) return null;
      idParam = candidate;
    } else {
      final uri = Uri.parse(link);
      routineParam = uri.queryParameters['routine'];
      idParam = uri.queryParameters['id'];
    }

    if (routineParam != null) {
      try {
        final compressed = base64Url.decode(routineParam);
        final bytes = gzip.decode(compressed);
        final decodedText = utf8.decode(bytes);

        if (decodedText.startsWith('3\n')) {
          return _deserializeV3(decodedText);
        }

        // Backward compatibility for V1 and V2 JSON formats
        var jsonMap = jsonDecode(decodedText) as Map<String, dynamic>;
        jsonMap = _fromCompressedMap(jsonMap);

        // Assign a new unique ID
        final newId = 'imported_${DateTime.now().millisecondsSinceEpoch}';
        jsonMap['id'] = newId;

        return Routine.fromJson(jsonMap);
      } catch (e) {
        debugPrint('[RoutineSharing] Error parsing local sharing link: $e');
        return null;
      }
    } else if (idParam != null) {
      // Cloud short links were experimental. Recognition remains so they fail
      // safely instead of being mistaken for unrelated clipboard contents.
      return null;
    }

    return null;
  }

  /// Stores last processed link to avoid prompt loop in the same session
  static String? _lastProcessedLink;

  /// Resets the last processed link tracking (useful for testing or manual triggers)
  static void resetLastProcessedLink() {
    _lastProcessedLink = null;
  }

  /// Checks the clipboard for a valid Valcue routine sharing link, parses it, and prompts the user to import it.
  static Future<void> checkClipboardAndImport(BuildContext context) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.isEmpty) return;
    final link = extractShareLink(text);
    if (link == null || link == _lastProcessedLink) return;

    final routine = await parseShareLink(link);
    if (routine == null) return;

    _lastProcessedLink = link; // Mark as processed

    if (!context.mounted) return;

    final l10n = AppLocalizations.of(context)!;

    // Check free limit for Treadmill
    final routineProvider =
        Provider.of<RoutineProvider>(context, listen: false);
    final settingsProvider =
        Provider.of<AppSettingsProvider>(context, listen: false);

    if (routine.machineType == MachineType.treadmill &&
        !settingsProvider.isPremium &&
        routineProvider.routines
                .where((r) => r.machineType == MachineType.treadmill)
                .length >=
            2) {
      // Prompt user about limit if they try to import
      showAppDialog<void>(
        context: context,
        builder: (dialogContext) => AppDialog(
          icon: Icons.lock_outline_rounded,
          title: l10n.routineLimitReached,
          message: l10n.routineLimitMessage,
          actions: [
            AppDialogAction(
              label: l10n.ok,
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        ),
      );
      return;
    }

    showAppDialog<void>(
      context: context,
      builder: (dialogContext) => AppDialog(
        icon: Icons.download_rounded,
        title: l10n.importSharedRoutine,
        message: l10n.importClipboardRoutinePrompt(
          routine.name,
          _localizedDifficulty(l10n, routine.difficulty),
          LocalizedFormat.decimal(
            context,
            routine.intervals.length,
            decimalDigits: 0,
          ),
        ),
        actions: [
          AppDialogAction(
            label: l10n.cancel,
            style: AppDialogActionStyle.secondary,
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          AppDialogAction(
            label: l10n.importAction,
            onPressed: () async {
              await routineProvider.addRoutine(routine);
              AnalyticsService.instance.logEvent(
                'routine_imported',
                {
                  'method': 'clipboard',
                  'machine_type': routine.machineType.name,
                  'interval_count': routine.intervals.length,
                },
              );
              if (!context.mounted || !dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();

              showAppMessage(
                context,
                l10n.importRoutineSuccess(routine.name),
                type: AppMessageType.success,
              );
            },
          ),
        ],
      ),
    );
  }

  static String _localizedDifficulty(
    AppLocalizations l10n,
    String storedDifficulty,
  ) {
    return switch (storedDifficulty) {
      '쉬움' || 'beginner' => l10n.easy,
      '중간' || 'intermediate' => l10n.medium,
      '높음' || 'advanced' => l10n.hard,
      _ => storedDifficulty,
    };
  }
}
