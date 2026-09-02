import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/data/auth_repository.dart';
import '../../auth/domain/auth_state.dart';
import '../../history/data/history_repository.dart';
import '../../history/domain/lifetime_stats.dart';
import 'profile_state.dart';

part 'profile_controller.g.dart';

/// Riverpod Notifier composing the Profile state (WU-5.3, FEATURES.md
/// §12.1): the reactive auth union plus the lifetime stats aggregate.
/// Re-emits whenever either source changes — sign-in/sign-out transitions
/// and workout history mutations alike (L8, zero polling).
///
/// Mutations are thin write-through pass-throughs (the nutrition
/// dashboard pattern): sign-out delegates to the auth repository and the
/// auth stream re-emits Guest — the state math is never duplicated here.
@riverpod
class ProfileController extends _$ProfileController {
  @override
  ProfileState build() {
    final authAsync = ref.watch(watchAuthStateProvider);
    final statsAsync = ref.watch(watchLifetimeStatsProvider);

    return ProfileState(
      // Broken auth store (AuthError) renders like Guest — the offline
      // core is never blocked by an identity failure (L2).
      auth: authAsync.value ?? const AuthState.loading(),
      stats: statsAsync.value ?? const LifetimeStats(),
    );
  }

  /// Signs out. The UI owns the confirmation dialog (L7 — data never
  /// silently vanishes): guest history stays on the device and the guest
  /// UUID survives (§5.4), so a later sign-in links it back. The auth
  /// stream re-emits Guest and the screen flips to the local profile.
  Future<void> signOut() => ref.read(authRepositoryProvider).logout();
}
