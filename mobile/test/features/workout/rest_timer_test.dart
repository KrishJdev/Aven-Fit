import 'package:aven_fit/core/notifications/notification_service.dart';
import 'package:aven_fit/features/workout/presentation/rest_timer_controller.dart';
import 'package:aven_fit/features/workout/presentation/rest_timer_state.dart';
import 'package:aven_fit/features/workout/presentation/widgets/rest_timer_bar.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_notification_service.dart';

void main() {
  late FakeNotificationService notifications;
  late ProviderContainer container;

  setUp(() {
    notifications = FakeNotificationService();
    container = ProviderContainer(overrides: [
      notificationServiceProvider.overrideWithValue(notifications),
    ]);
  });

  tearDown(() => container.dispose());

  RestTimerController notifier() =>
      container.read(restTimerControllerProvider.notifier);

  RestTimerState state() => container.read(restTimerControllerProvider);

  group('RestTimerController epoch countdown (WU-3.5)', () {
    test('start begins a 90s epoch deadline and mirrors the countdown notification',
        () async {
      final before = DateTime.now();
      notifier().start();
      // Flush the async just-in-time priming that attaches the notification.
      await Future<void>.delayed(Duration.zero);

      final s = state();
      expect(s.isRunning, isTrue);
      expect(s.totalSeconds, 90);
      expect(s.remainingSeconds, 90);
      expect(s.remainingDisplay, '01:30');
      final deadline = DateTime.fromMillisecondsSinceEpoch(s.endsAtEpochMs!);
      expect(deadline.isAfter(before.add(const Duration(seconds: 89))), isTrue);
      expect(deadline.isBefore(before.add(const Duration(seconds: 92))), isTrue);
      expect(notifications.calls, contains('countdown:90/90'));
    });

    test('per-exercise rest override replaces the default duration', () {
      notifier().start(
        seconds: 180,
        sessionExerciseId: 'se_1',
        exerciseName: 'Barbell Bench Press',
      );

      final s = state();
      expect(s.totalSeconds, 180);
      expect(s.sessionExerciseId, 'se_1');
      expect(s.exerciseName, 'Barbell Bench Press');
    });

    test('+15s / -15s adjust the epoch deadline symmetrically', () {
      notifier().start(seconds: 90);

      notifier().addTime(15);
      expect(state().remainingSeconds, 105);
      expect(state().totalSeconds, 105);
      expect(state().remainingDisplay, '01:45');
      expect(notifications.calls, contains('countdown:105/105'));

      notifier().addTime(-15);
      expect(state().remainingSeconds, 90);
      expect(state().totalSeconds, 90);
    });

    test('subtracting below zero dismisses the timer entirely', () {
      notifier().start(seconds: 10);

      notifier().addTime(-15);

      expect(state().isRunning, isFalse);
      expect(notifications.calls, contains('cancelNotification'));
    });

    test('cancel stops the countdown and clears the notification instantly',
        () {
      notifier().start();

      notifier().cancel();

      final s = state();
      expect(s.isRunning, isFalse);
      expect(s.remainingSeconds, 0);
      expect(notifications.calls, contains('cancelNotification'));
    });

    test('restart resets the live countdown to its full duration (§8.3)', () {
      notifier().start(seconds: 120);
      notifier().addTime(-45);
      expect(state().remainingSeconds, 75);

      notifier().restart();

      expect(state().remainingSeconds, 120);
      expect(state().totalSeconds, 120);
    });

    test('starting a second countdown replaces the live one (auto-cancel rule)',
        () {
      notifier().start(seconds: 90);

      notifier().start(seconds: 60);

      final s = state();
      expect(s.totalSeconds, 60);
      expect(s.remainingSeconds, 60);
    });

    test('manual start works from the header without any prior set (L1)', () {
      notifier().start();

      expect(state().isRunning, isTrue);
      expect(state().totalSeconds, RestTimerController.defaultRestSeconds);
    });
  });

  group('Rest timer ticking (epoch-derived, L8)', () {
    test('ticks recompute remaining from the deadline and complete at zero',
        () {
      fakeAsync((async) {
        final fakeNotifications = FakeNotificationService();
        final fakeContainer = ProviderContainer(overrides: [
          notificationServiceProvider.overrideWithValue(fakeNotifications),
        ]);
        addTearDown(fakeContainer.dispose);

        var fakeNow = DateTime(2026, 8, 31, 10, 0, 0);
        final testNotifier =
            fakeContainer.read(restTimerControllerProvider.notifier);
        testNotifier.clock = () => fakeNow;

        testNotifier.start(seconds: 5);
        expect(fakeContainer.read(restTimerControllerProvider).remainingSeconds,
            5);

        fakeNow = fakeNow.add(const Duration(seconds: 2));
        async.elapse(const Duration(seconds: 1));
        expect(fakeContainer.read(restTimerControllerProvider).remainingSeconds,
            3);

        fakeNow = fakeNow.add(const Duration(seconds: 1));
        async.elapse(const Duration(seconds: 1));
        expect(fakeContainer.read(restTimerControllerProvider).remainingSeconds,
            2);

        // Expire the deadline — natural completion path.
        fakeNow = fakeNow.add(const Duration(seconds: 5));
        async.elapse(const Duration(seconds: 1));
        final s = fakeContainer.read(restTimerControllerProvider);
        expect(s.isRunning, isFalse);
        expect(s.remainingSeconds, 0);
        expect(fakeNotifications.calls, contains('complete'));
        expect(fakeNotifications.calls, contains('cancelNotification'));
      });
    });
  });

  group('Just-in-time notification primer (FEATURES.md §3)', () {
    test('prime surfaces while undecided and resolves on grant', () async {
      final pending = FakeNotificationService(
        granted: false,
        decided: false,
        requestResult: true,
      );
      final pendingContainer = ProviderContainer(overrides: [
        notificationServiceProvider.overrideWithValue(pending),
      ]);
      addTearDown(pendingContainer.dispose);

      pendingContainer.read(restTimerControllerProvider.notifier).start();
      await Future<void>.delayed(Duration.zero);

      expect(
          pendingContainer.read(restTimerControllerProvider).isRunning, isTrue);
      expect(
        pendingContainer
            .read(restTimerControllerProvider)
            .needsPermissionPrimer,
        isTrue,
      );

      await pendingContainer
          .read(restTimerControllerProvider.notifier)
          .resolvePermissionPrimer(enable: true);

      final s = pendingContainer.read(restTimerControllerProvider);
      expect(s.needsPermissionPrimer, isFalse);
      expect(pending.calls, contains('requestPermission'));
      expect(pending.calls, contains('countdown:90/90'));
    });

    test('"not now" latches the decision and never shows the countdown',
        () async {
      final pending = FakeNotificationService(
        granted: false,
        decided: false,
        requestResult: false,
      );
      final pendingContainer = ProviderContainer(overrides: [
        notificationServiceProvider.overrideWithValue(pending),
      ]);
      addTearDown(pendingContainer.dispose);

      pendingContainer.read(restTimerControllerProvider.notifier).start();
      await Future<void>.delayed(Duration.zero);
      expect(
        pendingContainer
            .read(restTimerControllerProvider)
            .needsPermissionPrimer,
        isTrue,
      );

      await pendingContainer
          .read(restTimerControllerProvider.notifier)
          .resolvePermissionPrimer(enable: false);

      final s = pendingContainer.read(restTimerControllerProvider);
      expect(s.needsPermissionPrimer, isFalse);
      expect(s.isRunning, isTrue);
      expect(pending.calls, contains('decline'));
      expect(pending.calls.where((c) => c.startsWith('countdown:')), isEmpty);
    });

    test('a decided session never re-nags the primer (L4)', () async {
      final decidedDenied = FakeNotificationService(granted: false, decided: true);
      final decidedContainer = ProviderContainer(overrides: [
        notificationServiceProvider.overrideWithValue(decidedDenied),
      ]);
      addTearDown(decidedContainer.dispose);

      decidedContainer.read(restTimerControllerProvider.notifier).start();
      await Future<void>.delayed(Duration.zero);

      final s = decidedContainer.read(restTimerControllerProvider);
      expect(s.isRunning, isTrue);
      expect(s.needsPermissionPrimer, isFalse);
      expect(decidedDenied.calls.where((c) => c.startsWith('countdown:')),
          isEmpty);
    });
  });

  group('RestTimerBar widget', () {
    testWidgets('renders remaining time and adjusts with +/-15s and skip',
        (tester) async {
      var fakeNow = DateTime(2026, 8, 31, 10, 0, 0);
      container
          .read(restTimerControllerProvider.notifier)
          .clock = () => fakeNow;
      container.read(restTimerControllerProvider.notifier).start(seconds: 90);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [RestTimerBar()],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('REST TIMER:'), findsOneWidget);
      expect(find.text('01:30'), findsOneWidget);

      await tester.tap(find.text('+15s'));
      await tester.pumpAndSettle();
      expect(find.text('01:45'), findsOneWidget);

      await tester.tap(find.text('-15s'));
      await tester.pumpAndSettle();
      expect(find.text('01:30'), findsOneWidget);

      await tester.tap(find.byTooltip('Skip rest'));
      await tester.pumpAndSettle();
      expect(container.read(restTimerControllerProvider).isRunning, isFalse);
      expect(notifications.calls, contains('cancelNotification'));
    });
  });
}
