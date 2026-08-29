import React, { useState, useEffect } from 'react';
import { View, StyleSheet, ScrollView, KeyboardAvoidingView, Platform, TouchableOpacity } from 'react-native';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { RootStackParamList } from '@/navigation/types';
import { Typography, GlassButton, GlassCard } from '@/components/ui';
import { ExerciseBlock, ExerciseBlockData } from '@/components/workout/ExerciseBlock';
import { RestTimerOverlay } from '@/components/workout/RestTimerOverlay';
import { colors } from '@/theme/colors';
import { spacing, radii } from '@/theme/spacing';
import { ChevronDown, Play, Pause, Timer } from 'lucide-react-native';
import { useWorkoutStore } from '@/store';

type Props = NativeStackScreenProps<RootStackParamList, 'ActiveWorkout'>;

const formatDuration = (seconds: number) => {
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = seconds % 60;
  if (h > 0) return `${h}h ${m}m ${s}s`;
  if (m > 0) return `${m}m ${s}s`;
  return `${s}s`;
};

export const ActiveWorkoutScreen: React.FC<Props> = ({ navigation, route }) => {
  const insets = useSafeAreaInsets();
  const { workoutId } = route.params;
  const { 
    activeWorkoutId, 
    activeWorkoutName,
    activeExercises, 
    durationCounter,
    isPaused,
    tickDuration,
    togglePause,
    finishWorkout,
    addSetToExercise,
    updateSet,
    toggleSetComplete,
    loadActiveWorkoutState
  } = useWorkoutStore();

  const [timerActive, setTimerActive] = useState(false);
  const [timeRemaining, setTimeRemaining] = useState(90);

  // Load the workout data if it's not already in store
  useEffect(() => {
    if (workoutId && workoutId !== activeWorkoutId) {
      loadActiveWorkoutState(workoutId);
    }
  }, [workoutId]);

  // Workout Timer Ticker
  useEffect(() => {
    const interval = setInterval(() => {
      tickDuration();
    }, 1000);
    return () => clearInterval(interval);
  }, []);

  const handleToggleSet = async (setId: string) => {
    await toggleSetComplete(setId);
    setTimerActive(true);
    setTimeRemaining(90);
  };

  const handleFinishPress = async () => {
    const finishedId = await finishWorkout(activeWorkoutName);
    if (finishedId) {
      navigation.replace('WorkoutSummary', { workoutId: finishedId });
    }
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
            <Typography variant="microcopy" color={isPaused ? colors.warning : colors.primary}>
              {isPaused ? `PAUSED • ${formatDuration(durationCounter)}` : `${formatDuration(durationCounter)} ELAPSED`}
            </Typography>
          </View>
          
          <View style={styles.headerRight}>
            <TouchableOpacity style={styles.headerBtn} onPress={() => setTimerActive(!timerActive)}>
              <Timer color={colors.textSubtle} size={24} />
            </TouchableOpacity>
            <TouchableOpacity style={styles.headerBtn} onPress={togglePause}>
              {isPaused ? <Play color={colors.primary} size={24} /> : <Pause color={colors.textSubtle} size={24} />}
            </TouchableOpacity>
          </View>
        </View>

        {timerActive && (
          <RestTimerOverlay 
            timeRemaining={timeRemaining}
            onClose={() => setTimerActive(false)}
            onAddTime={(s) => setTimeRemaining(prev => prev + s)}
            onSubtractTime={(s) => setTimeRemaining(prev => Math.max(0, prev - s))}
          />
        )}

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
            onPress={handleFinishPress}
          />
        </ScrollView>
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
  headerRight: { flexDirection: 'row', alignItems: 'center' },
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


