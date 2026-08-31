// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod controller managing a specific routine's detail state and live session startup.
///
/// Implements Law L2 (reactive stream from SQLite), Law L7 (non-destructive session start
/// and write-through edits), and Law L1 (<1s startup latency).

@ProviderFor(RoutineDetailController)
final routineDetailControllerProvider = RoutineDetailControllerFamily._();

/// Riverpod controller managing a specific routine's detail state and live session startup.
///
/// Implements Law L2 (reactive stream from SQLite), Law L7 (non-destructive session start
/// and write-through edits), and Law L1 (<1s startup latency).
final class RoutineDetailControllerProvider
    extends $StreamNotifierProvider<RoutineDetailController, Routine?> {
  /// Riverpod controller managing a specific routine's detail state and live session startup.
  ///
  /// Implements Law L2 (reactive stream from SQLite), Law L7 (non-destructive session start
  /// and write-through edits), and Law L1 (<1s startup latency).
  RoutineDetailControllerProvider._({
    required RoutineDetailControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'routineDetailControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$routineDetailControllerHash();

  @override
  String toString() {
    return r'routineDetailControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RoutineDetailController create() => RoutineDetailController();

  @override
  bool operator ==(Object other) {
    return other is RoutineDetailControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$routineDetailControllerHash() =>
    r'a0e96725bf83f890fee1bfd4a0382aac70a2079f';

/// Riverpod controller managing a specific routine's detail state and live session startup.
///
/// Implements Law L2 (reactive stream from SQLite), Law L7 (non-destructive session start
/// and write-through edits), and Law L1 (<1s startup latency).

final class RoutineDetailControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          RoutineDetailController,
          AsyncValue<Routine?>,
          Routine?,
          Stream<Routine?>,
          String
        > {
  RoutineDetailControllerFamily._()
    : super(
        retry: null,
        name: r'routineDetailControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Riverpod controller managing a specific routine's detail state and live session startup.
  ///
  /// Implements Law L2 (reactive stream from SQLite), Law L7 (non-destructive session start
  /// and write-through edits), and Law L1 (<1s startup latency).

  RoutineDetailControllerProvider call(String routineId) =>
      RoutineDetailControllerProvider._(argument: routineId, from: this);

  @override
  String toString() => r'routineDetailControllerProvider';
}

/// Riverpod controller managing a specific routine's detail state and live session startup.
///
/// Implements Law L2 (reactive stream from SQLite), Law L7 (non-destructive session start
/// and write-through edits), and Law L1 (<1s startup latency).

abstract class _$RoutineDetailController extends $StreamNotifier<Routine?> {
  late final _$args = ref.$arg as String;
  String get routineId => _$args;

  Stream<Routine?> build(String routineId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Routine?>, Routine?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Routine?>, Routine?>,
              AsyncValue<Routine?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
