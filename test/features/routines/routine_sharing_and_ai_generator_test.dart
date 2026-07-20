import 'package:flutter_test/flutter_test.dart';
import 'package:valcue/features/routines/models/routine.dart';
import 'package:valcue/features/routines/models/interval.dart';
import 'package:valcue/features/routines/models/machine_type.dart';
import 'package:valcue/features/routines/utils/routine_link_codec.dart';
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
      expect(link, startsWith(RoutineLinkCodec.prefix));

      final restoredRoutine = await RoutineSharing.parseShareLink(link);
      expect(restoredRoutine, isNotNull);
      expect(restoredRoutine!.name, equals(originalRoutine.name));
      expect(restoredRoutine.difficulty, equals(originalRoutine.difficulty));
      expect(restoredRoutine.machineType, equals(originalRoutine.machineType));
      expect(restoredRoutine.intervals.length,
          equals(originalRoutine.intervals.length));
      expect(restoredRoutine.intervals[0].speedKmh,
          equals(originalRoutine.intervals[0].speedKmh));
      expect(restoredRoutine.intervals[0].grade,
          equals(originalRoutine.intervals[0].grade));
      expect(restoredRoutine.intervals[0].durationSeconds,
          equals(originalRoutine.intervals[0].durationSeconds));
      expect(restoredRoutine.id,
          isNot(equals(originalRoutine.id))); // ID must be newly assigned
    });

    test('parseShareLink returns null on invalid link', () async {
      expect(
          await RoutineSharing.parseShareLink('invalid_link_format'), isNull);
      expect(
          await RoutineSharing.parseShareLink(
              'valcue://share?routine=invalid_base64'),
          isNull);
      expect(
          await RoutineSharing.parseShareLink('valcue://r/too-long'), isNull);
    });

    test('recognizes short and legacy share links', () {
      expect(RoutineSharing.isShareLink('v:EAwB'), isTrue);
      expect(RoutineSharing.isShareLink('valcue://r/aB3xZ9'), isTrue);
      expect(RoutineSharing.isShareLink('valcue://share?id=aB3xZ9'), isTrue);
      expect(
          RoutineSharing.isShareLink('https://example.com/r/aB3xZ9'), isFalse);
      expect(
        RoutineSharing.extractShareLink('Valcue 루틴\n\nv:EAwB\n'),
        'v:EAwB',
      );
    });

    test('continues to parse previously shared long links', () async {
      const legacyLink =
          'valcue://share?routine=H4sIAAAAAAAAEzPmilZ6M3fL62UtCm-mt73umqLwevGKt91blHSUUpV0lEqUYrkM9U31DPQN9AwAx5z5rywAAAA=';
      final routine = await RoutineSharing.parseShareLink(legacyLink);
      expect(routine, isNotNull);
      expect(routine!.name, '이름 없는 루틴');
    });

    test('compact links preserve machine metrics and repeat groups', () async {
      final routines = [
        Routine(
          id: 'cycle',
          name: '이름 없는 루틴',
          difficulty: '높음',
          machineType: MachineType.cycle,
          intervals: [
            Interval.cycle(
              durationSeconds: 45,
              rpm: 90,
              resistance: 12,
              groupId: 'original-long-group-id',
              repeatCount: 4,
            ),
            Interval.cycle(
              durationSeconds: 30,
              rpm: 65,
              resistance: 7,
              groupId: 'original-long-group-id',
              repeatCount: 4,
            ),
          ],
        ),
        Routine(
          id: 'stairs',
          name: 'Stairs',
          difficulty: 'custom',
          machineType: MachineType.stairmaster,
          intervals: [
            Interval.stairmaster(durationSeconds: 75, level: 9),
          ],
        ),
      ];

      for (final original in routines) {
        final link = await RoutineSharing.generateShareLink(original);
        final restored = await RoutineSharing.parseShareLink(link);
        expect(restored, isNotNull);
        expect(restored!.name, original.name);
        expect(restored.difficulty, original.difficulty);
        expect(restored.machineType, original.machineType);
        expect(restored.intervals.length, original.intervals.length);
      }

      final cycle = await RoutineSharing.parseShareLink(
        await RoutineSharing.generateShareLink(routines.first),
      );
      expect(cycle!.intervals.first.rpm, 90);
      expect(cycle.intervals.first.resistance, 12);
      expect(cycle.intervals.first.repeatCount, 4);
      expect(cycle.intervals[0].groupId, cycle.intervals[1].groupId);
    });

    test('unnamed one-interval routine uses an extremely short link', () async {
      final routine = Routine(
        id: 'short',
        name: '이름 없는 루틴',
        difficulty: '중간',
        machineType: MachineType.treadmill,
        intervals: [
          Interval.treadmill(
            durationSeconds: 60,
            speedKmh: 5,
            grade: 0,
          ),
        ],
      );

      final link = await RoutineSharing.generateShareLink(routine);
      expect(link.length, lessThanOrEqualTo(16));
      expect(await RoutineSharing.parseShareLink(link), isNotNull);
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
