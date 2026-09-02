// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod controller for the login flow (WU-5.2, FEATURES.md §6.1).
///
/// Guest is a first-class outcome (L2): "Continue as guest" bypasses the
/// network entirely. An invalid phone never reaches the repository and
/// never navigates (L6); network errors surface with the backend's
/// message and a retry.

@ProviderFor(LoginController)
final loginControllerProvider = LoginControllerProvider._();

/// Riverpod controller for the login flow (WU-5.2, FEATURES.md §6.1).
///
/// Guest is a first-class outcome (L2): "Continue as guest" bypasses the
/// network entirely. An invalid phone never reaches the repository and
/// never navigates (L6); network errors surface with the backend's
/// message and a retry.
final class LoginControllerProvider
    extends $NotifierProvider<LoginController, LoginState> {
  /// Riverpod controller for the login flow (WU-5.2, FEATURES.md §6.1).
  ///
  /// Guest is a first-class outcome (L2): "Continue as guest" bypasses the
  /// network entirely. An invalid phone never reaches the repository and
  /// never navigates (L6); network errors surface with the backend's
  /// message and a retry.
  LoginControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginControllerHash();

  @$internal
  @override
  LoginController create() => LoginController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoginState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoginState>(value),
    );
  }
}

String _$loginControllerHash() => r'141ae4ce6614814d2ef295044cb121cc563d99d4';

/// Riverpod controller for the login flow (WU-5.2, FEATURES.md §6.1).
///
/// Guest is a first-class outcome (L2): "Continue as guest" bypasses the
/// network entirely. An invalid phone never reaches the repository and
/// never navigates (L6); network errors surface with the backend's
/// message and a retry.

abstract class _$LoginController extends $Notifier<LoginState> {
  LoginState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LoginState, LoginState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LoginState, LoginState>,
              LoginState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
