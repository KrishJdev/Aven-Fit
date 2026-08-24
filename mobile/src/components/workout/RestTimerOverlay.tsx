import React from 'react';
import { View, StyleSheet, TouchableOpacity } from 'react-native';
import { Typography } from '../common/Typography';
import { theme } from '@/theme';
import { X, Plus, Minus } from 'lucide-react-native';

export const RestTimerOverlay: React.FC = () => {
  // Mock timer state for design phase
  return (
    <View style={styles.container}>
      <View style={styles.content}>
        <View style={styles.left}>
          <Typography variant="label" color={theme.colors.warning}>RESTING</Typography>
          <Typography variant="display" style={styles.timerText}>01:25</Typography>
        </View>

        <View style={styles.actions}>
          <TouchableOpacity style={styles.actionBtn}>
            <Minus color={theme.colors.text} size={20} />
          </TouchableOpacity>
          <TouchableOpacity style={styles.actionBtn}>
            <Plus color={theme.colors.text} size={20} />
          </TouchableOpacity>
          <TouchableOpacity style={[styles.actionBtn, styles.closeBtn]}>
            <X color={theme.colors.background} size={20} />
          </TouchableOpacity>
        </View>
      </View>
      <View style={styles.progressTrack}>
        <View style={[styles.progressFill, { width: '45%' }]} />
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    bottom: 24,
    left: theme.spacing.screenHorizontal,
    right: theme.spacing.screenHorizontal,
    backgroundColor: theme.colors.surface,
    borderRadius: theme.radii.md,
    borderWidth: 1,
    borderColor: theme.colors.warningMuted,
    overflow: 'hidden',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.5,
    shadowRadius: 16,
    elevation: 10,
  },
  content: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: theme.spacing.md,
  },
  left: {
    justifyContent: 'center',
  },
  timerText: {
    fontVariant: ['tabular-nums'],
    marginTop: -4,
  },
  actions: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  actionBtn: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: theme.colors.surfaceHighlight,
    justifyContent: 'center',
    alignItems: 'center',
    marginLeft: theme.spacing.xs,
  },
  closeBtn: {
    backgroundColor: theme.colors.warning,
  },
  progressTrack: {
    height: 4,
    backgroundColor: theme.colors.surfaceHighlight,
  },
  progressFill: {
    height: '100%',
    backgroundColor: theme.colors.warning,
  },
});
