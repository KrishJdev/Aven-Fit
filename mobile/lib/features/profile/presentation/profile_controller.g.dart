// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod Notifier composing the Profile state (WU-5.3, FEATURES.md
/// §12.1): the reactive auth union plus the lifetime stats aggregate.
/// Re-emits whenever either source changes — sign-in/sign-out transitions
/// and workout history mutations alike (L8, zero polling).
///
/// Mutations are thin write-through pass-throughs (the nutrition
/// dashboard pattern): sign-out delegates to the auth repository and the
/// auth stream re-emits Guest — the state math is never duplicated here.

@ProviderFor(ProfileController)
final profileControllerProvider = ProfileControllerProvider._();

/// Riverpod Notifier composing the Profile state (WU-5.3, FEATURES.md
/// §12.1): the reactive auth union plus the lifetime stats aggregate.
/// Re-emits whenever either source changes — sign-in/sign-out transitions
/// and workout history mutations alike (L8, zero polling).
///
/// Mutations are thin write-through pass-throughs (the nutrition
/// dashboard pattern): sign-out delegates to the auth repository and the
/// auth stream re-emits Guest — the state math is never duplicated here.
final class ProfileControllerProvider
    extends $NotifierProvider<ProfileController, ProfileState> {
  /// Riverpod Notifier composing the Profile state (WU-5.3, FEATURES.md
  /// §12.1): the reactive auth union plus the lifetime stats aggregate.
  /// Re-emits whenever either source changes — sign-in/sign-out transitions
  /// and workout history mutations alike (L8, zero polling).
  ///
  /// Mutations are thin write-through pass-throughs (the nutrition
  /// dashboard pattern): sign-out delegates to the auth repository and the
  /// auth stream re-emits Guest — the state math is never duplicated here.
  ProfileControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileControllerHash();

  @$internal
  @override
  ProfileController create() => ProfileController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileState>(value),
    );
  }
}

String _$profileControllerHash() => r'981808910bfc5bd692f3f3fa8b8f8551265cf910';

/// Riverpod Notifier composing the Profile state (WU-5.3, FEATURES.md
/// §12.1): the reactive auth union plus the lifetime stats aggregate.
/// Re-emits whenever either source changes — sign-in/sign-out transitions
/// and workout history mutations alike (L8, zero polling).
///
/// Mutations are thin write-through pass-throughs (the nutrition
/// dashboard pattern): sign-out delegates to the auth repository and the
/// auth stream re-emits Guest — the state math is never duplicated here.

abstract class _$ProfileController extends $Notifier<ProfileState> {
  ProfileState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ProfileState, ProfileState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProfileState, ProfileState>,
              ProfileState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
