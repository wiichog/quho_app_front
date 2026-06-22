import { MaterialIcons } from '@expo/vector-icons';
import { LinearGradient } from 'expo-linear-gradient';
import { useRouter } from 'expo-router';
import { useMemo } from 'react';
import { Pressable, StyleSheet, View } from 'react-native';
import { PieChart } from 'react-native-gifted-charts';
import {
  Card,
  EmptyState,
  Loading,
  ScreenContainer,
  Text,
  TransactionRow,
} from '@/components';
import { useBudgetSummary, usePlan } from '@/features/finances/hooks';
import { useTransactions } from '@/features/transactions/hooks';
import { useAuthStore } from '@/store/authStore';
import { colorForCategory, colors, gradients, radius, spacing } from '@/theme';
import { apiMonth, currency, monthYear } from '@/utils/formatters';
import { amountOf } from '@/utils/money';

export default function DashboardScreen() {
  const router = useRouter();
  const profile = useAuthStore((s) => s.profile);
  const month = useMemo(() => apiMonth(), []);

  const budget = useBudgetSummary(month);
  const plan = usePlan();
  const recent = useTransactions({ limit: 5 });

  const onRefresh = () => {
    budget.refetch();
    recent.refetch();
    plan.refetch();
  };

  const exec = budget.data?.execution;
  const income = amountOf(exec?.total_income);
  const expense = amountOf(exec?.total_expense);
  const net = amountOf(exec?.net ?? income - expense);
  const code = profile?.currency || 'MXN';

  const recentList = (recent.data?.results ?? []).slice(0, 5);

  const spendingData = useMemo(() => {
    const rows = budget.data?.category_breakdown ?? [];
    return rows
      .map((r) => ({
        value: amountOf(r.spent as number),
        text: r.category,
        color: colorForCategory(r.category),
      }))
      .filter((d) => d.value > 0)
      .slice(0, 6);
  }, [budget.data]);
  const totalSpending = spendingData.reduce((s, d) => s + d.value, 0);

  return (
    <ScreenContainer scroll refreshing={budget.isRefetching} onRefresh={onRefresh}>
      {/* Saludo */}
      <View style={styles.greetRow}>
        <View style={styles.flex}>
          <Text variant="bodyMedium" color={colors.gray500}>
            Hola,
          </Text>
          <Text variant="h3">{profile?.first_name || 'usuario'} 👋</Text>
        </View>
        <Pressable onPress={() => router.push('/(app)/profile')} style={styles.bell}>
          <MaterialIcons name="notifications-none" size={24} color={colors.gray700} />
        </Pressable>
      </View>

      {/* Hero card */}
      <LinearGradient
        colors={gradients.hero as unknown as [string, string]}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
        style={styles.hero}
      >
        <Text variant="caption" color={colors.tealLight}>
          BALANCE DEL MES · {monthYear(new Date()).toUpperCase()}
        </Text>
        <Text variant="numberLarge" color={colors.white} style={styles.heroBalance}>
          {currency(net, code)}
        </Text>
        <View style={styles.heroRow}>
          <View style={styles.heroStat}>
            <MaterialIcons name="arrow-downward" size={16} color={colors.tealLight} />
            <View>
              <Text variant="caption" color={colors.tealLight}>
                Ingresos
              </Text>
              <Text variant="numberSmall" color={colors.white}>
                {currency(income, code)}
              </Text>
            </View>
          </View>
          <View style={styles.heroDivider} />
          <View style={styles.heroStat}>
            <MaterialIcons name="arrow-upward" size={16} color={colors.orangeLight} />
            <View>
              <Text variant="caption" color={colors.tealLight}>
                Gastos
              </Text>
              <Text variant="numberSmall" color={colors.white}>
                {currency(expense, code)}
              </Text>
            </View>
          </View>
        </View>
      </LinearGradient>

      {/* Quick actions */}
      <View style={styles.actions}>
        <QuickAction icon="add" label="Agregar" onPress={() => router.push('/(app)/transactions/add')} />
        <QuickAction icon="receipt-long" label="Movimientos" onPress={() => router.push('/(app)/transactions')} />
        <QuickAction icon="pie-chart" label="Presupuesto" onPress={() => router.push('/(app)/finances')} />
        <QuickAction icon="emoji-events" label="Logros" onPress={() => router.push('/(app)/gamification')} />
      </View>

      {/* Presupuesto por categoría */}
      <SectionHeader title="Presupuesto del mes" />
      {budget.isLoading ? (
        <Card><Loading /></Card>
      ) : (
        <Card>
          {(budget.data?.category_breakdown ?? []).length === 0 ? (
            <Text variant="bodyMedium" color={colors.gray500}>
              Aún no hay gastos categorizados este mes.
            </Text>
          ) : (
            (budget.data?.category_breakdown ?? []).slice(0, 4).map((row, i) => (
              <View key={`${row.category}-${i}`} style={styles.catRow}>
                <View style={styles.catHeader}>
                  <Text variant="bodyMedium">{row.category}</Text>
                  <Text variant="bodySmall" color={colors.gray500}>
                    {currency(amountOf(row.spent as number), code)}
                  </Text>
                </View>
                <View style={styles.progressTrack}>
                  <View
                    style={[
                      styles.progressFill,
                      { width: `${Math.min(Number(row.percentage) || 0, 100)}%` },
                    ]}
                  />
                </View>
              </View>
            ))
          )}
        </Card>
      )}

      {/* Distribución de gastos */}
      {spendingData.length > 0 ? (
        <>
          <SectionHeader title="Distribución de gastos" />
          <Card>
            <View style={styles.donutRow}>
              <PieChart
                data={spendingData}
                donut
                radius={70}
                innerRadius={48}
                centerLabelComponent={() => (
                  <View style={{ alignItems: 'center' }}>
                    <Text variant="caption" color={colors.gray400}>
                      Total
                    </Text>
                    <Text variant="numberSmall">{currency(totalSpending, code)}</Text>
                  </View>
                )}
              />
              <View style={styles.legend}>
                {spendingData.map((d) => (
                  <View key={d.text} style={styles.legendRow}>
                    <View style={[styles.legendDot, { backgroundColor: d.color }]} />
                    <Text variant="bodySmall" color={colors.gray600} style={styles.flex} numberOfLines={1}>
                      {d.text}
                    </Text>
                    <Text variant="bodySmall" color={colors.gray500}>
                      {totalSpending ? Math.round((d.value / totalSpending) * 100) : 0}%
                    </Text>
                  </View>
                ))}
              </View>
            </View>
          </Card>
        </>
      ) : null}

      {/* Movimientos recientes */}
      <SectionHeader
        title="Movimientos recientes"
        actionLabel="Ver todos"
        onAction={() => router.push('/(app)/transactions')}
      />
      <Card padded={false} style={styles.recentCard}>
        {recent.isLoading ? (
          <View style={{ padding: spacing.lg }}>
            <Loading />
          </View>
        ) : recentList.length === 0 ? (
          <View style={{ padding: spacing.md }}>
            <EmptyState
              icon="receipt-long"
              title="Sin movimientos"
              message="Agrega tu primer ingreso o gasto."
              actionLabel="Agregar"
              onAction={() => router.push('/(app)/transactions/add')}
            />
          </View>
        ) : (
          recentList.map((tx, i) => (
            <View key={tx.id}>
              {i > 0 ? <View style={styles.sep} /> : null}
              <View style={{ paddingHorizontal: spacing.md }}>
                <TransactionRow tx={tx} onPress={() => router.push(`/(app)/transactions/${tx.id}`)} />
              </View>
            </View>
          ))
        )}
      </Card>
    </ScreenContainer>
  );
}

