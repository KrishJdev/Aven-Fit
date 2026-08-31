import 'package:drift/drift.dart';

/// Drift SQLite table for anatomical muscle groups.
@DataClassName('MuscleGroupRow')
class MuscleGroups extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  IntColumn get displayOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Drift SQLite table for exercises library and custom exercises.
///
/// Complies with Law L2 (bundled offline catalog) and Law L7 (write-through persistence).
@DataClassName('ExerciseRow')
class Exercises extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text().withDefault(const Constant('OTHER'))();
  TextColumn get equipment => text().withDefault(const Constant('NONE'))();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  BoolColumn get isFavourite => boolean().withDefault(const Constant(false))();
  BoolColumn get isTimeBased => boolean().withDefault(const Constant(false))();
  BoolColumn get isCardio => boolean().withDefault(const Constant(false))();
  TextColumn get createdById => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Drift SQLite join table mapping exercises to muscle groups with their role (PRIMARY/SECONDARY).
@DataClassName('ExerciseMuscleGroupRow')
class ExerciseMuscleGroups extends Table {
  TextColumn get id => text()();
  TextColumn get exerciseId =>
      text().references(Exercises, #id, onDelete: KeyAction.cascade)();
  TextColumn get muscleGroupId =>
      text().references(MuscleGroups, #id, onDelete: KeyAction.cascade)();
  TextColumn get role => text().withDefault(const Constant('PRIMARY'))();
  DateTimeColumn get createdAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {exerciseId, muscleGroupId},
      ];
}
