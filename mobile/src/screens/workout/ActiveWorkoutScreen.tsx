import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, KeyboardAvoidingView, Platform, TouchableOpacity } from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { RootStackParamList } from '@/navigation/types';
import { Screen } from '@/components/common/Screen';
import { Typography } from '@/components/common/Typography';
import { Button } from '@/components/common/Button';
import { ExerciseBlock, ExerciseBlockData } from '@/components/workout/ExerciseBlock';
import { RestTimerOverlay } from '@/components/workout/RestTimerOverlay';
import { theme } from '@/theme';
import { ChevronDown, Timer } from 'lucide-react-native';

type Props = NativeStackScreenProps<RootStackParamList, 'ActiveWorkout'>;

// Mock data to demonstrate the UI
const INITIAL_DATA: ExerciseBlockData[] = [
  {
    id: 'ex-1',
    name: 'Bench Press (Barbell)',
    sets: [
      { id: 's1', index: 1, previousString: '60 × 10', kg: '60', reps: '10', isCompleted: true },
      { id: 's2', index: 2, previousString: '62.5 × 8', kg: '62.5', reps: '8', isCompleted: false },
      { id: 's3', index: 3, previousString: '62.5 × 6', kg: '', reps: '', isCompleted: false },
    ]
  },
  {
    id: 'ex-2',
    name: 'Incline Dumbbell Press',
    sets: [
      { id: 's4', index: 1, previousString: '24 × 10', kg: '24', reps: '10', isCompleted: false },
      { id: 's5', index: 2, previousString: '24 × 10', kg: '24', reps: '', isCompleted: false },
    ]
  }
];

export const ActiveWorkoutScreen: React.FC<Props> = ({ navigation }) => {
  const [exercises, setExercises] = useState(INITIAL_DATA);

  const handleUpdateSet = (setId: string, field: 'kg' | 'reps', value: string) => {
    setExercises(prev => prev.map(ex => ({
      ...ex,
      sets: ex.sets.map(s => s.id === setId ? { ...s, [field]: value } : s)
    })));
  };

  const handleToggleSet = (setId: string) => {
    setExercises(prev => prev.map(ex => ({
      ...ex,
      sets: ex.sets.map(s => s.id === setId ? { ...s, isCompleted: !s.isCompleted } : s)
    })));
  };

  const handleAddSet = (exerciseId: string) => {
    setExercises(prev => prev.map(ex => {
      if (ex.id !== exerciseId) return ex;
      const lastSet = ex.sets[ex.sets.length - 1];
      const newSet = {
        id: Math.random().toString(),
        index: ex.sets.length + 1,
        previousString: '—',
        kg: lastSet ? lastSet.kg : '',
        reps: lastSet ? lastSet.reps : '',
        isCompleted: false,
      };
      return { ...ex, sets: [...ex.sets, newSet] };
    }));
  };

  const handleFinish = () => {
    // Navigates back, effectively ending the workout mode
    navigation.goBack();
  };

  return (
    <Screen safeArea edges={['top']} style={styles.screen}>
      <KeyboardAvoidingView 
        style={styles.flex} 
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        {/* Sticky Immersive Header */}
        <View style={styles.header}>
          <TouchableOpacity onPress={() => navigation.goBack()} style={styles.iconBtn}>
            <ChevronDown color={theme.colors.text} size={28} />
          </TouchableOpacity>
          
          <View style={styles.timerContainer}>
            <Typography variant="tabular" style={styles.timerText}>42:15</Typography>
            <Typography variant="label" color={theme.colors.primary} style={styles.timerLabel}>
              IN PROGRESS
            </Typography>
          </View>

          <Button 
            title="FINISH" 
            onPress={handleFinish} 
            style={styles.finishBtn} 
          />
        </View>

        {/* Scrollable Content */}
        <ScrollView 
          style={styles.flex} 
          contentContainerStyle={styles.scrollContent}
          keyboardShouldPersistTaps="handled"
        >
          {exercises.map(ex => (
            <ExerciseBlock 
              key={ex.id} 
              data={ex} 
              onUpdateSet={handleUpdateSet}
              onToggleSet={handleToggleSet}
              onAddSet={handleAddSet}
            />
          ))}

          <Button 
            title="ADD EXERCISE" 
            variant="outline" 
            style={styles.addExerciseBtn}
          />
        </ScrollView>
        
        {/* The floating rest timer triggers automatically when a set is completed */}
        <RestTimerOverlay />
      </KeyboardAvoidingView>
    </Screen>
  );
};

const styles = StyleSheet.create({
  screen: {
    backgroundColor: theme.colors.background,
  },
  flex: {
    flex: 1,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: theme.spacing.screenHorizontal,
    paddingVertical: theme.spacing.sm,
    borderBottomWidth: 1,
    borderBottomColor: theme.colors.surfaceHighlight,
    backgroundColor: theme.colors.surface,
  },
  iconBtn: {
    padding: theme.spacing.xs,
  },
  timerContainer: {
    alignItems: 'center',
  },
  timerText: {
    fontSize: 20,
    fontWeight: '700',
  },
  timerLabel: {
    fontSize: 10,
    marginTop: 2,
  },
  finishBtn: {
    height: 36,
    paddingHorizontal: theme.spacing.md,
    borderRadius: theme.radii.full,
  },
  scrollContent: {
    paddingTop: theme.spacing.xl,
    paddingBottom: 100,
  },
  addExerciseBtn: {
    marginHorizontal: theme.spacing.screenHorizontal,
    marginTop: theme.spacing.md,
  },
});
