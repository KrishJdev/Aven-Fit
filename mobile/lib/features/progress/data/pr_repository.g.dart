// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pr_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider exposing [PRRepository] to feature controllers.

@ProviderFor(prRepository)
final prRepositoryProvider = PrRepositoryProvider._();

/// Riverpod provider exposing [PRRepository] to feature controllers.

final class PrRepositoryProvider
    extends $FunctionalProvider<PRRepository, PRRepository, PRRepository>
    with $Provider<PRRepository> {
  /// Riverpod provider exposing [PRRepository] to feature controllers.
  PrRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'prRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$prRepositoryHash();

  @$internal
  @override
  $ProviderElement<PRRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PRRepository create(Ref ref) {
    return prRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PRRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PRRepository>(value),
    );
  }
}

String _$prRepositoryHash() => r'43db205adac6dcffa5fe96bf604ca7b2734c8624';
