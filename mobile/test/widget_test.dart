import 'package:aven_fit/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots into the main shell with a Home tab', (tester) async {
    await tester.pumpWidget(const AvenFitApp());

    // Settle pending navigation (GoRouter) micro-tasks only — no
    // indefinite timers are expected at this stage.
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('START NEW SESSION'), findsOneWidget);
  });
}
