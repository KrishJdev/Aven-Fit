// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod AsyncNotifier managing the state and search filters of the Exercise Directory.
///
/// Implements Law L1 (<300ms search latency) and Law L2 (100% offline querying).

@ProviderFor(ExerciseListController)
final exerciseListControllerProvider = ExerciseListControllerProvider._();

/// Riverpod AsyncNotifier managing the state and search filters of the Exercise Directory.
///
/// Implements Law L1 (<300ms search latency) and Law L2 (100% offline querying).
final class ExerciseListControllerProvider
    extends $AsyncNotifierProvider<ExerciseListController, ExerciseListState> {
  /// Riverpod AsyncNotifier managing the state and search filters of the Exercise Directory.
  ///
  /// Implements Law L1 (<300ms search latency) and Law L2 (100% offline querying).
  ExerciseListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exerciseListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exerciseListControllerHash();

  @$internal
  @override
  ExerciseListController create() => ExerciseListController();
}

String _$exerciseListControllerHash() =>
    r'ceaec864ac23dfa1ab957a0df0f6fb335c126117';

/// Riverpod AsyncNotifier managing the state and search filters of the Exercise Directory.
///
/// Implements Law L1 (<300ms search latency) and Law L2 (100% offline querying).

abstract class _$ExerciseListController
    extends $AsyncNotifier<ExerciseListState> {
  FutureOr<ExerciseListState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<ExerciseListState>, ExerciseListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ExerciseListState>, ExerciseListState>,
              AsyncValue<ExerciseListState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
