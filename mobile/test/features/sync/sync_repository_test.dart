import 'dart:convert';
import 'dart:typed_data';

import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/core/network/api_client.dart';
import 'package:aven_fit/features/sync/data/sync_repository.dart';
import 'package:aven_fit/features/sync/domain/sync_models.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _ScriptedAdapter implements HttpClientAdapter {
  final List<ResponseBody> _responses = [];
  final List<RequestOptions> requests = [];

  void respond(ResponseBody response) => _responses.add(response);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (_responses.isEmpty) {
      throw StateError('No scripted response for ${options.uri}');
    }
    return _responses.removeAt(0);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object? body, [int status = 200]) {
  final bytes = utf8.encode(jsonEncode(body));
  return ResponseBody.fromBytes(
    bytes,
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  group('SyncRepository (ISSUE-11)', () {
    late AppDatabase db;
    late ApiClient client;
    late _ScriptedAdapter adapter;
    late SyncRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      adapter = _ScriptedAdapter();
      client = ApiClient(baseUrl: 'http://test.local');
      client.dio.httpClientAdapter = adapter;
      repo = SyncRepositoryImpl(apiClient: client, db: db);
    });

    tearDown(() async {
      await db.close();
    });

    test('push sends SyncPushRequest and parses SyncPushResponse', () async {
      adapter.respond(_json({
        'data': {
          'processed': 2,
          'conflicts': 0,
          'results': [
            {
              'clientId': 'ws_1',
              'serverId': 'ws_1',
              'status': 'CREATED',
            },
            {
              'clientId': 'ws_2',
              'serverId': 'ws_2',
              'status': 'IGNORED_DUPLICATE',
            },
          ],
        },
      }));

      final operations = [
        const SyncOperation(
          entityType: 'workout',
          entityId: 'ws_1',
          operation: 'CREATE',
          data: {'name': 'Push Workout 1'},
        ),
        const SyncOperation(
          entityType: 'workout',
          entityId: 'ws_2',
          operation: 'CREATE',
          data: {'name': 'Push Workout 2'},
        ),
      ];

      final response = await repo.push(operations);

      expect(response.processed, 2);
      expect(response.conflicts, 0);
      expect(response.results, hasLength(2));
      expect(response.results[0].status, 'CREATED');
      expect(response.results[1].status, 'IGNORED_DUPLICATE');

      expect(adapter.requests, hasLength(1));
      expect(adapter.requests[0].path, '/api/sync/push');
    });

    test('pull fetches delta and parses SyncPullResponse', () async {
      final now = DateTime.utc(2026, 9, 3, 2, 0);
      adapter.respond(_json({
        'data': {
          'exercises': [],
          'workouts': [
            {
              'id': 'ws_pulled_1',
              'name': 'Cloud Workout',
              'status': 'COMPLETED',
              'startedAt': now.toIso8601String(),
              'completedAt': now.add(const Duration(hours: 1)).toIso8601String(),
              'durationSeconds': 3600,
              'exercises': [],
            }
          ],
          'routines': [],
          'foodItems': [],
          'serverTimestamp': now.toIso8601String(),
        },
      }));

      final pull = await repo.pull(now.subtract(const Duration(days: 1)));

      expect(pull.workouts, hasLength(1));
      expect(pull.workouts[0]['name'], 'Cloud Workout');
      expect(adapter.requests[0].path, '/api/sync/pull');
      expect(adapter.requests[0].queryParameters['since'], isNotNull);
    });

    test('applyPull persists incoming delta to Drift SQLite tables atomically', () async {
      final now = DateTime.utc(2026, 9, 3, 2, 0);

      final pullData = SyncPullResponse(
        exercises: [
          {
            'id': 'ex_custom_1',
            'name': 'Synced Exercise',
            'category': 'CHEST',
            'equipment': 'BARBELL',
            'isCustom': true,
          }
        ],
        workouts: [
          {
            'id': 'ws_sync_1',
            'name': 'Synced Session',
            'status': 'COMPLETED',
            'startedAt': now.toIso8601String(),
            'completedAt': now.add(const Duration(minutes: 45)).toIso8601String(),
            'durationSeconds': 2700,
            'exercises': [
              {
                'id': 'se_sync_1',
                'exerciseId': 'ex_custom_1',
                'position': 1,
                'restSeconds': 90,
                'sets': [
                  {
                    'id': 'set_sync_1',
                    'position': 1,
                    'setType': 'NORMAL',
                    'weightKg': 80.0,
                    'reps': 8,
                    'isCompleted': true,
                  }
                ],
              }
            ],
          }
        ],
        routines: [
          {
            'id': 'r_sync_1',
            'name': 'Synced Routine',
            'description': 'Full body',
            'exercises': [],
          }
        ],
        foodItems: [
          {
            'id': 'food_sync_1',
            'name': 'Paneer Bhurji',
            'servingSize': 150.0,
            'servingUnit': 'g',
            'calories': 350.0,
            'proteinG': 22.0,
            'carbsG': 6.0,
            'fatG': 26.0,
          }
        ],
        serverTimestamp: now,
      );

      await repo.applyPull(pullData, userId: 'usr_cloud_1');

      // Assert exercises ingested
      final exercise = await (db.select(db.exercises)..where((t) => t.id.equals('ex_custom_1'))).getSingle();
      expect(exercise.name, 'Synced Exercise');

      // Assert workout and sets ingested
      final session = await (db.select(db.workoutSessions)..where((t) => t.id.equals('ws_sync_1'))).getSingle();
      expect(session.name, 'Synced Session');
      expect(session.status, 'completed');
      expect(session.userId, 'usr_cloud_1');

      final sets = await (db.select(db.workoutSets)..where((t) => t.id.equals('set_sync_1'))).getSingle();
      expect(sets.weightKg, 80.0);
      expect(sets.reps, 8);
      expect(sets.setType, 'normal');

      // Assert routines ingested
      final routine = await (db.select(db.routines)..where((t) => t.id.equals('r_sync_1'))).getSingle();
      expect(routine.name, 'Synced Routine');

      // Assert food items ingested
      final food = await (db.select(db.foodItems)..where((t) => t.id.equals('food_sync_1'))).getSingle();
      expect(food.name, 'Paneer Bhurji');
      expect(food.proteinG, 22.0);
    });
  });
}
