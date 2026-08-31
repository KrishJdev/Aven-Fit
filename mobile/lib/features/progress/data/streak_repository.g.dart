// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider exposing [StreakRepository] to feature controllers.

@ProviderFor(streakRepository)
final streakRepositoryProvider = StreakRepositoryProvider._();

/// Riverpod provider exposing [StreakRepository] to feature controllers.

final class StreakRepositoryProvider
    extends
        $FunctionalProvider<
          StreakRepository,
          StreakRepository,
          StreakRepository
        >
    with $Provider<StreakRepository> {
  /// Riverpod provider exposing [StreakRepository] to feature controllers.
  StreakRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streakRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streakRepositoryHash();

  @$internal
  @override
  $ProviderElement<StreakRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StreakRepository create(Ref ref) {
    return streakRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StreakRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StreakRepository>(value),
    );
  }
}

String _$streakRepositoryHash() => r'1263608806e9be337433537c41fcc1c8288db99c';

/// Reactive forgiving-streak state for the Home glance stats row (§5.2) —
/// re-emits whenever sessions or streak settings change (L8: no polling).

@ProviderFor(watchStreakInfo)
final watchStreakInfoProvider = WatchStreakInfoProvider._();

/// Reactive forgiving-streak state for the Home glance stats row (§5.2) —
/// re-emits whenever sessions or streak settings change (L8: no polling).

final class WatchStreakInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<StreakInfo>,
          StreakInfo,
          Stream<StreakInfo>
        >
    with $FutureModifier<StreakInfo>, $StreamProvider<StreakInfo> {
  /// Reactive forgiving-streak state for the Home glance stats row (§5.2) —
  /// re-emits whenever sessions or streak settings change (L8: no polling).
  WatchStreakInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchStreakInfoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchStreakInfoHash();

  @$internal
  @override
  $StreamProviderElement<StreakInfo> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<StreakInfo> create(Ref ref) {
    return watchStreakInfo(ref);
  }
}

String _$watchStreakInfoHash() => r'9b1f258303aeb6844374133e6a67677b6b3038e2';
