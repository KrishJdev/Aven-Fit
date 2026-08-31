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

@ProviderFor(ActiveWorkoutController)
final activeWorkoutControllerProvider = ActiveWorkoutControllerProvider._();

/// Riverpod AsyncNotifier managing the unidirectional state updates for an active workout.
///
/// Disallows legacy ChangeNotifier and two-way binding. Every state mutation produces
/// an immutable new state and initiates asynchronous write-through to SQLite.
final class ActiveWorkoutControllerProvider
    extends
        $AsyncNotifierProvider<ActiveWorkoutController, ActiveWorkoutState> {
  /// Riverpod AsyncNotifier managing the unidirectional state updates for an active workout.
  ///
  /// Disallows legacy ChangeNotifier and two-way binding. Every state mutation produces
  /// an immutable new state and initiates asynchronous write-through to SQLite.
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
    r'bf9c4637e18b6838d3319cc35e8001e3274c37ac';

/// Riverpod AsyncNotifier managing the unidirectional state updates for an active workout.
///
/// Disallows legacy ChangeNotifier and two-way binding. Every state mutation produces
/// an immutable new state and initiates asynchronous write-through to SQLite.

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
