import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/notifications/notification_service.dart';
import '../../../core/services/workout_foreground_service.dart';
import '../../workout/data/workout_repository.dart';
import 'rest_timer_state.dart';

part 'rest_timer_controller.g.dart';

/// Epoch-based rest countdown controller (WU-3.5, FEATURES.md §8.3).
///
/// The source of truth is the epoch deadline in [RestTimerState]; a
/// `Stream.periodic` subscription exists purely to refresh the UI and the
/// Android notification once per second — the displayed value is always
/// recomputed from the deadline, never accumulated (L8: zero CPU polling).
///
/// Resting and lifting are mutually exclusive states: starting a countdown
/// replaces any live one, [cancel] clears it instantly, and warm-up sets
/// never trigger rest. Keep-alive so the countdown survives navigation to
/// the exercise picker or other tabs while the session stays active.
///
/// WU-3.10: the controller also owns the foreground-service notification
/// actions (it is the keep-alive session-scope component): "+15s" adjusts
/// the countdown, "Finish Workout" completes the active session
/// (write-through, L7) and stops the service. Rest deadlines are pushed to
/// the service on every change so the lock-screen notification stays live.
@Riverpod(keepAlive: true)
class RestTimerController extends _$RestTimerController {
  /// Default rest duration — completing a set auto-starts a 90s countdown.
  static const int defaultRestSeconds = 90;

  StreamSubscription<void>? _tickSub;

  /// Injectable clock for deterministic tests; production uses wall time.
  @visibleForTesting
  DateTime Function() clock = DateTime.now;

  @override
  RestTimerState build() {
    ref.onDispose(_stopTicking);
    final notifications = ref.watch(notificationServiceProvider);
    notifications.actionHandler = _onNotificationAction;
    ref.onDispose(() => notifications.actionHandler = null);

    // Foreground-service notification actions (WU-3.10): the service is the
    // lock-screen surface; this controller stays authoritative for both.
    // The provider is a keep-alive singleton, so this controller is its only
    // ever owner — disposal clears the hooks unconditionally.
    final foreground = ref.watch(workoutForegroundServiceProvider);
    foreground.onAdd15 = () => addTime(15);
    foreground.onFinish = _finishFromNotification;
    ref.onDispose(() {
      foreground.onAdd15 = null;
      foreground.onFinish = null;
    });
    return const RestTimerState();
  }

  /// "Finish Workout" from the foreground-service notification (§8.1):
  /// completes the active session write-through so a lock-screen tap never
  /// risks losing the workout, stops the service, and clears notifications.
  Future<void> _finishFromNotification() async {
    final repository = ref.read(workoutRepositoryProvider);
    final active = await repository.getActiveSession();
    if (active == null) {
      await ref.read(workoutForegroundServiceProvider).stop();
      return;
    }
    cancel();
    await repository.finishWorkout(
      active.id,
      durationSeconds: active.elapsedSecondsNow(),
    );
    await ref.read(workoutForegroundServiceProvider).stop();
  }

  /// Starts a fresh countdown, replacing any live one (§8.3 auto-cancel rule:
  /// "the countdown is replaced by the restarted rest timer for the new set").
  ///
  /// [seconds] allows the per-exercise rest override; falls back to the 90s
  /// default. Manual header start calls this without any prior set (L1).
  void start({
    int? seconds,
    String? sessionExerciseId,
    String? exerciseName,
  }) {
    _startCountdown(
      durationSeconds: seconds ?? defaultRestSeconds,
      sessionExerciseId: sessionExerciseId,
      exerciseName: exerciseName,
    );
  }

  /// Restarts the countdown at its full original duration (§8.3) — undoing
  /// any ±15s adjustments made since it started.
  void restart() {
    final s = state;
    if (!s.isRunning || s.totalSeconds <= 0) return;
    _startCountdown(
      durationSeconds: s.initialSeconds > 0 ? s.initialSeconds : s.totalSeconds,
      sessionExerciseId: s.sessionExerciseId,
      exerciseName: s.exerciseName,
    );
  }

  /// Adjusts the live deadline by [deltaSeconds] (+15s / −15s). The value is
  /// applied to the epoch deadline, so past ticks cannot distort it. Dropping
  /// the remaining time at or below zero dismisses the timer entirely.
  void addTime(int deltaSeconds) {
    final s = state;
    if (!s.isRunning || s.endsAtEpochMs == null) return;

    final newRemaining = _computeRemainingSeconds(s) + deltaSeconds;
    if (newRemaining <= 0) {
      cancel();
      return;
    }

    final newTotal = s.totalSeconds + deltaSeconds;
    state = s.copyWith(
      totalSeconds: newTotal < 1 ? 1 : newTotal,
      endsAtEpochMs: clock().millisecondsSinceEpoch + newRemaining * 1000,
      remainingSeconds: newRemaining,
    );
    _syncNotification();
    _syncForegroundRest(state.endsAtEpochMs);
  }

