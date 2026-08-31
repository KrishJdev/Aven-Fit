// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_custom_exercise_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod AsyncNotifier managing custom exercise creation and validation.
///
/// Implements Law L2 (offline creation) and Law L6 (inline unique name validation).

@ProviderFor(CreateCustomExerciseController)
final createCustomExerciseControllerProvider =
    CreateCustomExerciseControllerProvider._();

/// Riverpod AsyncNotifier managing custom exercise creation and validation.
///
/// Implements Law L2 (offline creation) and Law L6 (inline unique name validation).
final class CreateCustomExerciseControllerProvider
    extends
        $AsyncNotifierProvider<
          CreateCustomExerciseController,
          List<MuscleGroup>
        > {
  /// Riverpod AsyncNotifier managing custom exercise creation and validation.
  ///
  /// Implements Law L2 (offline creation) and Law L6 (inline unique name validation).
  CreateCustomExerciseControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createCustomExerciseControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createCustomExerciseControllerHash();

  @$internal
  @override
  CreateCustomExerciseController create() => CreateCustomExerciseController();
}

String _$createCustomExerciseControllerHash() =>
    r'e8d8ad32046e99fd4506b8b3edc2aba57d0abc18';

/// Riverpod AsyncNotifier managing custom exercise creation and validation.
///
/// Implements Law L2 (offline creation) and Law L6 (inline unique name validation).

abstract class _$CreateCustomExerciseController
    extends $AsyncNotifier<List<MuscleGroup>> {
  FutureOr<List<MuscleGroup>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<MuscleGroup>>, List<MuscleGroup>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<MuscleGroup>>, List<MuscleGroup>>,
              AsyncValue<List<MuscleGroup>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
