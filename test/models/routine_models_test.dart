import 'package:flutter_test/flutter_test.dart';
import 'package:valcue/features/routines/models/interval.dart';
import 'package:valcue/features/routines/models/machine_type.dart';
import 'package:valcue/features/routines/models/routine.dart';

void main() {
  test('Interval formats duration as mm:ss', () {
    final interval = Interval(durationSeconds: 65);
    expect(interval.durationFormatted, '01:05');
  });

  test('Interval.fromJson supports legacy duration and x10 fields', () {
    final interval = Interval.fromJson({
      'id': 'i1',
      'durationMinutes': 2,
      'speedX10': 85,
      'gradeX10': 15,
    });

    expect(interval.durationSeconds, 120);
    expect(interval.speedKmh, closeTo(8.5, 0.0001));
    expect(interval.grade, closeTo(1.5, 0.0001));
  });

  test('Routine formats total duration with and without hours', () {
    final shortRoutine = Routine(
      id: 'r1',
      name: 'Short',
      difficulty: '중간',
      machineType: MachineType.treadmill,
      intervals: [
        Interval(durationSeconds: 60),
        Interval(durationSeconds: 75),
      ],
    );
    expect(shortRoutine.totalDurationFormatted, '02:15');

    final longRoutine = Routine(
      id: 'r2',
      name: 'Long',
      difficulty: '중간',
      machineType: MachineType.treadmill,
      intervals: [
        Interval(durationSeconds: 3600),
        Interval(durationSeconds: 65),
      ],
    );
    expect(longRoutine.totalDurationFormatted, '1:01:05');
  });

  test('Routine truncates names longer than 40 chars', () {
    final longName = 'A' * 45;
    final routine = Routine(
      id: 'r3',
      name: longName,
      difficulty: '중간',
      machineType: MachineType.treadmill,
      intervals: [
        Interval(durationSeconds: 30),
      ],
    );

    expect(routine.name.length, 40);
    expect(routine.name, longName.substring(0, 40));
  });

  test('MachineType toJson/fromJson roundtrip', () {
    expect(MachineType.cycle.toJson(), 'cycle');
    expect(MachineType.fromJson('cycle'), MachineType.cycle);
    expect(MachineType.fromJson('stairmaster'), MachineType.stairmaster);
    expect(MachineType.fromJson('unknown'), MachineType.treadmill);
  });
}
