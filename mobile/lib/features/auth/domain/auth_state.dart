import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

/// Immutable auth session state (WU-5.1, FEATURES.md §6).
///
/// Guest is the primary boot state (L2 — no account wall, the whole core
/// works offline); [AuthLoading] covers only the brief secure-storage
/// read at startup; [AuthError] surfaces a broken auth store without
/// ever blocking the offline core.
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.loading() = AuthLoading;

  /// Anonymous local identity — [clientUuid] is the handle that links
  /// local SQLite data to an account on a later sign-in (§6.2, L7).
  const factory AuthState.guest({required String clientUuid}) = AuthGuest;

  const factory AuthState.authenticated({
    required String userId,
    required String accessToken,
    required String refreshToken,
    String? displayName,
    String? phoneNumber,
  }) = AuthAuthenticated;

  const factory AuthState.error({required String message}) = AuthError;
}
