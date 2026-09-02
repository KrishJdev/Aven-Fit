import 'package:aven_fit/core/database/app_database.dart';
import 'package:aven_fit/main.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots into the main shell with a Home tab', (tester) async {
    // UncontrolledProviderScope with a container intentionally not disposed
    // inside the fake-async test body (project pattern): the Home resume
    // banner's drift stream must not be cancelled mid-test, or its cleanup
    // timer trips the pending-timer invariant. In-memory SQLite keeps the
    // shell smoke test hermetic — no platform database is ever opened.
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(
        AppDatabase(NativeDatabase.memory()),
      ),
    ]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const AvenFitApp(),
      ),
    );

    // Settle pending navigation (GoRouter) micro-tasks only — no
    // indefinite timers are expected at this stage.
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    // Fresh in-memory DB → the §5.1 first-run CTA.
    expect(find.text('START FIRST WORKOUT'), findsOneWidget);
  });
}
