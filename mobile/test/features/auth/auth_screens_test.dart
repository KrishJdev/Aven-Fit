import 'dart:async';

import 'package:aven_fit/core/theme/app_theme.dart';
import 'package:aven_fit/features/auth/data/auth_repository.dart';
import 'package:aven_fit/features/auth/domain/auth_state.dart';
import 'package:aven_fit/features/auth/presentation/login_controller.dart';
import 'package:aven_fit/features/auth/presentation/login_screen.dart';
import 'package:aven_fit/features/auth/presentation/login_state.dart';
import 'package:aven_fit/features/auth/presentation/otp_flow_state.dart';
import 'package:aven_fit/features/auth/presentation/otp_verification_controller.dart';
import 'package:aven_fit/features/auth/presentation/otp_verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Hand-written recording fake (WU-5.1 harness pattern) — the screens
/// are tested against their real repository contract, never mocks of
/// layers below it.
class _FakeAuthRepository implements AuthRepository {
  int requestOtpCalls = 0;
  List<String> requestOtpArgs = [];
  int loginCalls = 0;
  List<String> loginArgs = [];
  int guestCalls = 0;
  int googleCalls = 0;
  int logoutCalls = 0;

  int expiresInSeconds = 300;
  AuthException? requestOtpError;
  AuthException? loginError;

  /// When set, loginWithOtp parks on a completer the test releases —
  /// reentrancy-guard probe.
  Completer<AuthState>? pendingCompleter;

  AuthState currentUser = const AuthState.guest(clientUuid: 'guest-uuid-1');

  @override
  Future<int> requestOtp(String phoneNumber) async {
    requestOtpCalls++;
    requestOtpArgs = [phoneNumber];
    final error = requestOtpError;
    if (error != null) {
      throw error;
    }
    return expiresInSeconds;
  }

  @override
  Future<AuthState> loginWithOtp(String phoneNumber, String otp) async {
    loginCalls++;
    loginArgs = [phoneNumber, otp];
    final error = loginError;
    if (error != null) {
      throw error;
    }
    if (pendingCompleter != null) {
      return pendingCompleter!.future;
    }
    return currentUser = AuthState.authenticated(
      userId: 'user-1',
      accessToken: 'a',
      refreshToken: 'r',
    );
  }

  @override
  Future<AuthState> loginWithGoogle(String idToken) async {
    googleCalls++;
    return currentUser;
  }

  @override
  Future<AuthState> continueAsGuest() async {
    guestCalls++;
    return currentUser;
  }

  @override
  Future<AuthState> logout() async {
    logoutCalls++;
    return currentUser = const AuthState.guest(clientUuid: 'guest-uuid-1');
  }

  @override
  Future<bool> isGuest() async => currentUser is AuthGuest;

  @override
  Future<AuthState> currentAuthState() async => currentUser;

  @override
  Stream<AuthState> watchAuthState() => Stream.value(currentUser);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const kOtpTestPhone = '+919876543210';

  late _FakeAuthRepository repo;
  late ProviderContainer container;
  var harnessActive = false;

  setUp(() {
    repo = _FakeAuthRepository();
  });

