import { SafeAreaView } from 'react-native-safe-area-context';
import React from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { Typography, GlassButton, GlassCard } from '../../components/ui';
import { colors } from '../../theme/colors';
import { spacing, radii } from '../../theme/spacing';
import { Folder, MoreVertical, Dumbbell, Plus } from 'lucide-react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '@/navigation/types';

import { useRoutineStore, useWorkoutStore } from '@/store';

export const WorkoutListScreen = () => {
  const navigation = useNavigation<NativeStackNavigationProp<RootStackParamList>>();
  const { routines } = useRoutineStore();
  const { startWorkout } = useWorkoutStore();

  const handleStartRoutine = async (routineId: string) => {
    try {
      // Create a workout from the routine in SQLite
      const workoutId = await startWorkout(routineId);
      navigation.navigate('ActiveWorkout', { workoutId });
    } catch (e) {
      console.error(e);
    }
  };

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.container}>
        <View style={styles.header}>
          <Typography variant="microcopy" color={colors.primary}>TRAINING</Typography>
          <Typography variant="hero">Routines</Typography>
        </View>

        <View style={styles.actionsRow}>
          <GlassButton 
            variant="primary" 
            title="NEW PLAN" 
            leftIcon={<Plus color={colors.primary} size={18} />}
            style={styles.actionBtnPrimary} 
            onPress={() => navigation.navigate('RoutineMetadata', {})}
          />
          <GlassButton 
            variant="secondary" 
            title="FOLDER" 
            style={styles.actionBtn} 
          />
        </View>

        <View style={styles.folderList}>
          {routines.length === 0 ? (
            <Typography variant="body" color={colors.textMuted} style={{ fontStyle: 'italic', marginTop: spacing.md }}>
              No routines saved yet. Create a new plan to get started.
            </Typography>
          ) : (
            <View style={styles.folderContainer}>
              <View style={styles.folderHeader}>
                <View style={{flexDirection: 'row', alignItems: 'center', gap: spacing.sm}}>
                  <Folder color={colors.textMuted} size={20} />
                  <Typography variant="title">All Routines</Typography>
                </View>
                <TouchableOpacity style={styles.folderDots}>
                  <MoreVertical color={colors.textSubtle} size={20} />
                </TouchableOpacity>
              </View>

              {routines.map((routine) => (
                <GlassCard key={routine.id} style={styles.routineCard} noPadding>
                  <View style={styles.routineContent}>
                    <View style={styles.routineInfo}>
                      <Typography variant="body" style={{fontWeight: '600'}}>{routine.name}</Typography>
                      <Typography variant="microcopy" color={colors.textSubtle}>{routine.description}</Typography>
                    </View>
                    
                    <View style={styles.routineActions}>
                      <TouchableOpacity 
                        style={styles.startBtnSmall}
                        onPress={() => handleStartRoutine(routine.id)}
                      >
                        <Typography variant="body" style={styles.startBtnText}>START</Typography>
                      </TouchableOpacity>
                      <TouchableOpacity 
                        style={styles.dotsBtn}
                        onPress={() => navigation.navigate('RoutineDetail', { routineId: routine.id })}
                      >
                        <MoreVertical color={colors.textMuted} size={18} />
                      </TouchableOpacity>
                    </View>
                  </View>
                </GlassCard>
              ))}
            </View>
          )}
        </View>

      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  safeArea: { flex: 1, backgroundColor: colors.background },
  scrollView: { flex: 1 },
  container: { 
    paddingHorizontal: spacing.screenHorizontal, 
    paddingTop: spacing.xl,
    paddingBottom: spacing.xxl 
  },
  header: {
    marginBottom: spacing.xxl,
    alignItems: 'center',
  },
  actionsRow: {
    flexDirection: 'row',
    gap: spacing.md,
    marginBottom: spacing.xxl,
  },
  actionBtnPrimary: {
    flex: 2,
    height: 48,
  },
  actionBtn: {
    flex: 1,
    height: 48,
  },
  folderList: {
    gap: spacing.xl,
  },
  folderContainer: {
    gap: spacing.md,
  },
  folderHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: spacing.xs,
  },
  folderDots: {
    padding: spacing.xs,
  },
  routineCard: {
    // GlassCard handles base styles, we just need layout
  },
  routineContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: spacing.md,
  },
  routineInfo: {
    gap: spacing.xs,
  },
  routineActions: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
  },
  startBtnSmall: {
    backgroundColor: colors.primaryMuted,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.sm,
    borderRadius: radii.sm,
    borderWidth: 1,
    borderColor: 'rgba(0, 240, 255, 0.3)',
  },
  startBtnText: {
    fontWeight: '700',
    color: colors.primary,
    letterSpacing: 1,
  },
  dotsBtn: {
    padding: spacing.sm,
  },
});
