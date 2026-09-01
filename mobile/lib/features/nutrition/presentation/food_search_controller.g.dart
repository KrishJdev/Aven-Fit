// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_search_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod AsyncNotifier managing the state and search filters of the
/// Food Database Search screen (WU-4.4).
///
/// Implements Law L1 (<300ms search latency), Law L2 (100% offline catalog,
/// seeded on first build), and Law L6 (every filter combination leaves a
/// designed state).

@ProviderFor(FoodSearchController)
final foodSearchControllerProvider = FoodSearchControllerProvider._();

/// Riverpod AsyncNotifier managing the state and search filters of the
/// Food Database Search screen (WU-4.4).
///
/// Implements Law L1 (<300ms search latency), Law L2 (100% offline catalog,
/// seeded on first build), and Law L6 (every filter combination leaves a
/// designed state).
final class FoodSearchControllerProvider
    extends $AsyncNotifierProvider<FoodSearchController, FoodSearchState> {
  /// Riverpod AsyncNotifier managing the state and search filters of the
  /// Food Database Search screen (WU-4.4).
  ///
  /// Implements Law L1 (<300ms search latency), Law L2 (100% offline catalog,
  /// seeded on first build), and Law L6 (every filter combination leaves a
  /// designed state).
  FoodSearchControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foodSearchControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foodSearchControllerHash();

  @$internal
  @override
  FoodSearchController create() => FoodSearchController();
}

String _$foodSearchControllerHash() =>
    r'84400b28328b37641cc2b401258b1ee44ee843ff';

/// Riverpod AsyncNotifier managing the state and search filters of the
/// Food Database Search screen (WU-4.4).
///
/// Implements Law L1 (<300ms search latency), Law L2 (100% offline catalog,
/// seeded on first build), and Law L6 (every filter combination leaves a
/// designed state).

abstract class _$FoodSearchController extends $AsyncNotifier<FoodSearchState> {
  FutureOr<FoodSearchState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<FoodSearchState>, FoodSearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<FoodSearchState>, FoodSearchState>,
              AsyncValue<FoodSearchState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