function QuickAction({
  icon,
  label,
  onPress,
}: {
  icon: keyof typeof MaterialIcons.glyphMap;
  label: string;
  onPress: () => void;
}) {
  return (
    <Pressable onPress={onPress} style={styles.action}>
      <View style={styles.actionIcon}>
        <MaterialIcons name={icon} size={22} color={colors.teal} />
      </View>
      <Text variant="caption" color={colors.gray600} center>
        {label}
      </Text>
    </Pressable>
  );
}

function SectionHeader({
  title,
  actionLabel,
  onAction,
}: {
  title: string;
  actionLabel?: string;
  onAction?: () => void;
}) {
  return (
    <View style={styles.sectionHeader}>
      <Text variant="h4">{title}</Text>
      {actionLabel && onAction ? (
        <Pressable onPress={onAction} hitSlop={8}>
          <Text variant="caption" color={colors.teal}>
            {actionLabel}
          </Text>
        </Pressable>
      ) : null}
    </View>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  greetRow: { flexDirection: 'row', alignItems: 'center', marginBottom: spacing.md },
  bell: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: colors.white,
    alignItems: 'center',
    justifyContent: 'center',
  },
  hero: { borderRadius: radius.lg, padding: spacing.lg },
  heroBalance: { marginVertical: spacing.xs },
  heroRow: { flexDirection: 'row', alignItems: 'center', marginTop: spacing.sm },
  heroStat: { flexDirection: 'row', alignItems: 'center', gap: spacing.xs, flex: 1 },
  heroDivider: { width: 1, height: 36, backgroundColor: '#FFFFFF33', marginHorizontal: spacing.sm },
  actions: { flexDirection: 'row', justifyContent: 'space-between', marginVertical: spacing.lg },
  action: { alignItems: 'center', gap: spacing.xxs, flex: 1 },
  actionIcon: {
    width: 52,
    height: 52,
    borderRadius: 16,
    backgroundColor: colors.tealPale,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 2,
  },
  sectionHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginTop: spacing.lg,
    marginBottom: spacing.sm,
  },
  catRow: { marginBottom: spacing.md },
  catHeader: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: spacing.xxs },
  progressTrack: { height: 8, borderRadius: 4, backgroundColor: colors.gray100, overflow: 'hidden' },
  progressFill: { height: 8, borderRadius: 4, backgroundColor: colors.teal },
  recentCard: { overflow: 'hidden' },
  sep: { height: 1, backgroundColor: colors.gray100, marginLeft: spacing.md + 42 + spacing.sm },
  donutRow: { flexDirection: 'row', alignItems: 'center', gap: spacing.md },
  legend: { flex: 1, gap: spacing.xs },
  legendRow: { flexDirection: 'row', alignItems: 'center', gap: spacing.xs },
  legendDot: { width: 10, height: 10, borderRadius: 5 },
});
