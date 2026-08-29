import React, { useEffect } from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { useAuthStore } from '@/store/authStore';
import { RootStackParamList } from './types';
import { AuthNavigator } from './AuthNavigator';
import { MainTabNavigator } from './MainTabNavigator';

import { ActiveWorkoutScreen } from '@/screens/workout/ActiveWorkoutScreen';
import { WorkoutSummaryScreen } from '@/screens/workout/WorkoutSummaryScreen';
import { RoutineDetailScreen } from '@/screens/workout/RoutineDetailScreen';
import { RoutineMetadataScreen } from '@/screens/workout/RoutineMetadataScreen';
import { RoutineExerciseListEditor } from '@/screens/workout/RoutineExerciseListEditor';

import { ExerciseDirectoryScreen } from '@/screens/exercise/ExerciseDirectoryScreen';
import { ExerciseDetailScreen } from '@/screens/exercise/ExerciseDetailScreen';
import { CreateCustomExerciseScreen } from '@/screens/exercise/CreateCustomExerciseScreen';

import { BodyWeightHistoryScreen } from '@/screens/progress/BodyWeightHistoryScreen';
import { Exercise1RMChartScreen } from '@/screens/progress/Exercise1RMChartScreen';
import { PrVaultScreen } from '@/screens/progress/PrVaultScreen';
import { MuscleVolumeDistributionScreen } from '@/screens/progress/MuscleVolumeDistributionScreen';

import { MealLoggingOverviewScreen } from '@/screens/nutrition/MealLoggingOverviewScreen';
import { FoodDatabaseSearchScreen } from '@/screens/nutrition/FoodDatabaseSearchScreen';
import { FoodItemDetailScreen } from '@/screens/nutrition/FoodItemDetailScreen';

const Stack = createNativeStackNavigator<RootStackParamList>();

export const RootNavigator = () => {
  const { accessToken, hydrate } = useAuthStore();

  useEffect(() => {
    hydrate();
  }, [hydrate]);

  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      {accessToken ? (
        <Stack.Group>
          <Stack.Screen name="Main" component={MainTabNavigator} />
          
          <Stack.Screen name="ActiveWorkout" component={ActiveWorkoutScreen} options={{ presentation: 'fullScreenModal' }} />
          <Stack.Screen name="WorkoutSummary" component={WorkoutSummaryScreen} options={{ presentation: 'fullScreenModal' }} />
          <Stack.Screen name="RoutineDetail" component={RoutineDetailScreen} />
          <Stack.Screen name="RoutineMetadata" component={RoutineMetadataScreen} options={{ presentation: 'modal' }} />
          <Stack.Screen name="RoutineExerciseListEditor" component={RoutineExerciseListEditor} />

          <Stack.Screen name="ExerciseDirectory" component={ExerciseDirectoryScreen} options={{ presentation: 'modal' }} />
          <Stack.Screen name="ExerciseDetail" component={ExerciseDetailScreen} />
          <Stack.Screen name="CreateCustomExercise" component={CreateCustomExerciseScreen} options={{ presentation: 'modal' }} />

          <Stack.Screen name="BodyWeightHistory" component={BodyWeightHistoryScreen} />
          <Stack.Screen name="Exercise1RMChart" component={Exercise1RMChartScreen} />
          <Stack.Screen name="PrVault" component={PrVaultScreen} />
          <Stack.Screen name="MuscleVolumeDistribution" component={MuscleVolumeDistributionScreen} />

          <Stack.Screen name="MealLoggingOverview" component={MealLoggingOverviewScreen} />
          <Stack.Screen name="FoodDatabaseSearch" component={FoodDatabaseSearchScreen} options={{ presentation: 'fullScreenModal' }} />
          <Stack.Screen name="FoodItemDetail" component={FoodItemDetailScreen} options={{ presentation: 'modal' }} />
        </Stack.Group>
      ) : (
        <Stack.Screen name="Auth" component={AuthNavigator} />
      )}
    </Stack.Navigator>
  );
};
