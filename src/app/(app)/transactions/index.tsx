import { MaterialIcons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { useState } from 'react';
import { FlatList, Pressable, StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { EmptyState, Loading, Text, TransactionRow } from '@/components';
import type { TransactionType } from '@/api/transactions';
import { useTransactions } from '@/features/transactions/hooks';
import { colors, radius, shadow, spacing } from '@/theme';

type FilterValue = 'all' | TransactionType;
const FILTERS: { label: string; value: FilterValue }[] = [
  { label: 'Todos', value: 'all' },
  { label: 'Gastos', value: 'expense' },
  { label: 'Ingresos', value: 'income' },
];

export default function TransactionsListScreen() {
  const router = useRouter();
  const [filter, setFilter] = useState<FilterValue>('all');

  const query = useTransactions(filter === 'all' ? {} : { transaction_type: filter });
  const items = query.data?.results ?? [];

  return (
    <SafeAreaView style={styles.safe} edges={['top']}>
      <View style={styles.header}>
        <Text variant="h2">Movimientos</Text>
        {query.data?.count != null ? (
          <Text variant="bodySmall" color={colors.gray500}>
            {query.data.count} en total
          </Text>
        ) : null}
      </View>

      <View style={styles.chips}>
        {FILTERS.map((f) => {
          const active = filter === f.value;
          return (
            <Pressable
              key={f.value}
              onPress={() => setFilter(f.value)}
              style={[styles.chip, active && styles.chipActive]}
            >
              <Text variant="caption" color={active ? colors.white : colors.gray600}>
                {f.label}
              </Text>
            </Pressable>
          );
        })}
      </View>

      {query.isLoading ? (
        <Loading />
      ) : (
        <FlatList
          data={items}
          keyExtractor={(t) => String(t.id)}
          contentContainerStyle={styles.list}
          ItemSeparatorComponent={() => <View style={styles.sep} />}
          refreshing={query.isRefetching}
          onRefresh={query.refetch}
          renderItem={({ item }) => (
            <TransactionRow tx={item} onPress={() => router.push(`/(app)/transactions/${item.id}`)} />
          )}
          ListEmptyComponent={
            <EmptyState
              icon="receipt-long"
              title="Sin movimientos"
              message="No hay movimientos con este filtro."
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

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: colors.gray50 },
  header: { paddingHorizontal: spacing.screenH, paddingTop: spacing.sm },
  chips: { flexDirection: 'row', gap: spacing.xs, paddingHorizontal: spacing.screenH, paddingVertical: spacing.md },
  chip: {
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.xs,
    borderRadius: radius.full,
    backgroundColor: colors.white,
    borderWidth: 1,
    borderColor: colors.gray200,
  },
  chipActive: { backgroundColor: colors.teal, borderColor: colors.teal },
  list: { paddingHorizontal: spacing.screenH, paddingBottom: 120, flexGrow: 1 },
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
