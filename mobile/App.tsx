import React, { useEffect, useState } from 'react';
import { StatusBar, StyleSheet, View } from 'react-native';
import { SafeAreaProvider, SafeAreaView } from 'react-native-safe-area-context';
import { initDatabase } from '@/database';
import { Typography } from '@/components/common/Typography';
import { theme } from '@/theme';

function App() {
  const [isDbReady, setIsDbReady] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function setup() {
      try {
        await initDatabase();
        setIsDbReady(true);
      } catch (e) {
        setError(e instanceof Error ? e.message : 'Database initialization failed');
      }
    }
    setup();
  }, []);

  return (
    <SafeAreaProvider>
      {/* Force light-content as Aven Fit uses a premium dark theme by default */}
      <StatusBar barStyle="light-content" />
      
      <SafeAreaView style={styles.container} edges={['top', 'left', 'right', 'bottom']}>
        <View style={styles.content}>
          <Typography variant="h1" style={styles.title}>
            AVEN FIT
          </Typography>
          
          <Typography variant="body" color={theme.colors.textMuted} align="center" style={styles.subtitle}>
            Premium Performance Tracking
          </Typography>

          <View style={styles.statusBox}>
            {error ? (
              <Typography variant="label" color={theme.colors.error}>
                SYSTEM ERROR: {error}
              </Typography>
            ) : isDbReady ? (
              <Typography variant="label" color={theme.colors.success}>
                ● SYSTEM READY
              </Typography>
            ) : (
              <Typography variant="label" color={theme.colors.warning}>
                ○ INITIALIZING...
              </Typography>
            )}
          </View>
        </View>
      </SafeAreaView>
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.background,
  },
  content: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: theme.spacing.lg,
  },
  title: {
    letterSpacing: 2,
    marginBottom: theme.spacing.sm,
  },
  subtitle: {
    marginBottom: theme.spacing.xl,
  },
  statusBox: {
    marginTop: theme.spacing.xxl,
    paddingVertical: theme.spacing.sm,
    paddingHorizontal: theme.spacing.lg,
    backgroundColor: theme.colors.surface,
    borderRadius: theme.radii.sm,
    borderWidth: 1,
    borderColor: theme.colors.surfaceHighlight,
  }
});

export default App;
