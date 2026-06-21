import { MaterialIcons } from '@expo/vector-icons';
import { useMemo, useState } from 'react';
import { Alert, FlatList, Modal, Pressable, StyleSheet, TextInput, View } from 'react-native';
import { Card, Loading, ScreenContainer, Text } from '@/components';
import {
  useBudgetSummary,
  useCreateFixedExpense,
  useCreateGoal,
  useCreateIncome,
  useDeleteFixedExpense,
  useDeleteGoal,
  useDeleteIncome,
  useFixedExpenses,
  useGoals,
  useIncomes,
} from '@/features/finances/hooks';
import { useAuthStore } from '@/store/authStore';
import { colors, radius, spacing, text } from '@/theme';
import { apiMonth, currency, monthYear } from '@/utils/formatters';
import { amountOf, moneyText } from '@/utils/money';

type Segment = 'incomes' | 'fixed' | 'goals';

export default function FinancesScreen() {
  const month = useMemo(() => apiMonth(), []);
  const code = useAuthStore((s) => s.profile?.currency) || 'MXN';
  const [segment, setSegment] = useState<Segment>('incomes');
  const [showAdd, setShowAdd] = useState(false);

  const budget = useBudgetSummary(month);
  const incomes = useIncomes();
  const fixed = useFixedExpenses();
  const goals = useGoals();

  const deleteIncome = useDeleteIncome();
  const deleteFixed = useDeleteFixedExpense();
  const deleteGoal = useDeleteGoal();

  const exec = budget.data?.execution;
  const theo = budget.data?.theoretical;

  return (
    <ScreenContainer scroll refreshing={budget.isRefetching} onRefresh={budget.refetch}>
      <Text variant="h2">Finanzas</Text>
      <Text variant="bodyMedium" color={colors.gray500} style={{ marginBottom: spacing.lg }}>
        {monthYear(new Date())}
      </Text>

      {/* Resumen de presupuesto */}
      {budget.isLoading ? (
        <Card><Loading /></Card>
      ) : (
        <Card>
          <BudgetLine
            label="Ingresos"
            actual={amountOf(exec?.total_income)}
            planned={amountOf(theo?.total_income)}
            color={colors.green}
            code={code}
          />
          <BudgetLine
            label="Gastos"
            actual={amountOf(exec?.total_expense)}
            planned={amountOf(theo?.total_expense)}
            color={colors.red}
            code={code}
          />
          <BudgetLine
            label="Ahorro objetivo"
            actual={amountOf(exec?.net)}
            planned={amountOf(theo?.savings_target)}
            color={colors.teal}
            code={code}
          />
        </Card>
      )}

      {/* Segmentos */}
      <View style={styles.segment}>
        <SegBtn label="Ingresos" active={segment === 'incomes'} onPress={() => setSegment('incomes')} />
        <SegBtn label="Gastos fijos" active={segment === 'fixed'} onPress={() => setSegment('fixed')} />
        <SegBtn label="Metas" active={segment === 'goals'} onPress={() => setSegment('goals')} />
      </View>

      {/* Listas */}
      {segment === 'incomes' ? (
        <ItemList
          loading={incomes.isLoading}
          data={(incomes.data ?? []).map((i) => ({
            id: i.id,
            title: i.name,
            subtitle: i.frequency,
            amount: moneyText(i.normalized_monthly_display, code),
          }))}
          emptyLabel="Sin ingresos registrados"
          onDelete={(id) => confirmDelete(() => deleteIncome.mutate(id))}
        />
      ) : null}
      {segment === 'fixed' ? (
        <ItemList
          loading={fixed.isLoading}
          data={(fixed.data ?? []).map((f) => ({
            id: f.id,
            title: f.name,
            subtitle: f.category_name ?? f.frequency,
            amount: moneyText(f.normalized_monthly_display, code),
          }))}
          emptyLabel="Sin gastos fijos registrados"
          onDelete={(id) => confirmDelete(() => deleteFixed.mutate(id))}
        />
      ) : null}
      {segment === 'goals' ? (
        <ItemList
          loading={goals.isLoading}
          data={(goals.data ?? []).map((g) => ({
            id: g.id,
            title: g.name,
            subtitle: `${Math.round(g.progress_percentage)}% completado`,
            amount: moneyText(g.target_amount, code),
          }))}
          emptyLabel="Sin metas de ahorro"
          onDelete={(id) => confirmDelete(() => deleteGoal.mutate(id))}
        />
      ) : null}

      <Pressable style={styles.addBtn} onPress={() => setShowAdd(true)}>
        <MaterialIcons name="add" size={20} color={colors.teal} />
        <Text variant="h5" color={colors.teal}>
          {segment === 'incomes' ? 'Agregar ingreso' : segment === 'fixed' ? 'Agregar gasto fijo' : 'Agregar meta'}
        </Text>
      </Pressable>

      <AddModal
        visible={showAdd}
        segment={segment}
        onClose={() => setShowAdd(false)}
      />
    </ScreenContainer>
  );
}

