import { MaterialIcons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { useRouter } from 'expo-router';
import { StyleSheet, View } from 'react-native';
import { Card, Loading, ScreenContainer, Text } from '@/components';
import {
  useActiveMissions,
  useBadges,
  usePointsSummary,
} from '@/features/gamification/hooks';
import { colors, gradients, radius, spacing } from '@/theme';

export default function GamificationScreen() {
  const router = useRouter();
  const summary = usePointsSummary();
  const badges = useBadges();
  const missions = useActiveMissions();

  const s = summary.data;
  const progressPct =
    s && s.next_level_points
      ? Math.min((s.total_points / s.next_level_points) * 100, 100)
      : 100;

  const onRefresh = () => {
    summary.refetch();
    badges.refetch();
    missions.refetch();
  };

  return (
    <ScreenContainer scroll refreshing={summary.isRefetching} onRefresh={onRefresh}>
      <Text variant="h2" style={{ marginBottom: spacing.lg }}>
        Logros
      </Text>

      {/* Nivel + puntos */}
      {summary.isLoading ? (
        <Card><Loading /></Card>
      ) : (
        <LinearGradient
          colors={gradients.premium as unknown as [string, string]}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={styles.levelCard}
        >
          <View style={styles.levelHeader}>
            <View>
              <Text variant="caption" color={colors.white}>
                NIVEL
              </Text>
              <Text variant="h3" color={colors.white}>
                {s?.level.name ?? 'Bronce'}
              </Text>
            </View>
            <View style={styles.pointsBadge}>
              <MaterialIcons name="stars" size={18} color={colors.gold} />
              <Text variant="numberSmall" color={colors.white}>
                {s?.total_points ?? 0}
              </Text>
            </View>
          </View>

          <View style={styles.levelTrack}>
            <View style={[styles.levelFill, { width: `${progressPct}%` }]} />
          </View>
          <Text variant="caption" color={colors.white} style={{ marginTop: 6 }}>
            {s?.next_level_points
              ? `${s.points_to_next_level} pts para el siguiente nivel`
              : '¡Nivel máximo alcanzado!'}
          </Text>
        </LinearGradient>
      )}

      {/* Racha + insignias */}
      <View style={styles.statsRow}>
        <Card style={styles.statCard}>
          <MaterialIcons name="local-fire-department" size={26} color={colors.orange} />
          <Text variant="numberMedium">{s?.streak_days ?? 0}</Text>
          <Text variant="bodySmall" color={colors.gray500}>
            Días de racha
          </Text>
        </Card>
        <Card style={styles.statCard}>
          <MaterialIcons name="military-tech" size={26} color={colors.teal} />
          <Text variant="numberMedium">
            {s?.badges_unlocked ?? 0}/{s?.total_badges ?? 0}
          </Text>
          <Text variant="bodySmall" color={colors.gray500}>
            Insignias
          </Text>
        </Card>
      </View>

      {/* Asesor IA */}
      <Card style={styles.aiCard}>
        <View style={styles.aiIcon}>
          <MaterialIcons name="auto-awesome" size={22} color={colors.white} />
        </View>
        <View style={styles.flex}>
          <Text variant="h5">Asesor financiero IA</Text>
          <Text variant="bodySmall" color={colors.gray500}>
            Pregúntale cómo mejorar tus finanzas
          </Text>
        </View>
        <MaterialIcons
          name="chevron-right"
          size={24}
          color={colors.gray400}
          onPress={() => router.push('/(app)/ai-chat')}
        />
      </Card>

      {/* Desafíos */}
      <Text variant="h4" style={styles.sectionTitle}>
        Desafíos activos
      </Text>
      {missions.isLoading ? (
        <Card><Loading /></Card>
      ) : (missions.data ?? []).length === 0 ? (
        <Card>
          <Text variant="bodyMedium" color={colors.gray500} center>
            No hay desafíos activos por ahora.
          </Text>
        </Card>
      ) : (
        (missions.data ?? []).map((m) => (
          <Card key={m.id} style={styles.missionCard}>
            <View style={styles.flex}>
              <Text variant="h5">{m.title}</Text>
              <Text variant="bodySmall" color={colors.gray500}>
                {m.description}
              </Text>
            </View>
            <View style={styles.reward}>
              <MaterialIcons name="stars" size={14} color={colors.gold} />
              <Text variant="caption" color={colors.gray700}>
                +{m.reward_points}
              </Text>
            </View>
          </Card>
        ))
      )}

      {/* Insignias */}
      <Text variant="h4" style={styles.sectionTitle}>
        Insignias
      </Text>
      <View style={styles.badgeGrid}>
        {[...(badges.data?.unlocked ?? []), ...(badges.data?.locked ?? [])].slice(0, 8).map((b) => (
          <View key={b.id} style={styles.badgeItem}>
            <View style={[styles.badgeCircle, !b.unlocked && styles.badgeLocked]}>
              <MaterialIcons
                name={b.unlocked ? 'emoji-events' : 'lock'}
                size={24}
                color={b.unlocked ? colors.gold : colors.gray400}
              />
            </View>
            <Text variant="caption" color={colors.gray600} center numberOfLines={1}>
              {b.title}
            </Text>
          </View>
        ))}
      </View>
    </ScreenContainer>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  levelCard: { borderRadius: radius.lg, padding: spacing.lg },
  levelHeader: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: spacing.md },
  pointsBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    backgroundColor: '#FFFFFF33',
    paddingHorizontal: spacing.sm,
    paddingVertical: 4,
    borderRadius: 999,
  },
  levelTrack: { height: 8, borderRadius: 4, backgroundColor: '#FFFFFF44', overflow: 'hidden' },
  levelFill: { height: 8, borderRadius: 4, backgroundColor: colors.white },
  statsRow: { flexDirection: 'row', gap: spacing.md, marginTop: spacing.md },
  statCard: { flex: 1, alignItems: 'center', gap: 2 },
  aiCard: { flexDirection: 'row', alignItems: 'center', gap: spacing.sm, marginTop: spacing.md },
  aiIcon: {
    width: 42,
    height: 42,
    borderRadius: 21,
    backgroundColor: colors.teal,
    alignItems: 'center',
    justifyContent: 'center',
  },
  sectionTitle: { marginTop: spacing.lg, marginBottom: spacing.sm },
  missionCard: { flexDirection: 'row', alignItems: 'center', gap: spacing.sm, marginBottom: spacing.sm },
  reward: { flexDirection: 'row', alignItems: 'center', gap: 2 },
  badgeGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: spacing.sm },
  badgeItem: { width: '22%', alignItems: 'center', gap: 4 },
  badgeCircle: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: colors.orangeLight,
    alignItems: 'center',
    justifyContent: 'center',
  },
  badgeLocked: { backgroundColor: colors.gray100 },
});
