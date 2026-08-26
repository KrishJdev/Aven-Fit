import React from 'react';
import { View, StyleSheet } from 'react-native';
import { Typography } from '../common/Typography';
import { theme } from '@/theme';
import { Dumbbell } from 'lucide-react-native';

export interface HistoryItem {
  id: string;
  date: string;
  name: string;
  volume: string;
  prCount: number;
}

interface HistoryLedgerProps {
  items: HistoryItem[];
}

export const HistoryLedger: React.FC<HistoryLedgerProps> = ({ items }) => {
  return (
    <View style={styles.container}>
      <Typography variant="label" style={styles.title}>RECENT HISTORY</Typography>
      
      <View style={styles.list}>
        {items.map((item, index) => {
          const isLast = index === items.length - 1;
          
          return (
            <View key={item.id} style={styles.row}>
              {/* Timeline Column */}
              <View style={styles.timelineCol}>
                <View style={styles.node}>
                  <Dumbbell color={theme.colors.background} size={12} />
                </View>
                {!isLast && <View style={styles.line} />}
              </View>
              
              {/* Content Column */}
              <View style={[styles.contentCol, isLast && styles.contentColLast]}>
                <View style={styles.header}>
                  <Typography variant="h2">{item.name}</Typography>
                  <Typography variant="body" color={theme.colors.textSubtle}>{item.date}</Typography>
                </View>
                
                <View style={styles.stats}>
                  <Typography variant="body" color={theme.colors.textMuted}>
                    Volume: {item.volume}
                  </Typography>
                  {item.prCount > 0 && (
                    <View style={styles.prBadge}>
                      <Typography variant="label" color={theme.colors.highlight} style={styles.prText}>
                        {item.prCount} PR{item.prCount > 1 ? 's' : ''}
                      </Typography>
                    </View>
                  )}
                </View>
              </View>
            </View>
          );
        })}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginTop: theme.spacing.lg,
  },
  title: {
    marginBottom: theme.spacing.lg,
    letterSpacing: 1,
  },
  list: {
    paddingLeft: theme.spacing.xs,
  },
  row: {
    flexDirection: 'row',
  },
  timelineCol: {
    alignItems: 'center',
    width: 24,
  },
  node: {
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: theme.colors.text,
    justifyContent: 'center',
    alignItems: 'center',
    zIndex: 2,
  },
  line: {
    flex: 1,
    width: 2,
    backgroundColor: theme.colors.glassBorder,
    marginVertical: -4,
    zIndex: 1,
  },
  contentCol: {
    flex: 1,
    paddingLeft: theme.spacing.md,
    paddingBottom: theme.spacing.xl,
  },
  contentColLast: {
    paddingBottom: 0,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'baseline',
    marginBottom: theme.spacing.xs,
  },
  stats: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  prBadge: {
    marginLeft: theme.spacing.sm,
    paddingHorizontal: 6,
    paddingVertical: 2,
    borderRadius: 4,
    backgroundColor: 'rgba(226, 248, 53, 0.1)', // Highlight with opacity
  },
  prText: {
    fontSize: 10,
  }
});
