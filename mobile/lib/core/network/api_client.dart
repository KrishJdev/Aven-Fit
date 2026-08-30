import 'package:dio/dio.dart';

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

final _loggingInterceptor = InterceptorsWrapper(
  onError: (error, handler) {
    // Failures must surface, never disappear — but keep logs quiet on
    // connection errors, which are expected in offline-first usage.
    handler.next(error);
  },
);
