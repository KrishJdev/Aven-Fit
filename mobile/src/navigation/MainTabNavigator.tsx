import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { MainTabParamList } from './types';
import { theme } from '@/theme';
import { 
  Calendar, 
  Dumbbell, 
  Apple, 
  TrendingUp, 
  User 
} from 'lucide-react-native';

import { TodayScreen } from '@/screens/workout/TodayScreen';
import { TrainScreen } from '@/screens/workout/TrainScreen';
import { NutritionScreen } from '@/screens/nutrition/NutritionScreen';
import { ProgressScreen } from '@/screens/history/ProgressScreen';
import { ProfileScreen } from '@/screens/profile/ProfileScreen';

const Tab = createBottomTabNavigator<MainTabParamList>();

export const MainTabNavigator = () => {
  return (
    <Tab.Navigator
      screenOptions={{
        headerShown: false,
        tabBarStyle: {
          backgroundColor: theme.colors.surface,
          borderTopColor: theme.colors.surfaceHighlight,
          borderTopWidth: 1,
          height: 84,
          paddingBottom: 24,
          paddingTop: 12,
        },
        tabBarActiveTintColor: theme.colors.primary,
        tabBarInactiveTintColor: theme.colors.textMuted,
        tabBarLabelStyle: {
          fontFamily: theme.typography.primary,
          fontSize: 12,
          fontWeight: '500',
          marginTop: 4,
        },
      }}
    >
      <Tab.Screen 
        name="Today" 
        component={TodayScreen} 
        options={{
          tabBarIcon: ({ color, size }) => <Calendar color={color} size={size} />
        }}
      />
      <Tab.Screen 
        name="Train" 
        component={TrainScreen} 
        options={{
          tabBarIcon: ({ color, size }) => <Dumbbell color={color} size={size} />
        }}
      />
      <Tab.Screen 
        name="Nutrition" 
        component={NutritionScreen} 
        options={{
          tabBarIcon: ({ color, size }) => <Apple color={color} size={size} />
        }}
      />
      <Tab.Screen 
        name="Progress" 
        component={ProgressScreen} 
        options={{
          tabBarIcon: ({ color, size }) => <TrendingUp color={color} size={size} />
        }}
      />
      <Tab.Screen 
        name="Profile" 
        component={ProfileScreen} 
        options={{
          tabBarIcon: ({ color, size }) => <User color={color} size={size} />
        }}
      />
    </Tab.Navigator>
  );
};
