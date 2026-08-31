import 'package:aven_fit/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Slice-1 placeholder for the "Progress" tab. The full dashboard lands
/// with WU-X.3; workout history (WU-3.9) is reachable from here meanwhile.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.oledBlack,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PROGRESS',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              key: const ValueKey('progress_open_history'),
              onPressed: () => context.push('/history'),
              child: const Text(
                'WORKOUT HISTORY',
                style: TextStyle(color: AppTheme.neonCyan, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
