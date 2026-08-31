// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod controller managing the routines list state and actions.
///
/// Implements Law L2 (offline stream), Law L3 (unlimited routines),
/// and Law L7 (write-through duplication, deletion with confirmation, and safe session start).

@ProviderFor(RoutineListController)
final routineListControllerProvider = RoutineListControllerProvider._();

/// Riverpod controller managing the routines list state and actions.
///
/// Implements Law L2 (offline stream), Law L3 (unlimited routines),
/// and Law L7 (write-through duplication, deletion with confirmation, and safe session start).
final class RoutineListControllerProvider
    extends $StreamNotifierProvider<RoutineListController, List<Routine>> {
  /// Riverpod controller managing the routines list state and actions.
  ///
  /// Implements Law L2 (offline stream), Law L3 (unlimited routines),
  /// and Law L7 (write-through duplication, deletion with confirmation, and safe session start).
  RoutineListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routineListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routineListControllerHash();

  @$internal
  @override
  RoutineListController create() => RoutineListController();
}

String _$routineListControllerHash() =>
    r'e0dad7f7432507ebfd1d9b562f42cb686787abf4';

/// Riverpod controller managing the routines list state and actions.
///
/// Implements Law L2 (offline stream), Law L3 (unlimited routines),
/// and Law L7 (write-through duplication, deletion with confirmation, and safe session start).

abstract class _$RoutineListController extends $StreamNotifier<List<Routine>> {
  Stream<List<Routine>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Routine>>, List<Routine>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Routine>>, List<Routine>>,
              AsyncValue<List<Routine>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
