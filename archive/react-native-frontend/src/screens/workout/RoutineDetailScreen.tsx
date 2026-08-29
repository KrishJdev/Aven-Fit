import { SafeAreaView } from 'react-native-safe-area-context';
import React from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity } from 'react-native';
import { Typography, GlassButton } from '../../components/ui';
import { colors } from '../../theme/colors';
import { spacing } from '../../theme/spacing';
import { ChevronLeft, Dumbbell, MoreVertical } from 'lucide-react-native';

const MOCK_ROUTINE = {
  name: 'Push Day',
  description: 'Chest, Shoulders, and Triceps focus. Rest 2 mins between compounds.',
  exercises: [
    { id: '1', name: 'Barbell Bench Press', sets: 4, repRange: '8-10' },
    { id: '2', name: 'Incline Dumbbell Press', sets: 3, repRange: '10-12' },
    { id: '3', name: 'Overhead Press', sets: 3, repRange: '8-10' },
    { id: '4', name: 'Tricep Rope Pushdown', sets: 4, repRange: '12-15' },
  ]
};

export const RoutineDetailScreen = () => {
  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backBtn}>
          <ChevronLeft color={colors.text} size={28} />
        </TouchableOpacity>
        <TouchableOpacity style={styles.optionsBtn}>
          <MoreVertical color={colors.text} size={24} />
        </TouchableOpacity>
      </View>
      
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.container}>
        <Typography variant="hero" style={styles.title}>{MOCK_ROUTINE.name}</Typography>
        <Typography variant="body" color={colors.textMuted} style={styles.description}>
          {MOCK_ROUTINE.description}
        </Typography>

        <View style={styles.exercisesList}>
          {MOCK_ROUTINE.exercises.map((ex, index) => (
            <View key={ex.id} style={styles.exerciseRow}>
              <View style={styles.indexBox}>
                <Typography variant="body" tabular color={colors.textMuted}>{index + 1}</Typography>
              </View>
              <View style={styles.exerciseInfo}>
                <Typography variant="body" style={{ fontWeight: '700' }}>{ex.name}</Typography>
                <Typography variant="microcopy" color={colors.textSubtle} tabular>
                  {ex.sets} SETS • {ex.repRange} REPS
                </Typography>
              </View>
            </View>
          ))}
        </View>

      </ScrollView>

      <View style={styles.footer}>
        <GlassButton title="► START WORKOUT" variant="primary" style={{ flex: 1 }} />
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  safeArea: { flex: 1, backgroundColor: colors.background },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.sm,
  },
  backBtn: { padding: spacing.xs },
  optionsBtn: { padding: spacing.xs },
  scrollView: { flex: 1 },
  container: { 
    paddingHorizontal: spacing.screenHorizontal, 
    paddingBottom: spacing.xxl 
  },
  title: { marginBottom: spacing.sm },
  description: { marginBottom: spacing.xl },
  exercisesList: {
    borderTopWidth: 1,
    borderTopColor: colors.glassBorder,
  },
  exerciseRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: colors.glassBorder,
  },
  indexBox: {
    width: 32,
    alignItems: 'center',
    justifyContent: 'center',
  },
  exerciseInfo: {
    flex: 1,
    marginLeft: spacing.sm,
  },
  footer: {
    padding: spacing.screenHorizontal,
    borderTopWidth: 1,
    borderTopColor: colors.glassBorder,
    backgroundColor: colors.background,
  }
});
