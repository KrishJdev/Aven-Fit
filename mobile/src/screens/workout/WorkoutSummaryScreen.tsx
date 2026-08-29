import React, { useEffect, useState } from 'react';
import { View, Alert, StyleSheet, ScrollView, TouchableOpacity, TextInput } from 'react-native';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import { RootStackParamList } from '@/navigation/types';
import { Typography, GlassCard, GlassButton } from '@/components/ui';
import { colors } from '@/theme/colors';
import { spacing, radii } from '@/theme/spacing';
import { ChevronLeft, Flame, Pencil, Calendar, Clock, BarChart } from 'lucide-react-native';
import { db } from '@/database';
import { useWorkoutStore } from '@/store';

type Props = NativeStackScreenProps<RootStackParamList, 'WorkoutSummary'>;

const formatDuration = (seconds: number) => {
  const h = Math.floor(seconds / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = seconds % 60;
  if (h > 0) return `${h}h ${m}m`;
  return `${m}m ${s}s`;
};

export const WorkoutSummaryScreen: React.FC<Props> = ({ navigation, route }) => {
  const { workoutId } = route.params;
  const insets = useSafeAreaInsets();
  
  const [loading, setLoading] = useState(true);
  const [workout, setWorkout] = useState<any>(null);
  const [exercises, setExercises] = useState<any[]>([]);
  const [streak, setStreak] = useState(0);
  
  // Editing state
  const [isEditingName, setIsEditingName] = useState(false);
  const [editedName, setEditedName] = useState('');

  useEffect(() => {
    loadSummary();
    calculateStreak();
  }, [workoutId]);

  const loadSummary = async () => {
    try {
      // 1. Load Workout metadata
      const wRes = await db.execute(`
        SELECT name, duration_seconds, started_at, completed_at
        FROM workouts WHERE id = ?
      `, [workoutId]);
      const wRowsArray = wRes.rows?._array || (Array.isArray(wRes.rows) ? wRes.rows : []);
      const wData = wRowsArray[0] || wRes.rows?.item?.(0);
      
      if (!wData) {
        throw new Error(`Workout ID ${workoutId} not found in database.`);
      }

      setWorkout(wData);
      setEditedName(wData?.name || 'Workout');

      // 2. Load Exercises and Sets
      const weRes = await db.execute(`
        SELECT 
          we.id as we_id, 
          e.name as exercise_name,
          ws.weight_kg,
          ws.reps,
          ws.is_completed,
          ws.position as set_position
        FROM workout_exercises we
        JOIN exercises e ON we.exercise_id = e.id
        LEFT JOIN workout_sets ws ON ws.workout_exercise_id = we.id
        WHERE we.workout_id = ? AND ws.is_completed = 1
        ORDER BY we.position ASC, ws.position ASC
      `, [workoutId]);
      
      // @ts-ignore
      const rows = weRes.rows?._array || (Array.isArray(weRes.rows) ? weRes.rows : []);
      
      // Group by exercise
      const exMap = new Map<string, any>();
      for (const row of rows) {
        if (!exMap.has(row.we_id)) {
          exMap.set(row.we_id, {
            id: row.we_id,
            name: row.exercise_name,
            sets: []
          });
        }
        exMap.get(row.we_id).sets.push({
          weight: row.weight_kg,
          reps: row.reps
        });
      }
      setExercises(Array.from(exMap.values()));
    } catch (e) {
      console.error(e); Alert.alert('Error', (e as any)?.message || 'An unexpected error occurred.');
    } finally {
      setLoading(false);
    }
  };

  const calculateStreak = async () => {
    try {
      const res = await db.execute(`
        SELECT date(completed_at) as completed_date
        FROM workouts 
        WHERE status = 'COMPLETED' AND completed_at IS NOT NULL
        GROUP BY date(completed_at)
        ORDER BY completed_date DESC
      `);
      // @ts-ignore
      const rows = res.rows?._array || [];
      
      let currentStreak = 0;
      let checkDate = new Date(); // Start from today
      
      for (let i = 0; i < rows.length; i++) {
        const rowDateStr = rows[i].completed_date; // YYYY-MM-DD
        const checkDateStr = checkDate.toISOString().split('T')[0];
        
        if (rowDateStr === checkDateStr) {
          currentStreak++;
          checkDate.setDate(checkDate.getDate() - 1); // Move back one day
        } else if (i === 0) {
          // If the first date isn't today, check if it's yesterday
          checkDate.setDate(checkDate.getDate() - 1);
          const yesterdayStr = checkDate.toISOString().split('T')[0];
          if (rowDateStr === yesterdayStr) {
            currentStreak++;
            checkDate.setDate(checkDate.getDate() - 1);
          } else {
            break; // No streak
          }
        } else {
          break; // Gap in streak
        }
      }
      setStreak(currentStreak || 1); // Minimum 1 since they just finished a workout
    } catch (e) {
      console.error('Streak calculation failed', e); Alert.alert('Error', 'Failed to calculate streak.');
      setStreak(1);
    }
  };

  const { loadRecentWorkouts } = useWorkoutStore();

  const handleNameSave = async () => {
    try {
      const finalName = editedName.trim() || 'Workout';
      await db.execute(`UPDATE workouts SET name = ? WHERE id = ?`, [finalName, workoutId]);
      setIsEditingName(false);
      setEditedName(finalName);
      setWorkout({ ...workout, name: finalName });
      loadRecentWorkouts();
} catch (e) {
      console.error(e); Alert.alert('Error', (e as any)?.message || 'An unexpected error occurred.');
    }
  };

  if (loading) {
    return <View style={styles.safeArea} />
  }

  if (!workout) {
    return (
      <View style={[styles.safeArea, { justifyContent: 'center', alignItems: 'center' }]}>
        <Typography variant="body" color={colors.textMuted}>Workout not found.</Typography>
        <GlassButton 
          title="GO BACK" 
          variant="secondary" 
          onPress={() => navigation.navigate('Main', { screen: 'Workouts' })} 
          style={{ marginTop: spacing.lg }} 
        />
      </View>
    );
  }

  const totalSets = exercises.reduce((acc, ex) => acc + ex.sets.length, 0);
  const totalVolume = exercises.reduce((acc, ex) => 
    acc + ex.sets.reduce((sum: number, s: any) => sum + (s.weight * s.reps), 0), 0);

  return (
    <View style={[styles.safeArea, { paddingTop: insets.top }]}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.headerBtn} onPress={() => navigation.navigate('Main', { screen: 'Workouts' })}>
          <ChevronLeft color={colors.text} size={28} />
        </TouchableOpacity>
        <Typography variant="body" style={{ fontWeight: '600' }}>Summary</Typography>
        <View style={{ width: 44 }} />
      </View>

      <ScrollView style={{ flex: 1 }} contentContainerStyle={styles.container}>
        <View style={styles.streakBadge}>
          <Flame color={colors.warning} size={18} fill={colors.warning} />
          <Typography variant="microcopy" color={colors.warning} style={{ marginLeft: spacing.xs }}>
            {streak} DAY STREAK
          </Typography>
        </View>

        <View style={styles.titleSection}>
          {isEditingName ? (
            <TextInput 
              style={styles.nameInput}
              value={editedName}
              onChangeText={setEditedName}
              onBlur={handleNameSave}
              autoFocus
              onSubmitEditing={handleNameSave}
              returnKeyType="done"
            />
          ) : (
            <View style={styles.nameRow}>
              <Typography variant="hero" style={styles.workoutName}>{workout.name}</Typography>
              <TouchableOpacity onPress={() => setIsEditingName(true)} style={styles.editBtn}>
                <Pencil color={colors.primary} size={18} />
              </TouchableOpacity>
            </View>
          )}
          <Typography variant="microcopy" color={colors.textSubtle} style={{ marginTop: spacing.xs }}>
            {new Date(workout.started_at).toLocaleDateString(undefined, { weekday: 'long', month: 'short', day: 'numeric', hour: 'numeric', minute: 'numeric' })}
          </Typography>
        </View>

        <View style={styles.statsGrid}>
          <GlassCard style={styles.statCard}>
            <Clock color={colors.primary} size={20} style={{ marginBottom: spacing.sm }} />
            <Typography variant="title" color={colors.text}>{formatDuration(workout.duration_seconds || 0)}</Typography>
            <Typography variant="microcopy" color={colors.textMuted}>TIME</Typography>
          </GlassCard>
          
          <GlassCard style={styles.statCard}>
            <BarChart color={colors.primary} size={20} style={{ marginBottom: spacing.sm }} />
            <Typography variant="title" color={colors.text}>{totalVolume} kg</Typography>
            <Typography variant="microcopy" color={colors.textMuted}>VOLUME</Typography>
          </GlassCard>
          
          <GlassCard style={styles.statCard}>
            <Flame color={colors.primary} size={20} style={{ marginBottom: spacing.sm }} />
            <Typography variant="title" color={colors.text}>{totalSets}</Typography>
            <Typography variant="microcopy" color={colors.textMuted}>SETS</Typography>
          </GlassCard>
        </View>

        <Typography variant="header" style={styles.sectionTitle}>Workout Breakdown</Typography>
        
        {exercises.map((ex, idx) => (
          <GlassCard key={idx} style={styles.exerciseCard}>
            <Typography variant="body" style={{ fontWeight: '600', marginBottom: spacing.sm }}>
              {ex.name}
            </Typography>
            <View style={styles.setsList}>
              {ex.sets.map((set: any, sIdx: number) => (
                <View key={sIdx} style={styles.setRow}>
                  <Typography variant="microcopy" color={colors.textMuted} style={{ width: 30 }}>{sIdx + 1}</Typography>
                  <Typography variant="body" color={colors.text}>{set.weight} kg × {set.reps}</Typography>
                </View>
              ))}
            </View>
          </GlassCard>
        ))}
      </ScrollView>
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
  },
  headerBtn: { padding: spacing.sm },
  container: {
    paddingHorizontal: spacing.screenHorizontal,
    paddingBottom: spacing.xxl,
  },
  streakBadge: {
    alignSelf: 'flex-start',
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(255, 171, 0, 0.15)', // warning with opacity
    paddingHorizontal: spacing.sm,
    paddingVertical: 4,
    borderRadius: radii.full,
    borderWidth: 1,
    borderColor: 'rgba(255, 171, 0, 0.3)',
    marginBottom: spacing.md,
  },
  titleSection: {
    marginBottom: spacing.xl,
  },
  nameRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  workoutName: {
    color: colors.primary,
  },
  editBtn: {
    padding: spacing.sm,
    marginLeft: spacing.xs,
  },
  nameInput: {
    fontSize: 32,
    fontWeight: '700',
    color: colors.primary,
    borderBottomWidth: 1,
    borderBottomColor: colors.primary,
    paddingVertical: 0,
    marginVertical: 0,
  },
  statsGrid: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    gap: spacing.sm,
    marginBottom: spacing.xxl,
  },
  statCard: {
    flex: 1,
    alignItems: 'center',
    padding: spacing.md,
  },
  sectionTitle: {
    marginBottom: spacing.md,
  },
  exerciseCard: {
    marginBottom: spacing.md,
    padding: spacing.md,
  },
  setsList: {
    marginTop: spacing.xs,
  },
  setRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 4,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: colors.glassBorder,
  }
});




