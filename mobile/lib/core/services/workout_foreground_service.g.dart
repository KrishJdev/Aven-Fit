// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_foreground_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// App-wide foreground-service bridge (keep-alive so the native channel
/// handler and action callbacks survive screen navigation).

@ProviderFor(workoutForegroundService)
final workoutForegroundServiceProvider = WorkoutForegroundServiceProvider._();

/// App-wide foreground-service bridge (keep-alive so the native channel
/// handler and action callbacks survive screen navigation).

final class WorkoutForegroundServiceProvider
    extends
        $FunctionalProvider<
          WorkoutForegroundService,
          WorkoutForegroundService,
          WorkoutForegroundService
        >
    with $Provider<WorkoutForegroundService> {
  /// App-wide foreground-service bridge (keep-alive so the native channel
  /// handler and action callbacks survive screen navigation).
  WorkoutForegroundServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutForegroundServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutForegroundServiceHash();

  @$internal
  @override
  $ProviderElement<WorkoutForegroundService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WorkoutForegroundService create(Ref ref) {
    return workoutForegroundService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkoutForegroundService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkoutForegroundService>(value),
    );
  }
}

String _$workoutForegroundServiceHash() =>
    r'e748f7d6d8dafa3d13b369f921c322fbeeb464fc';
