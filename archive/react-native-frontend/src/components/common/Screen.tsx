import React from 'react';
import { View, ViewProps, StyleSheet, StatusBar } from 'react-native';
import { theme } from '@/theme';

interface ScreenProps extends ViewProps {
  safeArea?: boolean;
  edges?: ('top' | 'right' | 'bottom' | 'left')[];
}

export const Screen: React.FC<ScreenProps> = ({
  safeArea = true,
  edges = ['top', 'left', 'right', 'bottom'],
  style,
  children,
  ...props
}) => {
  return (
    <View style={[styles.container, style]} {...props}>
      <StatusBar barStyle="light-content" backgroundColor={theme.colors.background} />
      {children}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.background,
    paddingTop: 40,
  },
});
