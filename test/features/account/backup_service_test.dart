import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valcue/features/account/account_models.dart';
import 'package:valcue/features/account/account_service.dart';
import 'package:valcue/features/account/backup_service.dart';
import 'package:valcue/features/profile/models/weight_entry.dart';
import 'package:valcue/features/profile/models/workout_session.dart';
import 'package:valcue/features/profile/storage/weight_storage.dart';
import 'package:valcue/features/profile/storage/workout_session_storage.dart';
import 'package:valcue/features/routines/models/interval.dart';
import 'package:valcue/features/routines/models/machine_type.dart';
import 'package:valcue/features/routines/models/routine.dart';
import 'package:valcue/features/routines/storage/routine_storage.dart';

/// Sync decides whether someone's history survives a new phone, so the rules
/// that matter are: nothing is lost, nothing is duplicated, and a delete
/// stays deleted.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore firestore;
  late WorkoutSessionStorage workouts;
  late WeightStorage weights;
  late RoutineStorage routines;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    firestore = FakeFirebaseFirestore();
    workouts = WorkoutSessionStorage();
    weights = WeightStorage();
    routines = RoutineStorage();
  });

  BackupService serviceFor(AccountKind kind) {
    return BackupService(
      account: _FakeAccountService(kind),
      firestore: firestore,
      workouts: workouts,
      weights: weights,
      routines: routines,
    );
  }

  Future<List<String>> remoteIds(String collection) async {
    final snapshot = await firestore
        .collection(BackupService.usersCollection)
        .doc(_uid)
        .collection(collection)
        .get();
    return snapshot.docs.map((d) => d.id).toList()..sort();
  }

  group('who can sync', () {
    test('a guest syncs nothing and is not treated as an error', () async {
      await workouts.addSession(_session('w1'));

      final result = await serviceFor(AccountKind.guest).syncNow();

      expect(result.status, BackupStatus.notSignedIn);
      expect(await remoteIds(BackupService.workoutsCollection), isEmpty);
    });

    test('a signed-in account syncs', () async {
      final result = await serviceFor(AccountKind.google).syncNow();

      expect(result.status, BackupStatus.synced);
    });
  });

  group('uploading what is on this phone', () {
    test('sends workouts, weights and routines up', () async {
      await workouts.addSession(_session('w1'));
      await weights.addEntry(_weight('e1'));
      await routines.addRoutine(_routine('1700000000001'));

      final result = await serviceFor(AccountKind.google).syncNow();

      expect(result.uploaded, 3);
      expect(await remoteIds(BackupService.workoutsCollection), ['w1']);
      expect(await remoteIds(BackupService.weightsCollection), ['e1']);
      expect(
        await remoteIds(BackupService.routinesCollection),
        ['1700000000001'],
      );
    });

    test('syncing twice does not upload the same record again', () async {
      await workouts.addSession(_session('w1'));
      final service = serviceFor(AccountKind.google);

      await service.syncNow();
      final second = await service.syncNow();

      expect(second.uploaded, 0);
      expect(await remoteIds(BackupService.workoutsCollection), ['w1']);
    });

    test('a workout survives the round trip intact', () async {
      final original = WorkoutSession(
        id: 'w1',
        machineType: MachineType.cycle,
        dateTime: DateTime(2026, 5, 1, 7, 30),
        durationSeconds: 1800,
        elapsedMilliseconds: 1800500,
        averageRpm: 84.5,
        routineName: 'Tempo',
        routineId: 'r9',
      );
      await workouts.addSession(original);
      await serviceFor(AccountKind.google).syncNow();

      final doc = await firestore
          .collection(BackupService.usersCollection)
          .doc(_uid)
          .collection(BackupService.workoutsCollection)
          .doc('w1')
          .get();
      final restored = WorkoutSession.fromJson(doc.data()!);

      expect(restored.machineType, MachineType.cycle);
      expect(restored.dateTime, original.dateTime);
      expect(restored.averageRpm, 84.5);
      expect(restored.routineName, 'Tempo');
    });
  });

  group('downloading onto a new phone', () {
    test('brings the account records down', () async {
      await _seedRemote(firestore, BackupService.workoutsCollection, {
        'w1': _session('w1').toJson(),
        'w2': _session('w2').toJson(),
      });

      final result = await serviceFor(AccountKind.google).syncNow();

      expect(result.downloaded, 2);
      expect(
        (await workouts.loadSessions()).map((s) => s.id).toList()..sort(),
        ['w1', 'w2'],
      );
    });

    test('merges rather than replacing what is already here', () async {
      await workouts.addSession(_session('local'));
      await _seedRemote(firestore, BackupService.workoutsCollection, {
        'remote': _session('remote').toJson(),
      });

      await serviceFor(AccountKind.google).syncNow();

      expect(
        (await workouts.loadSessions()).map((s) => s.id).toList()..sort(),
        ['local', 'remote'],
      );
      expect(
        await remoteIds(BackupService.workoutsCollection),
        ['local', 'remote'],
      );
    });

    test('an unreadable backup record does not block the rest', () async {
      await _seedRemote(firestore, BackupService.workoutsCollection, {
        'broken': {'id': 'broken'},
        'fine': _session('fine').toJson(),
      });

      final result = await serviceFor(AccountKind.google).syncNow();

      expect(result.status, BackupStatus.synced);
      expect((await workouts.loadSessions()).map((s) => s.id), ['fine']);
    });
  });

  group('deleting stays deleted', () {
    test('a delete here removes it from the backup', () async {
      await workouts.addSession(_session('w1'));
      final service = serviceFor(AccountKind.google);
      await service.syncNow();

      await workouts.deleteSession('w1');
      final result = await service.syncNow();

      expect(result.deletedRemotely, 1);
      expect(await remoteIds(BackupService.workoutsCollection), isEmpty);
    });

    test('a deleted record is not handed back by the same sync', () async {
      // Without the deletion note, the pull half of this sync would see the
      // record still in the backup and put it straight back.
      await workouts.addSession(_session('w1'));
      final service = serviceFor(AccountKind.google);
      await service.syncNow();

      await workouts.deleteSession('w1');
      await service.syncNow();

      expect(await workouts.loadSessions(), isEmpty);
    });

    test('and does not come back on the next sync either', () async {
      await workouts.addSession(_session('w1'));
      final service = serviceFor(AccountKind.google);
      await service.syncNow();
      await workouts.deleteSession('w1');
      await service.syncNow();

      await service.syncNow();

      expect(await workouts.loadSessions(), isEmpty);
      expect(await remoteIds(BackupService.workoutsCollection), isEmpty);
    });

    test('deleting one record leaves the others alone', () async {
      await workouts.addSession(_session('keep'));
      await workouts.addSession(_session('gone'));
      final service = serviceFor(AccountKind.google);
      await service.syncNow();

      await workouts.deleteSession('gone');
      await service.syncNow();

      expect(await remoteIds(BackupService.workoutsCollection), ['keep']);
      expect((await workouts.loadSessions()).map((s) => s.id), ['keep']);
    });

    test('deleting a routine removes it from the backup too', () async {
      await routines.addRoutine(_routine('1700000000001'));
      final service = serviceFor(AccountKind.google);
      await service.syncNow();

      await routines.deleteRoutine('1700000000001');
      await service.syncNow();

      expect(await remoteIds(BackupService.routinesCollection), isEmpty);
      expect(await routines.loadRoutines(), isEmpty);
    });
  });

  group('deleting the backup', () {
    test('removes every collection the account owns', () async {
      await workouts.addSession(_session('w1'));
      await weights.addEntry(_weight('e1'));
      await routines.addRoutine(_routine('1700000000001'));
      final service = serviceFor(AccountKind.google);
      await service.syncNow();

      expect(await service.deleteEverythingBackedUp(), isTrue);

      expect(await remoteIds(BackupService.workoutsCollection), isEmpty);
      expect(await remoteIds(BackupService.weightsCollection), isEmpty);
      expect(await remoteIds(BackupService.routinesCollection), isEmpty);
    });

    test('leaves the records on this phone alone', () async {
      // Deleting an account is about the copy on the server. Wiping the
      // phone as a side effect would be a much worse surprise.
      await workouts.addSession(_session('w1'));
      final service = serviceFor(AccountKind.google);
      await service.syncNow();

      await service.deleteEverythingBackedUp();

      expect((await workouts.loadSessions()).map((s) => s.id), ['w1']);
    });

    test('a guest has nothing to delete and succeeds trivially', () async {
      expect(
        await serviceFor(AccountKind.guest).deleteEverythingBackedUp(),
        isTrue,
      );
    });

    test('reports failure when Firebase is missing', () async {
      final service = BackupService(
        account: _FakeAccountService(AccountKind.google),
        workouts: workouts,
        weights: weights,
        routines: routines,
      );

      expect(await service.deleteEverythingBackedUp(), isFalse);
    });
  });

  group('signing back in', () {
    test('restores records deleted while signed out', () async {
      // Sign in, record, sign out, delete everything, sign in again: the
      // deletions were made outside the account, so the backup must win.
      await workouts.addSession(_session('w1'));
      await routines.addRoutine(_routine('1700000000001'));
      final service = serviceFor(AccountKind.google);
      await service.syncNow();

      await workouts.deleteSession('w1');
      await routines.deleteRoutine('1700000000001');
      final result = await service.syncAfterSignIn();

      expect(result.deletedRemotely, 0);
      expect((await workouts.loadSessions()).map((s) => s.id), ['w1']);
      expect(
        (await routines.loadRoutines()).map((r) => r.id),
        ['1700000000001'],
      );
      expect(await remoteIds(BackupService.workoutsCollection), ['w1']);
    });

    test('an ordinary sync still applies deletions made while signed in',
        () async {
      await workouts.addSession(_session('w1'));
      final service = serviceFor(AccountKind.google);
      await service.syncNow();

      await workouts.deleteSession('w1');
      await service.syncNow();

      expect(await remoteIds(BackupService.workoutsCollection), isEmpty);
    });
  });

  group('telling the screens to reload', () {
    test('ticks when a sync brings records down', () async {
      await _seedRemote(firestore, BackupService.workoutsCollection, {
        'w1': _session('w1').toJson(),
      });
      final service = serviceFor(AccountKind.google);

      await service.syncNow();

      expect(service.localRecordsChanged.value, 1);
    });

    test('stays quiet when nothing new arrived', () async {
      await workouts.addSession(_session('w1'));
      final service = serviceFor(AccountKind.google);

      await service.syncNow();

      expect(service.localRecordsChanged.value, 0);
    });
  });

  group('overlapping syncs', () {
    test('a call made mid-sync joins it instead of racing it', () async {
      // Launch and sign-in can both start a sync within moments of each
      // other; two at once would download the same records twice.
      final service = serviceFor(AccountKind.google);

      final first = service.syncNow();
      final second = service.syncNow();

      expect(identical(first, second), isTrue);
      await first;
    });

    test('a call after the sync finished starts a fresh one', () async {
      final service = serviceFor(AccountKind.google);

      final first = service.syncNow();
      await first;
      final second = service.syncNow();

      expect(identical(first, second), isFalse);
      await second;
    });
  });

  group('when Firebase is not there', () {
    test('sync reports it instead of throwing', () async {
      final service = BackupService(
        account: _FakeAccountService(AccountKind.google),
        workouts: workouts,
        weights: weights,
        routines: routines,
      );

      expect((await service.syncNow()).status, BackupStatus.unavailable);
    });
  });
}