  /// Pumps the auth harness under an externally-owned container so
  /// tests can reach notifiers (clock injection).
  Future<GoRouter> pumpScreen(WidgetTester tester) async {
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWith((ref) => repo)],
    );
    final router = GoRouter(
      initialLocation: '/auth/login',
      routes: [
        GoRoute(
          path: '/auth/login',
          builder: (_, _) => const LoginScreen(),
        ),
        GoRoute(
          path: '/auth/otp',
          builder: (context, state) {
            final phone = state.uri.queryParameters['phone'] ?? '';
            return OtpVerificationScreen(
              phoneNumber: phone,
              expiresInSeconds: int.tryParse(
                    state.uri.queryParameters['expires'] ?? '',
                  ) ??
                  300,
            );
          },
        ),
        GoRoute(
          path: '/home',
          builder: (_, _) =>
              const Scaffold(body: Text('HOME STUB', key: ValueKey('home_stub'))),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: ThemeData.dark()
              .copyWith(scaffoldBackgroundColor: AppTheme.oledBlack),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    harnessActive = true;
    return router;
  }

  /// Unmount → dispose → pump: cancels the tick timer and any
  /// subscription before the test body ends.
  Future<void> drainScreen(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    await tester.pump(const Duration(milliseconds: 50));
  }

  OtpVerificationController otpNotifierOf(ProviderContainer c) => c.read(
        otpVerificationControllerProvider(
          phoneNumber: kOtpTestPhone,
          expiresInSeconds: 300,
        ).notifier,
      );

  ProviderSubscription<OtpFlowState> keepOtpAlive(ProviderContainer c) =>
      c.listen(
        otpVerificationControllerProvider(
          phoneNumber: kOtpTestPhone,
          expiresInSeconds: 300,
        ),
        (_, _) {},
      );

  /// Widget-test wrapper: drains the harness in a `finally` INSIDE the
  /// test body — flutter_test checks the pending-timer invariant before
  /// any addTearDown runs (probed empirically), so the controller's 1s
  /// tick must be cancelled here, not in a teardown.
  void authScreenTest(
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

  group('LoginController (WU-5.2)', () {
    late ProviderContainer container;
    late ProviderSubscription<LoginState> sub;

    setUp(() {
      container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWith((ref) => repo)],
      );
      sub = container.listen(loginControllerProvider, (_, _) {});
    });

    tearDown(() {
      sub.close();
      container.dispose();
    });

    LoginController notifier() =>
        container.read(loginControllerProvider.notifier);

    test('setPhone keeps digits only and caps at 15', () {
      notifier().setPhone('98-76 (5432) 10');
      expect(container.read(loginControllerProvider).phone, '9876543210');

      notifier().setPhone('12345678901234567890');
      expect(
        container.read(loginControllerProvider).phone,
        '123456789012345',
      );
    });

    test('empty phone surfaces an inline error and never calls out (L6)',
        () async {
      final result = await notifier().sendOtp();

      expect(result, isNull);
      expect(
        container.read(loginControllerProvider).inlineError,
        'Enter your phone number.',
      );
      expect(repo.requestOtpCalls, 0);
    });

    test('a 9-digit Indian number never navigates (§6.1)', () async {
      notifier().setPhone('987654321');
      final result = await notifier().sendOtp();

      expect(result, isNull);
      expect(
        container.read(loginControllerProvider).inlineError,
        'Indian numbers are exactly 10 digits.',
      );
      expect(repo.requestOtpCalls, 0);
    });

    test('a valid Indian number returns the full phone + backend expiry',
        () async {
      repo.expiresInSeconds = 120;
      notifier().setPhone('98765 43210');

      final result = await notifier().sendOtp();

      expect(result, isNotNull);
      expect(result!.phoneNumber, '+919876543210');
      expect(result.expiresInSeconds, 120);
      expect(repo.requestOtpArgs.single, '+919876543210');
      expect(container.read(loginControllerProvider).sendingOtp, isFalse);
    });

    test('other country codes accept 10–15 digits (NRI, §6.1)', () async {
      final notifier = container.read(loginControllerProvider.notifier);
      notifier.setCountryCode('+1');
      notifier.setPhone('1234567890');

      final result = await notifier.sendOtp();

      expect(result!.phoneNumber, '+11234567890');
    });

    test('a backend failure surfaces its message with the retry state',
        () async {
      repo.requestOtpError =
          const AuthException('Server unreachable', statusCode: 500);
      container.read(loginControllerProvider.notifier).setPhone('9876543210');

      final result =
          await container.read(loginControllerProvider.notifier).sendOtp();

      expect(result, isNull);
      expect(
        container.read(loginControllerProvider).sendError,
        'Server unreachable',
      );
    });

    test('Google surfaces the designed setup notice (deferred SDK)',
        () async {
      container.read(loginControllerProvider.notifier).signInWithGoogle();

      expect(
        container.read(loginControllerProvider).infoMessage,
        kGoogleSignInSetupMessage,
      );
      expect(repo.googleCalls, 0);
    });

    test('continueAsGuest delegates to the repository (L2)', () async {
      await container.read(loginControllerProvider.notifier).continueAsGuest();
      expect(repo.guestCalls, 1);
    });
  });

  group('OtpVerificationController (WU-5.2)', () {
    late ProviderContainer container;
    late ProviderSubscription<OtpFlowState> sub;
    // Anchored to real time so the build-time deadlines (baked with the
    // default clock) and the injected fake stay in one coherent frame.
    var fakeNow = DateTime.now();

    setUp(() {
      // Per-test anchor: tests advance [fakeNow] and must not leak that
      // into each other's cooldown/expiry math.
      fakeNow = DateTime.now();
      container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWith((ref) => repo)],
      );
      final provider = otpVerificationControllerProvider(
        phoneNumber: '+919876543210',
        expiresInSeconds: 300,
      );
      sub = container.listen(provider, (_, _) {});
      // Injectable clock (rest-timer pattern): deterministic deadlines.
      container.read(provider.notifier).clock = () => fakeNow;
    });

    tearDown(() {
      sub.close();
      container.dispose();
    });

    OtpFlowState state() => container.read(
          otpVerificationControllerProvider(
            phoneNumber: '+919876543210',
            expiresInSeconds: 300,
          ),
        );

    test('boots with the phone, a 30s resend cooldown, and the expiry',
        () {
      final s = state();
      expect(s.phoneNumber, '+919876543210');
      expect(s.status, OtpStatus.idle);
      expect(s.resendInSeconds, inInclusiveRange(29, 30));
      expect(s.canResend, isFalse);
      expect(s.expiresDisplay, '5:00');
    });

    test('otpChanged keeps digits only, caps at 6, and resets errors',
        () {
      final notifier = otpNotifierOf(container);
      notifier.otpChanged('a1b2c3d4e5f6g7');
      expect(state().otp, '123456');

      notifier.otpChanged('9');
      expect(state().otp, '9');
      expect(state().status, OtpStatus.idle);
      expect(state().errorMessage, isNull);
    });

    test('verify() with an incomplete code never calls the backend',
        () async {
      otpNotifierOf(container).otpChanged('123');

      await otpNotifierOf(container).verify();

      expect(repo.loginCalls, 0);
      expect(state().status, OtpStatus.idle);
    });

    test('verify() sends phone + code and lands on success', () async {
      otpNotifierOf(container).otpChanged('123456');

      final result = await otpNotifierOf(container).verify();

      expect(repo.loginCalls, 1);
      expect(repo.loginArgs, ['+919876543210', '123456']);
      expect(result.status, OtpStatus.success);
      expect(state().status, OtpStatus.success);
    });

    test('an invalid code shakes into the designed invalid state (L6)',
        () async {
      repo.loginError = const AuthException('Invalid OTP', statusCode: 401);
      otpNotifierOf(container).otpChanged('111111');

      final result = await otpNotifierOf(container).verify();

      expect(result.status, OtpStatus.invalid);
      expect(result.otp, isEmpty); // cells cleared for the retyping
      expect(result.errorMessage, 'Invalid OTP');
    });

    test('auto-submit fires exactly once — in-flight calls re-enter '
        'nothing (§6.2)', () async {
      repo.pendingCompleter = Completer<AuthState>();
      otpNotifierOf(container).otpChanged('654321');

      final first = otpNotifierOf(container).verify();
      await otpNotifierOf(container).verify(); // must be rejected, not queued
      expect(repo.loginCalls, 1);

      // Release the parked request; no second call ever fired.
      repo.pendingCompleter!.complete(
        AuthState.authenticated(
          userId: 'user-1',
          accessToken: 'a',
          refreshToken: 'r',
        ),
      );
      await first;
      expect(repo.loginCalls, 1);
      expect(state().status, OtpStatus.success);
    });

    test('a rejection past the validity window reads as expired (§6.2)',
        () async {
      repo.loginError = const AuthException('Invalid OTP', statusCode: 401);
      otpNotifierOf(container).otpChanged('000000');

      fakeNow = fakeNow.add(const Duration(seconds: 301));
      final result = await otpNotifierOf(container).verify();

      expect(result.status, OtpStatus.expired);
      expect(result.errorMessage, 'Invalid OTP');
    });

    test('resend is blocked while the 30s cooldown runs (§6.2)', () async {
      await otpNotifierOf(container).resend();
      expect(repo.requestOtpCalls, 0);
    });

    test('resend after the cooldown requests a fresh window', () async {
      fakeNow = fakeNow.add(const Duration(seconds: 31));
      repo.expiresInSeconds = 120;

      await otpNotifierOf(container).resend();

      expect(repo.requestOtpCalls, 1);
      expect(repo.requestOtpArgs.single, '+919876543210');
      expect(state().status, OtpStatus.idle);
      expect(state().otp, isEmpty);
      expect(state().expiresDisplay, '2:00');
      // The cooldown restarted from the resend moment.
      expect(state().canResend, isFalse);
    });

    test('a failed resend surfaces its message', () async {
      fakeNow = fakeNow.add(const Duration(seconds: 31));
      repo.requestOtpError = const AuthException('Offline', statusCode: 0);

      await otpNotifierOf(container).resend();

      expect(state().errorMessage, 'Offline');
    });
  });

  group('LoginScreen (WU-5.2)', () {
    authScreenTest('renders the wordmark, inputs, and every exit (§6.1)',
        (tester) async {
      await pumpScreen(tester);

      expect(find.text('AVEN FIT'), findsOneWidget);
      expect(find.byKey(const ValueKey('country_code_selector')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('phone_field')), findsOneWidget);
      expect(find.byKey(const ValueKey('send_otp_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('google_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('guest_button')), findsOneWidget);
      expect(find.textContaining('Privacy Policy'), findsOneWidget);
    });

    authScreenTest('an invalid phone shows the inline error and stays put '
        '(§6.1/L6)', (tester) async {
      await pumpScreen(tester);

      await tester.enterText(find.byKey(const ValueKey('phone_field')),
          '98765432');
      await tester.tap(find.byKey(const ValueKey('send_otp_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('phone_inline_error')), findsOneWidget);
      expect(find.text('Indian numbers are exactly 10 digits.'),
          findsOneWidget);
      expect(repo.requestOtpCalls, 0);
      // Still on the login screen — invalid input never navigates.
      expect(find.byKey(const ValueKey('send_otp_button')), findsOneWidget);
    });

    authScreenTest('a valid phone requests the OTP and carries the flow '
        'forward', (tester) async {
      await pumpScreen(tester);

      await tester.enterText(
          find.byKey(const ValueKey('phone_field')), '98765 43210');
      await tester.tap(find.byKey(const ValueKey('send_otp_button')));
      await tester.pumpAndSettle();

      expect(repo.requestOtpArgs.single, '+919876543210');
      // The OTP screen renders (real route, parsed from the query).
      expect(find.text('+919876543210'), findsOneWidget);
    });

    authScreenTest('Continue as guest bypasses the network flow to Home (L2)',
        (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byKey(const ValueKey('guest_button')));
      await tester.pumpAndSettle();

      expect(repo.guestCalls, 1);
      expect(find.byKey(const ValueKey('home_stub')), findsOneWidget);
    });

    authScreenTest('Google surfaces the designed setup notice, not a dead '
        'button (L6)', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byKey(const ValueKey('google_button')));
      await tester.pumpAndSettle();

      expect(find.text(kGoogleSignInSetupMessage), findsOneWidget);
    });

    authScreenTest('a backend failure shows the error banner with RETRY',
        (tester) async {
      repo.requestOtpError =
          const AuthException('Server unreachable', statusCode: 500);
      await pumpScreen(tester);

      await tester.enterText(
          find.byKey(const ValueKey('phone_field')), '9876543210');
      await tester.tap(find.byKey(const ValueKey('send_otp_button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('send_error_banner')),
        findsOneWidget,
      );
      expect(find.text('Server unreachable'), findsOneWidget);

      // Retry path re-requests once the error is cleared.
      repo.requestOtpError = null;
      await tester.tap(find.byKey(const ValueKey('retry_send')));
      await tester.pumpAndSettle();
      expect(find.text('+919876543210'), findsOneWidget);
    });
  });

  group('OtpVerificationScreen (WU-5.2)', () {
    authScreenTest('renders the number, cells, cooldown, and expiry',
        (tester) async {
      await pumpScreen(tester);
      keepOtpAlive(container);

      await tester.enterText(
          find.byKey(const ValueKey('phone_field')), '9876543210');
      await tester.tap(find.byKey(const ValueKey('send_otp_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('otp_phone_display')), findsOneWidget);
      expect(find.byKey(const ValueKey('otp_cell_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('otp_cell_5')), findsOneWidget);
      expect(find.textContaining('RESEND CODE IN'), findsOneWidget);
      expect(find.text('Code expires in 5:00'), findsOneWidget);

      // VERIFY is disabled until the code is complete (§6.2).
      final button = tester.widget<ElevatedButton>(
        find.byKey(const ValueKey('otp_verify_button')),
      );
      expect(button.onPressed, isNull);
    });

    authScreenTest('auto-submit fires exactly once on the fill and navigates '
        'Home on success (§6.2)', (tester) async {
      await pumpScreen(tester);

      await tester.enterText(
          find.byKey(const ValueKey('phone_field')), '9876543210');
      await tester.tap(find.byKey(const ValueKey('send_otp_button')));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const ValueKey('otp_hidden_field')), '123456');
      await tester.pumpAndSettle();

      expect(repo.loginCalls, 1);
      expect(repo.loginArgs, ['+919876543210', '123456']);
      expect(find.byKey(const ValueKey('home_stub')), findsOneWidget);
    });

    authScreenTest('an invalid code shows the error and clears the cells '
        '(§6.2)', (tester) async {
      repo.loginError = const AuthException('Invalid OTP', statusCode: 401);
      await pumpScreen(tester);
      keepOtpAlive(container);

      await tester.enterText(
          find.byKey(const ValueKey('phone_field')), '9876543210');
      await tester.tap(find.byKey(const ValueKey('send_otp_button')));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const ValueKey('otp_hidden_field')), '111111');
      await tester.pumpAndSettle();

      expect(find.text('Invalid OTP'), findsOneWidget);
      // Cells cleared for the retyping; VERIFY disabled again.
      final provider = otpVerificationControllerProvider(
        phoneNumber: '+919876543210',
        expiresInSeconds: 300,
      );
      expect(container.read(provider).otp, isEmpty);
      final button = tester.widget<ElevatedButton>(
        find.byKey(const ValueKey('otp_verify_button')),
      );
      expect(button.onPressed, isNull);
    });

    authScreenTest('Change number pops back to the login screen (§6.2)',
        (tester) async {
      await pumpScreen(tester);

      await tester.enterText(
          find.byKey(const ValueKey('phone_field')), '9876543210');
      await tester.tap(find.byKey(const ValueKey('send_otp_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('change_number')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('phone_field')), findsOneWidget);
    });

    authScreenTest('resend unlocks after the cooldown and refreshes the '
        'window (§6.2)', (tester) async {
      // Anchored to real time: the provider is created by the login
      // flow with the default clock, then the fake takes over — one
      // coherent timeline throughout.
      var fakeNow = DateTime.now();
      await pumpScreen(tester);

      await tester.enterText(
          find.byKey(const ValueKey('phone_field')), '9876543210');
      await tester.tap(find.byKey(const ValueKey('send_otp_button')));
      await tester.pumpAndSettle();

      // The OTP provider is alive (the screen listens) — inject now.
      keepOtpAlive(container);
      otpNotifierOf(container).clock = () => fakeNow;

      // Still cooling down — the tap is rejected (the login flow's own
      // requestOtp already counts, so compare against that baseline).
      final baseline = repo.requestOtpCalls;
      expect(find.textContaining('RESEND CODE IN'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('otp_resend')));
      await tester.pumpAndSettle();
      expect(repo.requestOtpCalls, baseline);

      // Advance past the cooldown, tick once, resend unlocks.
      fakeNow = fakeNow.add(const Duration(seconds: 31));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      repo.expiresInSeconds = 120;
      await tester.tap(find.byKey(const ValueKey('otp_resend')));
      await tester.pumpAndSettle();

      expect(repo.requestOtpCalls, baseline + 1);
      expect(find.text('Code expires in 2:00'), findsOneWidget);
    });
  });
}