  /// Stops the countdown and clears its notification instantly (§8.3: no
  /// double state — logging the next set calls this or replaces the timer).
  void cancel() {
    _stopTicking();
    unawaited(ref.read(notificationServiceProvider).cancelRestNotification());
    _syncForegroundRest(null);
    state = RestTimerState(needsPermissionPrimer: state.needsPermissionPrimer);
  }

  /// Resolves the just-in-time notification primer surfaced by the UI:
  /// enabling runs the Android 13+ runtime prompt (and attaches the live
  /// countdown notification on grant); "not now" latches the decision so the
  /// user is never re-nagged this session (FEATURES.md §3, L4).
  Future<void> resolvePermissionPrimer({required bool enable}) async {
    final notifications = ref.read(notificationServiceProvider);
    if (enable) {
      final granted = await notifications.requestPermission();
      if (granted) _syncNotification();
    } else {
      notifications.declinePermissionPrimer();
    }
    state = state.copyWith(needsPermissionPrimer: false);
  }

  void _startCountdown({
    required int durationSeconds,
    String? sessionExerciseId,
    String? exerciseName,
  }) {
    if (durationSeconds <= 0) return;
    _stopTicking();

    final now = clock();
    state = RestTimerState(
      isRunning: true,
      totalSeconds: durationSeconds,
      initialSeconds: durationSeconds,
      endsAtEpochMs: now.millisecondsSinceEpoch + durationSeconds * 1000,
      remainingSeconds: durationSeconds,
      sessionExerciseId: sessionExerciseId,
      exerciseName: exerciseName,
    );

    // UI/notification refresh ticks only — values come from the epoch deadline.
    _tickSub = Stream<void>.periodic(const Duration(seconds: 1)).listen((_) => _onTick());
    _syncForegroundRest(state.endsAtEpochMs);
    unawaited(_maybePrimeNotifications());
  }

  void _onTick() {
    final s = state;
    if (!s.isRunning || s.endsAtEpochMs == null) {
      _stopTicking();
      return;
    }

    final remaining = _computeRemainingSeconds(s);
    if (remaining <= 0) {
      _complete();
      return;
    }
    if (remaining != s.remainingSeconds) {
      state = s.copyWith(remainingSeconds: remaining);
    }
    _syncNotification();
  }

  /// Natural completion — silent by design (§8.3: completion sound/vibration
  /// is a P1 Settings concern). The countdown notification flips to a
  /// dismissible "rest complete" notice.
  void _complete() {
    _stopTicking();
    final notifications = ref.read(notificationServiceProvider);
    unawaited(notifications.cancelRestNotification());
    unawaited(notifications.showRestComplete());
    _syncForegroundRest(null);
    state = RestTimerState(needsPermissionPrimer: state.needsPermissionPrimer);
  }

  int _computeRemainingSeconds(RestTimerState s) {
    final endsAt = s.endsAtEpochMs;
    if (endsAt == null) return 0;
    final remainingMs = endsAt - clock().millisecondsSinceEpoch;
    if (remainingMs <= 0) return 0;
    return (remainingMs / 1000).ceil();
  }

  /// Mirrors the live rest deadline onto the foreground-service notification
  /// (WU-3.10) — re-render on state change only, no extra loops (L8).
  void _syncForegroundRest(int? endsAtEpochMs) {
    unawaited(ref.read(workoutForegroundServiceProvider).updateRest(endsAtEpochMs));
  }

  /// Just-in-time priming (FEATURES.md §3): while the permission decision is
  /// still pending the explainer dialog is requested via
  /// [RestTimerState.needsPermissionPrimer]; a decided/denied session never
  /// asks again and the in-app bar keeps working regardless (L2/L4).
  Future<void> _maybePrimeNotifications() async {
    final notifications = ref.read(notificationServiceProvider);
    await notifications.initialize();
    if (notifications.isPermissionGrantedCached) {
      _syncNotification();
      return;
    }
    if (!notifications.permissionDecided) {
      state = state.copyWith(needsPermissionPrimer: true);
    }
  }

  /// Mirrors the countdown onto the Android notification (updates in place on
  /// the same id — re-render on state change only, no background loops, L8).
  void _syncNotification() {
    final s = state;
    if (!s.isRunning) return;
    final notifications = ref.read(notificationServiceProvider);
    if (!notifications.isPermissionGrantedCached) return;
    unawaited(notifications.showRestCountdown(
      remainingSeconds: s.remainingSeconds,
      totalSeconds: s.totalSeconds,
    ));
  }

  void _onNotificationAction(RestNotificationAction action) {
    if (action == RestNotificationAction.add15) {
      addTime(15);
    }
  }

  void _stopTicking() {
    _tickSub?.cancel();
    _tickSub = null;
  }
}
