import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'workout_foreground_service.g.dart';

/// Platform-channel bridge to the Android workout foreground service
/// (WU-3.10, FEATURES.md §8.1).
///
/// Dart is the single source of truth for all timer state (L8): the native
/// service only renders epoch values pushed through this channel and ticks
/// its 1s notification clock from them. Every call is fire-and-forget safe —
/// a missing platform implementation (tests, non-Android) or a platform
/// failure is swallowed so core logging flows never depend on the service
/// (L2).
class WorkoutForegroundService {
  static const MethodChannel _channel = MethodChannel(
    'com.avenfit.aven_fit/workout_service',
  );

  /// Sentinel for "clear the live rest countdown" (mirrors the native
  /// `REST_CLEAR_SENTINEL`).
  static const int _restClearSentinel = -1;

  /// Resolved once: the service only exists on real Android builds. Flutter
  /// tests always run on desktop hosts, so this gate also guarantees the
  /// bridge never touches a platform channel in tests (no dangling replies).
  static final bool _platformSupported = !kIsWeb && Platform.isAndroid;

  /// Test seam: forces [_invoke] through the channel on desktop test hosts
  /// so outbound payloads can be verified against a mock handler.
  @visibleForTesting
  static bool debugForceSupported = false;

  bool _handlerRegistered = false;

  /// Native "+15s" action on the foreground-service notification. Wired to
  /// [RestTimerController.addTime] while the controller is alive.
  void Function()? onAdd15;

  /// Native "Finish Workout" action. Wired to the session-lifecycle finish
  /// path while the rest-timer controller is alive.
  void Function()? onFinish;

  /// Registers the native → Dart action callbacks once per process.
  void _ensureHandler() {
    if (_handlerRegistered) return;
    _handlerRegistered = true;
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onAdd15':
          onAdd15?.call();
        case 'onFinish':
          onFinish?.call();
      }
    });
  }

  /// Starts the persistent notification for a freshly created (or restored)
  /// active session.
  Future<void> startSession({
    required String workoutName,
    required int startedAtMs,
    required bool isPaused,
    required int pausedDurationMs,
    required int lastResumedAtMs,
    int? restEndsAtMs,
  }) {
    return _invoke('startSession', {
      'workoutName': workoutName,
      'startedAtMs': startedAtMs,
      'isPaused': isPaused,
      'pausedDurationMs': pausedDurationMs,
      'lastResumedAtMs': lastResumedAtMs,
      'restEndsAtMs': ?restEndsAtMs,
    });
  }

  /// Updates only the provided session fields (absent keys keep the native
  /// values) — pause/resume, rename, restore corrections.
  Future<void> updateSession({
    String? workoutName,
    int? startedAtMs,
    bool? isPaused,
    int? pausedDurationMs,
    int? lastResumedAtMs,
  }) {
    return _invoke('updateSession', {
      'workoutName': ?workoutName,
      'startedAtMs': ?startedAtMs,
      'isPaused': ?isPaused,
      'pausedDurationMs': ?pausedDurationMs,
      'lastResumedAtMs': ?lastResumedAtMs,
    });
  }

  /// Pushes the live rest countdown deadline (epoch ms); `null` clears it.
  Future<void> updateRest(int? restEndsAtMs) {
    return _invoke('updateRest', {
      'restEndsAtMs': restEndsAtMs ?? _restClearSentinel,
    });
  }

  /// Stops the service and dismisses the notification (session finished,
  /// discarded, or completed from the notification).
  Future<void> stop() {
    return _invoke('stop');
  }

  Future<void> _invoke(String method, [Map<String, Object?>? args]) async {
    if (!_platformSupported && !debugForceSupported) return;
    // Registered lazily behind the platform gate so test hosts (no widget
    // binding) never touch the messenger.
    _ensureHandler();
    try {
      await _channel.invokeMethod<void>(method, args);
    } on MissingPluginException {
      // No platform implementation — no-op (L2).
    } on PlatformException {
      // Platform-level failure (e.g. FGS restrictions) — the in-app UI keeps
      // working; the notification is best-effort by design.
    } catch (_) {
      // Never let notification plumbing break a core flow (L2/L4).
    }
  }
}

/// App-wide foreground-service bridge (keep-alive so the native channel
/// handler and action callbacks survive screen navigation).
@Riverpod(keepAlive: true)
WorkoutForegroundService workoutForegroundService(Ref ref) {
  final service = WorkoutForegroundService();
  ref.onDispose(() {
    service.onAdd15 = null;
    service.onFinish = null;
  });
  return service;
}
