import { SafeAreaView } from 'react-native-safe-area-context';
import React, { useState } from 'react';
import { View, StyleSheet, FlatList, TextInput, TouchableOpacity, ScrollView } from 'react-native';
import { Typography, GlassCard } from '../../components/ui';
import { colors } from '../../theme/colors';
import { spacing } from '../../theme/spacing';
import { Search, Plus, Dumbbell, ChevronRight } from 'lucide-react-native';

import { useNavigation } from '@react-navigation/native';
import { useExerciseStore, useWorkoutStore } from '@/store';

const FILTERS = ['All', 'Barbell', 'Dumbbell', 'Machine', 'Cable', 'Bodyweight'];

export const ExerciseDirectoryScreen = () => {
  const [activeFilter, setActiveFilter] = useState('All');
  const [searchQuery, setSearchQuery] = useState('');
  
  const navigation = useNavigation();
  const { exercises } = useExerciseStore();
  const { activeWorkoutId, addExerciseToWorkout } = useWorkoutStore();

  const handleSelectExercise = async (exerciseId: string, exerciseName: string) => {
    if (activeWorkoutId) {
      // If we are currently in a workout, add it to the workout and go back
      await addExerciseToWorkout(exerciseId, exerciseName);
      navigation.goBack();
    } else {
      // Otherwise maybe view details (optional)
      // navigation.navigate('ExerciseDetail', { exerciseId });
    }
  };

  const filtered = exercises.filter(ex => {
    if (activeFilter !== 'All' && ex.equipment !== activeFilter) return false;
    if (searchQuery && !ex.name.toLowerCase().includes(searchQuery.toLowerCase())) return false;
    return true;
  });

  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.container}>
        {/* Header */}
        <View style={styles.header}>
          <Typography variant="hero">Exercises</Typography>
        </View>

        {/* Search */}
        <View style={styles.searchContainer}>
          <Search color={colors.textMuted} size={20} style={styles.searchIcon} />
          <TextInput
            style={styles.searchInput}
            placeholder="Search exercises..."
            placeholderTextColor={colors.textSubtle}
            value={searchQuery}
            onChangeText={setSearchQuery}
          />
        </View>

        {/* Filters */}
        <View style={styles.filtersWrapper}>
          <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.filtersList}>
            {FILTERS.map((f) => (
              <TouchableOpacity
                key={f}
                style={[styles.filterChip, activeFilter === f && styles.filterChipActive]}
                onPress={() => setActiveFilter(f)}
              >
                <Typography variant="microcopy" color={activeFilter === f ? colors.background : colors.textMuted}>
                  {f}
                </Typography>
              </TouchableOpacity>
            ))}
          </ScrollView>
        </View>

        {/* List */}
        <FlatList
          data={filtered}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.listContent}
          renderItem={({ item }) => (
            <TouchableOpacity 
              style={styles.exerciseRow} 
              activeOpacity={0.7}
              onPress={() => handleSelectExercise(item.id, item.name)}
            >
              <View style={styles.rowLeft}>
                <View style={styles.iconBox}>
                  <Dumbbell color={colors.text} size={20} />
                </View>
                <View>
                  <Typography variant="body" style={{ fontWeight: '700' }}>{item.name}</Typography>
                  <Typography variant="microcopy" color={colors.textMuted}>
                    {item.category} • {item.equipment}
                  </Typography>
                </View>
              </View>
              {activeWorkoutId ? (
                <Plus color={colors.primary} size={20} />
              ) : (
                <ChevronRight color={colors.textSubtle} size={20} />
              )}
            </TouchableOpacity>
          )}
        />

        {/* FAB for Custom Exercise */}
        <TouchableOpacity style={styles.fab}>
          <Plus color="#000" size={24} />
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  safeArea: { flex: 1, backgroundColor: colors.background },
  container: { flex: 1 },
  header: {
    paddingHorizontal: spacing.screenHorizontal,
    marginTop: spacing.md,
    marginBottom: spacing.md,
  },
  searchContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.glassBase,
    borderWidth: 1,
    borderColor: colors.glassBorder,
    marginHorizontal: spacing.screenHorizontal,
    paddingHorizontal: spacing.md,
    marginBottom: spacing.md,
  },
  searchIcon: {
    marginRight: spacing.sm,
  },
  searchInput: {
    flex: 1,
    height: 48,
    color: colors.text,
    fontSize: 16,
  },
  filtersWrapper: {
    marginBottom: spacing.md,
  },
  filtersList: {
    paddingHorizontal: spacing.screenHorizontal,
    gap: spacing.sm,
  },
  filterChip: {
    borderWidth: 1,
    borderColor: colors.glassBorder,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.sm,
    backgroundColor: colors.background,
  },
  filterChipActive: {
    backgroundColor: '#FFF',
    borderColor: '#FFF',
  },
  listContent: {
    paddingHorizontal: spacing.screenHorizontal,
    paddingBottom: 100, // Space for FAB
  },
  exerciseRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: colors.glassBorder,
  },
  rowLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.md,
  },
  iconBox: {
    width: 40,
    height: 40,
    backgroundColor: colors.glassBase,
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 1,
    borderColor: colors.glassBorder,
  },
  fab: {
    position: 'absolute',
    bottom: 24,
    right: spacing.screenHorizontal,
    width: 56,
    height: 56,
    backgroundColor: '#FFF',
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 5,
  }
});