function confirmDelete(onConfirm: () => void) {
  Alert.alert('Eliminar', '¿Deseas eliminar este elemento?', [
    { text: 'Cancelar', style: 'cancel' },
    { text: 'Eliminar', style: 'destructive', onPress: onConfirm },
  ]);
}

function BudgetLine({
  label,
  actual,
  planned,
  color,
  code,
}: {
  label: string;
  actual: number;
  planned: number;
  color: string;
  code: string;
}) {
  const pct = planned > 0 ? Math.min((actual / planned) * 100, 100) : 0;
  return (
    <View style={styles.budgetLine}>
      <View style={styles.budgetHeader}>
        <Text variant="bodyMedium">{label}</Text>
        <Text variant="bodySmall" color={colors.gray500}>
          {currency(actual, code)} / {currency(planned, code)}
        </Text>
      </View>
      <View style={styles.track}>
        <View style={[styles.fill, { width: `${pct}%`, backgroundColor: color }]} />
      </View>
    </View>
  );
}

function SegBtn({ label, active, onPress }: { label: string; active: boolean; onPress: () => void }) {
  return (
    <Pressable onPress={onPress} style={[styles.segBtn, active && styles.segBtnActive]}>
      <Text variant="caption" color={active ? colors.white : colors.gray600}>
        {label}
      </Text>
    </Pressable>
  );
}

interface ListItem {
  id: number;
  title: string;
  subtitle: string;
  amount: string;
}

function ItemList({
  data,
  loading,
  emptyLabel,
  onDelete,
}: {
  data: ListItem[];
  loading: boolean;
  emptyLabel: string;
  onDelete: (id: number) => void;
}) {
  if (loading) return <Card><Loading /></Card>;
  if (data.length === 0) {
    return (
      <Card>
        <Text variant="bodyMedium" color={colors.gray500} center>
          {emptyLabel}
        </Text>
      </Card>
    );
  }
  return (
    <Card padded={false}>
      {data.map((item, i) => (
        <View key={item.id}>
          {i > 0 ? <View style={styles.sep} /> : null}
          <View style={styles.listRow}>
            <View style={styles.flex}>
              <Text variant="h5">{item.title}</Text>
              <Text variant="bodySmall" color={colors.gray500}>
                {item.subtitle}
              </Text>
            </View>
            <Text variant="numberSmall">{item.amount}</Text>
            <Pressable onPress={() => onDelete(item.id)} hitSlop={8} style={styles.deleteBtn}>
              <MaterialIcons name="delete-outline" size={20} color={colors.gray400} />
            </Pressable>
          </View>
        </View>
      ))}
    </Card>
  );
}

