import 'package:drift/drift.dart';

import '../../exercise/data/exercise_tables.dart';
import '../../workout/data/workout_tables.dart';

/// Drift SQLite table storing the current best personal records per exercise
/// and record type (WU-3.6, FEATURES.md §10.2).
///
/// One row per (exercise, record type) — plus one per weight for the
/// weight-keyed `maxRepsAtWeight` type (uniqueness for that key is maintained
/// by the repository's code-managed upsert, since SQLite treats NULLs as
/// distinct in unique constraints). Rows are written incrementally at
/// set-save time and are fully re-derivable via `PRRepository.recomputePRs`.
/// `sessionId`/`setId` cascade so deleting a set or session can never leave
/// orphaned records (L7).
@DataClassName('PersonalRecordRow')
class PersonalRecords extends Table {
  TextColumn get id => text()();
  TextColumn get exerciseId =>
      text().references(Exercises, #id, onDelete: KeyAction.cascade)();
  TextColumn get recordType => text()();
  RealColumn get value => real()();

  /// Weight key for `maxRepsAtWeight` records; null for the other types.
  RealColumn get weightKg => real().nullable()();
  DateTimeColumn get achievedAt => dateTime()();
  TextColumn get sessionId => text()
      .nullable()
      .references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get setId => text()
      .nullable()
      .references(WorkoutSets, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get createdAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
