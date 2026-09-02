import 'dart:async';
import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/workout_foreground_service.dart';
import '../../progress/data/pr_repository.dart';
import '../data/workout_repository.dart';
import '../domain/session_exercise.dart';
import '../domain/workout_session.dart';
import '../domain/workout_set.dart';
import 'active_workout_state.dart';
import 'rest_timer_controller.dart';

part 'active_workout_controller.g.dart';

/// Riverpod AsyncNotifier managing the unidirectional state updates for an active workout.
///
/// Disallows legacy ChangeNotifier and two-way binding. Every state mutation produces
/// an immutable new state and initiates asynchronous write-through to SQLite.
///
/// WU-3.10: the session lifecycle is mirrored onto the Android foreground
/// service — started/restored when a session becomes active, updated on
/// pause/resume/rename, stopped on finish/discard — so the lock-screen
/// notification always mirrors app state (L7/L8).
@riverpod
class ActiveWorkoutController extends _$ActiveWorkoutController {
  static int _setCounter = 0;

  @override
  FutureOr<ActiveWorkoutState> build() async {
    final repository = ref.watch(workoutRepositoryProvider);
    final activeSession = await repository.getActiveSession();
    if (activeSession != null) {
      // Crash resilience (WU-3.8, L7/L8): the launch-time restore path —
      // every exercise, set, and the epoch-math elapsed time come straight
      // from SQLite, so a force-kill mid-session loses nothing.
      final exercises = await repository.getSessionExercises(activeSession.id);
      final flatSets = exercises.expand((e) => e.sets).toList();
      final state = ActiveWorkoutState(
        session: activeSession,
        exercises: exercises,
        sets: flatSets,
        elapsedSeconds: activeSession.elapsedSecondsNow(),
        wasRestored: true,
      );
      _syncForegroundStart(activeSession);
      return state;
    }

    return const ActiveWorkoutState(session: null);
  }

