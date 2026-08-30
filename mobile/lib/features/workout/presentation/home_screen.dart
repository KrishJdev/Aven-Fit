import 'package:aven_fit/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Root shell hosting the four main tabs (FEATURES.md §7): pitch-black
/// bar, white active tint, glass border top.
class MainShell extends StatelessWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppTheme.oledBlack,
          border: Border(top: BorderSide(color: AppTheme.glassBorder)),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          destinations: const [
            NavigationDestination(icon: Icon(LucideIcons.home), label: 'Home'),
            NavigationDestination(icon: Icon(LucideIcons.dumbbell), label: 'Workouts'),
            NavigationDestination(icon: Icon(LucideIcons.chartColumn), label: 'Progress'),
            NavigationDestination(icon: Icon(LucideIcons.salad), label: 'Nutrition'),
          ],
        ),
      ),
    );
  }
}

/// Slice-1 placeholder for the Home tab. Real Home lands with its
/// owning slice; the shell proves theme + router + DI wiring end to end.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.oledBlack,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'AVEN FIT',
                style: AppTheme.num(28, weight: FontWeight.w600, color: AppTheme.neonCyan),
              ),
              const SizedBox(height: 8),
              const Text('Foundation online — offline-first.', style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {},
                child: const Text('START NEW SESSION'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
