import React from 'react';
import { ScrollView, View, StyleSheet } from 'react-native';
import { Screen } from '@/components/common/Screen';
import { Typography } from '@/components/common/Typography';
import { ActionCard } from '@/components/home/ActionCard';
import { FuelSummary } from '@/components/home/FuelSummary';
import { MomentumChart } from '@/components/home/MomentumChart';
import { theme } from '@/theme';
import { format } from 'date-fns';

import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '@/navigation/types';

export const TodayScreen = () => {
  const navigation = useNavigation<NativeStackNavigationProp<RootStackParamList>>();
  
  // Format as "25 AUG"
  const day = format(new Date(), 'dd');
  const month = format(new Date(), 'MMM').toUpperCase();
  
  const handleStartWorkout = () => {
    navigation.navigate('ActiveWorkout', {});
  };

  return (
    <Screen safeArea edges={['top', 'left', 'right']}>
      <ScrollView 
        style={styles.container} 
        contentContainerStyle={styles.content}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.header}>
          <Typography variant="h1" style={styles.dayText}>{day}</Typography>
          <Typography variant="h2" style={styles.monthText} color={theme.colors.textMuted}>{month}</Typography>
        </View>

        <ActionCard 
          title="Push Day" 
          subtitle="HYPERTROPHY FOCUS ? 6 EXERCISES" 
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
    backgroundColor: theme.colors.background,
  },
  content: {
    paddingHorizontal: theme.spacing.screenHorizontal,
    paddingTop: theme.spacing.xl,
    paddingBottom: 100,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'baseline',
    marginBottom: theme.spacing.xl,
  },
  dayText: {
    fontSize: 72,
    lineHeight: 76,
    letterSpacing: -2,
    fontWeight: '700',
  },
  monthText: {
    fontSize: 32,
    letterSpacing: 2,
    marginLeft: theme.spacing.sm,
  },
});
