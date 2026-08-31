// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod AsyncNotifier managing the state and actions of a single exercise detail view.

@ProviderFor(ExerciseDetailController)
final exerciseDetailControllerProvider = ExerciseDetailControllerFamily._();

/// Riverpod AsyncNotifier managing the state and actions of a single exercise detail view.
final class ExerciseDetailControllerProvider
    extends $AsyncNotifierProvider<ExerciseDetailController, Exercise?> {
  /// Riverpod AsyncNotifier managing the state and actions of a single exercise detail view.
  ExerciseDetailControllerProvider._({
    required ExerciseDetailControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'exerciseDetailControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$exerciseDetailControllerHash();

  @override
  String toString() {
    return r'exerciseDetailControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ExerciseDetailController create() => ExerciseDetailController();

  @override
  bool operator ==(Object other) {
    return other is ExerciseDetailControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$exerciseDetailControllerHash() =>
    r'ea19b3e6ad3d7fa4dd22f0787b2f7ea7f7bb9fd8';

/// Riverpod AsyncNotifier managing the state and actions of a single exercise detail view.

final class ExerciseDetailControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ExerciseDetailController,
          AsyncValue<Exercise?>,
          Exercise?,
          FutureOr<Exercise?>,
          String
        > {
  ExerciseDetailControllerFamily._()
    : super(
        retry: null,
        name: r'exerciseDetailControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Riverpod AsyncNotifier managing the state and actions of a single exercise detail view.

  ExerciseDetailControllerProvider call(String exerciseId) =>
      ExerciseDetailControllerProvider._(argument: exerciseId, from: this);

  @override
  String toString() => r'exerciseDetailControllerProvider';
}

/// Riverpod AsyncNotifier managing the state and actions of a single exercise detail view.

abstract class _$ExerciseDetailController extends $AsyncNotifier<Exercise?> {
  late final _$args = ref.$arg as String;
  String get exerciseId => _$args;

  FutureOr<Exercise?> build(String exerciseId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Exercise?>, Exercise?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Exercise?>, Exercise?>,
              AsyncValue<Exercise?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
