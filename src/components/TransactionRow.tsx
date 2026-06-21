import { MaterialIcons } from '@expo/vector-icons';
import { Pressable, StyleSheet, View } from 'react-native';
import type { Transaction } from '@/api/transactions';
import { colorForCategory, colors, spacing } from '@/theme';
import { dayMonth } from '@/utils/formatters';
import { amountOf, moneyText } from '@/utils/money';
import { Text } from './Text';

interface Props {
  tx: Transaction;
  onPress?: () => void;
}

export function TransactionRow({ tx, onPress }: Props) {
  const isIncome = tx.transaction_type === 'income';
  const isTransfer = tx.transaction_type === 'transfer';
  const catColor = isIncome ? colors.green : colorForCategory(tx.category_name);
  const sign = isIncome ? '+' : isTransfer ? '' : '-';
  const amountColor = isIncome ? colors.green : colors.gray900;

  return (
    <Pressable onPress={onPress} style={({ pressed }) => [styles.row, pressed && styles.pressed]}>
      <View style={[styles.icon, { backgroundColor: `${catColor}22` }]}>
        <MaterialIcons
          name={isIncome ? 'arrow-downward' : isTransfer ? 'swap-horiz' : 'arrow-upward'}
          size={20}
          color={catColor}
        />
      </View>
      <View style={styles.middle}>
        <Text variant="h5" numberOfLines={1}>
          {tx.description || tx.category_name || (isIncome ? 'Ingreso' : 'Gasto')}
        </Text>
        <Text variant="bodySmall" color={colors.gray500}>
          {tx.category_name ?? 'Sin categoría'} · {dayMonth(tx.date)}
        </Text>
      </View>
      <Text variant="numberSmall" color={amountColor}>
        {sign}
        {moneyText(tx.amount).replace(/^[-+]/, '')}
      </Text>
    </Pressable>
  );
}

export function txAmount(tx: Transaction): number {
  return amountOf(tx.amount);
}

const styles = StyleSheet.create({
  row: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: spacing.sm,
    gap: spacing.sm,
  },
  pressed: { opacity: 0.6 },
  icon: {
    width: 42,
    height: 42,
    borderRadius: 21,
    alignItems: 'center',
    justifyContent: 'center',
  },
  middle: { flex: 1 },
});
