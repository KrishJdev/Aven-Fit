import 'dart:async';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../domain/auth_state.dart';
import 'auth_local_source.dart';

part 'auth_repository.g.dart';

/// Auth failure with the backend's message attached — screens surface
/// this directly (§6.1: network/validation errors are never silent, L6).
class AuthException implements Exception {
  const AuthException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'AuthException($statusCode): $message';
}

/// Contract for the auth session (WU-5.1, FEATURES.md §6, L2).
///
/// Guest mode is the primary flow: a fresh install boots straight to
/// [AuthGuest] — the login screen is opt-in navigation, never a gate.
abstract class AuthRepository {
  /// Reactive session state; replays the current state to every new
  /// listener (loading → guest/authenticated on boot).
  Stream<AuthState> watchAuthState();

  /// Current state snapshot, waiting for the boot load to finish.
  Future<AuthState> currentAuthState();

  /// Sends the OTP SMS (§6.1 Continue). Returns the OTP expiry in
  /// seconds for the verification screen's resend countdown.
  Future<int> requestOtp(String phoneNumber);

  /// Verifies the OTP — sign-in and sign-up are the same flow (§6.1,
  /// no passwords; new and returning users identical).
  Future<AuthState> loginWithOtp(String phoneNumber, String otp);

  /// Signs in with a Google ID token (direct sign-in, §6.1).
  Future<AuthState> loginWithGoogle(String idToken);

  /// Enters guest mode explicitly; the guest UUID is the handle that
  /// links local SQLite data to an account on a later sign-in (§6.2).
  Future<AuthState> continueAsGuest();

  /// Signs out — best-effort server-side revocation, always succeeds
  /// locally (L2: logout can never require the network).
  Future<AuthState> logout();

  Future<bool> isGuest();
}

