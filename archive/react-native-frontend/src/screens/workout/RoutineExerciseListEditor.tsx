import { SafeAreaView } from 'react-native-safe-area-context';
import React from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity, TextInput } from 'react-native';
import { Typography, GlassButton } from '../../components/ui';
import { colors } from '../../theme/colors';
import { spacing } from '../../theme/spacing';
import { ChevronLeft, GripVertical, Trash2 } from 'lucide-react-native';

const MOCK_EXERCISES = [
  { id: '1', name: 'Barbell Bench Press', sets: '4', rest: '180s' },
  { id: '2', name: 'Incline Dumbbell Press', sets: '3', rest: '120s' },
];

export const RoutineExerciseListEditor = () => {
  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backBtn}>
          <ChevronLeft color={colors.text} size={28} />
        </TouchableOpacity>
        <Typography variant="title">Exercises</Typography>
        <View style={{ width: 28 }} />
      </View>
      
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.container}>
        {MOCK_EXERCISES.map((ex) => (
          <View key={ex.id} style={styles.exerciseCard}>
            <View style={styles.cardHeader}>
              <TouchableOpacity style={styles.grip}>
                <GripVertical color={colors.textMuted} size={20} />
              </TouchableOpacity>
              <Typography variant="body" style={{ fontWeight: '700', flex: 1 }}>{ex.name}</Typography>
              <TouchableOpacity style={styles.deleteBtn}>
                <Trash2 color={colors.primary} size={18} />
              </TouchableOpacity>
            </View>
            
            <View style={styles.cardInputs}>
              <View style={styles.inputCol}>
                <Typography variant="microcopy" color={colors.textMuted}>TARGET SETS</Typography>
                <TextInput
                  style={styles.input}
                  keyboardType="number-pad"
                  defaultValue={ex.sets}
                />
              </View>
              <View style={styles.inputCol}>
                <Typography variant="microcopy" color={colors.textMuted}>REST TIMER</Typography>
                <TextInput
                  style={styles.input}
                  keyboardType="number-pad"
                  defaultValue={ex.rest}
                />
              </View>
            </View>
          </View>
        ))}

        <GlassButton 
          title="+ ADD EXERCISE" 
          variant="secondary" 
          style={styles.addExerciseBtn} 
        />
      </ScrollView>

      <View style={styles.footer}>
        <GlassButton title="SAVE ROUTINE" variant="primary" style={{ flex: 1 }} />
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
    borderBottomWidth: 1,
    borderBottomColor: colors.glassBorder,
  },
  backBtn: { padding: spacing.xs },
  scrollView: { flex: 1 },
  container: { 
    paddingHorizontal: spacing.screenHorizontal, 
    paddingTop: spacing.md,
    paddingBottom: spacing.xxl 
  },
  exerciseCard: {
    backgroundColor: colors.glassBase,
    borderWidth: 1,
    borderColor: colors.glassBorder,
    marginBottom: spacing.md,
    padding: spacing.md,
  },
  cardHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.md,
  },
  grip: {
    marginRight: spacing.sm,
  },
  deleteBtn: {
    padding: spacing.xs,
  },
  cardInputs: {
    flexDirection: 'row',
    gap: spacing.md,
    paddingLeft: 32, // align with text, bypassing grip
  },
  inputCol: {
    flex: 1,
    gap: spacing.xs,
  },
  input: {
    height: 40,
    borderWidth: 1,
    borderColor: colors.glassBorder,
    color: colors.text,
    paddingHorizontal: spacing.sm,
    fontSize: 14,
    fontVariant: ['tabular-nums'],
  },
  addExerciseBtn: {
    marginTop: spacing.md,
  },
  footer: {
    padding: spacing.screenHorizontal,
    borderTopWidth: 1,
    borderTopColor: colors.glassBorder,
    backgroundColor: colors.background,
  }
});
