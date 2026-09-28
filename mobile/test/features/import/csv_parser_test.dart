import 'package:aven_fit/features/exercise/domain/exercise.dart';
import 'package:aven_fit/features/exercise/domain/muscle_group.dart';
import 'package:aven_fit/features/import/domain/csv_parser.dart';
import 'package:aven_fit/features/import/domain/exercise_matcher.dart';
import 'package:aven_fit/features/import/domain/import_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CsvParser', () {
    const parser = CsvParser();

    test('parses a Strong-format CSV with weight unit conversion (lb → kg)', () {
      // Strong exports quote date fields (they contain commas).
      // 13 columns: Date, Workout Name, Exercise Name, Set Order, Weight,
      // Weight Unit, Reps, RPE, Distance, Distance Unit, Duration,
      // Duration Unit, Notes.
      const csv = 'Date,Workout Name,Exercise Name,Set Order,Weight,Weight Unit,Reps,RPE,Distance,Distance Unit,Duration,Duration Unit,Notes\n'
          '"Aug 28, 2017 2:32 PM",Push Day,Bench Press (Barbell),1,135,lb,10,,,,,,warm up\n'
          '"Aug 28, 2017 2:32 PM",Push Day,Bench Press (Barbell),2,185,lb,8,,,,,,\n'
          '"Aug 28, 2017 2:32 PM",Push Day,Bench Press (Barbell),3,205,lb,5,8.5,,,,,\n'
          '"Aug 28, 2017 2:32 PM",Push Day,Triceps Pushdown (Cable),1,40,lb,12,,,,,,\n';

      final result = parser.parse(csv);

      expect(result.summary.source, ImportSource.strong);
      expect(result.summary.workouts, hasLength(1));
      final workout = result.summary.workouts.first;
      expect(workout.name, 'Push Day');
      expect(workout.exercises, hasLength(2));

      // Bench Press: 3 sets (1 warmup + 2 working).
      final bench = workout.exercises[0];
      expect(bench.name, 'Bench Press (Barbell)');
      expect(bench.sets, hasLength(3));
      expect(bench.sets[0].isWarmup, isTrue); // notes = "warm up"
      expect(bench.sets[0].weightKg, closeTo(61.23, 0.1)); // 135 lb → ~61.2 kg
      expect(bench.sets[0].reps, 10);
      expect(bench.sets[1].isWarmup, isFalse);
      expect(bench.sets[1].weightKg, closeTo(83.91, 0.1)); // 185 lb → ~83.9 kg
      expect(bench.sets[2].rpe, 8.5);

      // Triceps: 1 set, 40 lb.
      final triceps = workout.exercises[1];
      expect(triceps.name, 'Triceps Pushdown (Cable)');
      expect(triceps.sets, hasLength(1));
      expect(triceps.sets[0].weightKg, closeTo(18.14, 0.1));
    });

    test('parses a Hevy-format CSV with kg weights', () {
      // 10 columns: Date, Workout Name, Exercise Name, Set Order, Weight (kg),
      // Reps, Distance (km), Duration (sec), RPE, Notes.
      const csv = 'Date,Workout Name,Exercise Name,Set Order,Weight (kg),Reps,Distance (km),Duration (sec),RPE,Notes\n'
          '2021-03-15 10:30:00,Leg Day,Barbell Squat,1,60,10,,,,warmup\n'
          '2021-03-15 10:30:00,Leg Day,Barbell Squat,2,100,8,,,8.5,\n'
          '2021-03-15 10:30:00,Leg Day,Leg Press,1,120,12,,,,\n';

      final result = parser.parse(csv);

      expect(result.summary.source, ImportSource.hevy);
      expect(result.summary.workouts, hasLength(1));
      final workout = result.summary.workouts.first;
      expect(workout.name, 'Leg Day');
      expect(workout.exercises, hasLength(2));

      final squat = workout.exercises[0];
      expect(squat.name, 'Barbell Squat');
      expect(squat.sets, hasLength(2));
      expect(squat.sets[0].isWarmup, isTrue);
      expect(squat.sets[0].weightKg, 60.0);
      expect(squat.sets[1].weightKg, 100.0);
      expect(squat.sets[1].rpe, 8.5);

      final legPress = workout.exercises[1];
      expect(legPress.sets[0].weightKg, 120.0);
      expect(legPress.sets[0].reps, 12);
    });

    test('groups multiple workouts from the same file chronologically', () {
      const csv = 'Date,Workout Name,Exercise Name,Set Order,Weight (kg),Reps,Distance (km),Duration (sec),RPE,Notes\n'
          '2021-03-16 10:00:00,Workout B,Pull Up,1,0,8,,,,\n'
          '2021-03-15 10:00:00,Workout A,Bench Press,1,60,5,,,,\n';

      final result = parser.parse(csv);

      expect(result.summary.workouts, hasLength(2));
      // Sorted oldest-first for chronological PR replay.
      expect(result.summary.workouts[0].name, 'Workout A');
      expect(result.summary.workouts[1].name, 'Workout B');
    });

    test('skips blank rows and continues parsing', () {
      const csv = 'Date,Workout Name,Exercise Name,Set Order,Weight (kg),Reps,Distance (km),Duration (sec),RPE,Notes\n'
          '2021-03-15 10:00:00,W,E,1,50,5,,,,\n'
          ',,,,,,,,,,\n'
          '2021-03-15 10:00:00,W,E,2,55,5,,,,\n';

      final result = parser.parse(csv);

      expect(result.summary.workouts, hasLength(1));
      expect(result.summary.workouts.first.exercises.first.sets, hasLength(2));
    });

    test('throws on empty file', () {
      expect(() => parser.parse(''), throwsA(isA<CsvParseException>()));
    });

    test('throws on unrecognized format', () {
      const csv = 'Foo,Bar,Baz\n1,2,3\n';
      expect(() => parser.parse(csv), throwsA(isA<CsvParseException>()));
    });

    test('reports per-row errors without aborting the file', () {
      // Missing exercise name on row 2 — skipped, but row 3 still parses.
      const csv = 'Date,Workout Name,Exercise Name,Set Order,Weight (kg),Reps,Distance (km),Duration (sec),RPE,Notes\n'
          '2021-03-15 10:00:00,W,,1,50,5,,,,\n'
          '2021-03-15 10:00:00,W,Bench Press,1,60,5,,,,\n';

      final result = parser.parse(csv);

      expect(result.errors, isNotEmpty);
      expect(result.summary.workouts, hasLength(1));
      expect(result.summary.workouts.first.exercises, hasLength(1));
      expect(result.summary.workouts.first.exercises.first.name, 'Bench Press');
    });

    test('summary aggregates counts correctly', () {
      const csv = 'Date,Workout Name,Exercise Name,Set Order,Weight (kg),Reps,Distance (km),Duration (sec),RPE,Notes\n'
          '2021-03-15 10:00:00,W1,E1,1,50,5,,,,\n'
          '2021-03-15 10:00:00,W1,E1,2,55,5,,,,\n'
          '2021-03-15 10:00:00,W1,E2,1,60,5,,,,\n'
          '2021-03-16 10:00:00,W2,E1,1,70,5,,,,\n';

      final result = parser.parse(csv);

      expect(result.summary.workouts, hasLength(2));
      expect(result.summary.totalSets, 4);
      expect(result.summary.totalExercises, 3); // E1 (2 workouts) + E2
    });
  });

  group('ExerciseMatcher', () {
    // A small mock catalog mirroring the real seed-data patterns.
    final catalog = [
      Exercise(id: 'ex-001', name: 'Barbell Bench Press', equipment: Equipment.barbell),
      Exercise(id: 'ex-002', name: 'Incline Barbell Bench Press', equipment: Equipment.barbell),
      Exercise(id: 'ex-003', name: 'Dumbbell Bench Press', equipment: Equipment.dumbbell),
      Exercise(id: 'ex-004', name: 'Barbell Squat', equipment: Equipment.barbell),
      Exercise(id: 'ex-005', name: 'Deadlift', equipment: Equipment.barbell),
      Exercise(id: 'ex-006', name: 'Lat Pulldown', equipment: Equipment.cable),
      Exercise(id: 'ex-007', name: 'Triceps Pushdown', equipment: Equipment.cable),
    ];
    final matcher = ExerciseMatcher(catalog);

    test('exact name match → high confidence', () {
      final r = matcher.match('Barbell Bench Press');
      expect(r.confidence, MatchConfidence.high);
      expect(r.exerciseId, 'ex-001');
      expect(r.matchedName, 'Barbell Bench Press');
    });

    test('equipment suffix in parentheses → high confidence (containment)', () {
      // Strong export: "Bench Press (Barbell)" → catalog "Barbell Bench Press"
      // After stripping parens: "bench press" — this should match via
      // containment or token overlap.
      final r = matcher.match('Bench Press (Barbell)');
      expect(r.confidence, MatchConfidence.high);
      expect(r.exerciseId, 'ex-001');
    });

    test('word-order variation → high or medium confidence', () {
      // "Squat Barbell" vs "Barbell Squat" — token overlap should catch this.
      final r = matcher.match('Squat (Barbell)');
      expect(r.confidence, MatchConfidence.high);
      expect(r.exerciseId, 'ex-004');
    });

    test('partial token overlap → medium confidence', () {
      // "Incline Dumbbell Bench" shares tokens with both incline and dumbbell
      // bench press — should match one of them at medium confidence.
      final r = matcher.match('Incline Dumbbell Bench');
      expect(r.confidence, anyOf(MatchConfidence.high, MatchConfidence.medium));
      expect(r.exerciseId, isNotNull);
    });

    test('no reasonable match → low confidence (custom exercise offer)', () {
      final r = matcher.match('Kettlebell Turkish Get Up');
      expect(r.confidence, MatchConfidence.low);
      expect(r.exerciseId, isNull);
    });

    test('triceps pushdown matches via token overlap', () {
      // "Triceps Pushdown (Cable)" → catalog "Triceps Pushdown"
      final r = matcher.match('Triceps Pushdown (Cable)');
      expect(r.confidence, MatchConfidence.high);
      expect(r.exerciseId, 'ex-007');
    });

    test('matchAll deduplicates by name', () {
      final names = ['Barbell Bench Press', 'Barbell Bench Press', 'Deadlift'];
      final results = matcher.matchAll(names);
      expect(results, hasLength(2));
      expect(results['Barbell Bench Press']!.exerciseId, 'ex-001');
      expect(results['Deadlift']!.exerciseId, 'ex-005');
    });

    test('empty string → low confidence', () {
      final r = matcher.match('');
      expect(r.confidence, MatchConfidence.low);
    });
  });
}
