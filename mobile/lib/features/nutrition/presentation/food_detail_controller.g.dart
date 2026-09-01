// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod AsyncNotifier managing the food detail view (WU-4.4,
/// FEATURES.md §11.4): serving unit + quantity selection with instant
/// macro scaling, meal bucket selection, and write-through logging.

@ProviderFor(FoodDetailController)
final foodDetailControllerProvider = FoodDetailControllerFamily._();

/// Riverpod AsyncNotifier managing the food detail view (WU-4.4,
/// FEATURES.md §11.4): serving unit + quantity selection with instant
/// macro scaling, meal bucket selection, and write-through logging.
final class FoodDetailControllerProvider
    extends $AsyncNotifierProvider<FoodDetailController, FoodDetailState?> {
  /// Riverpod AsyncNotifier managing the food detail view (WU-4.4,
  /// FEATURES.md §11.4): serving unit + quantity selection with instant
  /// macro scaling, meal bucket selection, and write-through logging.
  FoodDetailControllerProvider._({
    required FoodDetailControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'foodDetailControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$foodDetailControllerHash();

  @override
  String toString() {
    return r'foodDetailControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FoodDetailController create() => FoodDetailController();

  @override
  bool operator ==(Object other) {
    return other is FoodDetailControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$foodDetailControllerHash() =>
    r'a83196987ddbba426e66b096da1961fecb495609';

/// Riverpod AsyncNotifier managing the food detail view (WU-4.4,
/// FEATURES.md §11.4): serving unit + quantity selection with instant
/// macro scaling, meal bucket selection, and write-through logging.

final class FoodDetailControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          FoodDetailController,
          AsyncValue<FoodDetailState?>,
          FoodDetailState?,
          FutureOr<FoodDetailState?>,
          String
        > {
  FoodDetailControllerFamily._()
    : super(
        retry: null,
        name: r'foodDetailControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Riverpod AsyncNotifier managing the food detail view (WU-4.4,
  /// FEATURES.md §11.4): serving unit + quantity selection with instant
  /// macro scaling, meal bucket selection, and write-through logging.

  FoodDetailControllerProvider call(String foodId) =>
      FoodDetailControllerProvider._(argument: foodId, from: this);

  @override
  String toString() => r'foodDetailControllerProvider';
}

/// Riverpod AsyncNotifier managing the food detail view (WU-4.4,
/// FEATURES.md §11.4): serving unit + quantity selection with instant
/// macro scaling, meal bucket selection, and write-through logging.

abstract class _$FoodDetailController extends $AsyncNotifier<FoodDetailState?> {
  late final _$args = ref.$arg as String;
  String get foodId => _$args;

  FutureOr<FoodDetailState?> build(String foodId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<FoodDetailState?>, FoodDetailState?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<FoodDetailState?>, FoodDetailState?>,
              AsyncValue<FoodDetailState?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
