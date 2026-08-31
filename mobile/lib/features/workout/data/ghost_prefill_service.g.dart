// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ghost_prefill_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider exposing [GhostPrefillService].

@ProviderFor(ghostPrefillService)
final ghostPrefillServiceProvider = GhostPrefillServiceProvider._();

/// Riverpod provider exposing [GhostPrefillService].

final class GhostPrefillServiceProvider
    extends
        $FunctionalProvider<
          GhostPrefillService,
          GhostPrefillService,
          GhostPrefillService
        >
    with $Provider<GhostPrefillService> {
  /// Riverpod provider exposing [GhostPrefillService].
  GhostPrefillServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ghostPrefillServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ghostPrefillServiceHash();

  @$internal
  @override
  $ProviderElement<GhostPrefillService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GhostPrefillService create(Ref ref) {
    return ghostPrefillService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GhostPrefillService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GhostPrefillService>(value),
    );
  }
}

String _$ghostPrefillServiceHash() =>
    r'df46677c390307f481f78995b5372f7689b4d198';
