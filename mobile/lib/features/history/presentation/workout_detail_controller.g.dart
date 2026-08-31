// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AutoDispose family controller for the read-only past-workout detail view
/// (WU-3.9, FEATURES.md §8.7). A null session drives the designed
/// workout-not-found state (L6); every action is a write-through (L7).

@ProviderFor(WorkoutDetailController)
final workoutDetailControllerProvider = WorkoutDetailControllerFamily._();

/// AutoDispose family controller for the read-only past-workout detail view
/// (WU-3.9, FEATURES.md §8.7). A null session drives the designed
/// workout-not-found state (L6); every action is a write-through (L7).
final class WorkoutDetailControllerProvider
    extends $AsyncNotifierProvider<WorkoutDetailController, WorkoutSession?> {
  /// AutoDispose family controller for the read-only past-workout detail view
  /// (WU-3.9, FEATURES.md §8.7). A null session drives the designed
  /// workout-not-found state (L6); every action is a write-through (L7).
  WorkoutDetailControllerProvider._({
    required WorkoutDetailControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'workoutDetailControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workoutDetailControllerHash();

  @override
  String toString() {
    return r'workoutDetailControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  WorkoutDetailController create() => WorkoutDetailController();

  @override
  bool operator ==(Object other) {
    return other is WorkoutDetailControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workoutDetailControllerHash() =>
    r'05dfad388a9820b72ae8135a3dcc9b55b253b125';

/// AutoDispose family controller for the read-only past-workout detail view
/// (WU-3.9, FEATURES.md §8.7). A null session drives the designed
/// workout-not-found state (L6); every action is a write-through (L7).

final class WorkoutDetailControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          WorkoutDetailController,
          AsyncValue<WorkoutSession?>,
          WorkoutSession?,
          FutureOr<WorkoutSession?>,
          String
        > {
  WorkoutDetailControllerFamily._()
    : super(
        retry: null,
        name: r'workoutDetailControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// AutoDispose family controller for the read-only past-workout detail view
  /// (WU-3.9, FEATURES.md §8.7). A null session drives the designed
  /// workout-not-found state (L6); every action is a write-through (L7).

  WorkoutDetailControllerProvider call(String sessionId) =>
      WorkoutDetailControllerProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'workoutDetailControllerProvider';
}

/// AutoDispose family controller for the read-only past-workout detail view
/// (WU-3.9, FEATURES.md §8.7). A null session drives the designed
/// workout-not-found state (L6); every action is a write-through (L7).

abstract class _$WorkoutDetailController
    extends $AsyncNotifier<WorkoutSession?> {
  late final _$args = ref.$arg as String;
  String get sessionId => _$args;

  FutureOr<WorkoutSession?> build(String sessionId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<WorkoutSession?>, WorkoutSession?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<WorkoutSession?>, WorkoutSession?>,
              AsyncValue<WorkoutSession?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
