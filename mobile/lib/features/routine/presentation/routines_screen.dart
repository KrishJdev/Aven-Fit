import 'package:flutter/material.dart';

import 'routine_list_screen.dart';

export 'routine_list_screen.dart';

/// Workouts & Routines tab screen displaying saved routines and starter templates.
class RoutinesScreen extends StatelessWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoutineListScreen();
  }
}

