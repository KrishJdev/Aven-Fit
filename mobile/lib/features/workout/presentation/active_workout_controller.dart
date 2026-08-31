import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/workout_repository.dart';
import '../domain/workout_set.dart';
import 'active_workout_state.dart';

part 'active_workout_controller.g.dart';

/// Riverpod AsyncNotifier managing the unidirectional state updates for an active workout.
///
/// Disallows legacy ChangeNotifier and two-way binding. Every state mutation produces
/// an immutable new state and initiates asynchronous write-through to SQLite.
@riverpod
class ActiveWorkoutController extends _$ActiveWorkoutController {
  Timer? _restTimer;

  @override
  FutureOr<ActiveWorkoutState> build() async {
    ref.onDispose(() {
      _restTimer?.cancel();
    });

    final repository = ref.watch(workoutRepositoryProvider);
    final activeSession = await repository.getActiveSession();
    if (activeSession != null) {
      final sets = await repository.getSetsForSession(activeSession.id);
      return ActiveWorkoutState(
        session: activeSession,
        sets: sets,
      );
    }

    return const ActiveWorkoutState(session: null);
  }

  /// Starts a new active workout session.
  Future<void> startWorkout({String name = 'Quick Workout'}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(workoutRepositoryProvider);
      final newSession = await repository.startWorkout(name: name);
      return ActiveWorkoutState(
        session: newSession,
        sets: const [],
      );
    });
  }

  /// Adds a new set with optimistic UI update and instant write-through.
  Future<void> addSet({
    required String exerciseId,
    required double weightKg,
    required int reps,
    SetType type = SetType.normal,
    double? rpe,
  }) async {
    final current = state.value;
    if (current == null || current.session == null) return;

    final repository = ref.read(workoutRepositoryProvider);
    final nextSetNumber =
        current.sets.where((s) => s.exerciseId == exerciseId).length + 1;

    final newSet = WorkoutSet(
      id: 'set_${DateTime.now().microsecondsSinceEpoch}',
      sessionId: current.session!.id,
      exerciseId: exerciseId,
      setNumber: nextSetNumber,
      weightKg: weightKg,
      reps: reps,
      type: type,
      rpe: rpe,
      isCompleted: false,
    );

    // Optimistic UI state update
    final updatedSets = [...current.sets, newSet];
    state = AsyncValue.data(current.copyWith(sets: updatedSets));

    // Write-through to SQLite
    await repository.logSet(newSet);
  }

  /// Toggles set completion status (<3s interaction loop).
  Future<void> toggleSetCompleted(String setId) async {
    final current = state.value;
    if (current == null) return;

    final setIndex = current.sets.indexWhere((s) => s.id == setId);
    if (setIndex == -1) return;

    final targetSet = current.sets[setIndex];
    final updatedSet = targetSet.copyWith(isCompleted: !targetSet.isCompleted);
    final updatedSets = [...current.sets]..[setIndex] = updatedSet;

    // Optimistic UI update
    state = AsyncValue.data(current.copyWith(sets: updatedSets));

    // Write-through to SQLite
    final repository = ref.read(workoutRepositoryProvider);
    await repository.updateSet(updatedSet);

    // Trigger rest timer on set completion
    if (updatedSet.isCompleted) {
      startRestTimer(current.restTimerDurationSeconds);
    }
  }

  /// Deletes a set from the session.
  Future<void> deleteSet(String setId) async {
    final current = state.value;
    if (current == null) return;

    final updatedSets = current.sets.where((s) => s.id != setId).toList();
    state = AsyncValue.data(current.copyWith(sets: updatedSets));

    final repository = ref.read(workoutRepositoryProvider);
    await repository.deleteSet(setId);
  }

  /// Starts the rest timer countdown with monotonic 1s ticks.
  void startRestTimer(int durationSeconds) {
    _restTimer?.cancel();
    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(
      isRestTimerRunning: true,
      restTimerDurationSeconds: durationSeconds,
      restTimerRemainingSeconds: durationSeconds,
    ));

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final s = state.value;
      if (s == null || !s.isRestTimerRunning) {
        timer.cancel();
        return;
      }

      if (s.restTimerRemainingSeconds <= 1) {
        timer.cancel();
        state = AsyncValue.data(s.copyWith(
          isRestTimerRunning: false,
          restTimerRemainingSeconds: 0,
        ));
      } else {
        state = AsyncValue.data(s.copyWith(
          restTimerRemainingSeconds: s.restTimerRemainingSeconds - 1,
        ));
      }
    });
  }

  /// Adds extra rest time (e.g. +15s button).
  void addRestTime(int additionalSeconds) {
    final current = state.value;
    if (current == null || !current.isRestTimerRunning) return;

    state = AsyncValue.data(current.copyWith(
      restTimerRemainingSeconds:
          current.restTimerRemainingSeconds + additionalSeconds,
      restTimerDurationSeconds:
          current.restTimerDurationSeconds + additionalSeconds,
    ));
  }

  /// Stops or skips the rest timer.
  void stopRestTimer() {
    _restTimer?.cancel();
    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(
      isRestTimerRunning: false,
      restTimerRemainingSeconds: 0,
    ));
  }

  /// Finishes the active workout session.
  Future<void> finishWorkout() async {
    final current = state.value;
    if (current == null || current.session == null) return;

    _restTimer?.cancel();
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(workoutRepositoryProvider);
      await repository.finishWorkout(current.session!.id);
      return const ActiveWorkoutState(session: null, sets: []);
    });
  }

  /// Discards/cancels the active workout session.
  Future<void> cancelWorkout() async {
    final current = state.value;
    if (current == null || current.session == null) return;

    _restTimer?.cancel();
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(workoutRepositoryProvider);
      await repository.cancelWorkout(current.session!.id);
      return const ActiveWorkoutState(session: null, sets: []);
    });
  }
}
