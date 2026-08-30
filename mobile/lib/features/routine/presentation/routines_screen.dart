import 'package:aven_fit/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Slice-1 placeholder for the "Workouts" tab (routines list lands in
/// Slice 2).
class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('ROUTINES', style: TextStyle(color: AppTheme.textSecondary)),
      ),
    );
  }
}
