import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/network/api_client.dart';
import '../../../main.dart';
import '../domain/sync_models.dart';
import 'sync_dto_mapper.dart';

abstract interface class SyncRepository {
  /// Pushes a batch of mutations to the Spring Boot cloud sync hub (Law L2, L7).
  Future<SyncPushResponse> push(List<SyncOperation> operations);

  /// Pulls all updates since [since] from the cloud hub.
  Future<SyncPullResponse> pull(DateTime since);

  /// Ingests a pulled delta directly into local SQLite via an atomic transaction (L7).
  Future<void> applyPull(SyncPullResponse pull, {String? userId});
}

class SyncRepositoryImpl implements SyncRepository {
  SyncRepositoryImpl({
    required ApiClient apiClient,
    required this.db,
  })  : _dio = apiClient.dio;

  final Dio _dio;
  final AppDatabase db;

  @override
  Future<SyncPushResponse> push(List<SyncOperation> operations) async {
    if (operations.isEmpty) {
      return const SyncPushResponse(processed: 0, conflicts: 0, results: []);
    }

    final request = SyncPushRequest(operations: operations);
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/sync/push',
      data: request.toJson(),
    );

    final data = (response.data?['data'] as Map?)?.cast<String, dynamic>() ??
        response.data ??
        {};
    return SyncPushResponse.fromJson(data);
  }

  @override
  Future<SyncPullResponse> pull(DateTime since) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/sync/pull',
      queryParameters: {
        'since': since.toUtc().toIso8601String(),
      },
    );

    final data = (response.data?['data'] as Map?)?.cast<String, dynamic>() ??
        response.data ??
        {};
    return SyncPullResponse.fromJson(data);
  }

  @override
  Future<void> applyPull(SyncPullResponse pull, {String? userId}) async {
    await db.transaction(() async {
      // 1. Ingest Exercises
      for (final exJson in pull.exercises) {
        final companion = SyncDtoMapper.exerciseDtoToCompanion(exJson);
        await db.into(db.exercises).insertOnConflictUpdate(companion);
      }

      // 2. Ingest Workouts (parent -> exercises -> sets)
      for (final wJson in pull.workouts) {
        final sessionComp =
            SyncDtoMapper.workoutDtoToSessionCompanion(wJson, userId: userId);
        await db.into(db.workoutSessions).insertOnConflictUpdate(sessionComp);

        final exList = wJson['exercises'] as List<dynamic>? ?? const [];
        for (final exItem in exList) {
          final seJson = exItem as Map<String, dynamic>;
          final seComp = SyncDtoMapper.workoutExerciseDtoToCompanion(
              sessionComp.id.value, seJson);
          await db.into(db.sessionExercises).insertOnConflictUpdate(seComp);

          final setList = seJson['sets'] as List<dynamic>? ?? const [];
          for (final setItem in setList) {
            final setJson = setItem as Map<String, dynamic>;
            final setComp = SyncDtoMapper.workoutSetDtoToCompanion(
              seComp.id.value,
              sessionComp.id.value,
              seComp.exerciseId.value,
              setJson,
            );
            await db.into(db.workoutSets).insertOnConflictUpdate(setComp);
          }
        }
      }

      // 3. Ingest Routines (routine -> exercises -> sets)
      for (final rJson in pull.routines) {
        final tuple =
            SyncDtoMapper.routineDtoToCompanions(rJson, userId: userId);
        await db.into(db.routines).insertOnConflictUpdate(tuple.routine);

        for (final reComp in tuple.exercises) {
          await db.into(db.routineExercises).insertOnConflictUpdate(reComp);
        }
        for (final rsComp in tuple.sets) {
          await db.into(db.routineSets).insertOnConflictUpdate(rsComp);
        }
      }

      // 4. Ingest Food Items
      for (final foodJson in pull.foodItems) {
        final foodComp = SyncDtoMapper.foodItemDtoToCompanion(foodJson);
        await db.into(db.foodItems).insertOnConflictUpdate(foodComp);
      }
    });
  }
}

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return SyncRepositoryImpl(
    apiClient: ref.watch(apiClientProvider),
    db: ref.watch(appDatabaseProvider),
  );
});
