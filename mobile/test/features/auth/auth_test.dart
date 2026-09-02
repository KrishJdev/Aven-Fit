import 'dart:async';
import 'dart:convert';

import 'package:aven_fit/core/network/api_client.dart';
import 'package:aven_fit/features/auth/data/auth_local_source.dart';
import 'package:aven_fit/features/auth/data/auth_repository.dart';
import 'package:aven_fit/features/auth/domain/auth_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory secure store backing the method-channel mock — the tests
/// read/seed it directly to arrange persisted state.
final secureStore = <String, String>{};

void _installSecureStorageMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
    (call) async {
      final args = Map<String, dynamic>.from(call.arguments ?? const {});
      switch (call.method) {
        case 'write':
          secureStore[args['key'] as String] = args['value'] as String;
          return null;
        case 'read':
          return secureStore[args['key'] as String];
        case 'delete':
          secureStore.remove(args['key'] as String);
          return null;
        case 'readAll':
          return Map<String, String>.from(secureStore);
        case 'deleteAll':
          secureStore.clear();
          return null;
        case 'containsKey':
          return secureStore.containsKey(args['key'] as String);
      }
      return null;
    },
  );
}

/// Immutable snapshot of a request at fetch time — the interceptor
/// mutates RequestOptions in place for the retry (extra flag + new
/// bearer), so a live reference would rewrite history.
class _RecordedRequest {
  _RecordedRequest(RequestOptions options)
      : method = options.method,
        path = options.uri.path,
        authorization = options.headers['Authorization'] as String?,
        data = options.data;

  final String method;
  final String path;
  final String? authorization;
  final Object? data;
}

/// Scripted adapter: every entry responds (ResponseBody) or fails
/// (DioException built from the live RequestOptions) in order.
class _ScriptedAdapter implements HttpClientAdapter {
  final requests = <_RecordedRequest>[];
  final _script = <Object Function(RequestOptions)>[];

  void respond(ResponseBody body) => _script.add((_) => body);

  void failWith(DioException Function(RequestOptions options) build) =>
      _script.add(build);

  bool get isDrained => _script.isEmpty;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(_RecordedRequest(options));
    if (_script.isEmpty) {
      fail('Unexpected request: ${options.method} ${options.uri}');
    }
    final outcome = _script.removeAt(0)(options);
    if (outcome is DioException) throw outcome;
    return outcome as ResponseBody;
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, [int status = 200]) =>
    ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
    );

Map<String, dynamic> _envelope(Object data) => {'data': data, 'message': 'OK'};

