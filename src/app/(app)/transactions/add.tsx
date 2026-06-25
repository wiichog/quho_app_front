import DateTimePicker from '@react-native-community/datetimepicker';
import { MaterialIcons } from '@expo/vector-icons';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useEffect, useMemo, useState } from 'react';
import {
  FlatList,
  Modal,
  Platform,
  Pressable,
  StyleSheet,
  TextInput,
  View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Button, Card, Text } from '@/components';
import type { TransactionType } from '@/api/transactions';
import { useCategories } from '@/features/finances/hooks';
import {
  useCreateTransaction,
  useTransaction,
  useUpdateTransaction,
} from '@/features/transactions/hooks';
import { useAuthStore } from '@/store/authStore';
import { colorForCategory, colors, radius, spacing, text } from '@/theme';
import { dateShort } from '@/utils/formatters';
import { amountOf } from '@/utils/money';

export default function AddTransactionScreen() {
  const router = useRouter();
  const { id } = useLocalSearchParams<{ id?: string }>();
  const editing = !!id;
  const txId = Number(id);

  const create = useCreateTransaction();
  const update = useUpdateTransaction();
  const detail = useTransaction(editing ? txId : NaN);
  const categories = useCategories();
  const currencyCode = useAuthStore((s) => s.profile?.currency) || 'MXN';

  const [type, setType] = useState<TransactionType>('expense');
  const [amount, setAmount] = useState('');
  const [description, setDescription] = useState('');
  const [categoryId, setCategoryId] = useState<number | null>(null);
  const [date, setDate] = useState(new Date());
  const [showPicker, setShowPicker] = useState(false);
  const [showCategories, setShowCategories] = useState(false);
  const [prefilled, setPrefilled] = useState(false);

  // Prefill en modo edición
  useEffect(() => {
    if (editing && detail.data && !prefilled) {
      const tx = detail.data;
      setType(tx.transaction_type === 'income' ? 'income' : 'expense');
      setAmount(String(amountOf(tx.amount)));
      setDescription(tx.description ?? '');
      setCategoryId(tx.category ?? null);
      if (tx.date) setDate(new Date(tx.date));
      setPrefilled(true);
    }
  }, [editing, detail.data, prefilled]);

  const selectedCategory = useMemo(
    () => categories.data?.find((c) => c.id === categoryId) ?? null,
    [categories.data, categoryId],
  );

  const numericAmount = parseFloat(amount.replace(',', '.'));
  const canSave = !Number.isNaN(numericAmount) && numericAmount > 0;
  const pending = create.isPending || update.isPending;
  const error = create.error?.message || update.error?.message;

  const onSave = () => {
    const payload = {
      transaction_type: type,
      amount: numericAmount.toFixed(2),
      amount_currency: currencyCode,
      date: date.toISOString().slice(0, 10),
      description: description.trim() || undefined,
      category: type === 'expense' ? categoryId : null,
    };
    if (editing) {
      update.mutate({ id: txId, payload }, { onSuccess: () => router.back() });
    } else {
      create.mutate(payload, { onSuccess: () => router.back() });
    }
  };

  return (
    <SafeAreaView style={styles.safe}>
      <View style={styles.header}>
        <Pressable onPress={() => router.back()} hitSlop={8}>
          <MaterialIcons name="close" size={26} color={colors.gray700} />
        </Pressable>
        <Text variant="h4" style={{ textTransform: 'uppercase', letterSpacing: 1 }}>
          {editing ? 'Editar movimiento' : 'Nuevo movimiento'}
        </Text>
        <View style={{ width: 26 }} />
      </View>

      <View style={styles.content}>
        <View style={styles.segment}>
          <SegmentBtn label="Gasto" active={type === 'expense'} onPress={() => setType('expense')} danger />
          <SegmentBtn label="Ingreso" active={type === 'income'} onPress={() => setType('income')} />
        </View>

        <View style={styles.amountWrap}>
          <Text variant="numberMedium" color={colors.gray400}>
            $
          </Text>
          <TextInput
            value={amount}
            onChangeText={setAmount}
            placeholder="0.00"
            placeholderTextColor={colors.gray300}
            keyboardType="decimal-pad"
            style={[text.numberLarge(type === 'income' ? colors.green : colors.gray900), styles.amountInput]}
            autoFocus={!editing}
          />
        </View>

        {error ? (
          <Text variant="bodySmall" color={colors.red} center>
            {error}
          </Text>
        ) : null}

        {type === 'expense' ? (
          <Pressable onPress={() => setShowCategories(true)}>
            <Card style={styles.fieldRow}>
              <MaterialIcons name="category" size={20} color={colors.gray500} />
              <Text variant="bodyMedium" color={selectedCategory ? colors.gray900 : colors.gray400} style={styles.flex}>
                {selectedCategory ? selectedCategory.display_name : 'Seleccionar categoría'}
              </Text>
              <MaterialIcons name="chevron-right" size={22} color={colors.gray400} />
            </Card>
          </Pressable>
        ) : null}

        <Pressable onPress={() => setShowPicker(true)}>
          <Card style={styles.fieldRow}>
            <MaterialIcons name="event" size={20} color={colors.gray500} />
            <Text variant="bodyMedium" style={styles.flex}>
              {dateShort(date)}
            </Text>
            <MaterialIcons name="chevron-right" size={22} color={colors.gray400} />
          </Card>
        </Pressable>

        <Card style={styles.fieldRow}>
          <MaterialIcons name="notes" size={20} color={colors.gray500} />
          <TextInput
            value={description}
            onChangeText={setDescription}
            placeholder="Descripción (opcional)"
            placeholderTextColor={colors.gray400}
            style={[text.bodyMedium(colors.gray900), styles.flex]}
          />
        </Card>
      </View>

      <View style={styles.footer}>
        <Button title={editing ? 'Guardar cambios' : 'Guardar'} onPress={onSave} disabled={!canSave} loading={pending} />
      </View>

      {showPicker ? (
        <DateTimePicker
          value={date}
          mode="date"
          maximumDate={new Date()}
          onChange={(_, selected) => {
            setShowPicker(Platform.OS === 'ios');
            if (selected) setDate(selected);
          }}
        />
      ) : null}

      <Modal visible={showCategories} animationType="slide" transparent onRequestClose={() => setShowCategories(false)}>
        <Pressable style={styles.modalBackdrop} onPress={() => setShowCategories(false)} />
        <View style={styles.modalSheet}>
          <View style={styles.modalHandle} />
          <Text variant="h4" style={styles.modalTitle}>
            Categoría
          </Text>
          <FlatList
            data={categories.data ?? []}
            keyExtractor={(c) => String(c.id)}
            renderItem={({ item }) => (
              <Pressable
                style={styles.catItem}
                onPress={() => {
                  setCategoryId(item.id);
                  setShowCategories(false);
                }}
              >
                <View style={[styles.catDot, { backgroundColor: item.color ?? colorForCategory(item.display_name) }]} />
                <Text variant="bodyLarge" style={styles.flex}>
                  {item.display_name}
                </Text>
                {categoryId === item.id ? (
                  <MaterialIcons name="check" size={20} color={colors.teal} />
                ) : null}
              </Pressable>
            )}
          />
        </View>
      </Modal>
    </SafeAreaView>
  );
}

function SegmentBtn({
  label,
  active,
  onPress,
  danger,
}: {
  label: string;
  active: boolean;
  onPress: () => void;
  danger?: boolean;
}) {
  const activeColor = danger ? colors.red : colors.green;
  return (
    <Pressable onPress={onPress} style={[styles.segmentBtn, active && { backgroundColor: colors.white }]}>
      <Text variant="h5" color={active ? activeColor : colors.gray500}>
        {label}
      </Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: colors.gray50 },
  flex: { flex: 1 },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
  },
  content: { flex: 1, paddingHorizontal: spacing.lg, gap: spacing.md },
  segment: { flexDirection: 'row', backgroundColor: colors.gray100, borderRadius: radius.sm, padding: 4 },
  segmentBtn: { flex: 1, alignItems: 'center', paddingVertical: spacing.sm, borderRadius: radius.xs },
  amountWrap: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: spacing.xs,
    paddingVertical: spacing.lg,
  },
  amountInput: { minWidth: 160, textAlign: 'center' },
  fieldRow: { flexDirection: 'row', alignItems: 'center', gap: spacing.sm },
  footer: { padding: spacing.lg },
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
