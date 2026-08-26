import React, { useEffect, useState } from 'react';
import { StatusBar, StyleSheet, View } from 'react-native';
import { SafeAreaProvider, initialWindowMetrics } from 'react-native-safe-area-context';
import { NavigationContainer, DefaultTheme } from '@react-navigation/native';
import { initDatabase } from '@/database';
import { Typography } from '@/components/common/Typography';
import { RootNavigator } from '@/navigation/RootNavigator';
import { theme } from '@/theme';
import { SyncEngine } from '@/services/sync/SyncEngine';

import { useExerciseStore, useWorkoutStore, useRoutineStore } from '@/store';

function App() {
  const [isDbReady, setIsDbReady] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function setup() {
      try {
        await initDatabase();
        SyncEngine.init();
        
        // Seed and load initial global data
        await useExerciseStore.getState().loadExercises();
        await useRoutineStore.getState().loadRoutines();
        await useWorkoutStore.getState().loadRecentWorkouts();
        
        setIsDbReady(true);
      } catch (e) {
        setError(e instanceof Error ? e.message : 'Database initialization failed');
      }
    }
    setup();
  }, []);

  if (error) {
    return (
      <View style={[styles.container, styles.centered]}>
        <Typography variant="label" color={theme.colors.error}>
          SYSTEM ERROR: {error}
        </Typography>
      </View>
    );
  }

  if (!isDbReady) {
    return (
      <View style={[styles.container, styles.centered]}>
        <Typography variant="label" color={theme.colors.warning}>
          INITIALIZING...
        </Typography>
      </View>
    );
  }

  return (
    <SafeAreaProvider initialMetrics={initialWindowMetrics} style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor={theme.colors.background} />
      <NavigationContainer theme={{
        ...DefaultTheme,
        dark: true,
        colors: {
          ...DefaultTheme.colors,
          primary: theme.colors.primary,
          background: theme.colors.background,
          card: theme.colors.glassBase,
          text: theme.colors.text,
          border: theme.colors.glassBorder,
          notification: theme.colors.primary,
        }
      }}>
        <RootNavigator />
      </NavigationContainer>
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.background,
  },
  centered: {
    justifyContent: 'center',
    alignItems: 'center',
  },
});

export default App;
