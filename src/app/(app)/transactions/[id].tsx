import { MaterialIcons } from '@expo/vector-icons';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useState } from 'react';
import { Alert, FlatList, Modal, Pressable, StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Button, Card, Loading, Text } from '@/components';
import { useCategories } from '@/features/finances/hooks';
import {
  useDeleteTransaction,
  useTransaction,
  useUpdateTransaction,
} from '@/features/transactions/hooks';
import { colorForCategory, colors, radius, spacing } from '@/theme';
import { dateShort } from '@/utils/formatters';
import { moneyText } from '@/utils/money';

export default function TransactionDetailScreen() {
  const router = useRouter();
  const { id } = useLocalSearchParams<{ id: string }>();
  const txId = Number(id);
  const query = useTransaction(txId);
  const del = useDeleteTransaction();
  const update = useUpdateTransaction();
  const categories = useCategories();
  const [showCategories, setShowCategories] = useState(false);

  const tx = query.data;
  const isIncome = tx?.transaction_type === 'income';
  const isExpense = tx?.transaction_type === 'expense';

  const changeCategory = (categoryId: number) => {
    update.mutate(
      { id: txId, payload: { category: categoryId } },
      { onSuccess: () => setShowCategories(false) },
    );
  };

  const confirmDelete = () => {
    Alert.alert('Eliminar movimiento', '¿Seguro que deseas eliminar este movimiento?', [
      { text: 'Cancelar', style: 'cancel' },
      {
        text: 'Eliminar',
        style: 'destructive',
        onPress: () => del.mutate(txId, { onSuccess: () => router.back() }),
      },
    ]);
  };

  return (
    <SafeAreaView style={styles.safe}>
      <View style={styles.header}>
        <Pressable onPress={() => router.back()} hitSlop={8}>
          <MaterialIcons name="close" size={26} color={colors.gray700} />
        </Pressable>
        <Text variant="h4">Detalle</Text>
        <View style={{ width: 26 }} />
      </View>

      {query.isLoading || !tx ? (
        <Loading />
      ) : (
        <View style={styles.content}>
          <View style={styles.amountBlock}>
            <View
              style={[
                styles.icon,
                { backgroundColor: `${isIncome ? colors.green : colorForCategory(tx.category_name)}22` },
              ]}
            >
              <MaterialIcons
                name={isIncome ? 'arrow-downward' : 'arrow-upward'}
                size={28}
                color={isIncome ? colors.green : colorForCategory(tx.category_name)}
              />
            </View>
            <Text variant="numberLarge" color={isIncome ? colors.green : colors.gray900}>
              {isIncome ? '+' : '-'}
              {moneyText(tx.amount).replace(/^[-+]/, '')}
            </Text>
            <Text variant="bodyMedium" color={colors.gray500}>
              {tx.description || tx.category_name || (isIncome ? 'Ingreso' : 'Gasto')}
            </Text>
          </View>

          <Card>
            <Row label="Tipo" value={isIncome ? 'Ingreso' : tx.transaction_type === 'transfer' ? 'Transferencia' : 'Gasto'} />
            <Divider />
            <Row label="Categoría" value={tx.category_name ?? 'Sin categoría'} />
            <Divider />
            <Row label="Fecha" value={dateShort(tx.date)} />
            <Divider />
            <Row label="Estado" value={tx.status ?? '—'} />
          </Card>

          {isExpense ? (
            <Button
              title="Cambiar categoría"
              variant="outline"
              icon="category"
              onPress={() => setShowCategories(true)}
              loading={update.isPending}
              style={{ marginTop: spacing.xl }}
            />
          ) : null}
          <Button
            title="Editar movimiento"
            variant="outline"
            icon="edit"
            onPress={() => router.push(`/(app)/transactions/add?id=${txId}`)}
            style={{ marginTop: isExpense ? spacing.sm : spacing.xl }}
          />
          <Button
            title="Eliminar movimiento"
            variant="danger"
            icon="delete-outline"
            onPress={confirmDelete}
            loading={del.isPending}
            style={{ marginTop: spacing.sm }}
          />
        </View>
      )}

      <Modal visible={showCategories} animationType="slide" transparent onRequestClose={() => setShowCategories(false)}>
        <Pressable style={styles.modalBackdrop} onPress={() => setShowCategories(false)} />
        <View style={styles.modalSheet}>
          <View style={styles.modalHandle} />
          <Text variant="h4" style={styles.modalTitle}>
            Cambiar categoría
          </Text>
          <FlatList
            data={categories.data ?? []}
            keyExtractor={(c) => String(c.id)}
            renderItem={({ item }) => (
              <Pressable style={styles.catItem} onPress={() => changeCategory(item.id)}>
                <View style={[styles.catDot, { backgroundColor: item.color ?? colorForCategory(item.display_name) }]} />
                <Text variant="bodyLarge" style={{ flex: 1 }}>
                  {item.display_name}
                </Text>
                {tx?.category === item.id ? <MaterialIcons name="check" size={20} color={colors.teal} /> : null}
              </Pressable>
            )}
          />
        </View>
      </Modal>
    </SafeAreaView>
  );
}

function Row({ label, value }: { label: string; value: string }) {
  return (
    <View style={styles.row}>
      <Text variant="bodyMedium" color={colors.gray500}>
        {label}
      </Text>
      <Text variant="bodyMedium" color={colors.gray900}>
        {value}
      </Text>
    </View>
  );
}

function Divider() {
  return <View style={styles.divider} />;
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: colors.gray50 },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
  },
  content: { flex: 1, padding: spacing.lg },
  amountBlock: { alignItems: 'center', gap: spacing.xs, marginBottom: spacing.xl },
  icon: { width: 64, height: 64, borderRadius: 32, alignItems: 'center', justifyContent: 'center', marginBottom: spacing.xs },
  row: { flexDirection: 'row', justifyContent: 'space-between', paddingVertical: spacing.sm },
  divider: { height: 1, backgroundColor: colors.gray100 },
  modalBackdrop: { flex: 1, backgroundColor: '#00000055' },
  modalSheet: {
    backgroundColor: colors.white,
    borderTopLeftRadius: radius.xl,
    borderTopRightRadius: radius.xl,
    paddingHorizontal: spacing.lg,
    paddingBottom: spacing.xl,
    maxHeight: '70%',
  },
  modalHandle: { width: 40, height: 4, borderRadius: 2, backgroundColor: colors.gray300, alignSelf: 'center', marginTop: spacing.sm },
  modalTitle: { marginVertical: spacing.md },
  catItem: { flexDirection: 'row', alignItems: 'center', gap: spacing.sm, paddingVertical: spacing.md },
  catDot: { width: 14, height: 14, borderRadius: 7 },
});
