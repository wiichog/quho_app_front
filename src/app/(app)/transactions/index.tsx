import { MaterialIcons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { useMemo, useState } from 'react';
import { ActivityIndicator, FlatList, Pressable, StyleSheet, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { EmptyState, ListSkeleton, ScreenHeader, Text, TransactionRow } from '@/components';
import type { TransactionType } from '@/api/transactions';
import { useInfiniteTransactions } from '@/features/transactions/hooks';
import { colors, radius, shadow, spacing, text } from '@/theme';
import { apiMonth } from '@/utils/formatters';

type TypeFilter = 'all' | TransactionType;
type Period = 'all' | 'this' | 'last';

const TYPE_FILTERS: { label: string; value: TypeFilter }[] = [
  { label: 'Todos', value: 'all' },
  { label: 'Gastos', value: 'expense' },
  { label: 'Ingresos', value: 'income' },
];
const PERIODS: { label: string; value: Period }[] = [
  { label: 'Este mes', value: 'this' },
  { label: 'Mes pasado', value: 'last' },
  { label: 'Todo', value: 'all' },
];

function lastMonth(): string {
  const d = new Date();
  d.setDate(1);
  d.setMonth(d.getMonth() - 1);
  return apiMonth(d);
}

export default function TransactionsListScreen() {
  const router = useRouter();
  const [type, setType] = useState<TypeFilter>('all');
  const [period, setPeriod] = useState<Period>('this');
  const [search, setSearch] = useState('');

  const filters = useMemo(() => {
    const f: Record<string, string> = {};
    if (type !== 'all') f.transaction_type = type;
    if (period === 'this') f.month = apiMonth();
    else if (period === 'last') f.month = lastMonth();
    return f;
  }, [type, period]);

  const query = useInfiniteTransactions(filters);
  const allItems = useMemo(
    () => (query.data?.pages ?? []).flatMap((p) => p.results),
    [query.data],
  );
  const items = useMemo(() => {
    const q = search.trim().toLowerCase();
    if (!q) return allItems;
    return allItems.filter(
      (t) =>
        (t.description ?? '').toLowerCase().includes(q) ||
        (t.category_name ?? '').toLowerCase().includes(q),
    );
  }, [allItems, search]);

  const total = query.data?.pages[0]?.count;

  return (
    <SafeAreaView style={styles.safe} edges={['top']}>
      <View style={styles.header}>
        <ScreenHeader
          title="Movimientos"
          subtitle={total != null ? `${total} en total` : undefined}
        />
      </View>

      <View style={styles.searchRow}>
        <MaterialIcons name="search" size={20} color={colors.gray400} />
        <TextInput
          value={search}
          onChangeText={setSearch}
          placeholder="Buscar por descripción o categoría"
          placeholderTextColor={colors.gray400}
          style={[styles.searchInput, text.bodyMedium(colors.gray900)]}
        />
        {search ? (
          <Pressable onPress={() => setSearch('')} hitSlop={8}>
            <MaterialIcons name="close" size={18} color={colors.gray400} />
          </Pressable>
        ) : null}
      </View>

      <View style={styles.chipsRow}>
        {TYPE_FILTERS.map((f) => (
          <Chip key={f.value} label={f.label} active={type === f.value} onPress={() => setType(f.value)} />
        ))}
        <View style={styles.chipSpacer} />
      </View>
      <View style={styles.chipsRow}>
        {PERIODS.map((p) => (
          <Chip key={p.value} label={p.label} active={period === p.value} onPress={() => setPeriod(p.value)} subtle />
        ))}
      </View>

      {query.isLoading ? (
        <View style={styles.skeleton}>
          <ListSkeleton rows={8} />
        </View>
      ) : (
        <FlatList
          data={items}
          keyExtractor={(t) => String(t.id)}
          contentContainerStyle={styles.list}
          ItemSeparatorComponent={() => <View style={styles.sep} />}
          refreshing={query.isRefetching && !query.isFetchingNextPage}
          onRefresh={query.refetch}
          onEndReachedThreshold={0.4}
          onEndReached={() => {
            if (query.hasNextPage && !query.isFetchingNextPage) query.fetchNextPage();
          }}
          renderItem={({ item }) => (
            <TransactionRow tx={item} onPress={() => router.push(`/(app)/transactions/${item.id}`)} />
          )}
          ListFooterComponent={
            query.isFetchingNextPage ? (
              <ActivityIndicator color={colors.teal} style={{ marginVertical: spacing.md }} />
            ) : null
          }
          ListEmptyComponent={
            <EmptyState
              icon="receipt-long"
              title="Sin movimientos"
              message="No hay movimientos con estos filtros."
              actionLabel="Agregar movimiento"
              onAction={() => router.push('/(app)/transactions/add')}
            />
          }
        />
      )}

      <Pressable style={styles.fab} onPress={() => router.push('/(app)/transactions/add')}>
        <MaterialIcons name="add" size={28} color={colors.white} />
      </Pressable>
    </SafeAreaView>
  );
}

function Chip({
  label,
  active,
  onPress,
  subtle,
}: {
  label: string;
  active: boolean;
  onPress: () => void;
  subtle?: boolean;
}) {
  const activeBg = subtle ? colors.darkNavy : colors.teal;
  return (
    <Pressable
      onPress={onPress}
      style={[styles.chip, active && { backgroundColor: activeBg, borderColor: activeBg }]}
    >
      <Text variant="caption" color={active ? colors.white : colors.gray600}>
        {label}
      </Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: colors.gray50 },
  header: { paddingHorizontal: spacing.screenH, paddingTop: spacing.sm },
  searchRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.xs,
    marginHorizontal: spacing.screenH,
    marginTop: spacing.sm,
    paddingHorizontal: spacing.md,
    height: 44,
    backgroundColor: colors.white,
    borderRadius: radius.sm,
    borderWidth: 1,
    borderColor: colors.gray200,
  },
  searchInput: { flex: 1, height: '100%' },
  chipsRow: { flexDirection: 'row', gap: spacing.xs, paddingHorizontal: spacing.screenH, marginTop: spacing.sm },
  chipSpacer: { flex: 1 },
  chip: {
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.xs,
    borderRadius: radius.full,
    backgroundColor: colors.white,
    borderWidth: 1,
    borderColor: colors.gray200,
  },
  list: { paddingHorizontal: spacing.screenH, paddingTop: spacing.sm, paddingBottom: 120, flexGrow: 1 },
  skeleton: { paddingHorizontal: spacing.screenH, paddingTop: spacing.md },
  sep: { height: 1, backgroundColor: colors.gray100 },
  fab: {
    position: 'absolute',
    right: spacing.lg,
    bottom: spacing.lg,
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: colors.teal,
    alignItems: 'center',
    justifyContent: 'center',
    ...shadow.elevated,
  },
});
