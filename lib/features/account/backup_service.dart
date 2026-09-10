import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/debug_log.dart';
import '../profile/models/weight_entry.dart';
import '../profile/models/workout_session.dart';
import '../profile/storage/weight_storage.dart';
import '../profile/storage/workout_session_storage.dart';
import '../routines/models/routine.dart';
import '../routines/storage/routine_storage.dart';
import 'account_models.dart';
import 'account_service.dart';

/// How a sync ended.
enum BackupStatus {
  /// Everything on this device and everything in the backup now match.
  synced,

  /// Nobody is signed in with a real account, so there is nothing to sync to.
  notSignedIn,

  /// Firebase is not usable on this launch.
  unavailable,

  /// The sync could not finish. Local records are untouched.
  failed,
}

class BackupResult {
  const BackupResult(
    this.status, {
    this.uploaded = 0,
    this.downloaded = 0,
    this.deletedRemotely = 0,
  });

  final BackupStatus status;
  final int uploaded;
  final int downloaded;
  final int deletedRemotely;

  bool get isSuccess => status == BackupStatus.synced;
}

/// Copies workouts, weight entries and routines between this device and the
/// signed-in account's backup.
///
/// Sync is a union, not a replace: records live under stable ids, so the same
/// record written from two phones lands in the same place. Deletions are the
/// exception - a record simply missing from one side means "not seen yet",
/// so deleting has to be recorded explicitly or the other phone would hand it
/// straight back.
class BackupService {
  BackupService({
    AccountService? account,
    FirebaseFirestore? firestore,
    WorkoutSessionStorage? workouts,
    WeightStorage? weights,
    RoutineStorage? routines,
  })  : _account = account ?? AccountService.instance,
        _injectedFirestore = firestore,
        _workouts = workouts ?? WorkoutSessionStorage(),
        _weights = weights ?? WeightStorage(),
        _routines = routines ?? RoutineStorage();

  static final BackupService instance = BackupService();

  static const String usersCollection = 'users';
  static const String workoutsCollection = 'workouts';
  static const String weightsCollection = 'weights';
  static const String routinesCollection = 'routines';

  final AccountService _account;
  final FirebaseFirestore? _injectedFirestore;
  final WorkoutSessionStorage _workouts;
  final WeightStorage _weights;
  final RoutineStorage _routines;

