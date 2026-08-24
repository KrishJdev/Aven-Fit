import React from 'react';
import { View, StyleSheet } from 'react-native';
import { Typography } from '../common/Typography';
import { theme } from '@/theme';
import { Trophy } from 'lucide-react-native';

interface PersonalRecordProps {
  exerciseName: string;
  recordType: 'MAX_WEIGHT' | 'MAX_VOLUME' | 'EST_1RM' | 'MAX_REPS';
  value: string;
  date: string;
}

const RECORD_LABELS = {
  MAX_WEIGHT: 'Max Weight',
  MAX_VOLUME: 'Max Volume',
  EST_1RM: 'Estimated 1RM',
  MAX_REPS: 'Max Reps',
};

export const PersonalRecordCard: React.FC<PersonalRecordProps> = ({ 
  exerciseName, 
  recordType, 
  value, 
  date 
}) => {
  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <View style={styles.titleRow}>
          <Trophy color={theme.colors.highlight} size={16} />
          <Typography variant="label" color={theme.colors.highlight} style={styles.label}>
            {RECORD_LABELS[recordType]}
          </Typography>
        </View>
        <Typography variant="body" color={theme.colors.textSubtle}>
          {date}
        </Typography>
      </View>
      
      <View style={styles.content}>
        <Typography variant="h2">{exerciseName}</Typography>
        <Typography variant="display" style={styles.value}>{value}</Typography>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    backgroundColor: theme.colors.surface,
    borderRadius: theme.radii.md,
    padding: theme.spacing.lg,
    borderWidth: 1,
    borderColor: theme.colors.surfaceHighlight,
    marginBottom: theme.spacing.md,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: theme.spacing.md,
  },
  titleRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  label: {
    marginLeft: theme.spacing.xs,
  },
  content: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
  },
  value: {
    color: theme.colors.text,
  }
});