/// Production implementation: secure-storage session + the shared Dio
/// client with a self-wired [AuthInterceptor] (bearer attach, one-shot
/// 401 refresh-retry).
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required ApiClient apiClient,
    AuthLocalSource? localSource,
  })  : _local = localSource ?? AuthLocalSource() {
    _dio = apiClient.dio;
    _dio.interceptors.add(AuthInterceptor(
      dio: _dio,
      getAccessToken: () => switch (_state) {
        AuthAuthenticated(:final accessToken) => accessToken,
        _ => null,
      },
      refreshAccessToken: _refreshAccessToken,
    ));
  }

  final AuthLocalSource _local;
  late final Dio _dio;

  AuthState _state = const AuthState.loading();
  final _controller = StreamController<AuthState>.broadcast();
  Future<void>? _loading;

  @override
  Stream<AuthState> watchAuthState() async* {
    await _ensureLoaded();
    yield _state;
    yield* _controller.stream;
  }

  @override
  Future<AuthState> currentAuthState() async {
    await _ensureLoaded();
    return _state;
  }

  @override
  Future<int> requestOtp(String phoneNumber) async {
    final data = await _postAuth(
      '/api/auth/phone/request-otp',
      {'phoneNumber': phoneNumber},
    );
    return (data['expiresInSeconds'] as num?)?.toInt() ?? 300;
  }

  @override
  Future<AuthState> loginWithOtp(String phoneNumber, String otp) async {
    await _ensureLoaded();
    final data = await _postAuth('/api/auth/phone/verify-otp', {
      'phoneNumber': phoneNumber,
      'otp': otp,
    });
    return _applySession(data);
  }

  @override
  Future<AuthState> loginWithGoogle(String idToken) async {
    await _ensureLoaded();
    final data = await _postAuth('/api/auth/google', {'idToken': idToken});
    return _applySession(data);
  }

  @override
  Future<AuthState> continueAsGuest() async {
    await _ensureLoaded();
    return _enterGuestMode();
  }

  @override
  Future<AuthState> logout() async {
    await _ensureLoaded();
    // Best-effort revocation (§6, L2): an expired token or offline
    // device never blocks the local sign-out.
    try {
      final stored = await _local.readSession();
      if (stored != null) {
        await _dio.post<void>(
          '/api/auth/logout',
          data: {'refreshToken': stored.refreshToken},
        );
      }
    } catch (_) {
      // Server revocation failed — local sign-out proceeds regardless.
    }
    await _local.clearSession();
    final state =
        AuthState.guest(clientUuid: await _local.readOrCreateGuestUuid());
    _setState(state);
    return state;
  }

  @override
  Future<bool> isGuest() async {
    await _ensureLoaded();
    return _state is AuthGuest;
  }

  /// Trades the refresh token for a new pair — called by the
  /// [AuthInterceptor] on a 401. Returns the new access token, or null
  /// when the refresh failed; a definitive rejection (401/403) clears
  /// the session so the user is never locked out of offline data (L2),
  /// while a transient/offline failure keeps the stored session intact.
  Future<String?> _refreshAccessToken() async {
    final StoredAuthSession? stored;
    try {
      stored = await _local.readSession();
    } catch (_) {
      return null;
    }
    if (stored == null) {
      return null;
    }
    try {
      final data = await _postAuth(
        '/api/auth/refresh',
        {'refreshToken': stored.refreshToken},
      );
      final newSession = _sessionFrom(data, fallback: stored);
      await _local.writeSession(newSession);
      _setState(_authenticatedState(newSession));
      return newSession.accessToken;
    } on AuthException catch (error) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        await _signOutToGuest();
      }
      return null;
    } catch (_) {
      // Offline or malformed-but-transient — keep the session; the
      // request itself surfaces the failure (L2/L6).
      return null;
    }
  }

  /// Boot load: stored session wins; otherwise guest is the default
  /// (L2 — no account wall). A broken secure store falls back to guest
  /// WITHOUT touching the stored tokens.
  ///
  /// The guest transition goes through [_enterGuestMode], NOT the public
  /// [continueAsGuest] — that one re-enters this guard and would await
  /// the very future this body is computing (circular await).
  Future<void> _ensureLoaded() =>
      _loading ??= () async {
        try {
          final session = await _local.readSession();
          if (session != null) {
            _setState(_authenticatedState(session));
          } else {
            await _enterGuestMode();
          }
        } catch (_) {
          _setState(AuthState.guest(clientUuid: generateUuidV4()));
        }
      }();

  /// Emits guest state with the stable stored identity — no boot guard
  /// inside (both [continueAsGuest] and the loader use it).
  Future<AuthState> _enterGuestMode() async {
    final state =
        AuthState.guest(clientUuid: await _local.readOrCreateGuestUuid());
    _setState(state);
    return state;
  }

  Future<AuthState> _applySession(Map<String, dynamic> data) async {
    final session = _sessionFrom(data);
    await _local.writeSession(session);
    final state = _authenticatedState(session);
    _setState(state);
    return state;
  }

  Future<AuthState> _signOutToGuest() async {
    await _local.clearSession();
    final state =
        AuthState.guest(clientUuid: await _local.readOrCreateGuestUuid());
    _setState(state);
    return state;
  }

  AuthState _authenticatedState(StoredAuthSession session) =>
      AuthState.authenticated(
        userId: session.userId,
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        displayName: session.displayName,
        phoneNumber: session.phoneNumber,
      );

  void _setState(AuthState state) {
    _state = state;
    _controller.add(state);
  }

  /// POSTs an auth-engine request and unwraps the standard
  /// `{data, message}` envelope (backend `ApiResponse`).
  Future<Map<String, dynamic>> _postAuth(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: body,
        options: Options(extra: {AuthInterceptor.skipAuthExtraKey: true}),
      );
      final data = response.data?['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      throw AuthException(
        'Malformed auth response',
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      throw AuthException(
        _messageOf(error),
        statusCode: error.response?.statusCode,
      );
    }
  }

  static String _messageOf(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'You appear to be offline';
      default:
        return 'Authentication failed';
    }
  }

  static StoredAuthSession _sessionFrom(
    Map<String, dynamic> data, {
    StoredAuthSession? fallback,
  }) {
    final accessToken = data['accessToken'] as String?;
    final refreshToken = data['refreshToken'] as String?;
    final user = data['user'] as Map<String, dynamic>?;
    final userId = user?['id'] as String?;
    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty ||
        (userId == null && fallback == null)) {
      throw const AuthException('Malformed auth response');
    }
    return StoredAuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId ?? fallback!.userId,
      displayName:
          (user?['displayName'] as String?) ?? fallback?.displayName,
      phoneNumber: (user?['phoneNumber'] as String?) ?? fallback?.phoneNumber,
    );
  }

  void dispose() => _controller.close();
}

/// KeepAlive: the auth session lives across screens and tabs.
@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) {
  final repository = AuthRepositoryImpl(apiClient: ref.watch(apiClientProvider));
  ref.onDispose(repository.dispose);
  return repository;
}

/// KeepAlive reactive auth union (WU-5.3): replays the boot state, then
/// follows every transition — the Profile screen renders from this and
/// re-emits live on sign-in/sign-out (L8, zero polling).
@Riverpod(keepAlive: true)
Stream<AuthState> watchAuthState(Ref ref) {
  return ref.watch(authRepositoryProvider).watchAuthState();
}
