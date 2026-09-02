import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Baseline HTTP client for the Spring Boot API.
///
/// Offline-first (Law L2): nothing in the core flow awaits this client.
/// Repositories use it only for sync and auth, and must degrade
/// gracefully when the network is unavailable.
class ApiClient {
  ApiClient({String? baseUrl, Iterable<Interceptor>? interceptors})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? const String.fromEnvironment(
              'AVENFIT_BASE_URL',
              defaultValue: 'http://10.0.2.2:8080/api/v1',
            ),
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
          ),
        ) {
    if (interceptors != null) {
      _dio.interceptors.addAll(interceptors);
    }
    _dio.interceptors.add(_loggingInterceptor);
  }

  final Dio _dio;

  /// Hook for auth tokens (Slice 5) and sync-queue headers.
  Interceptors get interceptors => _dio.interceptors;

  Dio get dio => _dio;
}

/// Riverpod access to the shared [ApiClient] — mirrors the
/// `appDatabaseProvider` pattern: one instance, tests override it.
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

/// Attaches the bearer token and transparently refreshes an expired
/// access token exactly once on 401 (WU-5.1).
///
/// Deliberately storage- and repository-agnostic — core never imports
/// `features/auth`; the auth repository binds its own closures when it
/// registers this interceptor on the shared [Dio].
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.dio,
    required this.getAccessToken,
    required this.refreshAccessToken,
  });

  /// Marks a retried request so a second 401 can never loop.
  static const _retriedExtraKey = 'avenfit_auth_retried';

  /// Marks auth-engine requests (the refresh call itself) so they bypass
  /// token attach and 401-refresh handling entirely.
  static const skipAuthExtraKey = 'avenfit_skip_auth';

  final Dio dio;
  final String? Function() getAccessToken;
  final Future<String?> Function() refreshAccessToken;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = getAccessToken();
    final skip = options.extra[skipAuthExtraKey] == true;
    if (token != null && !skip) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final response = err.response;
    // Auth-engine paths (login/refresh themselves) must surface their
    // own failures — a 401 there is the answer, not a trigger (L6).
    final isAuthPath = options.uri.path.startsWith('/api/auth/');
    final alreadyRetried = options.extra[_retriedExtraKey] == true;
    if (response?.statusCode != 401 || isAuthPath || alreadyRetried) {
      handler.next(err);
      return;
    }

    final newAccessToken = await refreshAccessToken();
    if (newAccessToken == null) {
      // The refresh callback already decided the session's fate (cleared
      // on a definitive rejection, kept when merely offline — L2).
      handler.next(err);
      return;
    }

    options
      ..extra[_retriedExtraKey] = true
      ..headers['Authorization'] = 'Bearer $newAccessToken';
    try {
      final response = await dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException {
      handler.next(err);
    }
  }
}

final _loggingInterceptor = InterceptorsWrapper(
  onError: (error, handler) {
    // Failures must surface, never disappear — but keep logs quiet on
    // connection errors, which are expected in offline-first usage.
    handler.next(error);
  },
);