Map<String, dynamic> _authData({
  String access = 'access_1',
  String refresh = 'refresh_1',
  String userId = '11111111-2222-3333-4444-555555555555',
  String? displayName = 'Aven User',
  String? phone = '+919876543210',
}) =>
    {
      'accessToken': access,
      'refreshToken': refresh,
      'user': {
        'id': userId,
        'phoneNumber': phone,
        'displayName': displayName,
        'unitPreference': 'METRIC',
      },
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  _installSecureStorageMock();

  final repos = <AuthRepositoryImpl>[];

  setUp(() {
    secureStore.clear();
  });

  tearDown(() {
    for (final repo in repos) {
      repo.dispose();
    }
    repos.clear();
  });

  /// Builds a repository over a scripted client; both handles returned
  /// so tests can drive raw Dio traffic for the interceptor cases.
  (AuthRepositoryImpl, ApiClient, _ScriptedAdapter) makeHarness() {
    final adapter = _ScriptedAdapter();
    final client = ApiClient(baseUrl: 'http://test.local');
    client.dio.httpClientAdapter = adapter;
    final repo = AuthRepositoryImpl(apiClient: client);
    repos.add(repo);
    return (repo, client, adapter);
  }

  group('AuthState (domain, WU-5.1)', () {
    test('union states construct and switch exhaustively', () {
      String describe(AuthState state) => switch (state) {
            AuthLoading() => 'loading',
            AuthGuest(:final clientUuid) => 'guest:$clientUuid',
            AuthAuthenticated(:final userId) => 'authed:$userId',
            AuthError(:final message) => 'error:$message',
          };

      expect(describe(const AuthState.loading()), 'loading');
      expect(
        describe(const AuthState.guest(clientUuid: 'u1')),
        'guest:u1',
      );
      expect(
        describe(const AuthState.authenticated(
          userId: 'u2',
          accessToken: 'a',
          refreshToken: 'r',
        )),
        'authed:u2',
      );
      expect(describe(const AuthState.error(message: 'x')), 'error:x');
    });
  });

  group('AuthLocalSource (WU-5.1)', () {
    test('guest uuid is v4-formatted, created once, and stable', () async {
      final source = AuthLocalSource();

      final first = await source.readOrCreateGuestUuid();
      expect(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ).hasMatch(first),
        isTrue,
      );
      expect(secureStore[AuthStorageKeys.guestUuid], first);

      final second = await source.readOrCreateGuestUuid();
      expect(second, first);

      // Sign-out clears the session but never the identity (§6.2).
      await source.clearSession();
      expect(await source.readOrCreateGuestUuid(), first);
    });

    test('session write/read round-trips every field', () async {
      final source = AuthLocalSource();
      const session = StoredAuthSession(
        accessToken: 'a',
        refreshToken: 'r',
        userId: 'u',
        displayName: 'Name',
        phoneNumber: '+911234567890',
      );

      await source.writeSession(session);
      final read = await source.readSession();

      expect(read, isNotNull);
      expect(read!.accessToken, 'a');
      expect(read.refreshToken, 'r');
      expect(read.userId, 'u');
      expect(read.displayName, 'Name');
      expect(read.phoneNumber, '+911234567890');
    });

    test('a partial token pair reads as signed out', () async {
      final source = AuthLocalSource();
      await source.writeSession(
        const StoredAuthSession(accessToken: 'a', refreshToken: 'r', userId: 'u'),
      );
      await source.writeSession(
        const StoredAuthSession(accessToken: 'a2', refreshToken: 'r2', userId: ''),
      );

      // userId: '' was written — present but empty still counts as a
      // stored pair; the null case is the meaningful one.
      expect(await source.readSession(), isNotNull);

      secureStore.remove(AuthStorageKeys.refreshToken);
      expect(await source.readSession(), isNull);

      secureStore.remove(AuthStorageKeys.userId);
      expect(await source.readSession(), isNull);
    });
  });

  group('AuthRepository (WU-5.1)', () {
    test('fresh install boots straight to Guest — no login wall (L2)',
        () async {
      final (repo, _, adapter) = makeHarness();

      final state = await repo.currentAuthState();

      expect(state, isA<AuthGuest>());
      expect(await repo.isGuest(), isTrue);
      // The identity persisted for the later account link (§6.2).
      final uuid = (state as AuthGuest).clientUuid;
      expect(secureStore[AuthStorageKeys.guestUuid], uuid);
      // Boot never touches the network.
      expect(adapter.requests, isEmpty);
    });

    test('a stored session boots Authenticated with its exact fields',
        () async {
      secureStore.addAll({
        AuthStorageKeys.accessToken: 'stored_a',
        AuthStorageKeys.refreshToken: 'stored_r',
        AuthStorageKeys.userId: 'user-7',
        AuthStorageKeys.displayName: 'Stored User',
        AuthStorageKeys.phoneNumber: '+919000000000',
      });
      final (repo, _, _) = makeHarness();

      final state = await repo.currentAuthState();

      expect(state, isA<AuthAuthenticated>());
      final authed = state as AuthAuthenticated;
      expect(authed.accessToken, 'stored_a');
      expect(authed.refreshToken, 'stored_r');
      expect(authed.userId, 'user-7');
      expect(authed.displayName, 'Stored User');
      expect(authed.phoneNumber, '+919000000000');
      expect(await repo.isGuest(), isFalse);
    });

    test('watchAuthState replays the current state and follows transitions',
        () async {
      final (repo, _, adapter) = makeHarness();
      adapter.respond(_json(_envelope(_authData())));

      final emissions = <AuthState>[];
      repo.watchAuthState().listen(emissions.add);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(emissions.single, isA<AuthGuest>());

      await repo.loginWithOtp('+919876543210', '123456');
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(emissions, hasLength(2));
      expect(emissions.last, isA<AuthAuthenticated>());
    });

    test('requestOtp posts the phone number and returns the expiry',
        () async {
      final (repo, _, adapter) = makeHarness();
      adapter.respond(_json(_envelope({
        'message': 'OTP sent',
        'expiresInSeconds': 300,
      })));

      final expires = await repo.requestOtp('+919876543210');

      expect(expires, 300);
      final request = adapter.requests.single;
      expect(request.path, '/api/auth/phone/request-otp');
      expect((request.data as Map)['phoneNumber'], '+919876543210');
      // Pre-auth endpoints never carry a bearer token.
      expect(request.authorization, isNull);
    });

    test('loginWithOtp persists the pair and flips to Authenticated',
        () async {
      final (repo, _, adapter) = makeHarness();
      adapter.respond(_json(_envelope(_authData())));

      final state = await repo.loginWithOtp('+919876543210', '123456');

      final request = adapter.requests.single;
      expect(request.path, '/api/auth/phone/verify-otp');
      expect((request.data as Map)['otp'], '123456');

      expect(state, isA<AuthAuthenticated>());
      final authed = state as AuthAuthenticated;
      expect(authed.accessToken, 'access_1');
      expect(authed.userId, '11111111-2222-3333-4444-555555555555');
      expect(authed.displayName, 'Aven User');

      expect(secureStore[AuthStorageKeys.accessToken], 'access_1');
      expect(secureStore[AuthStorageKeys.refreshToken], 'refresh_1');
      expect(secureStore[AuthStorageKeys.userId],
          '11111111-2222-3333-4444-555555555555');
    });

    test('an invalid OTP surfaces the backend message and changes nothing',
        () async {
      final (repo, _, adapter) = makeHarness();
      await repo.currentAuthState(); // boot → guest
      adapter.respond(_json({'message': 'Invalid OTP'}, 401));

      await expectLater(
        repo.loginWithOtp('+919876543210', '000000'),
        throwsA(
          isA<AuthException>()
              .having((e) => e.message, 'message', 'Invalid OTP')
              .having((e) => e.statusCode, 'statusCode', 401),
        ),
      );

      // Auth-engine 401s are answers, not refresh triggers — and a
      // failed login never mutates the session (L7).
      expect(adapter.requests, hasLength(1));
      expect(await repo.currentAuthState(), isA<AuthGuest>());
      expect(secureStore.containsKey(AuthStorageKeys.accessToken), isFalse);
    });

    test('loginWithGoogle signs in from an id token', () async {
      final (repo, _, adapter) = makeHarness();
      adapter.respond(_json(_envelope(_authData(access: 'g_a'))));

      final state = await repo.loginWithGoogle('google_id_token');

      expect(adapter.requests.single.path, '/api/auth/google');
      expect((adapter.requests.single.data as Map)['idToken'],
          'google_id_token');
      expect((state as AuthAuthenticated).accessToken, 'g_a');
    });

    test('full lifecycle: Guest → Authenticated → Logout → Guest (§6.2)',
        () async {
      final (repo, _, adapter) = makeHarness();
      final guestUuid =
          (await repo.currentAuthState() as AuthGuest).clientUuid;

      adapter.respond(_json(_envelope(_authData())));
      final authed = await repo.loginWithOtp('+919876543210', '123456');
      expect(await repo.isGuest(), isFalse);
      expect(
        (authed as AuthAuthenticated).userId,
        '11111111-2222-3333-4444-555555555555',
      );

      adapter.respond(_json({'message': 'OK'}));
      final signedOut = await repo.logout();

      expect(adapter.requests.last.path, '/api/auth/logout');
      expect((adapter.requests.last.data as Map)['refreshToken'], 'refresh_1');
      // The bearer was attached — logout requires authentication.
      expect(
        adapter.requests.last.authorization,
        contains('access_1'),
      );

      expect(signedOut, isA<AuthGuest>());
      expect(await repo.isGuest(), isTrue);
      expect(secureStore.containsKey(AuthStorageKeys.accessToken), isFalse);
      expect(secureStore.containsKey(AuthStorageKeys.refreshToken), isFalse);
      // Same anonymous identity survives the whole cycle (§6.2/L7).
      expect((signedOut as AuthGuest).clientUuid, guestUuid);
    });

    test('logout is best-effort — an offline server never blocks it (L2)',
        () async {
      final (repo, _, adapter) = makeHarness();
      adapter.respond(_json(_envelope(_authData())));
      await repo.loginWithOtp('+919876543210', '123456');

      adapter.failWith(
        (options) => DioException.connectionError(
          requestOptions: options,
          reason: 'airplane mode',
        ),
      );
      final state = await repo.logout();

      expect(state, isA<AuthGuest>());
      expect(secureStore.containsKey(AuthStorageKeys.accessToken), isFalse);
      expect(await repo.isGuest(), isTrue);
    });
  });

  group('AuthInterceptor (WU-5.1)', () {
    test('attaches the bearer token when authenticated', () async {
      final (repo, client, adapter) = makeHarness();
      adapter.respond(_json(_envelope(_authData())));
      await repo.loginWithOtp('+919876543210', '123456');

      adapter.respond(_json({'ok': true}));
      await client.dio.get<void>('/api/workouts');

      // requests[0] is the login; the probe is the last one.
      expect(
        adapter.requests.last.authorization,
        'Bearer access_1',
      );
    });

    test('sends no Authorization header while a guest', () async {
      final (repo, client, adapter) = makeHarness();
      await repo.currentAuthState();

      adapter.respond(_json({'ok': true}));
      await client.dio.get<void>('/api/workouts');

      expect(adapter.requests.single.authorization, isNull);
    });

    test('skip-flagged auth-engine requests never carry a token', () async {
      final (repo, client, adapter) = makeHarness();
      adapter.respond(_json(_envelope(_authData())));
      await repo.loginWithOtp('+919876543210', '123456');

      adapter.respond(_json(_envelope(_authData())));
      await client.dio.post<void>(
        '/api/auth/refresh',
        data: {'refreshToken': 'refresh_1'},
        options: Options(extra: {AuthInterceptor.skipAuthExtraKey: true}),
      );

      // requests[0] is the login (also skip-flagged); the manual refresh
      // probe is last.
      expect(adapter.requests.last.authorization, isNull);
    });

    test('a 401 refreshes once and retries with the new bearer', () async {
      final (repo, client, adapter) = makeHarness();
      adapter.respond(_json(_envelope(_authData())));
      await repo.loginWithOtp('+919876543210', '123456');

      adapter.respond(_json({'error': 'UNAUTHENTICATED'}, 401));
      adapter.respond(_json(_envelope(_authData(
        access: 'access_2',
        refresh: 'refresh_2',
      ))));
      adapter.respond(_json({'workouts': []}));

      final response = await client.dio.get<Map<String, dynamic>>(
        '/api/workouts',
      );

      expect(response.statusCode, 200);
      // [0] login · [1] original 401 · [2] refresh · [3] retry
      expect(adapter.requests, hasLength(4));
      expect(
        adapter.requests[1].authorization,
        'Bearer access_1',
      );
      // The refresh call itself: skip-flagged, bearer-less.
      expect(adapter.requests[2].path, '/api/auth/refresh');
      expect(adapter.requests[2].authorization, isNull);
      expect(
        adapter.requests[3].authorization,
        'Bearer access_2',
      );
      // The rotated pair was persisted and the state follows.
      expect(secureStore[AuthStorageKeys.accessToken], 'access_2');
      expect(secureStore[AuthStorageKeys.refreshToken], 'refresh_2');
      final state = await repo.currentAuthState();
      expect((state as AuthAuthenticated).accessToken, 'access_2');
    });

    test('a definitively dead refresh token signs out, never locks out (L2)',
        () async {
      final (repo, client, adapter) = makeHarness();
      adapter.respond(_json(_envelope(_authData())));
      await repo.loginWithOtp('+919876543210', '123456');

      adapter.respond(_json({'error': 'UNAUTHENTICATED'}, 401));
      adapter.respond(_json({'message': 'Invalid or expired refresh token'},
          401));

      await expectLater(
        client.dio.get<void>('/api/workouts'),
        throwsA(isA<DioException>()),
      );

      // [0] login · [1] original 401 · [2] refresh — no retry.
      expect(adapter.requests, hasLength(3));
      expect(adapter.requests[1].path, '/api/workouts');
      expect(adapter.requests[2].path, '/api/auth/refresh');
      expect(secureStore.containsKey(AuthStorageKeys.accessToken), isFalse);
      expect(secureStore.containsKey(AuthStorageKeys.refreshToken), isFalse);
      expect(await repo.currentAuthState(), isA<AuthGuest>());
    });

    test('an offline refresh keeps the session — no wrongful logout (L2)',
        () async {
      final (repo, client, adapter) = makeHarness();
      adapter.respond(_json(_envelope(_authData())));
      await repo.loginWithOtp('+919876543210', '123456');

      adapter.respond(_json({'error': 'UNAUTHENTICATED'}, 401));
      adapter.failWith(
        (options) => DioException.connectionError(
          requestOptions: options,
          reason: 'airplane mode',
        ),
      );

      await expectLater(
        client.dio.get<void>('/api/workouts'),
        throwsA(isA<DioException>()),
      );

      // Transient failure: the pair stays put for the next online run.
      expect(secureStore[AuthStorageKeys.accessToken], 'access_1');
      expect(secureStore[AuthStorageKeys.refreshToken], 'refresh_1');
      expect(await repo.currentAuthState(), isA<AuthAuthenticated>());
    });

    test('auth-engine 401s surface directly — no refresh loop', () async {
      final (repo, client, adapter) = makeHarness();
      adapter.respond(_json(_envelope(_authData())));
      await repo.loginWithOtp('+919876543210', '123456');

      adapter.respond(_json({'error': 'UNAUTHENTICATED'}, 401));

      await expectLater(
        client.dio.post<void>('/api/auth/logout', data: {'refreshToken': 'r'}),
        throwsA(isA<DioException>()),
      );
      // [0] login · [1] the failed logout — no refresh in between.
      expect(adapter.requests, hasLength(2));
      expect(adapter.requests.last.path, '/api/auth/logout');
    });

    test('a 401 without any stored session never attempts a refresh',
        () async {
      final (repo, client, adapter) = makeHarness();
      await repo.currentAuthState(); // guest — no tokens anywhere

      adapter.respond(_json({'error': 'UNAUTHENTICATED'}, 401));

      await expectLater(
        client.dio.get<void>('/api/workouts'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.requests, hasLength(1));
      expect(adapter.isDrained, isTrue);
    });
  });

  group('authRepositoryProvider (WU-5.1)', () {
    test('builds a working repository over the shared ApiClient',
        () async {
      final adapter = _ScriptedAdapter();
      final client = ApiClient(baseUrl: 'http://test.local');
      client.dio.httpClientAdapter = adapter;
      adapter.respond(_json(_envelope(_authData())));

      final container = ProviderContainer(
        overrides: [apiClientProvider.overrideWithValue(client)],
      );
      addTearDown(container.dispose);

      final repo = container.read(authRepositoryProvider);
      final state = await repo.loginWithOtp('+919876543210', '123456');

      expect(state, isA<AuthAuthenticated>());
      expect(secureStore[AuthStorageKeys.accessToken], 'access_1');
    });
  });
}
