import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../workout/data/workout_tables.dart';
import '../domain/streak_info.dart';
import 'streak_tables.dart';

part 'streak_local_source.g.dart';

/// One reactive read of the streak inputs: the effective weekly goal plus
/// the completion dates of every completed workout.
typedef StreakInput = ({int weeklyGoalDays, List<DateTime> completedDates});

/// DAO providing streak settings storage and the completed-workout history
/// input for the forgiving weekly streak (WU-X.2, FEATURES.md §17).
@DriftAccessor(tables: [StreakSettings, WorkoutSessions])
class StreakDao extends DatabaseAccessor<AppDatabase> with _$StreakDaoMixin {
  StreakDao(super.db);

  /// Singleton settings row key.
  static const String defaultSettingsId = 'default';

  /// The stored settings row, or null before the first goal change.
  Future<StreakSettingRow?> getSettings() {
    return (select(streakSettings)
          ..where((t) => t.id.equals(defaultSettingsId))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Persists the weekly goal (upsert of the singleton row).
  Future<void> setWeeklyGoal(int days) async {
    final existing = await getSettings();
    if (existing == null) {
      await into(streakSettings).insert(
        StreakSettingsCompanion.insert(
          id: defaultSettingsId,
          weeklyGoalDays: Value(days),
        ),
      );
    } else {
      await (update(streakSettings)
            ..where((t) => t.id.equals(defaultSettingsId)))
          .write(
        StreakSettingsCompanion(
          weeklyGoalDays: Value(days),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  /// Effective completion date of a session — when it actually counts
  /// toward the streak (completedAt, falling back to startedAt).
  DateTime _effectiveDate(WorkoutSessionRow row) =>
      row.completedAt ?? row.startedAt;

  /// Effective completion dates of every completed workout, oldest data
  /// unchanged — the raw input for the pure streak math.
  Future<List<DateTime>> getCompletedWorkoutDates() async {
    final rows = await (select(workoutSessions)
          ..where((t) => t.status.equals('completed')))
        .get();
    return rows.map(_effectiveDate).toList();
  }

  /// Reactive streak input: re-emits whenever the settings row OR any
  /// workout session changes. The tracked query reads only the goal (via
  /// subselect with a default fallback), but `readsFrom` subscribes the
  /// stream to both tables, and each re-execution re-reads the completed
  /// dates fresh — one drift-native stream covering both triggers (L8).
  Stream<StreakInput> watchStreakInput() {
    return customSelect(
      'SELECT COALESCE('
      '(SELECT weekly_goal_days FROM streak_settings WHERE id = ?), ?'
      ') AS weekly_goal_days',
      variables: [
        Variable<String>(defaultSettingsId),
        Variable<int>(kDefaultWeeklyGoal),
      ],
      readsFrom: {streakSettings, workoutSessions},
    )
        .watchSingle()
        .asyncMap((row) async {
      final goal = row.readNullable<int>('weekly_goal_days');
      final dates = await getCompletedWorkoutDates();
      return (
        weeklyGoalDays: goal ?? kDefaultWeeklyGoal,
        completedDates: dates,
      );
    });
  }
}
