// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_summary_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod controller computing post-workout summary stats (FEATURES.md §8.5).
///
/// Loads the fully persisted session from SQLite — zero network, zero live
/// re-fetch (L2/L7). Rendered immediately after Finish.

@ProviderFor(WorkoutSummaryController)
final workoutSummaryControllerProvider = WorkoutSummaryControllerFamily._();

/// Riverpod controller computing post-workout summary stats (FEATURES.md §8.5).
///
/// Loads the fully persisted session from SQLite — zero network, zero live
/// re-fetch (L2/L7). Rendered immediately after Finish.
final class WorkoutSummaryControllerProvider
    extends
        $AsyncNotifierProvider<WorkoutSummaryController, WorkoutSummaryState> {
  /// Riverpod controller computing post-workout summary stats (FEATURES.md §8.5).
  ///
  /// Loads the fully persisted session from SQLite — zero network, zero live
  /// re-fetch (L2/L7). Rendered immediately after Finish.
  WorkoutSummaryControllerProvider._({
    required WorkoutSummaryControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'workoutSummaryControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$workoutSummaryControllerHash();

  @override
  String toString() {
    return r'workoutSummaryControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  WorkoutSummaryController create() => WorkoutSummaryController();

  @override
  bool operator ==(Object other) {
    return other is WorkoutSummaryControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$workoutSummaryControllerHash() =>
    r'a03a80ff1c9b68e65d3928dc376e3cf155c87fb1';

/// Riverpod controller computing post-workout summary stats (FEATURES.md §8.5).
///
/// Loads the fully persisted session from SQLite — zero network, zero live
/// re-fetch (L2/L7). Rendered immediately after Finish.

final class WorkoutSummaryControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          WorkoutSummaryController,
          AsyncValue<WorkoutSummaryState>,
          WorkoutSummaryState,
          FutureOr<WorkoutSummaryState>,
          String
        > {
  WorkoutSummaryControllerFamily._()
    : super(
        retry: null,
        name: r'workoutSummaryControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Riverpod controller computing post-workout summary stats (FEATURES.md §8.5).
  ///
  /// Loads the fully persisted session from SQLite — zero network, zero live
  /// re-fetch (L2/L7). Rendered immediately after Finish.

  WorkoutSummaryControllerProvider call(String sessionId) =>
      WorkoutSummaryControllerProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'workoutSummaryControllerProvider';
}

/// Riverpod controller computing post-workout summary stats (FEATURES.md §8.5).
///
/// Loads the fully persisted session from SQLite — zero network, zero live
/// re-fetch (L2/L7). Rendered immediately after Finish.

abstract class _$WorkoutSummaryController
    extends $AsyncNotifier<WorkoutSummaryState> {
  late final _$args = ref.$arg as String;
  String get sessionId => _$args;

  FutureOr<WorkoutSummaryState> build(String sessionId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<WorkoutSummaryState>, WorkoutSummaryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<WorkoutSummaryState>, WorkoutSummaryState>,
              AsyncValue<WorkoutSummaryState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
