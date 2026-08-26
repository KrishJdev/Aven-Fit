import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, KeyboardAvoidingView, Platform, TouchableOpacity } from 'react-native';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { RootStackParamList } from '@/navigation/types';
import { Typography, GlassButton } from '@/components/ui';
import { ExerciseBlock, ExerciseBlockData } from '@/components/workout/ExerciseBlock';
import { RestTimerOverlay } from '@/components/workout/RestTimerOverlay';
import { colors } from '@/theme/colors';
import { spacing } from '@/theme/spacing';
import { ChevronDown, Timer } from 'lucide-react-native';
import { useWorkoutStore } from '@/store';

type Props = NativeStackScreenProps<RootStackParamList, 'ActiveWorkout'>;

export const ActiveWorkoutScreen: React.FC<Props> = ({ navigation, route }) => {
  const insets = useSafeAreaInsets();
  const { workoutId } = route.params;
  const { 
    activeWorkoutId, 
    activeWorkoutName,
    activeExercises, 
    finishWorkout,
    addSetToExercise,
    updateSet,
    toggleSetComplete,
    loadActiveWorkoutState
  } = useWorkoutStore();

  const [timerActive, setTimerActive] = useState(false);
  const [timeRemaining, setTimeRemaining] = useState(90);

  // Load the workout data if it's not already in store
  React.useEffect(() => {
    if (workoutId && workoutId !== activeWorkoutId) {
      loadActiveWorkoutState(workoutId);
    }
  }, [workoutId]);

  const handleToggleSet = async (setId: string) => {
    await toggleSetComplete(setId);
    setTimerActive(true);
    setTimeRemaining(90);
  };

  const handleFinish = async () => {
    await finishWorkout();
    navigation.goBack();
  };

  return (
    <View style={[styles.safeArea, { paddingTop: insets.top }]}>
      <KeyboardAvoidingView 
        style={{ flex: 1 }} 
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <View style={styles.header}>
          <TouchableOpacity style={styles.headerBtn} onPress={() => navigation.goBack()}>
            <ChevronDown color={colors.text} size={28} />
          </TouchableOpacity>
          <View style={styles.headerCenter}>
            <Typography variant="body" style={styles.titleText}>{activeWorkoutName || 'Workout'}</Typography>
            <Typography variant="microcopy" color={colors.primary}>1h 12m ELAPSED</Typography>
          </View>
          <TouchableOpacity style={styles.headerBtn}>
            <Timer color={colors.text} size={24} />
          </TouchableOpacity>
        </View>

        <ScrollView style={styles.scrollView} contentContainerStyle={styles.container}>
          {activeExercises.map((ex) => (
            <ExerciseBlock 
              key={ex.id} 
              data={ex} 
              onUpdateSet={updateSet}
              onToggleSet={handleToggleSet}
              onAddSet={() => addSetToExercise(ex.id)}
            />
          ))}

          <GlassButton 
            title="+ ADD EXERCISE" 
            variant="secondary"
            style={styles.addExerciseBtn}
            onPress={() => navigation.navigate('ExerciseDirectory')}
          />
          
          <GlassButton 
            title="FINISH WORKOUT" 
            variant="primary" 
            style={styles.finishBtn} 
            onPress={handleFinish}
          />
        </ScrollView>

        {timerActive && (
          <RestTimerOverlay 
            timeRemaining={timeRemaining}
            onClose={() => setTimerActive(false)}
            onAddTime={(s) => setTimeRemaining(prev => prev + s)}
            onSubtractTime={(s) => setTimeRemaining(prev => Math.max(0, prev - s))}
          />
        )}
      </KeyboardAvoidingView>
    </View>
  );
};

const styles = StyleSheet.create({
  safeArea: { flex: 1, backgroundColor: colors.background },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.md,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: colors.glassBorder,
    backgroundColor: 'rgba(3, 3, 5, 0.8)', // slight sheer for header
  },
  headerBtn: { padding: spacing.sm },
  headerCenter: { alignItems: 'center' },
  titleText: { fontWeight: '600', marginBottom: 2 },
  scrollView: { flex: 1 },
  container: { 
    paddingHorizontal: spacing.screenHorizontal, 
    paddingTop: spacing.xl,
    paddingBottom: 150 
  },
  addExerciseBtn: {
    marginBottom: spacing.xl,
  },
  finishBtn: {
    marginBottom: spacing.xxl,
  },
});
