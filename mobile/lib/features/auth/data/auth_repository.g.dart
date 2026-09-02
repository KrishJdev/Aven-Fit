// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// KeepAlive: the auth session lives across screens and tabs.

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// KeepAlive: the auth session lives across screens and tabs.

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// KeepAlive: the auth session lives across screens and tabs.
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'e47643a52cc719fe265d1cef674300d7883450ee';

/// KeepAlive reactive auth union (WU-5.3): replays the boot state, then
/// follows every transition — the Profile screen renders from this and
/// re-emits live on sign-in/sign-out (L8, zero polling).

@ProviderFor(watchAuthState)
final watchAuthStateProvider = WatchAuthStateProvider._();

/// KeepAlive reactive auth union (WU-5.3): replays the boot state, then
/// follows every transition — the Profile screen renders from this and
/// re-emits live on sign-in/sign-out (L8, zero polling).

final class WatchAuthStateProvider
    extends
        $FunctionalProvider<AsyncValue<AuthState>, AuthState, Stream<AuthState>>
    with $FutureModifier<AuthState>, $StreamProvider<AuthState> {
  /// KeepAlive reactive auth union (WU-5.3): replays the boot state, then
  /// follows every transition — the Profile screen renders from this and
  /// re-emits live on sign-in/sign-out (L8, zero polling).
  WatchAuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchAuthStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchAuthStateHash();

  @$internal
  @override
  $StreamProviderElement<AuthState> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AuthState> create(Ref ref) {
    return watchAuthState(ref);
  }
}

String _$watchAuthStateHash() => r'038379698fdc2236a5c16e5bb566f2ab09b6c3bf';
