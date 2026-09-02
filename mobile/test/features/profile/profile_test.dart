import 'dart:async';

import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/core/theme/app_theme.dart';
import 'package:aven_fit/features/auth/data/auth_repository.dart';
import 'package:aven_fit/features/auth/domain/auth_state.dart';
import 'package:aven_fit/features/history/data/history_repository.dart';
import 'package:aven_fit/features/history/domain/lifetime_stats.dart';
import 'package:aven_fit/features/profile/presentation/profile_controller.dart';
import 'package:aven_fit/features/profile/presentation/profile_screen.dart';
import 'package:aven_fit/features/progress/data/pr_repository.dart';
import 'package:aven_fit/features/progress/data/streak_repository.dart';
import 'package:aven_fit/features/progress/domain/streak_info.dart';
import 'package:aven_fit/features/workout/data/workout_repository.dart';
import 'package:aven_fit/features/workout/presentation/home_screen.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Hand-written recording fake (the auth-screens harness pattern): the
/// profile flows are tested against the real repository contract with a
/// live broadcast stream for transitions — never mocks of layers below.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    AuthState initial = const AuthState.guest(clientUuid: 'guest-uuid-1'),
  }) : currentUser = initial;

  final _controller = StreamController<AuthState>.broadcast();
  AuthState currentUser;
  int logoutCalls = 0;

  /// Pushes a transition through the live stream (sign-in/out flows).
  void emit(AuthState state) {
    currentUser = state;
    _controller.add(state);
  }

  void close() => _controller.close();

  @override
  Stream<AuthState> watchAuthState() async* {
    yield currentUser;
    yield* _controller.stream;
  }

  @override
  Future<AuthState> logout() async {
    logoutCalls++;
    final guest = const AuthState.guest(clientUuid: 'guest-uuid-1');
    emit(guest);
    return guest;
  }

  @override
  Future<AuthState> continueAsGuest() async => currentUser;

  @override
  Future<AuthState> currentAuthState() async => currentUser;

  @override
  Future<bool> isGuest() async => currentUser is AuthGuest;

  @override
  Future<AuthState> loginWithGoogle(String idToken) async => currentUser;

  @override
  Future<AuthState> loginWithOtp(String phoneNumber, String otp) async =>
      currentUser;

  @override
  Future<int> requestOtp(String phoneNumber) async => 300;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LifetimeStats domain (WU-5.3)', () {
    test('defaults render honest zero facts and "—" member since', () {
      const stats = LifetimeStats();
      expect(stats.workoutCount, 0);
      expect(stats.completedSetCount, 0);
      expect(stats.totalVolumeKg, 0.0);
      expect(stats.firstSessionAt, isNull);
      expect(stats.memberSinceDisplay, '—');
    });

    test('volume display trims trailing .0; member since formats month/year',
        () {
      const whole = LifetimeStats(totalVolumeKg: 1135.0);
      expect(whole.volumeDisplay, '1135');
      const fractional = LifetimeStats(totalVolumeKg: 82.5);
      expect(fractional.volumeDisplay, '82.5');
      final since = LifetimeStats(firstSessionAt: DateTime(2026, 8, 1));
      expect(since.memberSinceDisplay, 'Aug 2026');
    });
  });

  group('LifetimeStats DAO/Repository (WU-5.3)', () {
    late AppDatabase db;
    late HistoryRepository historyRepo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      historyRepo = HistoryRepositoryImpl(
        db.historyDao,
        WorkoutRepositoryImpl(db.workoutDao),
        PRRepositoryImpl(db.prDao),
      );
    });

    tearDown(() async {
      await db.close();
    });

    Future<void> seedExercise(String id, String name) async {
      await db.into(db.exercises).insert(
            ExercisesCompanion(
              id: drift.Value(id),
              name: drift.Value(name),
            ),
          );
    }

    /// Seeds one session with its exercise block and sets (raw rows for
    /// deterministic startedAt/status control — the repo path stamps
    /// startedAt with now).
    Future<void> seedSessionWithSets(
      String id, {
      required String status,
      required DateTime startedAt,
      DateTime? completedAt,
      required List<
          ({
            double weightKg,
            int reps,
            bool completed,
            String type,
          })> sets,
    }) async {
      await db.into(db.workoutSessions).insert(
            WorkoutSessionsCompanion.insert(
              id: id,
              startedAt: startedAt,
              completedAt: drift.Value(completedAt),
              status: drift.Value(status),
              createdAt: drift.Value(startedAt),
              updatedAt: drift.Value(startedAt),
            ),
          );
      await db.into(db.sessionExercises).insert(
            SessionExercisesCompanion.insert(
              id: 'se_$id',
              sessionId: id,
              exerciseId: 'ex_1',
            ),
          );
      for (var i = 0; i < sets.length; i++) {
        final set = sets[i];
        await db.into(db.workoutSets).insert(
              WorkoutSetsCompanion.insert(
                id: 'set_${id}_$i',
                sessionId: id,
                sessionExerciseId: 'se_$id',
                setNumber: i + 1,
                weightKg: drift.Value(set.weightKg),
                reps: drift.Value(set.reps),
                isCompleted: drift.Value(set.completed),
                setType: drift.Value(set.type),
              ),
            );
      }
    }

    test('empty history yields zeros and no member-since anchor', () async {
      final stats = await historyRepo.watchLifetimeStats().first;
      expect(stats.workoutCount, 0);
      expect(stats.completedSetCount, 0);
      expect(stats.totalVolumeKg, 0.0);
      expect(stats.firstSessionAt, isNull);
      expect(stats.memberSinceDisplay, '—');
    });

    test('aggregates completed workouts: warm-up excluded from volume, '
        'planned sets excluded, discarded excluded from member since',
        () async {
      await seedExercise('ex_1', 'Barbell Bench Press');

      // Aug 1: 3 confirmed sets (1 warm-up) + 1 planned set.
      await seedSessionWithSets(
        'w1',
        status: 'completed',
        startedAt: DateTime(2026, 8, 1, 10),
        completedAt: DateTime(2026, 8, 1, 10, 30),
        sets: const [
          (weightKg: 20, reps: 10, completed: true, type: 'warmup'),
          (weightKg: 40, reps: 8, completed: true, type: 'normal'),
          (weightKg: 50, reps: 6, completed: true, type: 'normal'),
          (weightKg: 60, reps: 5, completed: false, type: 'normal'),
        ],
      );
      // Aug 3: 1 confirmed set.
      await seedSessionWithSets(
        'w2',
        status: 'completed',
        startedAt: DateTime(2026, 8, 3, 9),
        completedAt: DateTime(2026, 8, 3, 9, 45),
        sets: const [
          (weightKg: 80, reps: 8, completed: true, type: 'normal'),
        ],
      );
      // Active session counts toward member-since only.
      await seedSessionWithSets(
        'live',
        status: 'active',
        startedAt: DateTime(2026, 8, 5, 18),
        sets: const [
          (weightKg: 100, reps: 3, completed: false, type: 'normal'),
        ],
      );
      // A long-discarded accidental start is NOT the training anchor.
      await seedSessionWithSets(
        'gone',
        status: 'discarded',
        startedAt: DateTime(2025, 1, 1, 7),
        sets: const [],
      );

      final stats = await historyRepo.watchLifetimeStats().first;

      expect(stats.workoutCount, 2);
      // Confirmed sets only: warm-up + 2 working + 1 = 4.
      expect(stats.completedSetCount, 4);
      // Working volume (L1): 40×8 + 50×6 + 80×8 = 1260 (warm-up excluded).
      expect(stats.totalVolumeKg, 1260.0);
      expect(stats.firstSessionAt, DateTime(2026, 8, 1, 10));
      expect(stats.memberSinceDisplay, 'Aug 2026');
    });

    test('stream re-emits when history grows and self-heals on edits',
        () async {
      final emissions = <LifetimeStats>[];
      final sub = historyRepo.watchLifetimeStats().listen(emissions.add);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      final initialCount = emissions.length;
      expect(initialCount, greaterThanOrEqualTo(1));
      expect(emissions.last.workoutCount, 0);

      await seedExercise('ex_1', 'Barbell Bench Press');
      await seedSessionWithSets(
        'w1',
        status: 'completed',
        startedAt: DateTime(2026, 8, 1, 10),
        completedAt: DateTime(2026, 8, 1, 10, 30),
        sets: const [
          (weightKg: 100, reps: 5, completed: true, type: 'normal'),
        ],
      );
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(emissions.length, greaterThan(initialCount));
      expect(emissions.last.workoutCount, 1);
      expect(emissions.last.completedSetCount, 1);
      expect(emissions.last.totalVolumeKg, 500.0);

      // Un-confirming the set self-heals the aggregate (derived state,
      // never stored — L7/L8).
      await (db.update(db.workoutSets)
            ..where((t) => t.sessionId.equals('w1')))
          .write(WorkoutSetsCompanion(isCompleted: drift.Value(false)));
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(emissions.last.completedSetCount, 0);
      expect(emissions.last.totalVolumeKg, 0.0);

      await sub.cancel();
    });
  });

  group('ProfileController (WU-5.3)', () {
    late _FakeAuthRepository repo;

    setUp(() {
      repo = _FakeAuthRepository();
    });

    ProviderContainer buildContainer(LifetimeStats stats) {
      return ProviderContainer(overrides: [
        authRepositoryProvider.overrideWith((ref) => repo),
        watchAuthStateProvider.overrideWith((ref) => repo.watchAuthState()),
        watchLifetimeStatsProvider.overrideWith((ref) => Stream.value(stats)),
      ]);
    }

    test('composes the guest identity with lifetime stats', () async {
      final container = buildContainer(
        const LifetimeStats(workoutCount: 7, totalVolumeKg: 12345.0),
      );
      addTearDown(container.dispose);
      // Keep-alive listener: autoDispose providers die without one while
      // we await the auth stream's replay (WU-5.2 lesson).
      final sub = container.listen(profileControllerProvider, (_, _) {});
      addTearDown(sub.close);

      // The auth stream emits on a microtask — let it land, then read.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final state = container.read(profileControllerProvider);
      expect(state.auth, isA<AuthGuest>());
      expect(state.stats.workoutCount, 7);
    });

    test('authenticated identity surfaces; sign-out delegates and re-emits '
        'Guest through the auth stream', () async {
      repo = _FakeAuthRepository(
        initial: const AuthState.authenticated(
          userId: 'user-1',
          accessToken: 'a',
          refreshToken: 'r',
          displayName: 'Arjun',
          phoneNumber: '+919876543210',
        ),
      );
      final container = buildContainer(const LifetimeStats());
      addTearDown(container.dispose);
      final sub = container.listen(profileControllerProvider, (_, _) {});
      addTearDown(sub.close);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(container.read(profileControllerProvider).auth,
          isA<AuthAuthenticated>());

      await container.read(profileControllerProvider.notifier).signOut();
      expect(repo.logoutCalls, 1);

      // The auth stream re-emitted Guest — the controller followed it.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(container.read(profileControllerProvider).auth,
          isA<AuthGuest>());
    });
  });

  group('ProfileScreen (WU-5.3)', () {
    late _FakeAuthRepository repo;
    late ProviderContainer container;
    var harnessActive = false;

    setUp(() {
      repo = _FakeAuthRepository();
    });

    Widget buildApp({required GoRouter router}) => UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: AppTheme.dark,
            routerConfig: router,
          ),
        );

    GoRouter profileRouter() => GoRouter(
          initialLocation: '/profile',
          routes: [
            GoRoute(
              path: '/profile',
              builder: (_, _) => const ProfileScreen(),
            ),
            GoRoute(
              path: '/auth/login',
              builder: (_, _) => const Scaffold(
                body: Text('LOGIN STUB', key: ValueKey('login_stub')),
              ),
            ),
          ],
        );

    Future<void> pumpProfile(
      WidgetTester tester, {
      LifetimeStats stats = const LifetimeStats(),
      GoRouter? router,
    }) async {
      container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWith((ref) => repo),
        watchAuthStateProvider.overrideWith((ref) => repo.watchAuthState()),
        watchLifetimeStatsProvider.overrideWith((ref) => Stream.value(stats)),
      ]);
      await tester.pumpWidget(buildApp(router: router ?? profileRouter()));
      await tester.pumpAndSettle();
      harnessActive = true;
    }

    /// Unmount → dispose → pump: cancels the stream subscriptions (and
    /// any snackbar timers) before the test body ends.
    Future<void> drainScreen(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
      repo.close();
      await tester.pump(const Duration(milliseconds: 50));
    }

    void profileScreenTest(
      String description,
      Future<void> Function(WidgetTester tester) body,
    ) {
      testWidgets(description, (tester) async {
        try {
          await body(tester);
        } finally {
          if (harnessActive) {
            harnessActive = false;
            await drainScreen(tester);
          }
        }
      });
    }

    profileScreenTest('guest render: local profile banner, sign-in action, '
        'stats grid, no sign-out', (tester) async {
      await pumpProfile(
        tester,
        stats: LifetimeStats(
          workoutCount: 12,
          completedSetCount: 148,
          totalVolumeKg: 31250.0,
          firstSessionAt: DateTime(2026, 6, 15),
        ),
      );

      expect(find.byKey(const ValueKey('profile_identity_card')),
          findsOneWidget);
      expect(find.text('Guest'), findsOneWidget);
      expect(find.byKey(const ValueKey('profile_upgrade_banner')),
          findsOneWidget);
      expect(find.text('LOCAL PROFILE'), findsOneWidget);
      expect(find.byKey(const ValueKey('profile_sign_in_button')),
          findsOneWidget);

      expect(find.byKey(const ValueKey('profile_stat_workouts')),
          findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.byKey(const ValueKey('profile_stat_sets')), findsOneWidget);
      expect(find.text('148'), findsOneWidget);
      expect(find.byKey(const ValueKey('profile_stat_volume')), findsOneWidget);
      expect(find.text('31250'), findsOneWidget);
      expect(find.byKey(const ValueKey('profile_stat_since')), findsOneWidget);
      expect(find.text('Jun 2026'), findsOneWidget);

      expect(find.byKey(const ValueKey('profile_link_settings')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('profile_link_export')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('profile_link_about')), findsOneWidget);
      expect(find.byKey(const ValueKey('profile_sign_out_button')),
          findsNothing);
    });

    profileScreenTest('authenticated render: display name with initial '
        'avatar, no banner, sign-out present', (tester) async {
      repo = _FakeAuthRepository(
        initial: const AuthState.authenticated(
          userId: 'user-1',
          accessToken: 'a',
          refreshToken: 'r',
          displayName: 'Arjun',
          phoneNumber: '+919876543210',
        ),
      );
      await pumpProfile(tester);

      expect(find.text('Arjun'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('Signed in'), findsOneWidget);
      expect(find.byKey(const ValueKey('profile_upgrade_banner')),
          findsNothing);
      expect(find.byKey(const ValueKey('profile_sign_in_button')),
          findsNothing);
      expect(find.byKey(const ValueKey('profile_sign_out_button')),
          findsOneWidget);
    });

    profileScreenTest('SIGN IN navigates to the opt-in login screen (L2)',
        (tester) async {
      await pumpProfile(tester);

      await tester.tap(find.byKey(const ValueKey('profile_sign_in_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('login_stub')), findsOneWidget);
    });

    profileScreenTest('sign-out requires confirmation; cancel keeps the '
        'session (L7)', (tester) async {
      repo = _FakeAuthRepository(
        initial: const AuthState.authenticated(
          userId: 'user-1',
          accessToken: 'a',
          refreshToken: 'r',
        ),
      );
      await pumpProfile(tester);

      await tester.tap(find.byKey(const ValueKey('profile_sign_out_button')));
      await tester.pumpAndSettle();
      expect(find.text('SIGN OUT?'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('profile_sign_out_cancel')));
      await tester.pumpAndSettle();
      expect(find.text('SIGN OUT?'), findsNothing);
      expect(find.byKey(const ValueKey('profile_sign_out_button')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('profile_upgrade_banner')),
          findsNothing);
      expect(repo.logoutCalls, 0);
    });

    profileScreenTest('confirming sign-out delegates to the repository and '
        'flips the screen to the local profile', (tester) async {
      repo = _FakeAuthRepository(
        initial: const AuthState.authenticated(
          userId: 'user-1',
          accessToken: 'a',
          refreshToken: 'r',
        ),
      );
      await pumpProfile(tester);

      await tester.tap(find.byKey(const ValueKey('profile_sign_out_button')));
      await tester.pumpAndSettle();
      await tester
          .tap(find.byKey(const ValueKey('profile_sign_out_confirm')));
      await tester.pumpAndSettle();

      expect(repo.logoutCalls, 1);
      expect(find.byKey(const ValueKey('profile_upgrade_banner')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('profile_sign_out_button')),
          findsNothing);
    });

    profileScreenTest('quick links: placeholders show neutral notices, '
        'About opens the dialog', (tester) async {
      await pumpProfile(tester);

      await tester.tap(find.byKey(const ValueKey('profile_link_settings')));
      await tester.pumpAndSettle();
      expect(find.text('Settings is coming in a future update.'),
          findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('profile_link_export')));
      await tester.pumpAndSettle();
      expect(find.text('Data export is coming in a future update.'),
          findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('profile_link_about')));
      await tester.pumpAndSettle();
      expect(find.text('AVEN FIT'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    });

    profileScreenTest('Home header avatar navigates to Profile (§7.1)',
        (tester) async {
      container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWith((ref) => repo),
        watchAuthStateProvider.overrideWith((ref) => repo.watchAuthState()),
        watchLifetimeStatsProvider
            .overrideWith((ref) => Stream.value(const LifetimeStats())),
        watchActiveSessionProvider.overrideWith((ref) => Stream.value(null)),
        watchStreakInfoProvider.overrideWith(
            (ref) => Stream.value(const StreakInfo())),
      ]);
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, _) => const HomePage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, _) => const ProfileScreen(),
          ),
        ],
      );
      await tester.pumpWidget(buildApp(router: router));
      await tester.pumpAndSettle();
      harnessActive = true;

      expect(
          find.byKey(const ValueKey('home_profile_avatar')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('home_profile_avatar')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('profile_identity_card')),
          findsOneWidget);
    });
  });
}
