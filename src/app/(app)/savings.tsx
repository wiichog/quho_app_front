import { MaterialIcons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { useState } from 'react';
import { Modal, Pressable, ScrollView, StyleSheet, TextInput, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import type { SavingsAccount } from '@/api/finances';
import { Button, Card, EmptyState, Loading, Text } from '@/components';
import {
  useCreateSavingsAccount,
  useCreateSavingsMovement,
  useSavingsAccounts,
  useSavingsMovements,
} from '@/features/finances/hooks';
import { useAuthStore } from '@/store/authStore';
import { colors, radius, spacing, text } from '@/theme';
import { dateShort } from '@/utils/formatters';
import { moneyText } from '@/utils/money';

type MovementKind = 'deposit' | 'withdrawal';

export default function SavingsScreen() {
  const router = useRouter();
  const code = useAuthStore((s) => s.profile?.currency) || 'MXN';
  const accounts = useSavingsAccounts();

  const [showNewAccount, setShowNewAccount] = useState(false);
  const [movementFor, setMovementFor] = useState<{ account: SavingsAccount; kind: MovementKind } | null>(null);
  const [historyFor, setHistoryFor] = useState<SavingsAccount | null>(null);

  return (
    <SafeAreaView style={styles.safe}>
      <View style={styles.header}>
        <Pressable onPress={() => router.back()} hitSlop={8}>
          <MaterialIcons name="arrow-back" size={24} color={colors.gray700} />
        </Pressable>
        <Text variant="h4" style={{ textTransform: 'uppercase', letterSpacing: 1 }}>
          Ahorros
        </Text>
        <Pressable onPress={() => setShowNewAccount(true)} hitSlop={8}>
          <MaterialIcons name="add" size={26} color={colors.purple} />
        </Pressable>
      </View>

      {accounts.isLoading ? (
        <Loading />
      ) : (accounts.data ?? []).length === 0 ? (
        <EmptyState
          icon="savings"
          title="Sin cuentas de ahorro"
          message="Crea una cuenta para empezar a apartar dinero."
          actionLabel="Nueva cuenta"
          onAction={() => setShowNewAccount(true)}
        />
      ) : (
        <ScrollView contentContainerStyle={styles.list}>
          {(accounts.data ?? []).map((acc) => (
            <Card key={acc.id} style={styles.accountCard}>
              <View style={styles.accountHeader}>
                <View style={styles.iconCircle}>
                  <MaterialIcons name="savings" size={22} color={colors.purple} />
                </View>
                <View style={styles.flex}>
                  <Text variant="h5">{acc.name}</Text>
                  <Text variant="numberMedium" color={colors.purple}>
                    {moneyText(acc.balance_display, code)}
                  </Text>
                </View>
              </View>
              <View style={styles.accountActions}>
                <Button
                  title="Depositar"
                  size="sm"
                  icon="add"
                  onPress={() => setMovementFor({ account: acc, kind: 'deposit' })}
                  style={styles.flex}
                />
                <Button
                  title="Retirar"
                  size="sm"
                  variant="outline"
                  icon="remove"
                  onPress={() => setMovementFor({ account: acc, kind: 'withdrawal' })}
                  style={styles.flex}
                />
              </View>
              <Pressable style={styles.historyLink} onPress={() => setHistoryFor(acc)}>
                <MaterialIcons name="history" size={16} color={colors.gray500} />
                <Text variant="caption" color={colors.gray500}>
                  Ver movimientos
                </Text>
              </Pressable>
            </Card>
          ))}
        </ScrollView>
      )}

      <NewAccountModal visible={showNewAccount} onClose={() => setShowNewAccount(false)} />
      <MovementModal
        data={movementFor}
        currencyCode={code}
        onClose={() => setMovementFor(null)}
      />
      <HistoryModal account={historyFor} currencyCode={code} onClose={() => setHistoryFor(null)} />
    </SafeAreaView>
  );
}

function HistoryModal({
  account,
  currencyCode,
  onClose,
}: {
  account: SavingsAccount | null;
  currencyCode: string;
  onClose: () => void;
}) {
  const movements = useSavingsMovements(account?.id ?? null);
  const items = movements.data ?? [];

  return (
    <Modal visible={!!account} transparent animationType="slide" onRequestClose={onClose}>
      <Pressable style={styles.backdrop} onPress={onClose} />
      <View style={[styles.sheet, { maxHeight: '75%' }]}>
        <View style={styles.handle} />
        <Text variant="h4" style={{ marginVertical: spacing.md }}>
          Movimientos · {account?.name}
        </Text>
        {movements.isLoading ? (
          <Text variant="bodyMedium" color={colors.gray500} style={{ paddingVertical: spacing.lg }}>
            Cargando…
          </Text>
        ) : items.length === 0 ? (
          <Text variant="bodyMedium" color={colors.gray500} style={{ paddingVertical: spacing.lg }}>
            Aún no hay movimientos en esta cuenta.
          </Text>
        ) : (
          <ScrollView>
            {items.map((m) => {
              const isDeposit = m.kind === 'deposit';
              return (
                <View key={m.id} style={styles.moveRow}>
                  <View
                    style={[
                      styles.moveIcon,
                      { backgroundColor: isDeposit ? colors.greenLight : colors.redLight },
                    ]}
                  >
                    <MaterialIcons
                      name={isDeposit ? 'arrow-downward' : 'arrow-upward'}
                      size={18}
                      color={isDeposit ? colors.green : colors.red}
                    />
                  </View>
                  <View style={styles.flex}>
                    <Text variant="h5">{isDeposit ? 'Depósito' : 'Retiro'}</Text>
                    <Text variant="bodySmall" color={colors.gray500}>
                      {dateShort(m.date)}
                      {m.note ? ` · ${m.note}` : ''}
                    </Text>
                  </View>
                  <Text variant="numberSmall" color={isDeposit ? colors.green : colors.gray900}>
                    {isDeposit ? '+' : '-'}
                    {moneyText(m.amount, currencyCode).replace(/^[-+]/, '')}
                  </Text>
                </View>
              );
            })}
          </ScrollView>
        )}
      </View>
    </Modal>
  );
}

function NewAccountModal({ visible, onClose }: { visible: boolean; onClose: () => void }) {
  const [name, setName] = useState('');
  const create = useCreateSavingsAccount();
  const close = () => {
    setName('');
    onClose();
  };
  return (
    <Modal visible={visible} transparent animationType="slide" onRequestClose={close}>
      <Pressable style={styles.backdrop} onPress={close} />
      <View style={styles.sheet}>
        <View style={styles.handle} />
        <Text variant="h4" style={{ marginVertical: spacing.md }}>
          Nueva cuenta de ahorro
        </Text>
        <TextInput
          value={name}
          onChangeText={setName}
          placeholder="Ej. Fondo de emergencia"
          placeholderTextColor={colors.gray400}
          style={[styles.input, text.bodyMedium(colors.gray900)]}
        />
        <Button
          title="Crear cuenta"
          onPress={() => create.mutate(name.trim(), { onSuccess: close })}
          loading={create.isPending}
          disabled={name.trim().length === 0}
          style={{ marginTop: spacing.md }}
        />
      </View>
    </Modal>
  );
}

function MovementModal({
  data,
  currencyCode,
  onClose,
}: {
  data: { account: SavingsAccount; kind: MovementKind } | null;
  currencyCode: string;
  onClose: () => void;
}) {
  const [amount, setAmount] = useState('');
  const [note, setNote] = useState('');
  const create = useCreateSavingsMovement();

  const close = () => {
    setAmount('');
    setNote('');
    onClose();
  };

  const numeric = parseFloat(amount.replace(',', '.'));
  const canSave = !Number.isNaN(numeric) && numeric > 0;
  const isDeposit = data?.kind === 'deposit';

  const onSave = () => {
    if (!data) return;
    create.mutate(
      {
        account: data.account.id,
        amount: numeric.toFixed(2),
        kind: data.kind,
        date: new Date().toISOString().slice(0, 10),
        note: note.trim() || undefined,
      },
      { onSuccess: close },
    );
  };

  return (
    <Modal visible={!!data} transparent animationType="slide" onRequestClose={close}>
      <Pressable style={styles.backdrop} onPress={close} />
      <View style={styles.sheet}>
        <View style={styles.handle} />
        <Text variant="h4" style={{ marginVertical: spacing.md }}>
          {isDeposit ? 'Depositar' : 'Retirar'} · {data?.account.name}
        </Text>
        {create.isError ? (
          <Text variant="bodySmall" color={colors.red} style={{ marginBottom: spacing.xs }}>
            {create.error?.message}
          </Text>
        ) : null}
        <Text variant="caption" color={colors.gray600} style={styles.fieldLabel}>
          Monto ({currencyCode})
        </Text>
        <TextInput
          value={amount}
          onChangeText={setAmount}
          placeholder="0.00"
          keyboardType="decimal-pad"
          placeholderTextColor={colors.gray400}
          style={[styles.input, text.bodyMedium(colors.gray900)]}
          autoFocus
        />
        <Text variant="caption" color={colors.gray600} style={styles.fieldLabel}>
          Nota (opcional)
        </Text>
        <TextInput
          value={note}
          onChangeText={setNote}
          placeholder="Ej. ahorro mensual"
          placeholderTextColor={colors.gray400}
          style={[styles.input, text.bodyMedium(colors.gray900)]}
        />
        <Button
          title={isDeposit ? 'Depositar' : 'Retirar'}
          variant={isDeposit ? 'primary' : 'outline'}
          onPress={onSave}
          loading={create.isPending}
          disabled={!canSave}
          style={{ marginTop: spacing.md }}
        />
      </View>
    </Modal>
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
  list: { padding: spacing.lg, gap: spacing.md },
  accountCard: { gap: spacing.md },
  accountHeader: { flexDirection: 'row', alignItems: 'center', gap: spacing.sm },
  iconCircle: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: colors.purplePale,
    alignItems: 'center',
    justifyContent: 'center',
  },
  accountActions: { flexDirection: 'row', gap: spacing.sm },
  historyLink: { flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: 4, marginTop: spacing.xs },
  moveRow: { flexDirection: 'row', alignItems: 'center', gap: spacing.sm, paddingVertical: spacing.sm },
  moveIcon: { width: 36, height: 36, borderRadius: 18, alignItems: 'center', justifyContent: 'center' },
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
});
