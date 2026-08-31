// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_picker_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod controller managing search, filtering, and recent history for the in-session exercise picker.
///
/// Implements Law L1 (<100ms local filtering) and Law L2 (100% offline).

@ProviderFor(ExercisePickerController)
final exercisePickerControllerProvider = ExercisePickerControllerProvider._();

/// Riverpod controller managing search, filtering, and recent history for the in-session exercise picker.
///
/// Implements Law L1 (<100ms local filtering) and Law L2 (100% offline).
final class ExercisePickerControllerProvider
    extends
        $AsyncNotifierProvider<ExercisePickerController, ExercisePickerState> {
  /// Riverpod controller managing search, filtering, and recent history for the in-session exercise picker.
  ///
  /// Implements Law L1 (<100ms local filtering) and Law L2 (100% offline).
  ExercisePickerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exercisePickerControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exercisePickerControllerHash();

  @$internal
  @override
  ExercisePickerController create() => ExercisePickerController();
}

String _$exercisePickerControllerHash() =>
    r'bcff8b9a95630694955d682af01a0ad28b13689f';

/// Riverpod controller managing search, filtering, and recent history for the in-session exercise picker.
///
/// Implements Law L1 (<100ms local filtering) and Law L2 (100% offline).

abstract class _$ExercisePickerController
    extends $AsyncNotifier<ExercisePickerState> {
  FutureOr<ExercisePickerState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<ExercisePickerState>, ExercisePickerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ExercisePickerState>, ExercisePickerState>,
              AsyncValue<ExercisePickerState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
