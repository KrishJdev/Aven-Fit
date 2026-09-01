import 'package:aven_fit/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Placeholder for the "Nutrition" tab. The full dashboard lands with
/// WU-4.5; food database search (WU-4.4) is reachable from here meanwhile.
class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.oledBlack,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'NUTRITION',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              key: const ValueKey('nutrition_open_foods'),
              onPressed: () => context.push('/foods'),
              child: const Text(
                'FOOD DATABASE',
                style: TextStyle(color: AppTheme.neonCyan, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