  /// Starts a new active workout session.
  Future<void> startWorkout({
    String name = 'Quick Workout',
    String? routineId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(workoutRepositoryProvider);
      final newSession = await repository.startWorkout(
        name: name,
        routineId: routineId,
      );
      _syncForegroundStart(newSession);
      return ActiveWorkoutState(
        session: newSession,
        exercises: const [],
        sets: const [],
      );
    });
  }

  /// Adds an exercise to the active workout session.
  Future<SessionExercise?> addExercise(
    String exerciseId, {
    int restSeconds = 90,
    String? notes,
  }) async {
    final current = state.value;
    if (current == null || current.session == null) return null;

    final repository = ref.read(workoutRepositoryProvider);
    final sessionExercise = await repository.addExerciseToSession(
      sessionId: current.session!.id,
      exerciseId: exerciseId,
      restSeconds: restSeconds,
      notes: notes,
    );

    final updatedExercises = [...current.exercises, sessionExercise];
    final updatedSets = updatedExercises.expand((e) => e.sets).toList();
    state = AsyncValue.data(current.copyWith(
      exercises: updatedExercises,
      sets: updatedSets,
    ));

    return sessionExercise;
  }

  /// Removes an exercise entry from the active session.
  Future<void> removeExercise(String sessionExerciseId) async {
    final current = state.value;
    if (current == null || current.session == null) return;

    final updatedExercises =
        current.exercises.where((e) => e.id != sessionExerciseId).toList();
    final updatedSets = updatedExercises.expand((e) => e.sets).toList();
    state = AsyncValue.data(current.copyWith(
      exercises: updatedExercises,
      sets: updatedSets,
    ));

    final repository = ref.read(workoutRepositoryProvider);
    await repository.removeExerciseFromSession(sessionExerciseId);
  }

  /// Reorders exercises within the active workout session.
  Future<void> reorderExercises(List<String> orderedSessionExerciseIds) async {
    final current = state.value;
    if (current == null || current.session == null) return;

    final exerciseMap = {for (final e in current.exercises) e.id: e};
    final updatedExercises = orderedSessionExerciseIds
        .map((id) => exerciseMap[id])
        .whereType<SessionExercise>()
        .toList();

    state = AsyncValue.data(current.copyWith(exercises: updatedExercises));

    final repository = ref.read(workoutRepositoryProvider);
    await repository.reorderSessionExercises(
      current.session!.id,
      orderedSessionExerciseIds,
    );
  }

  /// Adds a new set with optimistic UI update and instant write-through.
  Future<void> addSet({
    String? sessionExerciseId,
    required String exerciseId,
    required double weightKg,
    required int reps,
    SetType type = SetType.normal,
    double? rpe,
  }) async {
    final current = state.value;
    if (current == null || current.session == null) return;

    final repository = ref.read(workoutRepositoryProvider);

    // Resolve or create sessionExerciseId
    var targetSeId = sessionExerciseId;
    if (targetSeId == null) {
      final existingSe = current.exercises.where((e) => e.exerciseId == exerciseId);
      if (existingSe.isNotEmpty) {
        targetSeId = existingSe.first.id;
      } else {
        final newSe = await repository.addExerciseToSession(
          sessionId: current.session!.id,
          exerciseId: exerciseId,
        );
        targetSeId = newSe.id;
      }
    }

    final setsForExercise =
        current.sets.where((s) => s.sessionExerciseId == targetSeId).toList();
    final nextSetNumber = setsForExercise.length + 1;

    final newSet = WorkoutSet(
      id: 'set_${DateTime.now().microsecondsSinceEpoch}_${_setCounter++}',
      sessionId: current.session!.id,
      sessionExerciseId: targetSeId,
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
    final updatedExercises = current.exercises.map((se) {
      if (se.id == targetSeId) {
        return se.copyWith(sets: [...se.sets, newSet]);
      }
      return se;
    }).toList();

    state = AsyncValue.data(current.copyWith(
      sets: updatedSets,
      exercises: updatedExercises,
    ));

    // Write-through to SQLite
    await repository.logSet(newSet);
  }

  /// Toggles set completion status (<3s interaction loop).
  ///
  /// Crash resilience (WU-3.8, L7): the confirmed values are written through
  /// to SQLite *before* the UI locks the row — a force-kill immediately after
  /// ✓ can never lose the set (J1 gate). PR detection runs after the durable
  /// write and must never jeopardize it.
  Future<void> toggleSetCompleted(String setId) async {
    final current = state.value;
    if (current == null) return;

    final setIndex = current.sets.indexWhere((s) => s.id == setId);
    if (setIndex == -1) return;

    final targetSet = current.sets[setIndex];
    final repository = ref.read(workoutRepositoryProvider);

    if (targetSet.isCompleted) {
      // Un-completing: revert to planned values, clear the PR flag.
      final updatedSet = targetSet.copyWith(
        isCompleted: false,
        completedAt: null,
        isPr: false,
      );
      state = AsyncValue.data(_withSet(current, updatedSet, setIndex));
      await repository.updateSet(updatedSet);
      return;
    }

    // Write-through FIRST, then UI lock (L7): the confirmed values hit SQLite
    // synchronously before the row renders Volt-Green locked.
    var updatedSet = targetSet.copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );
    await repository.updateSet(updatedSet);
    state = AsyncValue.data(_withSet(current, updatedSet, setIndex));

    // PR detection (§8.1, §10.2): computed instantly from local history at
    // set-save time. Warm-up sets never count; beaten records flash the PR
    // badge on the set row and celebrate with a medium haptic (L5). A PR
    // failure never rolls back the completion — the set is already durable.
    if (updatedSet.type != SetType.warmup && updatedSet.exerciseId != null) {
      try {
        final newPRs = await ref.read(prRepositoryProvider).detectPRs(
              exerciseId: updatedSet.exerciseId!,
              set: updatedSet,
            );
        if (newPRs.isNotEmpty) {
          updatedSet = updatedSet.copyWith(isPr: true);
          state = AsyncValue.data(_withSet(current, updatedSet, setIndex));
          await repository.updateSet(updatedSet);
        }
      } catch (_) {
        // PR detection is best-effort; the confirmed set is already persisted.
      }
    }

    // Rest timer (§8.3): resting and lifting are mutually exclusive — any ✓
    // cancels the live countdown; a completed working set restarts it with
    // the exercise's rest override (default 90s). Warm-up sets never rest.
    final restTimer = ref.read(restTimerControllerProvider.notifier);
    if (updatedSet.isCompleted) {
      if (updatedSet.type == SetType.warmup) {
        restTimer.cancel();
      } else {
        final matches =
            current.exercises.where((e) => e.id == updatedSet.sessionExerciseId);
        final sessionExercise = matches.isNotEmpty ? matches.first : null;
        restTimer.start(
          seconds: sessionExercise?.restSeconds,
          sessionExerciseId: updatedSet.sessionExerciseId,
          exerciseName: sessionExercise?.exerciseName,
        );
      }
    }
  }

  /// Returns [current] with [set] patched into both the flat set list and its
  /// nested session-exercise at [setIndex].
  ActiveWorkoutState _withSet(
    ActiveWorkoutState current,
    WorkoutSet set,
    int setIndex,
  ) {
    final updatedSets = [...current.sets]..[setIndex] = set;
    final updatedExercises = current.exercises.map((se) {
      if (se.id == set.sessionExerciseId) {
        final sIdx = se.sets.indexWhere((s) => s.id == set.id);
        if (sIdx != -1) {
          final newSeSets = [...se.sets]..[sIdx] = set;
          return se.copyWith(sets: newSeSets);
        }
      }
      return se;
    }).toList();
    return current.copyWith(sets: updatedSets, exercises: updatedExercises);
  }

  /// Deletes a set from the session.
  Future<void> deleteSet(String setId) async {
    final current = state.value;
    if (current == null) return;

    final targetSet = current.sets.firstWhere((s) => s.id == setId);
    final updatedSets = current.sets.where((s) => s.id != setId).toList();
    final updatedExercises = current.exercises.map((se) {
      if (se.id == targetSet.sessionExerciseId) {
        return se.copyWith(
          sets: se.sets.where((s) => s.id != setId).toList(),
        );
      }
      return se;
    }).toList();

    state = AsyncValue.data(current.copyWith(
      sets: updatedSets,
      exercises: updatedExercises,
    ));

    final repository = ref.read(workoutRepositoryProvider);
    await repository.deleteSet(setId);
  }

  /// Updates the name of the active workout session with SQLite write-through (L7).
  Future<void> updateWorkoutName(String newName) async {
    final current = state.value;
    if (current == null || current.session == null) return;

    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    final updatedSession = current.session!.copyWith(name: trimmed);
    state = AsyncValue.data(current.copyWith(session: updatedSession));

    final repository = ref.read(workoutRepositoryProvider);
    await repository.renameSession(current.session!.id, trimmed);
    _syncForegroundSession(updatedSession);
  }

  /// Pauses the session timer (§8.1): freezes elapsed time at the pause
  /// moment and persists the paused state so a crash/kill restores it frozen
  /// (L7/L8). Write-through first, then the state update.
  Future<void> pauseWorkout() async {
    final current = state.value;
    if (current == null || current.session == null || current.session!.isPaused) {
      return;
    }

    final repository = ref.read(workoutRepositoryProvider);
    final updatedSession = await repository.pauseWorkout(current.session!.id);
    state = AsyncValue.data(current.copyWith(
      session: updatedSession,
      elapsedSeconds: updatedSession.elapsedSecondsNow(),
    ));
    _syncForegroundSession(updatedSession);
  }

  /// Resumes the session timer (§8.1): folds the pause span into
  /// [WorkoutSession.pausedDurationSeconds] and keeps ticking from epoch math.
  Future<void> resumeWorkout() async {
    final current = state.value;
    if (current == null || current.session == null || !current.session!.isPaused) {
      return;
    }

    final repository = ref.read(workoutRepositoryProvider);
    final updatedSession = await repository.resumeWorkout(current.session!.id);
    state = AsyncValue.data(current.copyWith(
      session: updatedSession,
      elapsedSeconds: updatedSession.elapsedSecondsNow(),
    ));
    _syncForegroundSession(updatedSession);
  }

  /// Dismisses the "Workout resumed" restore banner (§8.1 states).
  void dismissRestoredBanner() {
    final current = state.value;
    if (current == null || !current.wasRestored) return;
    state = AsyncValue.data(current.copyWith(wasRestored: false));
  }

  /// Updates set values (weight, reps, rpe, type) with instant write-through.
  Future<void> updateSet(WorkoutSet updatedSet) async {
    final current = state.value;
    if (current == null) return;

    final setIndex = current.sets.indexWhere((s) => s.id == updatedSet.id);
    if (setIndex == -1) return;

    final updatedSets = [...current.sets]..[setIndex] = updatedSet;
    final updatedExercises = current.exercises.map((se) {
      if (se.id == updatedSet.sessionExerciseId) {
        final sIdx = se.sets.indexWhere((s) => s.id == updatedSet.id);
        if (sIdx != -1) {
          final newSeSets = [...se.sets]..[sIdx] = updatedSet;
          return se.copyWith(sets: newSeSets);
        }
      }
      return se;
    }).toList();

    state = AsyncValue.data(current.copyWith(
      sets: updatedSets,
      exercises: updatedExercises,
    ));

    final repository = ref.read(workoutRepositoryProvider);
    await repository.updateSet(updatedSet);
  }

  /// Generates a progressive warm-up pyramid ladder (§8.1) before working sets.
  Future<void> generateWarmupPyramid({
    required String sessionExerciseId,
    required String exerciseId,
    required double workingWeightKg,
  }) async {
    final ladder = <({double weight, int reps})>[];

    if (workingWeightKg >= 40.0) {
      ladder.add((weight: 20.0, reps: 10)); // Empty bar
      ladder.add((weight: ((workingWeightKg * 0.5) / 2.5).round() * 2.5, reps: 5));
      ladder.add((weight: ((workingWeightKg * 0.7) / 2.5).round() * 2.5, reps: 3));
      ladder.add((weight: ((workingWeightKg * 0.85) / 2.5).round() * 2.5, reps: 1));
    } else {
      ladder.add((weight: ((workingWeightKg * 0.5) / 2.5).round() * 2.5, reps: 8));
      ladder.add((weight: ((workingWeightKg * 0.75) / 2.5).round() * 2.5, reps: 4));
    }

    for (final step in ladder) {
      await addSet(
        sessionExerciseId: sessionExerciseId,
        exerciseId: exerciseId,
        weightKg: step.weight > 0 ? step.weight : 20.0,
        reps: step.reps,
        type: SetType.warmup,
      );
    }
  }

  /// Generates a time-of-day default workout name per FEATURES.md §8.1 —
  /// each band offers two names and ONE is picked randomly, so repeated
  /// sessions vary. [random] is injectable for deterministic tests.
  static String generateDefaultWorkoutName([DateTime? time, Random? random]) {
    final t = time ?? DateTime.now();
    final hour = t.hour;
    final names = switch (hour) {
      >= 5 && < 9 => ['Early Bird Workout', 'Dawn Patrol'],
      >= 9 && < 12 => ['Morning Grind', 'Morning Workout'],
      >= 12 && < 17 => ['Afternoon Pump', 'Midday Session'],
      >= 17 && < 21 => ['Evening Workout', 'Sundown Session'],
      >= 21 => ['Night Session', 'Late Lift'],
      _ => ['Late Night Lift', 'Midnight Session'],
    };
    final rand = random ?? Random();
    return names[rand.nextInt(names.length)];
  }

  /// Finishes the active workout session and returns its id so the screen can
  /// navigate to the Workout Summary (§8.5). Returns null when there was
  /// nothing to finish, the save is already in flight, or the write-through
  /// failed. The stored duration is computed via epoch math
  /// (`now − startedAt − pausedDuration`) so pauses are honored and the
  /// summary never re-derives it (L7/L8).
  Future<String?> finishWorkout() async {
    final current = state.value;
    if (current == null || current.session == null || current.isSaving) {
      return null;
    }

    final sessionId = current.session!.id;
    final elapsedSeconds = current.session!.elapsedSecondsNow();
    ref.read(restTimerControllerProvider.notifier).cancel();

    // §8.1 "saving" state: the logging view stays fully alive (session +
    // every logged set still in state) while the write-through completes —
    // a finish must never collapse the screen into the load-error state.
    state = AsyncValue.data(current.copyWith(isSaving: true));
    try {
      final repository = ref.read(workoutRepositoryProvider);
      await repository.finishWorkout(sessionId, durationSeconds: elapsedSeconds);
      unawaited(ref.read(workoutForegroundServiceProvider).stop());
      state = const AsyncValue.data(
        ActiveWorkoutState(session: null, exercises: [], sets: []),
      );
      return sessionId;
    } catch (_) {
      // §8.1 "save error with retry": the write failed but the data is
      // still local and recoverable — the state keeps the session and
      // every set, the screen surfaces the designed error + RETRY, and a
      // retry simply re-runs this finish (L6/L7).
      state = AsyncValue.data(current.copyWith(
        isSaving: false,
        errorMessage: 'Could not save workout. Your sets are safe on this device.',
      ));
      return null;
    }
  }

  /// Discards/cancels the active workout session.
  Future<void> cancelWorkout() async {
    final current = state.value;
    if (current == null || current.session == null) return;

    ref.read(restTimerControllerProvider.notifier).cancel();
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(workoutRepositoryProvider);
      await repository.cancelWorkout(current.session!.id);
      unawaited(ref.read(workoutForegroundServiceProvider).stop());
      return const ActiveWorkoutState(
        session: null,
        exercises: [],
        sets: [],
      );
    });
  }

  /// Starts (or re-syncs) the foreground-service notification for a session
  /// that just became active — creation or launch-time restore (WU-3.10).
  void _syncForegroundStart(WorkoutSession session) {
    unawaited(ref.read(workoutForegroundServiceProvider).startSession(
          workoutName: session.name,
          startedAtMs: session.startedAt.millisecondsSinceEpoch,
          isPaused: session.isPaused,
          pausedDurationMs: session.pausedDurationSeconds * 1000,
          lastResumedAtMs: session.lastResumedAt?.millisecondsSinceEpoch ?? 0,
        ));
  }

  /// Mirrors pause/resume/rename state changes onto the service
  /// (absent rest fields keep the live countdown untouched).
  void _syncForegroundSession(WorkoutSession session) {
    unawaited(ref.read(workoutForegroundServiceProvider).updateSession(
          workoutName: session.name,
          startedAtMs: session.startedAt.millisecondsSinceEpoch,
          isPaused: session.isPaused,
          pausedDurationMs: session.pausedDurationSeconds * 1000,
          lastResumedAtMs: session.lastResumedAt?.millisecondsSinceEpoch ?? 0,
        ));
  }
}