  FirebaseFirestore? get _firestoreOrNull {
    if (_injectedFirestore != null) return _injectedFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugLog('[BackupService] Firestore unavailable: $e');
      return null;
    }
  }

  /// Pushes local changes up and pulls the account's records down.
  ///
  /// Safe to call whenever - it is a no-op for guests, and doing nothing is
  /// reported rather than treated as a failure.
  Future<BackupResult> syncNow() async {
    final user = _account.currentUser;
    if (user == null || !user.canBackUp) {
      return const BackupResult(BackupStatus.notSignedIn);
    }

    final firestore = _firestoreOrNull;
    if (firestore == null) {
      return const BackupResult(BackupStatus.unavailable);
    }

    try {
      final root = firestore.collection(usersCollection).doc(user.id);

      final workouts = await _syncCollection<WorkoutSession>(
        remote: root.collection(workoutsCollection),
        localRecords: await _workouts.loadSessions(),
        localDeletions: await _workouts.deletedSessionIds(),
        idOf: (session) => session.id,
        toJson: (session) => session.toJson(),
        fromJson: WorkoutSession.fromJson,
        saveLocally: _workouts.addSession,
        forgetDeletion: _workouts.forgetDeletedSession,
      );

      final weights = await _syncCollection<WeightEntry>(
        remote: root.collection(weightsCollection),
        localRecords: await _weights.loadEntries(),
        localDeletions: await _weights.deletedEntryIds(),
        idOf: (entry) => entry.id,
        toJson: (entry) => entry.toJson(),
        fromJson: WeightEntry.fromJson,
        saveLocally: _weights.addEntry,
        forgetDeletion: _weights.forgetDeletedEntry,
      );

      final routines = await _syncCollection<Routine>(
        remote: root.collection(routinesCollection),
        localRecords: await _routines.loadRoutines(),
        localDeletions: await _routines.deletedRoutineIds(),
        idOf: (routine) => routine.id,
        toJson: (routine) => routine.toJson(),
        fromJson: Routine.fromJson,
        saveLocally: _routines.addRoutine,
        forgetDeletion: _routines.forgetDeletedRoutine,
      );

      return BackupResult(
        BackupStatus.synced,
        uploaded: workouts.uploaded + weights.uploaded + routines.uploaded,
        downloaded:
            workouts.downloaded + weights.downloaded + routines.downloaded,
        deletedRemotely: workouts.deletedRemotely +
            weights.deletedRemotely +
            routines.deletedRemotely,
      );
    } catch (e) {
      debugLog('[BackupService] Sync failed: $e');
      return const BackupResult(BackupStatus.failed);
    }
  }

  Future<BackupResult> _syncCollection<T>({
    required CollectionReference<Map<String, dynamic>> remote,
    required List<T> localRecords,
    required Map<String, int> localDeletions,
    required String Function(T) idOf,
    required Map<String, dynamic> Function(T) toJson,
    required T Function(Map<String, dynamic>) fromJson,
    required Future<void> Function(T) saveLocally,
    required Future<void> Function(String) forgetDeletion,
  }) async {
    final snapshot = await remote.get();
    final remoteIds = snapshot.docs.map((doc) => doc.id).toSet();
    final localById = {for (final record in localRecords) idOf(record): record};

    // Deletions first, so a record deleted here is gone before the pull
    // below could see it and put it back.
    var deletedRemotely = 0;
    for (final id in localDeletions.keys) {
      if (remoteIds.contains(id)) {
        await remote.doc(id).delete();
        deletedRemotely++;
      }
      await forgetDeletion(id);
    }

    var uploaded = 0;
    for (final entry in localById.entries) {
      if (remoteIds.contains(entry.key)) continue;
      await remote.doc(entry.key).set(toJson(entry.value));
      uploaded++;
    }

    var downloaded = 0;
    for (final doc in snapshot.docs) {
      if (localById.containsKey(doc.id)) continue;
      if (localDeletions.containsKey(doc.id)) continue;
      final record = _decode(doc.id, doc.data(), fromJson);
      if (record == null) continue;
      await saveLocally(record);
      downloaded++;
    }

    return BackupResult(
      BackupStatus.synced,
      uploaded: uploaded,
      downloaded: downloaded,
      deletedRemotely: deletedRemotely,
    );
  }

  /// Removes everything this account has backed up.
  ///
  /// Records on the device are deliberately left alone: deleting an account
  /// is about the copy on the server, and wiping someone's phone as a side
  /// effect would be a far worse surprise than leaving it.
  Future<bool> deleteEverythingBackedUp() async {
    final user = _account.currentUser;
    if (user == null || !user.canBackUp) return true;

    final firestore = _firestoreOrNull;
    if (firestore == null) return false;

    try {
      final root = firestore.collection(usersCollection).doc(user.id);
      for (final name in const [
        workoutsCollection,
        weightsCollection,
        routinesCollection,
      ]) {
        final snapshot = await root.collection(name).get();
        for (final doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }
      await root.delete();
      return true;
    } catch (e) {
      debugLog('[BackupService] Could not delete the backup: $e');
      return false;
    }
  }

  /// A record the backup cannot parse is skipped, never allowed to abort the
  /// whole sync - one bad document must not block someone's history.
  T? _decode<T>(
    String id,
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    try {
      return fromJson(data);
    } catch (e) {
      debugLog('[BackupService] Skipping unreadable backup record $id: $e');
      return null;
    }
  }
}

/// Convenience for callers that only care whether a backup is possible.
extension BackupAvailability on AccountUser? {
  bool get hasBackup => this?.canBackUp ?? false;
}
