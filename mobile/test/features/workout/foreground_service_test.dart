import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/core/notifications/notification_service.dart';
import 'package:aven_fit/core/services/workout_foreground_service.dart';
import 'package:aven_fit/features/workout/data/workout_repository.dart';
import 'package:aven_fit/features/workout/domain/workout_set.dart';
import 'package:aven_fit/features/workout/presentation/active_workout_controller.dart';
import 'package:aven_fit/features/workout/presentation/rest_timer_controller.dart';
import 'package:aven_fit/main.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_notification_service.dart';

/// Recording test double — no platform channels are touched.
class FakeWorkoutForegroundService extends WorkoutForegroundService {
  final List<String> calls = [];
  final List<String> startedWith = [];
  final List<Map<String, Object?>> sessionUpdates = [];
  final List<int?> restDeadlines = [];
  int stopCount = 0;

  @override
  Future<void> startSession({
    required String workoutName,
    required int startedAtMs,
    required bool isPaused,
    required int pausedDurationMs,
    required int lastResumedAtMs,
    int? restEndsAtMs,
  }) async {
    calls.add('start');
    startedWith.add(workoutName);
  }

  @override
  Future<void> updateSession({
    String? workoutName,
    int? startedAtMs,
    bool? isPaused,
    int? pausedDurationMs,
    int? lastResumedAtMs,
  }) async {
    calls.add('update');
    sessionUpdates.add({
      'workoutName': ?workoutName,
      'isPaused': ?isPaused,
    });
  }

  @override
  Future<void> updateRest(int? restEndsAtMs) async {
    calls.add('rest');
    restDeadlines.add(restEndsAtMs);
  }

  @override
  Future<void> stop() async {
    calls.add('stop');
    stopCount++;
  }
}

