import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../main.dart';
import '../../progress/data/pr_repository.dart';
import '../../workout/data/workout_repository.dart';
import '../../workout/domain/workout_session.dart';
import '../domain/lifetime_stats.dart';
import '../domain/week_stats.dart';
import '../domain/workout_history_item.dart';
import 'history_local_source.dart';

part 'history_repository.g.dart';

/// Contract for browsing and acting on past workouts (WU-3.9, §8.6/§8.7).
abstract class HistoryRepository {
  /// Reactive, paginated feed of completed workouts, newest first.
  Stream<List<WorkoutHistoryItem>> watchCompletedWorkouts({
    int limit = 50,
    int offset = 0,
  });

  /// One-shot variant of [watchCompletedWorkouts] for non-reactive reads.
  Future<List<WorkoutHistoryItem>> getCompletedWorkouts({
    int limit = 50,
    int offset = 0,
  });

  /// Reactive lifetime aggregate (WU-5.3, §12.1): total completed
  /// workouts, confirmed sets, working volume (warm-ups excluded, L1)
  /// and the "member since" anchor — recomputed on every history change.
  Stream<LifetimeStats> watchLifetimeStats();

  /// Reactive week-over-week glance (WU-X.1, §7.1): this week's and last
  /// week's workouts/sets/working volume for the Home delta badges.
  Stream<WeeklyGlance> watchWeeklyGlance();

  /// Full read-only breakdown (exercises with names + every set).
  Future<WorkoutSession?> getWorkoutDetail(String sessionId);

  /// Starts a new active session pre-loaded with this workout's exercises
  /// and sets as planned rows. Returns the new session id.
  Future<String> repeatWorkout(String sessionId);

  /// Converts this workout into a reusable routine. Returns the routine id.
  Future<String> saveWorkoutAsRoutine(String sessionId, {required String name});

  /// Renames a past workout (write-through, L7).
  Future<void> renameWorkout(String sessionId, String name);

  /// Deletes the workout (with confirmation at the UI layer, L7) and
  /// recomputes personal records from the remaining history so no PR row
  /// dangles or goes stale (§10.2 parity).
  Future<void> deleteWorkout(String sessionId);
}

/// Production implementation of [HistoryRepository] backed by [HistoryDao]
/// plus the workout repository (joined detail reads) and the PR repository
/// (self-healing recompute after deletes).
class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl(this._dao, this._workoutRepository, this._prRepository);

  final HistoryDao _dao;
  final WorkoutRepository _workoutRepository;
  final PRRepository _prRepository;

  @override
  Stream<List<WorkoutHistoryItem>> watchCompletedWorkouts({
    int limit = 50,
    int offset = 0,
  }) {
    return _dao.watchCompletedWorkouts(limit: limit, offset: offset);
  }

  @override
  Future<List<WorkoutHistoryItem>> getCompletedWorkouts({
    int limit = 50,
    int offset = 0,
  }) {
    return _dao.getCompletedWorkouts(limit: limit, offset: offset);
  }

  @override
  Stream<LifetimeStats> watchLifetimeStats() {
    return _dao.watchLifetimeStats();
  }

  @override
  Stream<WeeklyGlance> watchWeeklyGlance() {
    return _dao.watchWeeklyGlance();
  }

  @override
  Future<WorkoutSession?> getWorkoutDetail(String sessionId) {
    return _workoutRepository.getSessionById(sessionId);
  }

  @override
  Future<String> repeatWorkout(String sessionId) {
    return _dao.repeatWorkout(sessionId);
  }

  @override
  Future<String> saveWorkoutAsRoutine(
    String sessionId, {
    required String name,
  }) {
    return _dao.saveWorkoutAsRoutine(sessionId, name);
  }

  @override
  Future<void> renameWorkout(String sessionId, String name) {
    return _workoutRepository.renameSession(sessionId, name);
  }

  @override
  Future<void> deleteWorkout(String sessionId) async {
    final affectedExerciseIds = await _dao.deleteWorkout(sessionId);
    for (final exerciseId in affectedExerciseIds) {
      await _prRepository.recomputePRs(exerciseId);
    }
  }
}

/// Riverpod provider exposing [HistoryRepository] to feature controllers.
@riverpod
HistoryRepository historyRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return HistoryRepositoryImpl(
    db.historyDao,
    ref.watch(workoutRepositoryProvider),
    ref.watch(prRepositoryProvider),
  );
}

/// Page size for the history feed — loadMore grows the window (§8.6
/// virtualized list, smooth across years of data).
@riverpod
class HistoryFeedLimit extends _$HistoryFeedLimit {
  static const int pageSize = 50;

  @override
  int build() => pageSize;

  void loadMore() => state = state + pageSize;
}

/// Reactive history feed: watches completed workouts with the current page
/// window. Re-executes when the limit grows or the underlying SQLite tables
/// change (L2 — renders from local data in <2s cold start).
@riverpod
Stream<List<WorkoutHistoryItem>> watchWorkoutHistory(Ref ref) {
  final limit = ref.watch(historyFeedLimitProvider);
  return ref.watch(historyRepositoryProvider).watchCompletedWorkouts(
        limit: limit,
      );
}

/// Reactive lifetime stats for the Profile screen (WU-5.3): drift
/// re-emits whenever the session/set tables change — zero polling (L8).
@riverpod
Stream<LifetimeStats> watchLifetimeStats(Ref ref) {
  return ref.watch(historyRepositoryProvider).watchLifetimeStats();
}
