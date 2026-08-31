import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';

import '../../../core/database/app_database.dart';
import 'exercise_local_source.dart';

/// Service for loading bundled exercise and muscle group seed data into SQLite.
///
/// Implements Law L2 (zero-network first-run experience).
class ExerciseSeedLoader {
  static const String muscleGroupsAssetPath = 'assets/data/muscle_groups.json';
  static const String exercisesAssetPath = 'assets/data/exercises.json';

  /// Loads bundled seed assets and populates the SQLite database on first run.
  static Future<int> seedInitialData(
    ExerciseDao dao, {
    AssetBundle? bundle,
    bool force = false,
  }) async {
    final existingCount = await dao.countExercises();
    if (existingCount > 0 && !force) {
      return existingCount;
    }

    final activeBundle = bundle ?? rootBundle;
    final mgJson = await activeBundle.loadString(muscleGroupsAssetPath);
    final exJson = await activeBundle.loadString(exercisesAssetPath);

    return seedFromJsonStrings(
      dao,
      muscleGroupsJson: mgJson,
      exercisesJson: exJson,
      force: force,
    );
  }

  /// Seeds database directly from JSON strings.
  static Future<int> seedFromJsonStrings(
    ExerciseDao dao, {
    required String muscleGroupsJson,
    required String exercisesJson,
    bool force = false,
  }) async {
    final existingCount = await dao.countExercises();
    if (existingCount > 0 && !force) {
      return existingCount;
    }

    // 1. Parse and insert MuscleGroups
    final List<dynamic> mgList = jsonDecode(muscleGroupsJson) as List<dynamic>;
    final mgCompanions = mgList.map((item) {
      final map = item as Map<String, dynamic>;
      return MuscleGroupsCompanion(
        id: Value(map['id'] as String),
        name: Value(map['name'] as String),
        displayOrder: Value(map['displayOrder'] as int? ?? 0),
      );
    }).toList();

    await dao.batchInsertMuscleGroups(mgCompanions);

    // 2. Parse and insert Exercises + ExerciseMuscleGroups
    final List<dynamic> exList = jsonDecode(exercisesJson) as List<dynamic>;
    final List<ExercisesCompanion> exCompanions = [];
    final List<ExerciseMuscleGroupsCompanion> linkCompanions = [];

    for (final item in exList) {
      final map = item as Map<String, dynamic>;
      final exId = map['id'] as String;

      exCompanions.add(
        ExercisesCompanion(
          id: Value(exId),
          name: Value(map['name'] as String),
          description: Value(map['description'] as String?),
          category: Value(map['category'] as String? ?? 'OTHER'),
          equipment: Value(map['equipment'] as String? ?? 'NONE'),
          isCustom: Value(map['isCustom'] as bool? ?? false),
          isFavourite: Value(map['isFavourite'] as bool? ?? false),
          isTimeBased: Value(map['isTimeBased'] as bool? ?? false),
          isCardio: Value(map['isCardio'] as bool? ?? false),
        ),
      );

      final mgLinks = map['muscleGroups'] as List<dynamic>? ?? [];
      for (final link in mgLinks) {
        final linkMap = link as Map<String, dynamic>;
        final mgId = linkMap['muscleGroupId'] as String;
        final role = linkMap['role'] as String? ?? 'PRIMARY';
        final linkId = '${exId}_$mgId';

        linkCompanions.add(
          ExerciseMuscleGroupsCompanion(
            id: Value(linkId),
            exerciseId: Value(exId),
            muscleGroupId: Value(mgId),
            role: Value(role),
          ),
        );
      }
    }

    await dao.batchInsertExercises(
      exerciseRows: exCompanions,
      linkRows: linkCompanions,
    );

    return exCompanions.length;
  }
}
