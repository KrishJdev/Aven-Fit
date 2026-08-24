import React from 'react';
import { View, ViewProps, StyleSheet } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
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
  if (safeArea) {
    return (
      <SafeAreaView style={[styles.container, style]} edges={edges} {...props}>
        {children}
      </SafeAreaView>
    );
  }

  return (
    <View style={[styles.container, style]} {...props}>
      {children}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.background,
  },
});
