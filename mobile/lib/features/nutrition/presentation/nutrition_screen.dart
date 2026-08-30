import 'package:aven_fit/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Slice-1 placeholder for the "Nutrition" tab (dashboard lands in
/// Slice 4).
class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('NUTRITION', style: TextStyle(color: AppTheme.textSecondary)),
      ),
    );
  }
}