function AddModal({
  visible,
  segment,
  onClose,
}: {
  visible: boolean;
  segment: Segment;
  onClose: () => void;
}) {
  const [name, setName] = useState('');
  const [amount, setAmount] = useState('');
  const createIncome = useCreateIncome();
  const createFixed = useCreateFixedExpense();
  const createGoal = useCreateGoal();

  const reset = () => {
    setName('');
    setAmount('');
  };
  const close = () => {
    reset();
    onClose();
  };

  const numeric = parseFloat(amount.replace(',', '.'));
  const canSave = name.trim().length > 0 && !Number.isNaN(numeric) && numeric > 0;

  const onSave = () => {
    const value = numeric.toFixed(2);
    if (segment === 'incomes') {
      createIncome.mutate({ name: name.trim(), amount: value, frequency: 'monthly' }, { onSuccess: close });
    } else if (segment === 'fixed') {
      createFixed.mutate({ name: name.trim(), amount: value, frequency: 'monthly' }, { onSuccess: close });
    } else {
      createGoal.mutate({ name: name.trim(), target_amount: value }, { onSuccess: close });
    }
  };

  const pending = createIncome.isPending || createFixed.isPending || createGoal.isPending;
  const title =
    segment === 'incomes' ? 'Nuevo ingreso' : segment === 'fixed' ? 'Nuevo gasto fijo' : 'Nueva meta';

  return (
    <Modal visible={visible} transparent animationType="slide" onRequestClose={close}>
      <Pressable style={styles.backdrop} onPress={close} />
      <View style={styles.sheet}>
        <View style={styles.handle} />
        <Text variant="h4" style={{ marginVertical: spacing.md }}>
          {title}
        </Text>
        <Text variant="caption" color={colors.gray600} style={styles.fieldLabel}>
          Nombre
        </Text>
        <TextInput
          value={name}
          onChangeText={setName}
          placeholder={segment === 'goals' ? 'Fondo de emergencia' : 'Ej. Salario'}
          placeholderTextColor={colors.gray400}
          style={[styles.input, text.bodyMedium(colors.gray900)]}
        />
        <Text variant="caption" color={colors.gray600} style={styles.fieldLabel}>
          {segment === 'goals' ? 'Monto objetivo' : 'Monto mensual'}
        </Text>
        <TextInput
          value={amount}
          onChangeText={setAmount}
          placeholder="0.00"
          keyboardType="decimal-pad"
          placeholderTextColor={colors.gray400}
          style={[styles.input, text.bodyMedium(colors.gray900)]}
        />
        <Pressable
          onPress={onSave}
          disabled={!canSave || pending}
          style={[styles.saveBtn, (!canSave || pending) && { opacity: 0.5 }]}
        >
          <Text variant="button" color={colors.white}>
            {pending ? 'Guardando…' : 'Guardar'}
          </Text>
        </Pressable>
      </View>
    </Modal>
  );
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  budgetLine: { marginBottom: spacing.md },
  budgetHeader: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: spacing.xxs },
  track: { height: 8, borderRadius: 4, backgroundColor: colors.gray100, overflow: 'hidden' },
  fill: { height: 8, borderRadius: 4 },
  segment: {
    flexDirection: 'row',
    backgroundColor: colors.gray100,
    borderRadius: radius.sm,
    padding: 4,
    marginTop: spacing.lg,
    marginBottom: spacing.md,
  },
  segBtn: { flex: 1, alignItems: 'center', paddingVertical: spacing.sm, borderRadius: radius.xs },
  segBtnActive: { backgroundColor: colors.teal },
  sep: { height: 1, backgroundColor: colors.gray100, marginHorizontal: spacing.md },
  listRow: { flexDirection: 'row', alignItems: 'center', gap: spacing.sm, padding: spacing.md },
  deleteBtn: { padding: 2 },
  addBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: spacing.xs,
    marginTop: spacing.md,
    paddingVertical: spacing.md,
    borderRadius: radius.sm,
    borderWidth: 1.5,
    borderColor: colors.tealPale,
    backgroundColor: colors.tealPale,
  },
  backdrop: { flex: 1, backgroundColor: '#00000055' },
  sheet: {
    backgroundColor: colors.white,
    borderTopLeftRadius: radius.xl,
    borderTopRightRadius: radius.xl,
    padding: spacing.lg,
    paddingBottom: spacing.xxl,
  },
  handle: { width: 40, height: 4, borderRadius: 2, backgroundColor: colors.gray300, alignSelf: 'center' },
  fieldLabel: { marginBottom: spacing.xxs, marginTop: spacing.sm },
  input: {
    backgroundColor: colors.gray50,
    borderRadius: radius.xs,
    borderWidth: 1.5,
    borderColor: colors.gray200,
    paddingHorizontal: spacing.md,
    height: 52,
  },
  saveBtn: {
    backgroundColor: colors.teal,
    borderRadius: radius.xs,
    height: 52,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: spacing.lg,
  },
});
