import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_service.g.dart';

/// Actions the rest-timer notification exposes to the user.
enum RestNotificationAction { add15 }

/// Android notification plumbing for the rest-timer countdown (WU-3.5,
/// FEATURES.md §8.3): channel setup, just-in-time permission priming, and
/// show/update/cancel of the countdown + completion notifications.
///
/// Hard requirements honored here:
/// - Silent channel, no sound/vibration (§8.3 — completion sound/vibration is
///   a P1 Settings concern).
/// - Permission is requested just-in-time with a session-scoped latch: after
///   one user decision the OS prompt is never re-nagged (FEATURES.md §3).
/// - Denial (or an unsupported platform) never breaks a core flow — every
///   platform call is guarded and no-ops, the in-app rest bar keeps working
///   with notifications denied (L2/L4).
class NotificationService {
  NotificationService();

  static const String _restChannelId = 'avenfit_rest_timer';
  static const String _restChannelName = 'Rest Timer';
  static const String _restChannelDescription =
      'Silent rest countdown shown during workout sessions';
  static const String _actionAdd15Id = 'avenfit_action_rest_plus_15';

  static const int _restCountdownNotificationId = 1001;
  static const int _restCompleteNotificationId = 1002;

  /// Handler invoked when the user taps the "+15s" action on the countdown
  /// notification. Wired to the rest timer controller while a countdown is
  /// live; full lock-screen action support lands with the foreground service
  /// (WU-3.10).
  void Function(RestNotificationAction action)? actionHandler;

  FlutterLocalNotificationsPlugin? _plugin;
  Future<void>? _initializing;
  bool _permissionDecided = false;
  bool _granted = false;

  /// Whether the user has made a permission decision this session (grant or
  /// deny). Once true the primer/OS prompt must never appear again.
  bool get permissionDecided => _permissionDecided;

  /// Synchronous snapshot of the last known permission state; false until
  /// [initialize] completes or a request resolves.
  bool get isPermissionGrantedCached => _granted;

  /// Idempotent plugin + channel bootstrap. Safe to await from anywhere.
  Future<void> initialize() {
    return _initializing ??= _doInitialize();
  }

  Future<void> _doInitialize() async {
    try {
      final plugin = FlutterLocalNotificationsPlugin();
      await plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );
      final android = plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          _restChannelId,
          _restChannelName,
          description: _restChannelDescription,
          importance: Importance.low,
          playSound: false,
          enableVibration: false,
        ),
      );
      _granted = await android?.areNotificationsEnabled() ?? false;
      _plugin = plugin;
    } catch (_) {
      // Platform channel unavailable (tests / non-Android): notifications
      // silently disabled — core flows never depend on them (L2).
      _plugin = null;
    }
  }

  /// Runs the Android 13+ POST_NOTIFICATIONS runtime prompt. Records the
  /// decision so the primer is never re-nagged this session.
  Future<bool> requestPermission() async {
    _permissionDecided = true;
    final android = _plugin
        ?.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return false;
    try {
      final granted = await android.requestNotificationsPermission() ?? false;
      _granted = granted;
      return granted;
    } catch (_) {
      return false;
    }
  }

  /// Records an explicit "not now" so the just-in-time primer never appears
  /// again this session while leaving the OS-level state untouched.
  void declinePermissionPrimer() {
    _permissionDecided = true;
  }

  /// Shows (or updates in place) the ongoing rest countdown notification with
  /// an epoch-derived remaining time and a progress bar.
  Future<void> showRestCountdown({
    required int remainingSeconds,
    required int totalSeconds,
  }) async {
    await initialize();
    final plugin = _plugin;
    if (plugin == null || !_granted) return;
    try {
      await plugin.show(
        id: _restCountdownNotificationId,
        title: 'Rest Timer',
        body: '${_formatClock(remainingSeconds)} remaining — next set when ready',
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _restChannelId,
            _restChannelName,
            channelDescription: _restChannelDescription,
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
            onlyAlertOnce: true,
            playSound: false,
            enableVibration: false,
            showProgress: true,
            maxProgress: totalSeconds < 1 ? 1 : totalSeconds,
            progress: remainingSeconds.clamp(0, totalSeconds < 1 ? 1 : totalSeconds),
            category: AndroidNotificationCategory.progress,
            actions: <AndroidNotificationAction>[
              const AndroidNotificationAction(
                _actionAdd15Id,
                '+15s',
                showsUserInterface: true,
                cancelNotification: false,
              ),
            ],
          ),
        ),
      );
    } catch (_) {
      // Notification failures never surface to the logging flow (L2).
    }
  }

  /// Shows the silent "rest complete" notice. Replaces the countdown;
  /// dismissed on tap or by the next countdown/cancel.
  Future<void> showRestComplete() async {
    await initialize();
    final plugin = _plugin;
    if (plugin == null || !_granted) return;
    try {
      await plugin.show(
        id: _restCompleteNotificationId,
        title: 'Rest complete',
        body: 'Next set when you are ready',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _restChannelId,
            _restChannelName,
            channelDescription: _restChannelDescription,
            importance: Importance.low,
            priority: Priority.low,
            playSound: false,
            enableVibration: false,
            autoCancel: true,
          ),
        ),
      );
    } catch (_) {}
  }

  /// Removes any rest countdown / completion notification (timer cancelled,
  /// next set logged, or session ended).
  Future<void> cancelRestNotification() async {
    final plugin = _plugin;
    if (plugin == null) return;
    try {
      await plugin.cancel(id: _restCountdownNotificationId);
      await plugin.cancel(id: _restCompleteNotificationId);
    } catch (_) {}
  }

  void _onNotificationResponse(NotificationResponse response) {
    if (response.actionId == _actionAdd15Id) {
      actionHandler?.call(RestNotificationAction.add15);
    }
  }

  static String _formatClock(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

/// App-wide notification service (channel setup fires once, on first watch).
@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  final service = NotificationService();
  unawaited(service.initialize());
  return service;
}
