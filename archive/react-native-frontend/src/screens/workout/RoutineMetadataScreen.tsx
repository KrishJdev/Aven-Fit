import { SafeAreaView } from 'react-native-safe-area-context';
import React, { useState } from 'react';
import { View, Alert, StyleSheet, TouchableOpacity, TextInput } from 'react-native';
import { Typography, GlassButton } from '../../components/ui';
import { colors } from '../../theme/colors';
import { spacing } from '../../theme/spacing';
import { ChevronLeft } from 'lucide-react-native';
import { useNavigation } from '@react-navigation/native';
import { useRoutineStore } from '@/store';

export const RoutineMetadataScreen = () => {
  const navigation = useNavigation();
  const { createRoutine } = useRoutineStore();
  
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [isSaving, setIsSaving] = useState(false);

  const handleSave = async () => {
    if (!name.trim()) return;
    setIsSaving(true);
    try {
      await createRoutine(name, description);
      navigation.goBack();
    } catch (e) {
      console.error(e); Alert.alert('Error', (e as any)?.message || 'Failed to save routine.');
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <SafeAreaView style={styles.safeArea}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backBtn} onPress={() => navigation.goBack()}>
          <ChevronLeft color={colors.text} size={28} />
        </TouchableOpacity>
        <Typography variant="title">New Routine</Typography>
        <View style={{ width: 28 }} />
      </View>
      
      <View style={styles.container}>
        <View style={styles.inputGroup}>
          <Typography variant="microcopy" color={colors.textMuted} style={styles.label}>ROUTINE NAME</Typography>
          <TextInput
            style={styles.input}
            placeholder="e.g. Push Day"
            placeholderTextColor={colors.textSubtle}
            value={name}
            onChangeText={setName}
          />
        </View>

        <View style={styles.inputGroup}>
          <Typography variant="microcopy" color={colors.textMuted} style={styles.label}>DESCRIPTION (OPTIONAL)</Typography>
          <TextInput
            style={[styles.input, styles.textArea]}
            placeholder="e.g. Focus on upper chest"
            placeholderTextColor={colors.textSubtle}
            multiline
            textAlignVertical="top"
            value={description}
            onChangeText={setDescription}
          />
        </View>
      </View>

      <View style={styles.footer}>
        <GlassButton 
          title="SAVE PLAN" 
          variant="primary" 
          style={{ flex: 1 }} 
          onPress={handleSave}
          disabled={!name.trim() || isSaving}
        />
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
  container: { 
    flex: 1,
    padding: spacing.screenHorizontal, 
    paddingTop: spacing.xl,
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
  textArea: {
    height: 100,
    paddingVertical: spacing.md,
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


