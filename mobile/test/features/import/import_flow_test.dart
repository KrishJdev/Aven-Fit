import 'dart:io';

import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/features/exercise/data/exercise_local_source.dart';
import 'package:aven_fit/features/exercise/data/exercise_repository.dart';
import 'package:aven_fit/features/exercise/data/exercise_seed_loader.dart';
import 'package:aven_fit/features/import/data/file_picker_service.dart';
import 'package:aven_fit/features/import/data/import_repository.dart';
import 'package:aven_fit/features/import/domain/import_models.dart';
import 'package:aven_fit/features/import/presentation/import_controller.dart';
import 'package:aven_fit/features/import/presentation/import_screen.dart';
import 'package:aven_fit/features/import/presentation/import_state.dart';
import 'package:aven_fit/features/progress/data/pr_local_source.dart';
import 'package:aven_fit/features/progress/data/pr_repository.dart';
import 'package:aven_fit/features/workout/data/workout_local_source.dart';
import 'package:aven_fit/l10n/app_localizations.dart';
import 'package:aven_fit/main.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _strongSampleCsv =
    'Date,Workout Name,Exercise Name,Set Order,Weight,Weight Unit,Reps,RPE,Distance,Distance Unit,Duration,Duration Unit,Notes\n'
    '"Aug 28, 2023 2:32 PM",Push Day,Bench Press (Barbell),1,135,lb,10,,,,,,warm up\n'
    '"Aug 28, 2023 2:32 PM",Push Day,Bench Press (Barbell),2,185,lb,8,,,,,,\n'
    '"Aug 28, 2023 2:32 PM",Push Day,Bench Press (Barbell),3,205,lb,5,8.5,,,,,\n'
    '"Aug 28, 2023 2:32 PM",Push Day,Triceps Pushdown (Cable),1,40,lb,12,,,,,,\n';

const _hevySampleCsv =
    'Date,Workout Name,Exercise Name,Set Order,Weight (kg),Reps,Distance (km),Duration (sec),RPE,Notes\n'
    '2024-01-15 10:30:00,Leg Day,Barbell Squat,1,60,10,,,,warmup\n'
    '2024-01-15 10:30:00,Leg Day,Barbell Squat,2,100,8,,,8.5,\n'
    '2024-01-15 10:30:00,Leg Day,Kettlebell Turkish Get Up,1,16,5,,,,\n';

class FakeFilePickerService implements FilePickerService {
  FakeFilePickerService({this.content, this.name = 'sample.csv'});

  String? content;
  String name;

  @override
  Future<({String content, String name})?> pickCsvFile() async {
    if (content == null) return null;
    return (content: content!, name: name);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ExerciseDao exerciseDao;
  late ExerciseRepository exerciseRepo;
  late PrDao prDao;
  late PRRepository prRepo;
  late WorkoutDao workoutDao;
  late ImportRepository importRepo;
  late FakeFilePickerService fakePicker;

  setUp(() async {
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
    exerciseDao = db.exerciseDao;
    exerciseRepo = ExerciseRepositoryImpl(exerciseDao);
    prDao = db.prDao;
    prRepo = PRRepositoryImpl(prDao);
    workoutDao = db.workoutDao;
    importRepo = ImportRepository(
      workoutDao: workoutDao,
      exerciseRepo: exerciseRepo,
      prRepo: prRepo,
    );
    fakePicker = FakeFilePickerService(content: _strongSampleCsv);
  });

  tearDown(() async {
    await db.close();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        exerciseRepositoryProvider.overrideWithValue(exerciseRepo),
        prRepositoryProvider.overrideWithValue(prRepo),
        importRepositoryProvider.overrideWithValue(importRepo),
        filePickerServiceProvider.overrideWithValue(fakePicker),
      ],
    );
  }

  group('ImportController Unit Tests', () {
    test('initial state is idle', () {
      final container = createContainer();
      addTearDown(container.dispose);

      final state = container.read(importControllerProvider);
      expect(state.status, ImportStatus.idle);
      expect(state.summary, isNull);
      expect(state.result, isNull);
    });

    test('cancelled file picker leaves state idle', () async {
      fakePicker.content = null;
      final container = createContainer();
      addTearDown(container.dispose);

      final controller = container.read(importControllerProvider.notifier);
      await controller.pickAndParseFile();

      final state = container.read(importControllerProvider);
      expect(state.status, ImportStatus.idle);
    });

    test('parses Strong CSV into preview state with matches', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final controller = container.read(importControllerProvider.notifier);
      await controller.pickAndParseFile();

      final state = container.read(importControllerProvider);
      expect(state.status, ImportStatus.preview);
      expect(state.summary, isNotNull);
      expect(state.summary!.source, ImportSource.strong);
      expect(state.summary!.workouts, hasLength(1));
      expect(state.summary!.totalSets, 4);

      // Matches: Bench Press and Triceps Pushdown should match catalog
      expect(state.matchResults['Bench Press (Barbell)'], isNotNull);
      expect(state.matchResults['Bench Press (Barbell)']!.confidence,
          MatchConfidence.high);
      expect(state.matchResults['Bench Press (Barbell)']!.matchedName,
          'Barbell Bench Press');
      expect(state.matchResults['Bench Press (Barbell)']!.exerciseId, isNotNull);

      expect(state.matchResults['Triceps Pushdown (Cable)'], isNotNull);
      expect(state.matchResults['Triceps Pushdown (Cable)']!.confidence,
          MatchConfidence.high);
      expect(state.matchResults['Triceps Pushdown (Cable)']!.matchedName,
          'Tricep Pushdown (Cable)');
      expect(state.matchResults['Triceps Pushdown (Cable)']!.exerciseId, isNotNull);
    });

    test('parses Hevy CSV and identifies custom/missing exercises', () async {
      fakePicker.content = _hevySampleCsv;
      fakePicker.name = 'hevy_export.csv';
      final container = createContainer();
      addTearDown(container.dispose);

      final controller = container.read(importControllerProvider.notifier);
      await controller.pickAndParseFile();

      final state = container.read(importControllerProvider);
      expect(state.status, ImportStatus.preview);
      expect(state.summary!.source, ImportSource.hevy);
      expect(state.summary!.totalSets, 3);

      // "Kettlebell Turkish Get Up" is not in catalog → should be low confidence (custom)
      expect(state.matchResults['Kettlebell Turkish Get Up'], isNotNull);
      expect(state.matchResults['Kettlebell Turkish Get Up']!.confidence,
          MatchConfidence.low);
      expect(state.lowConfidenceMatches, hasLength(1));
    });

    test('updateExerciseMatch modifies match mapping', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final controller = container.read(importControllerProvider.notifier);
      await controller.pickAndParseFile();

      const newMatch = ExerciseMatchResult(
        originalName: 'Bench Press (Barbell)',
        confidence: MatchConfidence.medium,
        exerciseId: 'ex-squat',
        matchedName: 'Barbell Back Squat',
      );

      controller.updateExerciseMatch('Bench Press (Barbell)', newMatch);

      final state = container.read(importControllerProvider);
      expect(
        state.matchResults['Bench Press (Barbell)']!.matchedName,
        'Barbell Back Squat',
      );
    });

