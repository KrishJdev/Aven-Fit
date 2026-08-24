import React, { useEffect } from 'react';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { useAuthStore } from '@/store/authStore';
import { RootStackParamList } from './types';
import { AuthNavigator } from './AuthNavigator';
import { MainTabNavigator } from './MainTabNavigator';

import { ActiveWorkoutScreen } from '@/screens/workout/ActiveWorkoutScreen';

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
          <Stack.Screen 
            name="ActiveWorkout" 
            component={ActiveWorkoutScreen} 
            options={{ presentation: 'fullScreenModal' }}
          />
        </Stack.Group>
      ) : (
        <Stack.Screen name="Auth" component={AuthNavigator} />
      )}
    </Stack.Navigator>
  );
};
