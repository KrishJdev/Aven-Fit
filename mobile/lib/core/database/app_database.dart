import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/workout_sessions.dart';

part 'app_database.g.dart';

/// Aven Fit local SQLite database — the primary source of truth during
/// live usage (Law L2).
///
/// Runs in a background isolate via `drift_flutter` so queries never
/// block the UI thread on budget devices.
@DriftDatabase(tables: [WorkoutSessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Future migrations go here — never destructive by default.
        },
      );
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'aven_fit',
    native: const DriftNativeOptions(
      // Share one database instance across isolates; prevents
      // "database is locked" when background work (sync, timers)
      // touches the DB concurrently with the UI.
      shareAcrossIsolates: true,
    ),
  );
}
