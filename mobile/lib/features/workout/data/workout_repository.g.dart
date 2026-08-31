// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider exposing [WorkoutRepository] to feature controllers.

@ProviderFor(workoutRepository)
final workoutRepositoryProvider = WorkoutRepositoryProvider._();

/// Riverpod provider exposing [WorkoutRepository] to feature controllers.

final class WorkoutRepositoryProvider
    extends
        $FunctionalProvider<
          WorkoutRepository,
          WorkoutRepository,
          WorkoutRepository
        >
    with $Provider<WorkoutRepository> {
  /// Riverpod provider exposing [WorkoutRepository] to feature controllers.
  WorkoutRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutRepositoryHash();

  @$internal
  @override
  $ProviderElement<WorkoutRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WorkoutRepository create(Ref ref) {
    return workoutRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkoutRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkoutRepository>(value),
    );
  }
}

String _$workoutRepositoryHash() => r'483f2825d98578ac840dc2cb8393b4195de5f82b';

/// Reactive stream of the active workout session (or null), fully joined with
/// its exercises and sets. Drives the Home resume banner (§7.1) and the
/// one-session rule checks (§8.1) — renders from local SQLite in <2s (L2/L7).

@ProviderFor(watchActiveSession)
final watchActiveSessionProvider = WatchActiveSessionProvider._();

/// Reactive stream of the active workout session (or null), fully joined with
/// its exercises and sets. Drives the Home resume banner (§7.1) and the
/// one-session rule checks (§8.1) — renders from local SQLite in <2s (L2/L7).

final class WatchActiveSessionProvider
    extends
        $FunctionalProvider<
          AsyncValue<WorkoutSession?>,
          WorkoutSession?,
          Stream<WorkoutSession?>
        >
    with $FutureModifier<WorkoutSession?>, $StreamProvider<WorkoutSession?> {
  /// Reactive stream of the active workout session (or null), fully joined with
  /// its exercises and sets. Drives the Home resume banner (§7.1) and the
  /// one-session rule checks (§8.1) — renders from local SQLite in <2s (L2/L7).
  WatchActiveSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchActiveSessionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchActiveSessionHash();

  @$internal
  @override
  $StreamProviderElement<WorkoutSession?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<WorkoutSession?> create(Ref ref) {
    return watchActiveSession(ref);
  }
}

String _$watchActiveSessionHash() =>
    r'73bea13204aa4d9d0c10cac1eb030250143680b2';
