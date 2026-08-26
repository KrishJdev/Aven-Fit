import { SafeAreaView } from 'react-native-safe-area-context';
import React from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { Typography, GlassButton, GlassCard } from '../../components/ui';
import { colors } from '../../theme/colors';
import { spacing, radii } from '../../theme/spacing';
import { Dumbbell, MoreVertical, Zap } from 'lucide-react-native';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '@/navigation/types';

import { useWorkoutStore } from '@/store';

export const HomeScreen = () => {
  const navigation = useNavigation<NativeStackNavigationProp<RootStackParamList>>();
  const { recentWorkouts, startWorkout } = useWorkoutStore();

  const handleStartEmpty = async () => {
    try {
      const workoutId = await startWorkout();
      navigation.navigate('ActiveWorkout', { workoutId });
    } catch (e) {
      console.error(e);
    }
  };

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.container}>
        
        {/* Glassy Greeting Area */}
        <View style={styles.header}>
          <Typography variant="microcopy" color={colors.primary}>SYSTEM ACTIVE</Typography>
          <Typography variant="hero" style={styles.heroText}>Welcome Back</Typography>
        </View>

        {/* Floating Start Orb / Button */}
        <View style={styles.startContainer}>
          <GlassButton 
            title="START NEW SESSION" 
            variant="primary" 
            leftIcon={<Zap color={colors.primary} size={20} />}
            style={styles.startButton} 
            onPress={handleStartEmpty}
          />
        </View>
        
        {/* Glance Stats (Glass Panes) */}
        <View style={styles.glanceRow}>
          <GlassCard style={styles.glanceCard}>
            <Typography variant="microcopy" color={colors.textMuted}>SETS THIS WEEK</Typography>
            <Typography variant="header" tabular>0</Typography>
          </GlassCard>
          <GlassCard style={styles.glanceCard}>
            <Typography variant="microcopy" color={colors.textMuted}>CALORIES</Typography>
            <Typography variant="header" tabular>0</Typography>
          </GlassCard>
        </View>

        {/* Recent Workouts */}
        <View style={styles.recentSection}>
          <Typography variant="title" style={styles.sectionTitle}>Recent Logs</Typography>

          {recentWorkouts.length === 0 && (
            <Typography variant="body" color={colors.textMuted} style={{ fontStyle: 'italic', marginTop: spacing.md }}>
              No workouts logged yet. Start a new session above!
            </Typography>
          )}

          {recentWorkouts.map((workout) => (
            <TouchableOpacity 
              key={workout.id} 
              activeOpacity={0.8}
            >
              <GlassCard style={styles.workoutCard}>
                <View style={styles.workoutHeader}>
                  <View style={styles.workoutTitleRow}>
                    <Dumbbell color={colors.primary} size={18} />
                    <Typography variant="body" style={styles.workoutName}>{workout.name}</Typography>
                  </View>
                  <TouchableOpacity style={styles.optionsBtn}>
                    <MoreVertical color={colors.textMuted} size={18} />
                  </TouchableOpacity>
                </View>

                <Typography variant="body" color={colors.textMuted} style={styles.date}>
                  {new Date(workout.started_at).toLocaleDateString()}
                </Typography>

                <Typography variant="body" color={colors.textSubtle} style={styles.exercises}>
                  {workout.exercisesStr}
                </Typography>

                <View style={styles.workoutFooter}>
                  <Typography variant="microcopy" color={colors.textMuted}>
                    {workout.sets} SETS
                  </Typography>
                  <Typography variant="microcopy" color={colors.textMuted}>
                    {workout.volume.toLocaleString()} KG VOL
                  </Typography>
                </View>
              </GlassCard>
            </TouchableOpacity>
          ))}
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
    paddingTop: spacing.xxl,
    paddingBottom: spacing.xxl 
  },
  header: {
    marginBottom: spacing.xxl,
    alignItems: 'center',
  },
  heroText: {
    marginTop: spacing.xs,
    textShadowColor: 'rgba(255,255,255,0.1)',
    textShadowOffset: { width: 0, height: 4 },
    textShadowRadius: 16,
  },
  startContainer: {
    marginBottom: spacing.xxl,
    alignItems: 'center',
  },
  startButton: {
    width: '100%',
    height: 64, // Larger, more prominent
    borderRadius: radii.lg,
  },
  glanceRow: {
    flexDirection: 'row',
    gap: spacing.md,
    marginBottom: spacing.xxl,
  },
  glanceCard: {
    flex: 1,
    paddingVertical: spacing.lg,
    alignItems: 'center',
    gap: spacing.xs,
  },
  recentSection: {
    gap: spacing.md,
  },
  sectionTitle: {
    marginBottom: spacing.sm,
    color: colors.textMuted,
  },
  workoutCard: {
    marginBottom: spacing.sm,
  },
  workoutHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing.xs,
  },
  workoutTitleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
  },
  workoutName: {
    fontWeight: '600',
    color: colors.text,
  },
  optionsBtn: {
    padding: spacing.xs,
  },
  date: {
    marginBottom: spacing.md,
  },
  exercises: {
    marginBottom: spacing.md,
    lineHeight: 22,
  },
  workoutFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    borderTopWidth: StyleSheet.hairlineWidth,
    borderTopColor: colors.glassBorder,
    paddingTop: spacing.sm,
  },
});
