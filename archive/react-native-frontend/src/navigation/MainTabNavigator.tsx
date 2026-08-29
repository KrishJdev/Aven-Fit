import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Home, Dumbbell, TrendingUp, UtensilsCrossed } from 'lucide-react-native';
import { colors } from '../theme/colors';

import { HomeScreen } from '../screens/home/HomeScreen';
import { WorkoutListScreen } from '../screens/workout/WorkoutListScreen';
import { ProgressDashboardScreen } from '../screens/progress/ProgressDashboardScreen';
import { NutritionDashboardScreen } from '../screens/nutrition/NutritionDashboardScreen';

const Tab = createBottomTabNavigator();

export const MainTabNavigator = () => {
  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarStyle: {
          backgroundColor: '#000000', // Pitch black tab bar
          borderTopWidth: 1,
          borderTopColor: colors.glassBorder, // Zinc 800
          height: 60,
          paddingBottom: 8,
          paddingTop: 8,
        },
        tabBarActiveTintColor: '#FFFFFF',
        tabBarInactiveTintColor: colors.textSubtle,
        tabBarLabelStyle: {
          fontSize: 10,
          fontWeight: '700',
        }
      }}
    >
      <Tab.Screen 
        name="Home" 
        component={HomeScreen} 
        options={{
          tabBarLabel: 'Home',
          tabBarIcon: ({ color, size }) => <Home color={color} size={size} />
        }}
      />
      <Tab.Screen 
        name="Workouts" 
        component={WorkoutListScreen} 
        options={{
          tabBarLabel: 'Workouts',
          tabBarIcon: ({ color, size }) => <Dumbbell color={color} size={size} />
        }}
      />
      <Tab.Screen 
        name="Progress" 
        component={ProgressDashboardScreen} 
        options={{
          tabBarLabel: 'Progress',
          tabBarIcon: ({ color, size }) => <TrendingUp color={color} size={size} />
        }}
      />
      <Tab.Screen 
        name="Nutrition" 
        component={NutritionDashboardScreen} 
        options={{
          tabBarLabel: 'Nutrition',
          tabBarIcon: ({ color, size }) => <UtensilsCrossed color={color} size={size} />
        }}
      />
    </Tab.Navigator>
  );
};
