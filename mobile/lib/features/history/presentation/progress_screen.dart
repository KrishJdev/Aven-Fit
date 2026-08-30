import 'package:aven_fit/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Slice-1 placeholder for the "Progress" tab (dashboard lands with the
/// history slices).
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('PROGRESS', style: TextStyle(color: AppTheme.textSecondary)),
      ),
    );
  }
}
