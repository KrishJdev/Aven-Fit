import React from 'react';
import { View, ViewProps, StyleSheet } from 'react-native';
import { colors } from '../../theme/colors';
import { spacing, radii } from '../../theme/spacing';

interface GlassCardProps extends ViewProps {
  noPadding?: boolean;
}

export const GlassCard: React.FC<GlassCardProps> = ({
  noPadding = false,
  style,
  children,
  ...props
}) => {
  return (
    <View
      style={[
        styles.card,
        !noPadding && { padding: spacing.md },
        style,
      ]}
      {...props}
    >
      {children}
    </View>
  );
};

const styles = StyleSheet.create({
  card: {
    backgroundColor: colors.glassBase,
    borderWidth: StyleSheet.hairlineWidth, // Ultra-thin border for glass effect
    borderColor: colors.glassBorder,
    borderRadius: radii.md, // 12px for modern soft glass feel
  },
});
