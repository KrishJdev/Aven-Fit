// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_editor_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod controller managing the routine creation / editing workflow.
///
/// Implements Law L2 (offline persistence), Law L6 (inline validation),
/// and Law L7 (write-through saves and crash-safe editing).

@ProviderFor(RoutineEditorController)
final routineEditorControllerProvider = RoutineEditorControllerFamily._();

/// Riverpod controller managing the routine creation / editing workflow.
///
/// Implements Law L2 (offline persistence), Law L6 (inline validation),
/// and Law L7 (write-through saves and crash-safe editing).
final class RoutineEditorControllerProvider
    extends
        $AsyncNotifierProvider<RoutineEditorController, RoutineEditorState> {
  /// Riverpod controller managing the routine creation / editing workflow.
  ///
  /// Implements Law L2 (offline persistence), Law L6 (inline validation),
  /// and Law L7 (write-through saves and crash-safe editing).
  RoutineEditorControllerProvider._({
    required RoutineEditorControllerFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'routineEditorControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$routineEditorControllerHash();

  @override
  String toString() {
    return r'routineEditorControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RoutineEditorController create() => RoutineEditorController();

  @override
  bool operator ==(Object other) {
    return other is RoutineEditorControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$routineEditorControllerHash() =>
    r'0b4f0b0c530769280dd8e8a18a79a0676de407f7';

/// Riverpod controller managing the routine creation / editing workflow.
///
/// Implements Law L2 (offline persistence), Law L6 (inline validation),
/// and Law L7 (write-through saves and crash-safe editing).

final class RoutineEditorControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          RoutineEditorController,
          AsyncValue<RoutineEditorState>,
          RoutineEditorState,
          FutureOr<RoutineEditorState>,
          String?
        > {
  RoutineEditorControllerFamily._()
    : super(
        retry: null,
        name: r'routineEditorControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Riverpod controller managing the routine creation / editing workflow.
  ///
  /// Implements Law L2 (offline persistence), Law L6 (inline validation),
  /// and Law L7 (write-through saves and crash-safe editing).

  RoutineEditorControllerProvider call(String? routineId) =>
      RoutineEditorControllerProvider._(argument: routineId, from: this);

  @override
  String toString() => r'routineEditorControllerProvider';
}

/// Riverpod controller managing the routine creation / editing workflow.
///
/// Implements Law L2 (offline persistence), Law L6 (inline validation),
/// and Law L7 (write-through saves and crash-safe editing).

abstract class _$RoutineEditorController
    extends $AsyncNotifier<RoutineEditorState> {
  late final _$args = ref.$arg as String?;
  String? get routineId => _$args;

  FutureOr<RoutineEditorState> build(String? routineId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<RoutineEditorState>, RoutineEditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<RoutineEditorState>, RoutineEditorState>,
              AsyncValue<RoutineEditorState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
