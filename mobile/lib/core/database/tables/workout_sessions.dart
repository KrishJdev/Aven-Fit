import 'package:drift/drift.dart';

/// Base session table — the root of the workout domain.
///
/// Slice 1 keeps the schema minimal; columns for routine linkage,
/// duration and notes land with their owning slices (2–3).
///
/// Client-generated UUIDs are the primary key everywhere so the local
/// SQLite database stays the source of truth and the sync contract
/// (AGENTS.md) never needs server-side ID mapping.
class WorkoutSessions extends Table {
  TextColumn get id => text()();

  /// When the session started.
  DateTimeColumn get startedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
