import 'package:aven_fit/core/notifications/notification_service.dart';

/// Test double for [NotificationService] — records invocations instead of
/// touching platform channels.
class FakeNotificationService extends NotificationService {
  FakeNotificationService({
    this.granted = true,
    this.decided = true,
    this.requestResult = true,
  });

  /// Last known permission state exposed synchronously.
  bool granted;

  /// Whether the user has made a permission decision this session.
  bool decided;

  /// What [requestPermission] resolves to when called.
  bool requestResult;

  final List<String> calls = [];

  @override
  bool get permissionDecided => decided;

  @override
  bool get isPermissionGrantedCached => granted;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async {
    calls.add('requestPermission');
    decided = true;
    granted = requestResult;
    return granted;
  }

  @override
  void declinePermissionPrimer() {
    calls.add('decline');
    decided = true;
  }

  @override
  Future<void> showRestCountdown({
    required int remainingSeconds,
    required int totalSeconds,
  }) async {
    calls.add('countdown:$remainingSeconds/$totalSeconds');
  }

  @override
  Future<void> showRestComplete() async {
    calls.add('complete');
  }

  @override
  Future<void> cancelRestNotification() async {
    calls.add('cancelNotification');
  }
}
