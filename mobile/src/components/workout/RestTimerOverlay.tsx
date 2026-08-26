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
    <View style={styles.overlayContainer} pointerEvents="box-none">
      <View style={styles.pill}>
        <View style={styles.timerLeft}>
          <Timer color={colors.primary} size={20} />
          <Typography variant="header" tabular style={styles.timeText}>{timeStr}</Typography>
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
            <X color={colors.text} size={24} />
          </TouchableOpacity>
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  overlayContainer: {
    position: 'absolute',
    bottom: spacing.xxl, // Float above bottom
    left: 0,
    right: 0,
    alignItems: 'center',
    paddingHorizontal: spacing.md,
  },
  pill: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: 'rgba(15, 17, 21, 0.95)', // Deep glass
    borderWidth: 1,
    borderColor: 'rgba(0, 240, 255, 0.3)', // Cyan glow border
    borderRadius: radii.full,
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.lg,
    width: '100%',
    shadowColor: colors.primary,
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.3,
    shadowRadius: 24,
    elevation: 10,
  },
  timerLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
  },
  timeText: {
    color: colors.primary,
    fontWeight: '600',
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
    height: 24,
    backgroundColor: colors.glassBorder,
    marginHorizontal: spacing.xs,
  },
  closeBtn: {
    padding: spacing.xs,
  },
});
