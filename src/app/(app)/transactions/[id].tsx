import { MaterialIcons } from '@expo/vector-icons';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { Alert, Pressable, StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Button, Card, Loading, Text } from '@/components';
import { useDeleteTransaction, useTransaction } from '@/features/transactions/hooks';
import { colorForCategory, colors, spacing } from '@/theme';
import { dateShort } from '@/utils/formatters';
import { moneyText } from '@/utils/money';

export default function TransactionDetailScreen() {
  const router = useRouter();
  const { id } = useLocalSearchParams<{ id: string }>();
  const txId = Number(id);
  const query = useTransaction(txId);
  const del = useDeleteTransaction();

  const tx = query.data;
  const isIncome = tx?.transaction_type === 'income';

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

          <Button
            title="Eliminar movimiento"
            variant="danger"
            icon="delete-outline"
            onPress={confirmDelete}
            loading={del.isPending}
            style={{ marginTop: spacing.xl }}
          />
        </View>
      )}
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
});
