import { NavigatorScreenParams } from '@react-navigation/native';

export type AuthStackParamList = {
  Login: undefined;
  OtpVerification: { phoneNumber: string };
};

export type MainTabParamList = {
  Home: undefined;
  Workouts: undefined;
  Progress: undefined;
  Nutrition: undefined;
};

export type RootStackParamList = {
  Auth: NavigatorScreenParams<AuthStackParamList>;
  Main: NavigatorScreenParams<MainTabParamList>;
  ActiveWorkout: { workoutId?: string; routineId?: string };
  WorkoutSummary: { workoutId: string };
  
  // Workouts
  RoutineDetail: { routineId: string };
  RoutineMetadata: { routineId?: string };
  RoutineExerciseListEditor: { routineId: string };
  
  // Exercises
  ExerciseDirectory: undefined;
  ExerciseDetail: { exerciseId: string };
  CreateCustomExercise: undefined;
  
  // Progress
  BodyWeightHistory: undefined;
  Exercise1RMChart: { exerciseId: string };
  PrVault: undefined;
  MuscleVolumeDistribution: undefined;
  
  // Nutrition
  MealLoggingOverview: { mealType: string };
  FoodDatabaseSearch: undefined;
  FoodItemDetail: { foodId: string };
};
