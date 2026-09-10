import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valcue/features/account/backup_auto_sync.dart';
import 'package:valcue/features/account/backup_service.dart';
import 'package:valcue/features/profile/models/weight_entry.dart';
import 'package:valcue/features/profile/models/workout_session.dart';
import 'package:valcue/features/profile/providers/weight_tracker_provider.dart';
import 'package:valcue/features/profile/providers/workout_history_provider.dart';
import 'package:valcue/features/profile/storage/weight_storage.dart';
import 'package:valcue/features/profile/storage/workout_session_storage.dart';
import 'package:valcue/features/routines/models/interval.dart';
import 'package:valcue/features/routines/models/machine_type.dart';
import 'package:valcue/features/routines/models/routine.dart';
import 'package:valcue/features/routines/storage/routine_provider.dart';
import 'package:valcue/features/routines/storage/routine_storage.dart';

void main() {
  late _FakeBackup backup;
  late RoutineProvider routines;
  late WorkoutHistoryProvider history;
  late WeightTrackerProvider weights;

  Future<void> pump(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    backup = _FakeBackup();
    routines = RoutineProvider();
    history = WorkoutHistoryProvider();
    weights = WeightTrackerProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<RoutineProvider>.value(value: routines),
          ChangeNotifierProvider<WorkoutHistoryProvider>.value(value: history),
          ChangeNotifierProvider<WeightTrackerProvider>.value(value: weights),
        ],
        child: MaterialApp(
          home: BackupAutoSync(
            backup: backup,
            child: const SizedBox.shrink(),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('records a sync brings down show up without a restart',
      (tester) async {
    // The screens load records once and keep them in memory. A restore that
    // landed afterwards used to stay invisible until the app restarted.
    await pump(tester);
    expect(routines.routines, isEmpty);

    // What a sync does: write straight to storage, behind the providers.
    await RoutineStorage().addRoutine(_routine());
    await WorkoutSessionStorage().addSession(_session());
    await WeightStorage().addEntry(
      WeightEntry(id: 'e1', dateTime: DateTime(2026, 5, 1), weightKg: 70),
    );
    expect(routines.routines, isEmpty);

    backup.localRecordsChanged.value++;
    await tester.pump();
    await tester.pump();

    expect(routines.routines.map((r) => r.id), ['1700000000001']);
    expect(history.sessions.map((s) => s.id), ['w1']);
    expect(weights.entries.map((e) => e.id), ['e1']);
  });

  testWidgets('going to the background backs up what was just recorded',
      (tester) async {
    // Records made while signed in used to reach the backup only on the next
    // launch - a phone lost before then took them with it.
    await pump(tester);
    backup.syncs = 0;

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);

    expect(backup.syncs, 1);
  });

  testWidgets('coming back picks up what another phone changed',
      (tester) async {
    await pump(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    backup.syncs = 0;

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

    expect(backup.syncs, 1);
  });
}

Routine _routine() {
  return Routine(
    id: '1700000000001',
    name: 'Routine',
    difficulty: '중간',
    machineType: MachineType.treadmill,
    intervals: [
      Interval.treadmill(
        id: 'i-1',
        durationSeconds: 60,
        speedKmh: 8,
        grade: 1,
      ),
    ],
  );
}

WorkoutSession _session() {
  return WorkoutSession(
    id: 'w1',
    machineType: MachineType.treadmill,
    dateTime: DateTime(2026, 5, 1, 7, 30),
    durationSeconds: 600,
    routineName: 'Intervals',
    routineId: 'r1',
  );
}

class _FakeBackup implements BackupService {
  int syncs = 0;

  @override
  final ValueNotifier<int> localRecordsChanged = ValueNotifier<int>(0);

  @override
  Future<BackupResult> syncNow() async {
    syncs++;
    return const BackupResult(BackupStatus.synced);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
