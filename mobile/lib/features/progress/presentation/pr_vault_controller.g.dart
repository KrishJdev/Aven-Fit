// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pr_vault_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reactive PR vault (WU-X.3, FEATURES.md §10.2): every personal record
/// joined with its exercise name, newest achievement first — the
/// Progress preview and the full vault screen share this one stream.
/// Drift re-emits on any record change (L8, zero polling).

@ProviderFor(prVaultStream)
final prVaultStreamProvider = PrVaultStreamProvider._();

/// Reactive PR vault (WU-X.3, FEATURES.md §10.2): every personal record
/// joined with its exercise name, newest achievement first — the
/// Progress preview and the full vault screen share this one stream.
/// Drift re-emits on any record change (L8, zero polling).

final class PrVaultStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PRVaultEntry>>,
          List<PRVaultEntry>,
          Stream<List<PRVaultEntry>>
        >
    with
        $FutureModifier<List<PRVaultEntry>>,
        $StreamProvider<List<PRVaultEntry>> {
  /// Reactive PR vault (WU-X.3, FEATURES.md §10.2): every personal record
  /// joined with its exercise name, newest achievement first — the
  /// Progress preview and the full vault screen share this one stream.
  /// Drift re-emits on any record change (L8, zero polling).
  PrVaultStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'prVaultStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$prVaultStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<PRVaultEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PRVaultEntry>> create(Ref ref) {
    return prVaultStream(ref);
  }
}

String _$prVaultStreamHash() => r'10ca4f41ee35aad812110fe8d8f3d3905a31638e';
