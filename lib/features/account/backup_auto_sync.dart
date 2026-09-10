import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../profile/providers/weight_tracker_provider.dart';
import '../profile/providers/workout_history_provider.dart';
import '../routines/storage/routine_provider.dart';
import 'backup_service.dart';

/// Keeps the backup current while the app runs, and the screens current with
/// the backup.
///
/// Syncs when the app goes to the background - the last reliable moment to
/// push what was just recorded - and when it comes back, to pick up what
/// another phone changed. When a sync brings records down, the record
/// providers reload: they read storage once and keep it in memory, so a
/// restore would otherwise stay hidden until the next launch.
class BackupAutoSync extends StatefulWidget {
  const BackupAutoSync({
    super.key,
    required this.child,
    this.backup,
  });

  final Widget child;
  final BackupService? backup;

  @override
  State<BackupAutoSync> createState() => _BackupAutoSyncState();
}

class _BackupAutoSyncState extends State<BackupAutoSync>
    with WidgetsBindingObserver {
  late final BackupService _backup = widget.backup ?? BackupService.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _backup.localRecordsChanged.addListener(_reload);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _backup.localRecordsChanged.removeListener(_reload);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.resumed) {
      // Guests make this a no-op inside syncNow.
      unawaited(_backup.syncNow());
    }
  }

  void _reload() {
    if (!mounted) return;
    context.read<RoutineProvider>().loadRoutines();
    context.read<WorkoutHistoryProvider>().loadSessions();
    context.read<WeightTrackerProvider>().loadData();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
