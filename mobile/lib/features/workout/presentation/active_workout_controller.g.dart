// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_workout_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod AsyncNotifier managing the unidirectional state updates for an active workout.
///
/// Disallows legacy ChangeNotifier and two-way binding. Every state mutation produces
/// an immutable new state and initiates asynchronous write-through to SQLite.
///
/// WU-3.10: the session lifecycle is mirrored onto the Android foreground
/// service — started/restored when a session becomes active, updated on
/// pause/resume/rename, stopped on finish/discard — so the lock-screen
/// notification always mirrors app state (L7/L8).

@ProviderFor(ActiveWorkoutController)
final activeWorkoutControllerProvider = ActiveWorkoutControllerProvider._();

/// Riverpod AsyncNotifier managing the unidirectional state updates for an active workout.
///
/// Disallows legacy ChangeNotifier and two-way binding. Every state mutation produces
/// an immutable new state and initiates asynchronous write-through to SQLite.
///
/// WU-3.10: the session lifecycle is mirrored onto the Android foreground
/// service — started/restored when a session becomes active, updated on
/// pause/resume/rename, stopped on finish/discard — so the lock-screen
/// notification always mirrors app state (L7/L8).
final class ActiveWorkoutControllerProvider
    extends
        $AsyncNotifierProvider<ActiveWorkoutController, ActiveWorkoutState> {
  /// Riverpod AsyncNotifier managing the unidirectional state updates for an active workout.
  ///
  /// Disallows legacy ChangeNotifier and two-way binding. Every state mutation produces
  /// an immutable new state and initiates asynchronous write-through to SQLite.
  ///
  /// WU-3.10: the session lifecycle is mirrored onto the Android foreground
  /// service — started/restored when a session becomes active, updated on
  /// pause/resume/rename, stopped on finish/discard — so the lock-screen
  /// notification always mirrors app state (L7/L8).
  ActiveWorkoutControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeWorkoutControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeWorkoutControllerHash();

  @$internal
  @override
  ActiveWorkoutController create() => ActiveWorkoutController();
}

String _$activeWorkoutControllerHash() =>
    r'bd35d84168c03b2d86ec0fb1796dbb5dc616990f';

/// Riverpod AsyncNotifier managing the unidirectional state updates for an active workout.
///
/// Disallows legacy ChangeNotifier and two-way binding. Every state mutation produces
/// an immutable new state and initiates asynchronous write-through to SQLite.
///
/// WU-3.10: the session lifecycle is mirrored onto the Android foreground
/// service — started/restored when a session becomes active, updated on
/// pause/resume/rename, stopped on finish/discard — so the lock-screen
/// notification always mirrors app state (L7/L8).

abstract class _$ActiveWorkoutController
    extends $AsyncNotifier<ActiveWorkoutState> {
  FutureOr<ActiveWorkoutState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<ActiveWorkoutState>, ActiveWorkoutState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ActiveWorkoutState>, ActiveWorkoutState>,
              AsyncValue<ActiveWorkoutState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
