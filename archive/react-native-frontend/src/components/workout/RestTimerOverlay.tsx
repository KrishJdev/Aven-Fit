import React from 'react';
import { View, StyleSheet, TouchableOpacity } from 'react-native';
import { Typography } from '../ui/Typography';
import { colors } from '../../theme/colors';
import { spacing, radii } from '../../theme/spacing';
import { Timer, X, Plus, Minus } from 'lucide-react-native';

interface RestTimerOverlayProps {
  timeRemaining: number;
  onClose: () => void;
  onAddTime: (seconds: number) => void;
  onSubtractTime: (seconds: number) => void;
}

export const RestTimerOverlay: React.FC<RestTimerOverlayProps> = ({
  timeRemaining,
  onClose,
  onAddTime,
  onSubtractTime,
}) => {
  const mins = Math.floor(timeRemaining / 60);
  const secs = timeRemaining % 60;
  const timeStr = `${mins}:${secs.toString().padStart(2, '0')}`;

  return (
    <View style={styles.barContainer}>
      <View style={styles.timerLeft}>
        <Timer color={colors.primary} size={20} />
        <Typography variant="body" tabular style={styles.timeText}>{timeStr}</Typography>
      </View>
      
      <View style={styles.actions}>
        <TouchableOpacity style={styles.actionBtn} onPress={() => onSubtractTime(15)}>
          <Typography variant="body" color={colors.textMuted}>-15s</Typography>
        </TouchableOpacity>
        <TouchableOpacity style={styles.actionBtn} onPress={() => onAddTime(15)}>
          <Typography variant="body" color={colors.textMuted}>+15s</Typography>
        </TouchableOpacity>
        <View style={styles.divider} />
        <TouchableOpacity style={styles.closeBtn} onPress={onClose}>
          <X color={colors.textSubtle} size={20} />
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  barContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: colors.glassBase,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: colors.glassBorder,
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.md,
  },
  timerLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
  },
  timeText: {
    color: colors.primary,
    fontWeight: '600',
    fontSize: 18,
  },
  actions: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
  },
  actionBtn: {
    paddingHorizontal: spacing.xs,
    paddingVertical: spacing.xs,
  },
  divider: {
    width: 1,
    height: 16,
    backgroundColor: colors.glassBorder,
    marginHorizontal: spacing.xs,
  },
  closeBtn: {
    padding: spacing.xs,
  },
});
