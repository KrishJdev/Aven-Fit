import 'package:aven_fit/features/auth/presentation/login_screen.dart';
import 'package:aven_fit/features/auth/presentation/login_state.dart';
import 'package:aven_fit/features/auth/presentation/otp_verification_screen.dart';
import 'package:aven_fit/features/exercise/presentation/create_custom_exercise_screen.dart';
import 'package:aven_fit/features/exercise/presentation/exercise_detail_screen.dart';
import 'package:aven_fit/features/exercise/presentation/exercise_list_screen.dart';
import 'package:aven_fit/features/history/presentation/history_list_screen.dart';
import 'package:aven_fit/features/history/presentation/progress_screen.dart';
import 'package:aven_fit/features/history/presentation/workout_detail_screen.dart';
import 'package:aven_fit/features/nutrition/presentation/food_detail_screen.dart';
import 'package:aven_fit/features/nutrition/presentation/food_search_screen.dart';
import 'package:aven_fit/features/nutrition/presentation/nutrition_screen.dart';
import 'package:aven_fit/features/routine/presentation/routine_detail_screen.dart';
import 'package:aven_fit/features/routine/presentation/routine_editor_screen.dart';
import 'package:aven_fit/features/routine/presentation/routines_screen.dart';
import 'package:aven_fit/features/workout/presentation/active_workout_screen.dart';
import 'package:aven_fit/features/workout/presentation/exercise_picker_screen.dart';
import 'package:aven_fit/features/workout/presentation/home_screen.dart';
import 'package:aven_fit/features/workout/presentation/workout_summary_screen.dart';
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
    GoRoute(
      path: '/workout/summary/:id',
      builder: (context, state) => WorkoutSummaryScreen(
        sessionId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryListScreen(),
    ),
    GoRoute(
      path: '/history/:id',
      builder: (context, state) => WorkoutDetailScreen(
        sessionId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/workout/picker',
      builder: (context, state) => const ExercisePickerScreen(),
    ),
    GoRoute(
      path: '/exercises',
      builder: (context, state) => const ExerciseListScreen(),
    ),
    GoRoute(
      path: '/exercises/new',
      builder: (context, state) => const CreateCustomExerciseScreen(),
    ),
    GoRoute(
      path: '/exercises/:id',
      builder: (context, state) => ExerciseDetailScreen(
        exerciseId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/foods',
      builder: (context, state) => FoodSearchScreen(
        // The dashboard's meal sections pass their bucket (e.g.
        // `?meal=lunch`) so the flow logs into the right meal (WU-4.5).
        mealHint: state.uri.queryParameters['meal'],
      ),
    ),
    GoRoute(
      path: '/foods/:id',
      builder: (context, state) => FoodDetailScreen(
        foodId: state.pathParameters['id']!,
        mealHint: state.uri.queryParameters['meal'],
      ),
    ),
    GoRoute(
      path: '/routines/new',
      builder: (context, state) => const RoutineEditorScreen(),
    ),
    GoRoute(
      path: '/routines/:id',
      builder: (context, state) => RoutineDetailScreen(
        routineId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/routines/:id/edit',
      builder: (context, state) => RoutineEditorScreen(
        routineId: state.pathParameters['id'],
      ),
    ),
    // Auth (WU-5.2) — reachable only by explicit navigation (Profile in
    // WU-5.3), never a gate: guest mode works without ever seeing these
    // screens (L2).
    GoRoute(
      path: '/auth/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/auth/otp',
      builder: (context, state) {
        final phone = state.uri.queryParameters['phone'];
        if (phone == null || phone.isEmpty) {
          // Deep-link without a number → restart the flow at login.
          return const LoginScreen();
        }
        return OtpVerificationScreen(
          phoneNumber: phone,
          expiresInSeconds:
              int.tryParse(state.uri.queryParameters['expires'] ?? '') ??
                  kDefaultOtpExpirySeconds,
        );
      },
    ),
  ],
);
