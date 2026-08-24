import React from 'react';
import { ScrollView, View, StyleSheet } from 'react-native';
import { Screen } from '@/components/common/Screen';
import { Typography } from '@/components/common/Typography';
import { ActionCard } from '@/components/home/ActionCard';
import { FuelSummary } from '@/components/home/FuelSummary';
import { MomentumChart } from '@/components/home/MomentumChart';
import { theme } from '@/theme';
import { useAuthStore } from '@/store/authStore';
import { format } from 'date-fns';

export const TodayScreen = () => {
  const { user } = useAuthStore();
  const todayDate = format(new Date(), 'EEEE, MMMM do').toUpperCase();
  
  // Example "start workout" handler
  const handleStartWorkout = () => {
    // In future phases, this will navigate to the Active Workout flow
    console.log('Start Workout');
  };

  return (
    <Screen safeArea edges={['top', 'left', 'right']}>
      <ScrollView 
        style={styles.container} 
        contentContainerStyle={styles.content}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.header}>
          <Typography variant="label" color={theme.colors.textMuted} style={styles.date}>
            {todayDate}
          </Typography>
          <Typography variant="h1" style={styles.greeting}>
            Good morning, {user?.displayName || 'Athlete'}.
          </Typography>
        </View>

        <ActionCard 
          title="Push Day" 
          subtitle="Hypertrophy Focus • 6 Exercises" 
          onPress={handleStartWorkout} 
        />

        <FuelSummary />
        
        <MomentumChart />
      </ScrollView>
    </Screen>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  content: {
    paddingHorizontal: theme.spacing.screenHorizontal,
    paddingTop: theme.spacing.lg,
    paddingBottom: 100, // Account for bottom tab bar
  },
  header: {
    marginBottom: theme.spacing.xxl,
  },
  date: {
    marginBottom: theme.spacing.sm,
    letterSpacing: 1.5,
  },
  greeting: {
    letterSpacing: -0.5,
  },
});
