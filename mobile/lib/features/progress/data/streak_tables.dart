import 'package:drift/drift.dart';

/// Drift SQLite table storing the user's streak settings (WU-X.2,
/// FEATURES.md §17).
///
/// A single 'default' row per device — the forgiving weekly goal. The
/// streak itself is never stored: it is re-derived from the completed
/// workout history on every read, so set edits/deletes self-heal (L7).
@DataClassName('StreakSettingRow')
class StreakSettings extends Table {
  /// Singleton row key ('default') — one settings record per device.
  TextColumn get id => text()();

  /// Target workouts per week for the forgiving streak (§17, 3–6 range
  /// from §5.2). Defaults to 3 when the setup quiz was skipped (mirrors
  /// [kDefaultWeeklyGoal]; a literal so generated code stays import-free).
  IntColumn get weeklyGoalDays => integer().withDefault(const Constant(3))();

  DateTimeColumn get updatedAt =>
      dateTime().nullable().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
