import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:workmanager/workmanager.dart';

import 'core/database/app_database.dart';
import 'core/router/app_router.dart';
import 'core/sync/workmanager_dispatcher.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

/// Provider so features resolve [AppDatabase] via DI — no globals, and
/// tests can override it with an in-memory instance.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

Future<void> main() async {
  // Required before plugin channels (Sentry, Workmanager) are touched
  // prior to runApp.
  WidgetsFlutterBinding.ensureInitialized();

  await SentryFlutter.init(
    (options) {
      // Placeholder DSN — swap for the real project DSN when the Sentry
      // org is provisioned. An invalid DSN disables network sending while
      // keeping the SDK wired, so local/dev builds stay clean.
      options.dsn = const String.fromEnvironment(
        'AVENFIT_SENTRY_DSN',
        defaultValue: 'https://placeholder@sentry.avenfit.app/0',
      );
      options.environment = const String.fromEnvironment(
        'AVENFIT_ENV',
        defaultValue: 'development',
      );
      // Distributed tracing for the offline-first critical paths
      // (cold start, set logging, sync drain).
      options.tracesSampleRate = 1.0;
      options.sendDefaultPii = false;
    },
    // App run is wrapped so crashes during startup itself are captured.
    appRunner: () => runApp(const ProviderScope(child: AvenFitApp())),
  );

  // Registers the top-level dispatcher's callback handle with the
  // platform — Android resolves it from SharedPreferences when the OS
  // wakes a background task (must precede any task registration).
  await Workmanager().initialize(workmanagerDispatcher);

  // Scheduled periodic drain for the sync queue (Slice 5 replaces the
  // no-op handler with real queue draining; cadence honors L8 — no CPU
  // polling, network-constrained execution with exponential backoff).
  await Workmanager().registerPeriodicTask(
    'com.avenfit.aven_fit.sync.periodic',
    WorkmanagerTasks.syncQueueDrain,
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    backoffPolicy: BackoffPolicy.exponential,
  );
}

class AvenFitApp extends ConsumerWidget {
  const AvenFitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Aven Fit',
      theme: AppTheme.dark,
      // §15 localization-ready: gen-l10n delegates installed; the English
      // template arb is the single source for every UI string.
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
    );
  }
}
