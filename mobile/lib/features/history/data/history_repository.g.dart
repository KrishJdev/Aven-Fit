// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider exposing [HistoryRepository] to feature controllers.

@ProviderFor(historyRepository)
final historyRepositoryProvider = HistoryRepositoryProvider._();

/// Riverpod provider exposing [HistoryRepository] to feature controllers.

final class HistoryRepositoryProvider
    extends
        $FunctionalProvider<
          HistoryRepository,
          HistoryRepository,
          HistoryRepository
        >
    with $Provider<HistoryRepository> {
  /// Riverpod provider exposing [HistoryRepository] to feature controllers.
  HistoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyRepositoryHash();

  @$internal
  @override
  $ProviderElement<HistoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HistoryRepository create(Ref ref) {
    return historyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HistoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HistoryRepository>(value),
    );
  }
}

String _$historyRepositoryHash() => r'0888a1d687abe3278b149f91f27c5ab22f25de42';

/// Page size for the history feed — loadMore grows the window (§8.6
/// virtualized list, smooth across years of data).

@ProviderFor(HistoryFeedLimit)
final historyFeedLimitProvider = HistoryFeedLimitProvider._();

/// Page size for the history feed — loadMore grows the window (§8.6
/// virtualized list, smooth across years of data).
final class HistoryFeedLimitProvider
    extends $NotifierProvider<HistoryFeedLimit, int> {
  /// Page size for the history feed — loadMore grows the window (§8.6
  /// virtualized list, smooth across years of data).
  HistoryFeedLimitProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyFeedLimitProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyFeedLimitHash();

  @$internal
  @override
  HistoryFeedLimit create() => HistoryFeedLimit();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$historyFeedLimitHash() => r'43274473455037ac976a378bba22bbb7666e2bc8';

/// Page size for the history feed — loadMore grows the window (§8.6
/// virtualized list, smooth across years of data).

abstract class _$HistoryFeedLimit extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Reactive history feed: watches completed workouts with the current page
/// window. Re-executes when the limit grows or the underlying SQLite tables
/// change (L2 — renders from local data in <2s cold start).

@ProviderFor(watchWorkoutHistory)
final watchWorkoutHistoryProvider = WatchWorkoutHistoryProvider._();

/// Reactive history feed: watches completed workouts with the current page
/// window. Re-executes when the limit grows or the underlying SQLite tables
/// change (L2 — renders from local data in <2s cold start).

final class WatchWorkoutHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WorkoutHistoryItem>>,
          List<WorkoutHistoryItem>,
          Stream<List<WorkoutHistoryItem>>
        >
    with
        $FutureModifier<List<WorkoutHistoryItem>>,
        $StreamProvider<List<WorkoutHistoryItem>> {
  /// Reactive history feed: watches completed workouts with the current page
  /// window. Re-executes when the limit grows or the underlying SQLite tables
  /// change (L2 — renders from local data in <2s cold start).
  WatchWorkoutHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchWorkoutHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchWorkoutHistoryHash();

  @$internal
  @override
  $StreamProviderElement<List<WorkoutHistoryItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<WorkoutHistoryItem>> create(Ref ref) {
    return watchWorkoutHistory(ref);
  }
}

String _$watchWorkoutHistoryHash() =>
    r'b022ef44f5703f802a68d6eb3e18718039413ab0';