const String _uid = 'uid-1';

Future<void> _seedRemote(
  FakeFirebaseFirestore firestore,
  String collection,
  Map<String, Map<String, dynamic>> docs,
) async {
  final ref = firestore
      .collection(BackupService.usersCollection)
      .doc(_uid)
      .collection(collection);
  for (final entry in docs.entries) {
    await ref.doc(entry.key).set(entry.value);
  }
}

WorkoutSession _session(String id) {
  return WorkoutSession(
    id: id,
    machineType: MachineType.treadmill,
    dateTime: DateTime(2026, 5, 1, 7, 30),
    durationSeconds: 600,
    routineName: 'Intervals',
    routineId: 'r1',
  );
}

WeightEntry _weight(String id) {
  return WeightEntry(id: id, dateTime: DateTime(2026, 5, 1), weightKg: 70);
}

Routine _routine(String id) {
  return Routine(
    id: id,
    name: 'Routine',
    difficulty: '중간',
    machineType: MachineType.treadmill,
    intervals: [
      Interval.treadmill(
        id: 'i-$id',
        durationSeconds: 60,
        speedKmh: 8,
        grade: 1,
      ),
    ],
  );
}

/// Stands in for the real service so tests never touch Firebase Auth.
class _FakeAccountService implements AccountService {
  _FakeAccountService(this.kind);

  final AccountKind kind;

  @override
  AccountUser? get currentUser => AccountUser(id: _uid, kind: kind);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
