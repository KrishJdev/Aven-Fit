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
///
/// KeepAlive: the Home suggested-routine card (WU-X.1) one-tap-starts
/// through [startWorkoutFromRoutine] — an autoDispose controller could
/// be torn down mid-flight while its async write-through runs.

@ProviderFor(RoutineListController)
final routineListControllerProvider = RoutineListControllerProvider._();

/// Riverpod controller managing the routines list state and actions.
///
/// Implements Law L2 (offline stream), Law L3 (unlimited routines),
/// and Law L7 (write-through duplication, deletion with confirmation, and safe session start).
///
/// KeepAlive: the Home suggested-routine card (WU-X.1) one-tap-starts
/// through [startWorkoutFromRoutine] — an autoDispose controller could
/// be torn down mid-flight while its async write-through runs.
final class RoutineListControllerProvider
    extends $StreamNotifierProvider<RoutineListController, List<Routine>> {
  /// Riverpod controller managing the routines list state and actions.
  ///
  /// Implements Law L2 (offline stream), Law L3 (unlimited routines),
  /// and Law L7 (write-through duplication, deletion with confirmation, and safe session start).
  ///
  /// KeepAlive: the Home suggested-routine card (WU-X.1) one-tap-starts
  /// through [startWorkoutFromRoutine] — an autoDispose controller could
  /// be torn down mid-flight while its async write-through runs.
  RoutineListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routineListControllerProvider',
        isAutoDispose: false,
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
    r'c2bd5e4ad32763e77d2cf3948fbf4b05a1ed16a8';

/// Riverpod controller managing the routines list state and actions.
///
/// Implements Law L2 (offline stream), Law L3 (unlimited routines),
/// and Law L7 (write-through duplication, deletion with confirmation, and safe session start).
///
/// KeepAlive: the Home suggested-routine card (WU-X.1) one-tap-starts
/// through [startWorkoutFromRoutine] — an autoDispose controller could
/// be torn down mid-flight while its async write-through runs.

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
