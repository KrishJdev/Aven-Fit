import 'package:aven_fit/features/history/presentation/progress_screen.dart';
import 'package:aven_fit/features/nutrition/presentation/nutrition_screen.dart';
import 'package:aven_fit/features/routine/presentation/routines_screen.dart';
import 'package:aven_fit/features/workout/presentation/active_workout_screen.dart';
import 'package:aven_fit/features/workout/presentation/home_screen.dart';
import 'package:go_router/go_router.dart';

/// Declarative navigation (GoRouter). The shell hosts the four main
/// tabs (FEATURES.md §7); deep links attach here as slices land.
final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/home', builder: (context, state) => const HomePage()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/workouts', builder: (context, state) => const RoutinesScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/progress', builder: (context, state) => const ProgressScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/nutrition', builder: (context, state) => const NutritionScreen()),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/workout/active',
      builder: (context, state) => const ActiveWorkoutScreen(),
    ),
  ],
);
