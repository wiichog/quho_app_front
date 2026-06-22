import { MaterialIcons } from '@expo/vector-icons';
import { useQuery } from '@tanstack/react-query';
import { useRouter } from 'expo-router';
import { useMemo } from 'react';
import { Pressable, StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { getInsights, getScore } from '@/api/ai';
import { Card, EmptyState, Loading, Text } from '@/components';
import { colors, radius, spacing } from '@/theme';
import { apiMonth, monthYear } from '@/utils/formatters';

function scoreColor(score: number): string {
  if (score >= 75) return colors.green;
  if (score >= 50) return colors.orange;
  return colors.red;
}

export default function InsightsScreen() {
  const router = useRouter();
  const month = useMemo(() => apiMonth(), []);
  const score = useQuery({ queryKey: ['ai', 'score', month], queryFn: () => getScore(month) });
  const insights = useQuery({ queryKey: ['ai', 'insights', month], queryFn: () => getInsights(month) });

  const loading = score.isLoading || insights.isLoading;
  const hasScore = score.data?.score != null;
  const breakdown = (score.data?.breakdown ?? {}) as Record<string, number>;

  return (
    <SafeAreaView style={styles.safe}>
      <View style={styles.header}>
        <Pressable onPress={() => router.back()} hitSlop={8}>
          <MaterialIcons name="arrow-back" size={24} color={colors.gray700} />
        </Pressable>
        <Text variant="h4">Reportes e insights</Text>
        <View style={{ width: 24 }} />
      </View>

      <View style={styles.content}>
        <Text variant="bodyMedium" color={colors.gray500} style={{ marginBottom: spacing.md }}>
          {monthYear(new Date())}
        </Text>

        {loading ? (
          <Loading />
        ) : !hasScore && (insights.data ?? []).length === 0 ? (
          <EmptyState
            icon="insights"
            title="Aún no hay reportes"
            message="Registra movimientos durante el mes y tu asesor IA generará tu score e insights financieros."
          />
        ) : (
          <>
            {hasScore ? (
              <Card style={styles.scoreCard}>
                <View
                  style={[styles.scoreCircle, { borderColor: scoreColor(score.data!.score!) }]}
                >
                  <Text variant="numberLarge" color={scoreColor(score.data!.score!)}>
                    {score.data!.score}
                  </Text>
                  <Text variant="caption" color={colors.gray500}>
                    / 100
                  </Text>
                </View>
                <Text variant="h5" center style={{ marginTop: spacing.sm }}>
                  Tu score financiero
                </Text>
                {Object.keys(breakdown).length > 0 ? (
                  <View style={styles.breakdown}>
                    {Object.entries(breakdown).map(([key, value]) => (
                      <View key={key} style={styles.breakdownRow}>
                        <Text variant="bodySmall" color={colors.gray600} style={styles.flex}>
                          {key.replace(/_/g, ' ')}
                        </Text>
                        <View style={styles.miniTrack}>
                          <View style={[styles.miniFill, { width: `${Math.min(Number(value), 100)}%` }]} />
                        </View>
                      </View>
                    ))}
                  </View>
                ) : null}
              </Card>
            ) : null}

            {(insights.data ?? []).map((ins) => (
              <Card key={ins.id} style={styles.insightCard}>
                <View style={styles.insightIcon}>
                  <MaterialIcons name="lightbulb" size={18} color={colors.teal} />
                </View>
                <View style={styles.flex}>
                  <Text variant="h5">{ins.title}</Text>
                  <Text variant="bodySmall" color={colors.gray600}>
                    {ins.body}
                  </Text>
                </View>
              </Card>
            ))}
          </>
        )}
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: colors.gray50 },
  flex: { flex: 1 },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: spacing.md,
  },
  content: { flex: 1, paddingHorizontal: spacing.lg },
  scoreCard: { alignItems: 'center', marginBottom: spacing.md },
  scoreCircle: {
    width: 120,
    height: 120,
    borderRadius: 60,
    borderWidth: 8,
    alignItems: 'center',
    justifyContent: 'center',
  },
  breakdown: { alignSelf: 'stretch', marginTop: spacing.md, gap: spacing.xs },
  breakdownRow: { flexDirection: 'row', alignItems: 'center', gap: spacing.sm },
  miniTrack: { width: 120, height: 6, borderRadius: 3, backgroundColor: colors.gray100, overflow: 'hidden' },
  miniFill: { height: 6, borderRadius: 3, backgroundColor: colors.teal },
  insightCard: { flexDirection: 'row', gap: spacing.sm, marginBottom: spacing.sm },
  insightIcon: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: colors.tealPale,
    alignItems: 'center',
    justifyContent: 'center',
  },
});
