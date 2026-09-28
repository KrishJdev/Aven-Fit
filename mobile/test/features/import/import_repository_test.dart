import 'dart:io';

import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/features/exercise/data/exercise_repository.dart';
import 'package:aven_fit/features/exercise/data/exercise_seed_loader.dart';
import 'package:aven_fit/features/exercise/domain/exercise.dart';
import 'package:aven_fit/features/import/data/import_repository.dart';
import 'package:aven_fit/features/import/domain/csv_parser.dart';
import 'package:aven_fit/features/import/domain/exercise_matcher.dart';
import 'package:aven_fit/features/progress/data/pr_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ImportRepository importRepo;
  late ExerciseRepository exerciseRepo;
  late PRRepository prRepo;
  late List<Exercise> catalog;

  setUpAll(() async {
    final muscleGroupsJson =
        await File('assets/data/muscle_groups.json').readAsString();
    final exercisesJson =
        await File('assets/data/exercises.json').readAsString();
    db = AppDatabase(NativeDatabase.memory());
    await ExerciseSeedLoader.seedFromJsonStrings(
      db.exerciseDao,
      muscleGroupsJson: muscleGroupsJson,
      exercisesJson: exercisesJson,
    );
    exerciseRepo = ExerciseRepositoryImpl(db.exerciseDao);
    prRepo = PRRepositoryImpl(db.prDao);
    importRepo = ImportRepository(
      workoutDao: db.workoutDao,
      exerciseRepo: exerciseRepo,
      prRepo: prRepo,
    );
    catalog = await exerciseRepo.searchExercises();
  });

  tearDown(() async {
    // Don't close the shared db in tearDown — it's created once in setUpAll.
    // Each test cleans up by deleting imported sessions.
  });

  /// Parses a Hevy-style CSV, matches exercises, and imports.
  Future<ImportResult> doImport(String csv) async {
    final parseResult = const CsvParser().parse(csv);
    final summary = parseResult.summary;
    final uniqueNames = summary.workouts
        .expand((w) => w.exercises.map((e) => e.name))
        .toSet();
    final matcher = ExerciseMatcher(catalog);
    final matchResults = matcher.matchAll(uniqueNames);
    return importRepo.importWorkouts(
      summary: summary,
      matchResults: matchResults,
    );
  }

  group('ImportRepository — basic import', () {
    test('imports workouts, session exercises, and sets into SQLite', () async {
      const csv = 'Date,Workout Name,Exercise Name,Set Order,Weight (kg),Reps,Distance (km),Duration (sec),RPE,Notes\n'
          '2021-03-15 10:30:00,Push Day,Barbell Bench Press,1,60,10,,,,\n'
          '2021-03-15 10:30:00,Push Day,Barbell Bench Press,2,80,8,,,8.5,\n'
          '2021-03-15 10:30:00,Push Day,Lat Pulldown,1,40,12,,,,\n'
          '2021-03-16 10:30:00,Leg Day,Barbell Squat,1,100,5,,,7.5,\n';

      final result = await doImport(csv);

      expect(result.workoutsImported, 2);
      expect(result.setsImported, 4);
      expect(result.workoutsSkipped, 0);

      // Verify sessions in SQLite.
      final sessions = await db.select(db.workoutSessions).get();
      final completed = sessions.where((s) => s.status == 'completed').toList();
      expect(completed.length, 2);

      // Verify the push day session.
      final pushDay = completed.firstWhere((s) => s.name == 'Push Day');
      expect(pushDay.startedAt, DateTime(2021, 3, 15, 10, 30));
      expect(pushDay.importSourceId, isNotNull);

      // Verify session exercises.
      final ses = await (db.select(db.sessionExercises)
            ..where((t) => t.sessionId.equals(pushDay.id)))
          .get();
      expect(ses.length, 2);

      // Verify sets — bench press has 2 sets.
      final benchSets = await (db.select(db.workoutSets)
            ..where((t) => t.sessionExerciseId.equals(ses.first.id)))
          .get();
      expect(benchSets.length, 2);
      expect(benchSets[0].weightKg, 60.0);
      expect(benchSets[0].reps, 10);
      expect(benchSets[0].isCompleted, isTrue);
      expect(benchSets[1].weightKg, 80.0);
      expect(benchSets[1].rpe, 8.5);

      // Clean up.
      await db.delete(db.workoutSets).go();
      await db.delete(db.sessionExercises).go();
      await db.delete(db.workoutSessions).go();
    });

    test('recomputes PRs from imported sets (§10.2 parity)', () async {
      const csv = 'Date,Workout Name,Exercise Name,Set Order,Weight (kg),Reps,Distance (km),Duration (sec),RPE,Notes\n'
          '2021-03-15 10:30:00,PR Test,Barbell Bench Press,1,100,5,,,,\n'
          '2021-03-22 10:30:00,PR Test,Barbell Bench Press,1,110,3,,,,\n';

      final result = await doImport(csv);

      expect(result.workoutsImported, 2);
      expect(result.prCount, greaterThan(0));

      // The 110 kg set should hold the maxWeight PR.
      final benchId = catalog.firstWhere((e) => e.name == 'Barbell Bench Press').id;
      final records = await prRepo.getRecordsForExercise(benchId);
      final maxWeight = records.where((r) => r.recordType.name == 'maxWeight').toList();
      expect(maxWeight, isNotEmpty);
      expect(maxWeight.first.value, 110.0);

      // Clean up.
      await db.delete(db.workoutSets).go();
      await db.delete(db.sessionExercises).go();
      await db.delete(db.workoutSessions).go();
      await db.delete(db.personalRecords).go();
    });
  });

  group('ImportRepository — duplicate detection', () {
    test('re-importing the same CSV skips every workout (L7)', () async {
      const csv = 'Date,Workout Name,Exercise Name,Set Order,Weight (kg),Reps,Distance (km),Duration (sec),RPE,Notes\n'
          '2021-03-15 10:30:00,Workout A,Barbell Bench Press,1,60,5,,,,\n'
          '2021-03-16 10:30:00,Workout B,Barbell Squat,1,100,5,,,,\n';

      // First import.
      final result1 = await doImport(csv);
      expect(result1.workoutsImported, 2);
      expect(result1.workoutsSkipped, 0);

      // Second import — same CSV.
      final result2 = await doImport(csv);
      expect(result2.workoutsImported, 0);
      expect(result2.workoutsSkipped, 2);
      expect(result2.wasIdempotentSkip, isTrue);

      // Verify no double-logged sessions.
      final sessions = await db.select(db.workoutSessions).get();
      final imported = sessions.where((s) => s.importSourceId != null).toList();
      expect(imported.length, 2); // still only 2, not 4

      // Clean up.
      await db.delete(db.workoutSets).go();
      await db.delete(db.sessionExercises).go();
      await db.delete(db.workoutSessions).go();
    });
  });

  group('ImportRepository — custom exercise creation', () {
    test('low-confidence match creates a custom exercise (L7: no data loss)',
        () async {
      const csv = 'Date,Workout Name,Exercise Name,Set Order,Weight (kg),Reps,Distance (km),Duration (sec),RPE,Notes\n'
          '2021-03-15 10:30:00,Weird Day,Kettlebell Turkish Get Up,1,16,5,,,,\n';

      final result = await doImport(csv);

      expect(result.workoutsImported, 1);
      expect(result.exercisesCreated, 1);

      // The custom exercise should exist in the catalog.
      final customs = await exerciseRepo.searchExercises(query: 'Kettlebell Turkish Get Up');
      expect(customs, isNotEmpty);
      expect(customs.first.isCustom, isTrue);
      expect(customs.first.name, 'Kettlebell Turkish Get Up');

      // The set should be linked to the custom exercise.
      final sets = await db.select(db.workoutSets).get();
      expect(sets.length, 1);
      expect(sets.first.exerciseId, customs.first.id);

      // Clean up.
      await db.delete(db.workoutSets).go();
      await db.delete(db.sessionExercises).go();
      await db.delete(db.workoutSessions).go();
    });
  });

  group('ImportRepository — warm-up preservation', () {
    test('warm-up sets have setType=warmup in SQLite (§8.1)', () async {
      const csv = 'Date,Workout Name,Exercise Name,Set Order,Weight (kg),Reps,Distance (km),Duration (sec),RPE,Notes\n'
          '2021-03-15 10:30:00,Warmup Test,Barbell Bench Press,1,40,10,,,,warmup\n'
          '2021-03-15 10:30:00,Warmup Test,Barbell Bench Press,2,80,8,,,,\n';

      await doImport(csv);

      final sets = await db.select(db.workoutSets).get();
      expect(sets.length, 2);
      expect(sets[0].setType, 'warmup');
      expect(sets[1].setType, 'normal');

      // Clean up.
      await db.delete(db.workoutSets).go();
      await db.delete(db.sessionExercises).go();
      await db.delete(db.workoutSessions).go();
    });
  });
}
