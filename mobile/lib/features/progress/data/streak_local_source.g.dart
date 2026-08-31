// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_local_source.dart';

// ignore_for_file: type=lint
mixin _$StreakDaoMixin on DatabaseAccessor<AppDatabase> {
  $StreakSettingsTable get streakSettings => attachedDatabase.streakSettings;
  $RoutinesTable get routines => attachedDatabase.routines;
  $WorkoutSessionsTable get workoutSessions => attachedDatabase.workoutSessions;
  StreakDaoManager get managers => StreakDaoManager(this);
}

class StreakDaoManager {
  final _$StreakDaoMixin _db;
  StreakDaoManager(this._db);
  $$StreakSettingsTableTableManager get streakSettings =>
      $$StreakSettingsTableTableManager(
        _db.attachedDatabase,
        _db.streakSettings,
      );
  $$RoutinesTableTableManager get routines =>
      $$RoutinesTableTableManager(_db.attachedDatabase, _db.routines);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(
        _db.attachedDatabase,
        _db.workoutSessions,
      );
}
