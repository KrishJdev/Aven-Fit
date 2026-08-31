import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/history_repository.dart';
import '../../workout/domain/workout_session.dart';

part 'workout_detail_controller.g.dart';

/// AutoDispose family controller for the read-only past-workout detail view
/// (WU-3.9, FEATURES.md §8.7). A null session drives the designed
/// workout-not-found state (L6); every action is a write-through (L7).
@riverpod
class WorkoutDetailController extends _$WorkoutDetailController {
  @override
  Future<WorkoutSession?> build(String sessionId) async {
    final repository = ref.watch(historyRepositoryProvider);
    return repository.getWorkoutDetail(sessionId);
  }

  /// Renames the past workout: optimistic update + write-through (L7).
  Future<void> renameWorkout(String newName) async {
    final current = state.value;
    if (current == null) return;

    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    state = AsyncValue.data(current.copyWith(name: trimmed));
    await ref.read(historyRepositoryProvider).renameWorkout(sessionId, trimmed);
  }

  /// Repeats this workout (§8.7): creates a new active session pre-loaded
  /// with the same exercises/sets. Returns the new session id for
  /// navigation, or null when nothing was loaded / the write failed.
  Future<String?> repeatWorkout() async {
    final current = state.value;
    if (current == null) return null;
    try {
      return await ref.read(historyRepositoryProvider).repeatWorkout(sessionId);
    } catch (_) {
      return null;
    }
  }

  /// Saves this workout as a reusable routine. Returns the routine id,
  /// or null on failure (empty workouts cannot become routines).
  Future<String?> saveAsRoutine(String name) async {
    final current = state.value;
    if (current == null) return null;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;
    try {
      return await ref
          .read(historyRepositoryProvider)
          .saveWorkoutAsRoutine(sessionId, name: trimmed);
    } catch (_) {
      return null;
    }
  }

  /// Deletes this workout (destructive confirm handled by the UI, L7).
  Future<void> deleteWorkout() async {
    await ref.read(historyRepositoryProvider).deleteWorkout(sessionId);
  }
}
