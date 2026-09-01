import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/features/progress/data/streak_repository.dart';
import 'package:aven_fit/features/workout/data/workout_repository.dart';
import 'package:aven_fit/features/workout/domain/workout_session.dart';
import 'package:aven_fit/features/workout/domain/workout_set.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// WU-3.11: the Slice 3 session lifecycle journey (FEATURES.md §7.1/§8.1,
/// Laws L1/L7/L8). Walks create → log → pause → resume → finish (and the
/// crash-restore + discard paths) through the production repository,
/// asserting persisted SQLite state between every stage.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<WorkoutRepositoryImpl> newRepo() async =>
      WorkoutRepositoryImpl(db.workoutDao);

  Future<void> seedExercise(String id, String name) async {
    await db.into(db.exercises).insert(
          ExercisesCompanion.insert(id: id, name: name),
        );
  }

  /// Backdates a session column so epoch math is observable deterministically.
  Future<void> backdateSession(
    String sessionId, {
    DateTime? startedAt,
    DateTime? lastResumedAt,
  }) async {
    await (db.update(db.workoutSessions)..where((t) => t.id.equals(sessionId)))
        .write(WorkoutSessionsCompanion(
      startedAt:
          startedAt == null ? const drift.Value.absent() : drift.Value(startedAt),
      lastResumedAt: lastResumedAt == null
          ? const drift.Value.absent()
          : drift.Value(lastResumedAt),
    ));
  }

  group('Session lifecycle journey (WU-3.11)', () {
    test('full happy path: create → log → pause → resume → finish → restart',
        () async {
      final repo = await newRepo();
      await seedExercise('ex_bench', 'Barbell Bench Press');

      // 1. Create.
      final session = await repo.startWorkout(name: 'Push Day');
      expect(session.status, WorkoutStatus.active);
      expect(session.name, 'Push Day');
      expect((await repo.getActiveSession())!.id, session.id);

      // 2. Two exercise blocks, sets logged with write-through (L1/L7).
      final se1 = await repo.addExerciseToSession(
        sessionId: session.id,
        exerciseId: 'ex_bench',
      );
      final se2 = await repo.addExerciseToSession(
        sessionId: session.id,
        exerciseId: 'ex_bench',
      );
      expect(se1.orderIndex, 0);
      expect(se2.orderIndex, 1);

      await repo.logSet(WorkoutSet(
        id: 'l1_warm',
        sessionId: session.id,
        sessionExerciseId: se1.id,
        exerciseId: 'ex_bench',
        setNumber: 1,
        weightKg: 20,
        reps: 10,
        isCompleted: true,
        type: SetType.warmup,
        completedAt: DateTime.now(),
      ));
      await repo.logSet(WorkoutSet(
        id: 'l1_s2',
        sessionId: session.id,
        sessionExerciseId: se1.id,
        exerciseId: 'ex_bench',
        setNumber: 2,
        weightKg: 80,
        reps: 8,
        isCompleted: true,
        completedAt: DateTime.now(),
      ));
      await repo.logSet(WorkoutSet(
        id: 'l1_s3',
        sessionId: session.id,
        sessionExerciseId: se1.id,
        exerciseId: 'ex_bench',
        setNumber: 3,
        weightKg: 82.5,
        reps: 6,
        isCompleted: true,
        completedAt: DateTime.now(),
      ));
      await repo.logSet(WorkoutSet(
        id: 'l2_s1',
        sessionId: session.id,
        sessionExerciseId: se2.id,
        exerciseId: 'ex_bench',
        setNumber: 1,
        weightKg: 60,
        reps: 10,
        // Planned, never confirmed.
      ));

      // 3. Pause with a deterministic frozen span, then resume.
      await repo.pauseWorkout(session.id);
      final paused = await repo.getActiveSession();
      expect(paused!.isPaused, isTrue);
      expect(paused.lastResumedAt, isNotNull);
      await backdateSession(
        session.id,
        lastResumedAt: DateTime.now().subtract(const Duration(seconds: 60)),
      );
      final resumed = await repo.resumeWorkout(session.id);
      expect(resumed.isPaused, isFalse);
      expect(resumed.pausedDurationSeconds, inInclusiveRange(60, 65));

      // The joined stream exposes exercises + sets live from SQLite.
      final live = await repo.getSessionById(session.id);
      expect(live!.exercises.length, 2);
      expect(live.exercises[0].sets.length, 3);
      expect(live.exercises[1].sets.length, 1);

      // 4. Finish — the production controller computes the epoch duration
      //    and hands it to the repository (started 10 min ago, ~1 min
      //    paused); the stored value must round-trip exactly.
      await backdateSession(
        session.id,
        startedAt: DateTime.now().subtract(const Duration(seconds: 600)),
      );
      final liveBeforeFinish = (await repo.getSessionById(session.id))!;
      final elapsed = liveBeforeFinish.elapsedSecondsNow();
      expect(elapsed, inInclusiveRange(525, 555));
      await repo.finishWorkout(session.id, durationSeconds: elapsed);

      final finished = (await repo.getSessionById(session.id))!;
      expect(finished.status, WorkoutStatus.completed);
      expect(finished.completedAt, isNotNull);
      expect(finished.durationSeconds, elapsed);
      expect(finished.durationSeconds, inInclusiveRange(525, 555));
      // Working volume excludes the 20×10 warm-up (L1): 80×8 + 82.5×6.
      expect(finished.totalVolumeKg, 1135.0);
      expect(finished.completedSetsCount, 3); // warm-ups were still lifted

      // 5. The active slot is freed — a new session can start immediately.
      expect(await repo.getActiveSession(), isNull);
      final next = await repo.startWorkout(name: 'Next Session');
      expect(next.status, WorkoutStatus.active);
      expect(next.id, isNot(session.id));
    });

    test('crash mid-flow: a fresh repository restores the exact state from SQLite',
        () async {
      final repoA = await newRepo();
      await seedExercise('ex_squat', 'Back Squat');

      final session = await repoA.startWorkout(name: 'Crash Journey');
      final se = await repoA.addExerciseToSession(
        sessionId: session.id,
        exerciseId: 'ex_squat',
      );
      await repoA.logSet(WorkoutSet(
        id: 'crash_s1',
        sessionId: session.id,
        sessionExerciseId: se.id,
        exerciseId: 'ex_squat',
        setNumber: 1,
        weightKg: 100,
        reps: 5,
        isCompleted: true,
        completedAt: DateTime.now(),
      ));
      await backdateSession(
        session.id,
        startedAt: DateTime.now().subtract(const Duration(seconds: 120)),
      );

      // "Process death": a brand-new repository over the same SQLite —
      // every byte of state must come back from disk (L7).
      final repoB = await newRepo();
      final restored = (await repoB.getActiveSession())!;
      expect(restored.id, session.id);
      expect(restored.name, 'Crash Journey');
      expect(restored.status, WorkoutStatus.active);
      expect(restored.elapsedSecondsNow(), inInclusiveRange(120, 135));
      expect(restored.exercises.single.exerciseId, 'ex_squat');
      final restoredSet = restored.exercises.single.sets.single;
      expect(restoredSet.isCompleted, isTrue);
      expect(restoredSet.weightKg, 100.0);
      expect(restoredSet.reps, 5);

      // The restored instance can finish the journey it inherited.
      await repoB.finishWorkout(session.id);
      final finished = (await repoB.getSessionById(session.id))!;
      expect(finished.status, WorkoutStatus.completed);
      expect(finished.completedSetsCount, 1);
    });

    test('multiple pause/resume cycles accumulate the paused span', () async {
      final repo = await newRepo();
      await seedExercise('ex_row', 'Barbell Row');

      final session = await repo.startWorkout(name: 'Pause Cycles');
      await repo.addExerciseToSession(
        sessionId: session.id,
        exerciseId: 'ex_row',
      );
      await backdateSession(
        session.id,
        startedAt: DateTime.now().subtract(const Duration(seconds: 300)),
      );

      // Cycle 1: paused ~40s. Cycle 2: paused ~25s.
      await repo.pauseWorkout(session.id);
      await backdateSession(
        session.id,
        lastResumedAt: DateTime.now().subtract(const Duration(seconds: 40)),
      );
      await repo.resumeWorkout(session.id);

      await repo.pauseWorkout(session.id);
      await backdateSession(
        session.id,
        lastResumedAt: DateTime.now().subtract(const Duration(seconds: 25)),
      );
      final resumed = await repo.resumeWorkout(session.id);
      expect(resumed.pausedDurationSeconds, inInclusiveRange(65, 75));

      // Finish via the production contract: epoch duration handed in
      // (~300s wall span minus ~65–75s paused).
      final live = (await repo.getSessionById(session.id))!;
      final elapsed = live.elapsedSecondsNow();
      expect(elapsed, inInclusiveRange(220, 245));
      await repo.finishWorkout(session.id, durationSeconds: elapsed);
      final finished = (await repo.getSessionById(session.id))!;
      expect(finished.durationSeconds, elapsed);
      expect(finished.durationSeconds, inInclusiveRange(220, 245));
    });

    test('discard path: frozen elapsed time and never counted as completed',
        () async {
      final repo = await newRepo();
      final streakRepo = StreakRepositoryImpl(db.streakDao);
      await seedExercise('ex_dl', 'Deadlift');

      final session = await repo.startWorkout(name: 'Abandoned');
      final se = await repo.addExerciseToSession(
        sessionId: session.id,
        exerciseId: 'ex_dl',
      );
      await repo.logSet(WorkoutSet(
        id: 'dl_s1',
        sessionId: session.id,
        sessionExerciseId: se.id,
        exerciseId: 'ex_dl',
        setNumber: 1,
        weightKg: 140,
        reps: 3,
        isCompleted: true,
        completedAt: DateTime.now(),
      ));
      await backdateSession(
        session.id,
        startedAt: DateTime.now().subtract(const Duration(seconds: 90)),
      );

      await repo.cancelWorkout(session.id);

      final discarded = (await repo.getSessionById(session.id))!;
      expect(discarded.status, WorkoutStatus.discarded);
      // Discarded sessions freeze — stale sessions never keep counting (L8).
      final now = DateTime.now();
      final frozenNow = discarded.elapsedSecondsNow(now);
      final frozenLater =
          discarded.elapsedSecondsNow(now.add(const Duration(hours: 1)));
      expect(frozenLater, frozenNow);

      // The active slot is freed and the discarded session never pollutes
      // the completed-streak input (§17 data contract).
      expect(await repo.getActiveSession(), isNull);
      final streak = await streakRepo.getStreakInfo();
      expect(streak.workoutsThisWeek, 0);
      expect(streak.currentStreakWeeks, 0);
    });
  });
}
