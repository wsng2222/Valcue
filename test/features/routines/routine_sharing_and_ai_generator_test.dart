import 'package:flutter_test/flutter_test.dart';
import 'package:valcue/features/routines/models/routine.dart';
import 'package:valcue/features/routines/models/interval.dart';
import 'package:valcue/features/routines/models/machine_type.dart';
import 'package:valcue/features/routines/utils/routine_sharing.dart';
import 'package:valcue/app_settings/app_settings_model.dart';

void main() {
  group('RoutineSharing Tests', () {
    test('generateShareLink and parseShareLink roundtrip', () async {
      final originalRoutine = Routine(
        id: 'r_original_123',
        name: 'HIIT Treadmill test',
        difficulty: '중간',
        machineType: MachineType.treadmill,
        intervals: [
          Interval.treadmill(durationSeconds: 60, speedKmh: 10.0, grade: 2.0),
          Interval.treadmill(durationSeconds: 120, speedKmh: 5.5, grade: 1.0),
        ],
      );

      final link = await RoutineSharing.generateShareLink(originalRoutine);
      expect(link, startsWith(RoutineSharing.linkPrefix));

      final restoredRoutine = await RoutineSharing.parseShareLink(link);
      expect(restoredRoutine, isNotNull);
      expect(restoredRoutine!.name, equals(originalRoutine.name));
      expect(restoredRoutine.difficulty, equals(originalRoutine.difficulty));
      expect(restoredRoutine.machineType, equals(originalRoutine.machineType));
      expect(restoredRoutine.intervals.length, equals(originalRoutine.intervals.length));
      expect(restoredRoutine.intervals[0].speedKmh, equals(originalRoutine.intervals[0].speedKmh));
      expect(restoredRoutine.intervals[0].grade, equals(originalRoutine.intervals[0].grade));
      expect(restoredRoutine.intervals[0].durationSeconds, equals(originalRoutine.intervals[0].durationSeconds));
      expect(restoredRoutine.id, isNot(equals(originalRoutine.id))); // ID must be newly assigned
    });

    test('parseShareLink returns null on invalid link', () async {
      expect(await RoutineSharing.parseShareLink('invalid_link_format'), isNull);
      expect(await RoutineSharing.parseShareLink('valcue://share?routine=invalid_base64'), isNull);
    });
  });

  group('AppSettings TTS Customization Field Tests', () {
    test('defaults are initialized correctly', () {
      final settings = AppSettings.defaultSettings;
      expect(settings.voiceGuideCountdownTriggers, equals([10, 20, 30]));
    });

    test('toJson and fromJson support TTS settings', () {
      final settings = AppSettings.defaultSettings.copyWith(
        voiceGuideCountdownTriggers: [5, 10, 15],
      );

      final json = settings.toJson();
      expect(json['voiceGuideCountdownTriggers'], equals([5, 10, 15]));

      final restored = AppSettings.fromJson(json);
      expect(restored.voiceGuideCountdownTriggers, equals([5, 10, 15]));
    });
  });
}