void main() {
  late AppDatabase db;
  late WorkoutRepositoryImpl repo;
  late FakeNotificationService notifications;
  late FakeWorkoutForegroundService foreground;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = WorkoutRepositoryImpl(db.workoutDao);
    notifications = FakeNotificationService();
    foreground = FakeWorkoutForegroundService();
    container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(db),
      notificationServiceProvider.overrideWithValue(notifications),
      workoutForegroundServiceProvider.overrideWithValue(foreground),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<String> seedActiveSession({String name = 'Chest Day'}) async {
    await db.into(db.exercises).insert(
          const ExercisesCompanion(
            id: drift.Value('ex_bench'),
            name: drift.Value('Barbell Bench Press'),
          ),
        );
    final session = await repo.startWorkout(name: name);
    final se = await repo.addExerciseToSession(
      sessionId: session.id,
      exerciseId: 'ex_bench',
    );
    await repo.logSet(WorkoutSet(
      id: '${session.id}_1',
      sessionId: session.id,
      sessionExerciseId: se.id,
      exerciseId: 'ex_bench',
      setNumber: 1,
      weightKg: 80,
      reps: 8,
      isCompleted: true,
    ));
    // Backdate so epoch-math duration assertions have room.
    await (db.update(db.workoutSessions)
          ..where((t) => t.id.equals(session.id)))
        .write(WorkoutSessionsCompanion(
      startedAt: drift.Value(DateTime.now().subtract(const Duration(minutes: 5))),
    ));
    return session.id;
  }

  group('Rest deadline mirroring (WU-3.10)', () {
    test('start/addTime push the live deadline; cancel clears it', () async {
      // Reading the notifier builds the controller and wires the callbacks.
      container.read(restTimerControllerProvider.notifier);

      container.read(restTimerControllerProvider.notifier).start(seconds: 90);
      final startedDeadline = foreground.restDeadlines.single;
      expect(startedDeadline, isNotNull);
      final startedAt = DateTime.fromMillisecondsSinceEpoch(startedDeadline!);
      expect(
        startedAt.isAfter(DateTime.now().add(const Duration(seconds: 88))),
        isTrue,
      );

      foreground.restDeadlines.clear();
      container.read(restTimerControllerProvider.notifier).addTime(15);
      final adjusted = foreground.restDeadlines.single;
      // addTime re-derives the epoch deadline from now + remaining, so the
      // pushed value sits within execution jitter of the original + 15s.
      expect(
        adjusted,
        inInclusiveRange(startedDeadline + 15 * 1000 - 2000, startedDeadline + 15 * 1000 + 2000),
      );

      foreground.restDeadlines.clear();
      container.read(restTimerControllerProvider.notifier).cancel();
      expect(foreground.restDeadlines.single, isNull);
    });

    test('"Finish Workout" from the notification completes the active session',
        () async {
      final sessionId = await seedActiveSession();
      // Build the controller to wire the notification actions.
      container.read(restTimerControllerProvider.notifier);

      foreground.onFinish!();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final row = await (db.select(db.workoutSessions)
            ..where((t) => t.id.equals(sessionId)))
          .getSingle();
      expect(row.status, 'completed');
      expect(row.durationSeconds, isNotNull);
      expect(foreground.stopCount, 1);
      // The countdown was cleared on the notification surface too.
      expect(foreground.restDeadlines.last, isNull);
    });

    test('"Finish Workout" with no active session just stops the service',
        () async {
      container.read(restTimerControllerProvider.notifier);

      foreground.onFinish!();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(foreground.stopCount, 1);
      expect(foreground.calls, isNot(contains('update')));
    });

    test('"+15s" from the notification adjusts the live countdown', () async {
      container.read(restTimerControllerProvider.notifier);
      container.read(restTimerControllerProvider.notifier).start(seconds: 90);

      foreground.onAdd15!();
      final state = container.read(restTimerControllerProvider);
      expect(state.isRunning, isTrue);
      expect(state.remainingSeconds, 105);
    });
  });

  group('Session lifecycle mirroring (WU-3.10)', () {
    test('start pushes the service; pause/resume update it; finish stops it',
        () async {
      final sub = container.listen(activeWorkoutControllerProvider, (_, _) {});
      final controller = container.read(activeWorkoutControllerProvider.notifier);
      await container.read(activeWorkoutControllerProvider.future);

      await controller.startWorkout(name: 'Notification Test');
      expect(foreground.calls, contains('start'));
      expect(foreground.startedWith.last, 'Notification Test');

      await controller.pauseWorkout();
      expect(foreground.sessionUpdates.last['isPaused'], isTrue);

      await controller.resumeWorkout();
      expect(foreground.sessionUpdates.last['isPaused'], isFalse);

      foreground.stopCount = 0;
      await controller.finishWorkout();
      expect(foreground.stopCount, 1);
      sub.close();
    });

    test('discard also stops the service', () async {
      final sub = container.listen(activeWorkoutControllerProvider, (_, _) {});
      final controller = container.read(activeWorkoutControllerProvider.notifier);
      await container.read(activeWorkoutControllerProvider.future);

      await controller.startWorkout(name: 'Discard Test');
      foreground.stopCount = 0;
      await controller.cancelWorkout();
      expect(foreground.stopCount, 1);
      sub.close();
    });

    test('launch-time restore pushes the restored session onto the service',
        () async {
      await seedActiveSession(name: 'Restored Session');

      final sub = container.listen(activeWorkoutControllerProvider, (_, _) {});
      final state = await container.read(activeWorkoutControllerProvider.future);

      expect(state.wasRestored, isTrue);
      expect(foreground.calls, contains('start'));
      expect(foreground.startedWith.last, 'Restored Session');
      sub.close();
    });

    test('rename mirrors the new workout name onto the service', () async {
      final sub = container.listen(activeWorkoutControllerProvider, (_, _) {});
      final controller = container.read(activeWorkoutControllerProvider.notifier);
      await container.read(activeWorkoutControllerProvider.future);

      await controller.startWorkout(name: 'Old Name');
      foreground.sessionUpdates.clear();
      await controller.updateWorkoutName('Pump Day');

      expect(foreground.sessionUpdates.last['workoutName'], 'Pump Day');
      sub.close();
    });
  });

  group('Real bridge platform-channel behavior', () {
    testWidgets(
        'force-supported: sends the clear sentinel for null rest deadlines',
        (tester) async {
      final calls = <MethodCall>[];
      const channel = MethodChannel('com.avenfit.aven_fit/workout_service');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return null;
      });
      addTearDown(() => TestDefaultBinaryMessengerBinding.instance
          .defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null));

      WorkoutForegroundService.debugForceSupported = true;
      addTearDown(() => WorkoutForegroundService.debugForceSupported = false);

      final service = WorkoutForegroundService();
      await service.updateRest(null);
      await service.stop();

      expect(calls.map((c) => c.method), ['updateRest', 'stop']);
      // Null deadline → explicit -1 sentinel (native REST_CLEAR_SENTINEL).
      expect(calls.first.arguments, {'restEndsAtMs': -1});
    });

    testWidgets('unsupported platform (test host): no channel traffic at all',
        (tester) async {
      final calls = <MethodCall>[];
      const channel = MethodChannel('com.avenfit.aven_fit/workout_service');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return null;
      });
      addTearDown(() => TestDefaultBinaryMessengerBinding.instance
          .defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null));

      final service = WorkoutForegroundService();
      await service.updateRest(null);
      await service.stop();
      await service.startSession(
        workoutName: 'X',
        startedAtMs: 1,
        isPaused: false,
        pausedDurationMs: 0,
        lastResumedAtMs: 0,
      );

      // The desktop test host is not Android: the gate short-circuits and
      // nothing ever reaches the platform (no dangling replies, no hang).
      expect(calls, isEmpty);
    });
  });
}
