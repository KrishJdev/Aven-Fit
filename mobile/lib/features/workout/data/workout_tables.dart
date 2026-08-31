import 'package:drift/drift.dart';

/// Drift SQLite table for workout sessions.
///
/// Uses client-generated UUID primary keys (Law L2, L7) so the local
/// SQLite database remains the authority and sync requires no ID remapping.
@DataClassName('WorkoutSessionRow')
class WorkoutSessions extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withDefault(const Constant('Workout'))();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Drift SQLite table for logged workout sets.
@DataClassName('WorkoutSetRow')
class WorkoutSets extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId =>
      text().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId => text()();
  IntColumn get setNumber => integer()();
  RealColumn get weightKg => real()();
  IntColumn get reps => integer()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  TextColumn get setType => text().withDefault(const Constant('normal'))();
  RealColumn get rpe => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
