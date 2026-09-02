import 'package:flutter/foundation.dart';

@immutable
class SyncOperation {
  const SyncOperation({
    required this.entityType,
    required this.entityId,
    required this.operation,
    this.clientTimestamp,
    this.data,
  });

  final String entityType;
  final String entityId;
  final String operation;
  final DateTime? clientTimestamp;
  final Map<String, dynamic>? data;

  Map<String, dynamic> toJson() => {
        'entityType': entityType,
        'entityId': entityId,
        'operation': operation,
        if (clientTimestamp != null)
          'clientTimestamp': clientTimestamp!.toUtc().toIso8601String(),
        if (data != null) 'data': data,
      };

  factory SyncOperation.fromJson(Map<String, dynamic> json) => SyncOperation(
        entityType: json['entityType'] as String,
        entityId: json['entityId'] as String,
        operation: json['operation'] as String,
        clientTimestamp: json['clientTimestamp'] != null
            ? DateTime.parse(json['clientTimestamp'] as String)
            : null,
        data: (json['data'] as Map?)?.cast<String, dynamic>(),
      );
}

@immutable
class SyncPushRequest {
  const SyncPushRequest({required this.operations});

  final List<SyncOperation> operations;

  Map<String, dynamic> toJson() => {
        'operations': operations.map((o) => o.toJson()).toList(),
      };

  factory SyncPushRequest.fromJson(Map<String, dynamic> json) =>
      SyncPushRequest(
        operations: (json['operations'] as List<dynamic>)
            .map((e) => SyncOperation.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

@immutable
class SyncOperationResult {
  const SyncOperationResult({
    required this.clientId,
    this.serverId,
    required this.status,
  });

  final String clientId;
  final String? serverId;
  final String status;

  factory SyncOperationResult.fromJson(Map<String, dynamic> json) =>
      SyncOperationResult(
        clientId: json['clientId'] as String,
        serverId: json['serverId'] as String?,
        status: json['status'] as String,
      );

  Map<String, dynamic> toJson() => {
        'clientId': clientId,
        if (serverId != null) 'serverId': serverId,
        'status': status,
      };
}

@immutable
class SyncPushResponse {
  const SyncPushResponse({
    required this.processed,
    required this.conflicts,
    required this.results,
  });

  final int processed;
  final int conflicts;
  final List<SyncOperationResult> results;

  factory SyncPushResponse.fromJson(Map<String, dynamic> json) =>
      SyncPushResponse(
        processed: json['processed'] as int? ?? 0,
        conflicts: json['conflicts'] as int? ?? 0,
        results: (json['results'] as List<dynamic>? ?? const [])
            .map((e) => SyncOperationResult.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'processed': processed,
        'conflicts': conflicts,
        'results': results.map((r) => r.toJson()).toList(),
      };
}

@immutable
class SyncPullResponse {
  const SyncPullResponse({
    this.exercises = const [],
    this.workouts = const [],
    this.routines = const [],
    this.foodItems = const [],
    required this.serverTimestamp,
  });

  final List<Map<String, dynamic>> exercises;
  final List<Map<String, dynamic>> workouts;
  final List<Map<String, dynamic>> routines;
  final List<Map<String, dynamic>> foodItems;
  final DateTime serverTimestamp;

  factory SyncPullResponse.fromJson(Map<String, dynamic> json) =>
      SyncPullResponse(
        exercises: (json['exercises'] as List<dynamic>? ?? const [])
            .map((e) => (e as Map).cast<String, dynamic>())
            .toList(),
        workouts: (json['workouts'] as List<dynamic>? ?? const [])
            .map((e) => (e as Map).cast<String, dynamic>())
            .toList(),
        routines: (json['routines'] as List<dynamic>? ?? const [])
            .map((e) => (e as Map).cast<String, dynamic>())
            .toList(),
        foodItems: (json['foodItems'] as List<dynamic>? ?? const [])
            .map((e) => (e as Map).cast<String, dynamic>())
            .toList(),
        serverTimestamp: json['serverTimestamp'] != null
            ? DateTime.parse(json['serverTimestamp'] as String)
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'exercises': exercises,
        'workouts': workouts,
        'routines': routines,
        'foodItems': foodItems,
        'serverTimestamp': serverTimestamp.toUtc().toIso8601String(),
      };
}
