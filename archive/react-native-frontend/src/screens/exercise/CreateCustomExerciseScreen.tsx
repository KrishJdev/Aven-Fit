import { SafeAreaView } from 'react-native-safe-area-context';
import React from 'react';
import { View, StyleSheet, ScrollView, TouchableOpacity, TextInput } from 'react-native';
import { Typography, GlassButton } from '../../components/ui';
import { colors } from '../../theme/colors';
import { spacing } from '../../theme/spacing';
import { ChevronLeft } from 'lucide-react-native';

export const CreateCustomExerciseScreen = () => {
  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backBtn}>
          <ChevronLeft color={colors.text} size={28} />
        </TouchableOpacity>
        <Typography variant="title">Create Exercise</Typography>
        <View style={{ width: 28 }} />
      </View>
      
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.container}>
        
        <View style={styles.inputGroup}>
          <Typography variant="microcopy" color={colors.textMuted} style={styles.label}>EXERCISE NAME</Typography>
          <TextInput
            style={styles.input}
            placeholder="e.g. Deficit Deadlift"
            placeholderTextColor={colors.textSubtle}
          />
        </View>

        <View style={styles.inputGroup}>
          <Typography variant="microcopy" color={colors.textMuted} style={styles.label}>EQUIPMENT</Typography>
          <TouchableOpacity style={styles.dropdown}>
            <Typography variant="body" color={colors.text}>Select Equipment</Typography>
            <Typography variant="body" color={colors.textMuted}>▼</Typography>
          </TouchableOpacity>
        </View>

        <View style={styles.inputGroup}>
          <Typography variant="microcopy" color={colors.textMuted} style={styles.label}>PRIMARY MUSCLE</Typography>
          <TouchableOpacity style={styles.dropdown}>
            <Typography variant="body" color={colors.text}>Select Muscle Group</Typography>
            <Typography variant="body" color={colors.textMuted}>▼</Typography>
          </TouchableOpacity>
        </View>

      </ScrollView>

      <View style={styles.footer}>
        <GlassButton title="SAVE EXERCISE" variant="primary" style={{ flex: 1 }} />
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
  backBtn: {
    padding: spacing.xs,
  },
  scrollView: { flex: 1 },
  container: { 
    padding: spacing.screenHorizontal, 
    paddingTop: spacing.xl,
    paddingBottom: spacing.xxl 
  },
  inputGroup: {
    marginBottom: spacing.xl,
  },
  label: {
    marginBottom: spacing.sm,
  },
  input: {
    height: 48,
    backgroundColor: colors.glassBase,
    borderWidth: 1,
    borderColor: colors.glassBorder,
    color: colors.text,
    paddingHorizontal: spacing.md,
    fontSize: 16,
  },
  dropdown: {
    height: 48,
    backgroundColor: colors.glassBase,
    borderWidth: 1,
    borderColor: colors.glassBorder,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: spacing.md,
  },
  footer: {
    padding: spacing.screenHorizontal,
    borderTopWidth: 1,
    borderTopColor: colors.glassBorder,
    backgroundColor: colors.background,
  }
});