    test('startImport imports workouts and recomputes PRs', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final controller = container.read(importControllerProvider.notifier);
      await controller.pickAndParseFile();
      await controller.startImport();

      final state = container.read(importControllerProvider);
      expect(state.status, ImportStatus.success);
      expect(state.result, isNotNull);
      expect(state.result!.workoutsImported, 1);
      expect(state.result!.setsImported, 4);
      expect(state.result!.prCount, greaterThan(0));

      // Second import should be detected as duplicate
      await controller.pickAndParseFile();
      await controller.startImport();
      final state2 = container.read(importControllerProvider);
      expect(state2.result!.wasIdempotentSkip, isTrue);
      expect(state2.result!.workoutsSkipped, 1);
      expect(state2.result!.workoutsImported, 0);
    });

    test('parse error handles malformed CSV', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final controller = container.read(importControllerProvider.notifier);
      await controller.parseCsvContent('Invalid,Unknown,Headers\n1,2,3');

      final state = container.read(importControllerProvider);
      expect(state.status, ImportStatus.error);
      expect(state.errorMessage, contains('Unrecognized CSV format'));

      controller.reset();
      expect(container.read(importControllerProvider).status, ImportStatus.idle);
    });
  });

  group('ImportScreen Widget Tests', () {
    testWidgets('renders idle state with file picker button', (tester) async {
      final container = createContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ImportScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('IMPORT WORKOUTS'), findsOneWidget);
      expect(find.text('MIGRATE YOUR WORKOUTS'), findsOneWidget);
      expect(find.byKey(const ValueKey('import_select_file_button')),
          findsOneWidget);
      expect(find.text('SELECT CSV FILE'), findsOneWidget);
    });

    testWidgets('file picking transitions to preview and allows cancel',
        (tester) async {
      final container = createContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ImportScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap select file
      await tester.tap(find.byKey(const ValueKey('import_select_file_button')));
      await tester.pumpAndSettle();

      // Should be in preview
      expect(find.text('WORKOUT SUMMARY'), findsOneWidget);
      expect(find.text('STRONG'), findsOneWidget);
      expect(find.text('1'), findsWidgets); // 1 workout
      expect(find.text('4'), findsWidgets); // 4 sets
      expect(find.text('EXERCISE MATCHING'), findsOneWidget);
      expect(find.byKey(const ValueKey('import_commit_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('import_cancel_button')), findsOneWidget);

      // Tap cancel → back to idle
      await tester.tap(find.byKey(const ValueKey('import_cancel_button')));
      await tester.pumpAndSettle();

      expect(find.text('MIGRATE YOUR WORKOUTS'), findsOneWidget);
      expect(find.byKey(const ValueKey('import_select_file_button')),
          findsOneWidget);
    });

    testWidgets('preview commit executes import and shows success state',
        (tester) async {
      final container = createContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ImportScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Pick file
      await tester.tap(find.byKey(const ValueKey('import_select_file_button')));
      await tester.pumpAndSettle();

      // Tap import
      await tester.tap(find.byKey(const ValueKey('import_commit_button')));
      await tester.pumpAndSettle();

      // Verify success screen
      expect(find.text('IMPORT COMPLETE'), findsOneWidget);
      expect(find.textContaining('Imported 1 workouts · 4 sets'), findsOneWidget);
      expect(find.byKey(const ValueKey('import_view_progress_button')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('import_done_button')), findsOneWidget);
    });

    testWidgets('error state shows error message and retry button',
        (tester) async {
      fakePicker.content = 'Bad,Headers\n1,2';
      final container = createContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ImportScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap select file
      await tester.tap(find.byKey(const ValueKey('import_select_file_button')));
      await tester.pumpAndSettle();

      // Expect error view
      expect(find.text('IMPORT FAILED'), findsOneWidget);
      expect(find.byKey(const ValueKey('import_retry_button')), findsOneWidget);

      // Tap retry
      await tester.tap(find.byKey(const ValueKey('import_retry_button')));
      await tester.pumpAndSettle();

      expect(find.text('MIGRATE YOUR WORKOUTS'), findsOneWidget);
    });
  });
}
