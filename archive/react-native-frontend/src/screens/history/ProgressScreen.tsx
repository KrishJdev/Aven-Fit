import React from 'react';
import { ScrollView, View, StyleSheet } from 'react-native';
import { Screen } from '@/components/common/Screen';
import { Typography } from '@/components/common/Typography';
import { PersonalRecordCard } from '@/components/progress/PersonalRecordCard';
import { TrendChart } from '@/components/progress/TrendChart';
import { HistoryLedger } from '@/components/progress/HistoryLedger';
import { theme } from '@/theme';

// Mock Data for the design phase
const MOCK_PRS = [
  { id: '1', exercise: 'Bench Press (Barbell)', type: 'MAX_WEIGHT' as const, value: '110 kg', date: 'Oct 12' },
  { id: '2', exercise: 'Squat (Barbell)', type: 'EST_1RM' as const, value: '145 kg', date: 'Oct 08' },
];

const MOCK_TREND = [
  { label: 'W1', value: 90 },
  { label: 'W2', value: 95 },
  { label: 'W3', value: 100 },
  { label: 'W4', value: 100 },
  { label: 'W5', value: 105 },
  { label: 'W6', value: 110 },
];

const MOCK_HISTORY = [
  { id: 'h1', name: 'Push Day - Hypertrophy', date: 'Today', volume: '7,450 kg', prCount: 1 },
  { id: 'h2', name: 'Pull Day - Strength', date: 'Yesterday', volume: '9,200 kg', prCount: 2 },
  { id: 'h3', name: 'Legs - Volume', date: 'Oct 10', volume: '11,050 kg', prCount: 0 },
];

export const ProgressScreen = () => {
  return (
    <Screen safeArea edges={['top', 'left', 'right']}>
      <ScrollView 
        style={styles.container} 
        contentContainerStyle={styles.content}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.header}>
          <Typography variant="h1" style={styles.title}>PROGRESS</Typography>
        </View>

        <View style={styles.section}>
          <Typography variant="label" style={styles.sectionTitle}>RECENT RECORDS</Typography>
          {MOCK_PRS.map(pr => (
            <PersonalRecordCard 
              key={pr.id}
              exerciseName={pr.exercise}
              recordType={pr.type}
              value={pr.value}
              date={pr.date}
            />
          ))}
        </View>

        <View style={styles.section}>
          <TrendChart 
            title="Bench Press • 1RM Trend" 
            data={MOCK_TREND} 
          />
        </View>

        <HistoryLedger items={MOCK_HISTORY} />
        
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
    marginBottom: theme.spacing.xl,
  },
  title: {
    letterSpacing: 2,
  },
  section: {
    marginBottom: theme.spacing.lg,
  },
  sectionTitle: {
    marginBottom: theme.spacing.md,
    letterSpacing: 1,
  },
});
