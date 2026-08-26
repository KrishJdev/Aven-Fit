import { SafeAreaView } from 'react-native-safe-area-context';
import React, { useState } from 'react';
import { View, StyleSheet, FlatList, TextInput, TouchableOpacity } from 'react-native';
import { Typography } from '../../components/ui';
import { colors } from '../../theme/colors';
import { spacing } from '../../theme/spacing';
import { Search, ChevronLeft, Plus } from 'lucide-react-native';

const MOCK_RESULTS = [
  { id: '1', name: 'Roti / Chapati', brand: 'Generic', calories: '104 kcal', serving: '1 medium (30g)' },
  { id: '2', name: 'Dal Tadka', brand: 'Generic', calories: '150 kcal', serving: '1 katori (150g)' },
  { id: '3', name: 'Chicken Breast (Cooked)', brand: 'Generic', calories: '165 kcal', serving: '100g' },
];

export const FoodDatabaseSearchScreen = () => {
  const [searchQuery, setSearchQuery] = useState('');

  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backBtn}>
          <ChevronLeft color={colors.text} size={28} />
        </TouchableOpacity>
        
        <View style={styles.searchContainer}>
          <Search color={colors.textMuted} size={18} style={styles.searchIcon} />
          <TextInput
            style={styles.searchInput}
            placeholder="Search food or brand..."
            placeholderTextColor={colors.textSubtle}
            value={searchQuery}
            onChangeText={setSearchQuery}
            autoFocus
          />
        </View>
      </View>

      <FlatList
        data={MOCK_RESULTS}
        keyExtractor={(item) => item.id}
        contentContainerStyle={styles.listContent}
        renderItem={({ item }) => (
          <TouchableOpacity style={styles.resultRow}>
            <View style={styles.resultInfo}>
              <Typography variant="body" style={{ fontWeight: '700' }}>{item.name}</Typography>
              <Typography variant="microcopy" color={colors.textMuted}>
                {item.brand} • {item.serving}
              </Typography>
            </View>
            <View style={styles.resultStats}>
              <Typography variant="body" tabular>{item.calories}</Typography>
              <Plus color={colors.textMuted} size={20} />
            </View>
          </TouchableOpacity>
        )}
      />

    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  safeArea: { flex: 1, backgroundColor: colors.background },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: colors.glassBorder,
  },
  backBtn: { padding: spacing.xs, marginRight: spacing.sm },
  searchContainer: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.glassBase,
    borderWidth: 1,
    borderColor: colors.glassBorder,
    paddingHorizontal: spacing.sm,
    height: 40,
  },
  searchIcon: { marginRight: spacing.sm },
  searchInput: {
    flex: 1,
    color: colors.text,
    fontSize: 16,
  },
  listContent: {
    paddingHorizontal: spacing.screenHorizontal,
  },
  resultRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: spacing.md,
    borderBottomWidth: 1,
    borderBottomColor: colors.glassBorder,
  },
  resultInfo: {
    flex: 1,
  },
  resultStats: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.md,
  }
});
