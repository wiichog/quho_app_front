import { MaterialCommunityIcons, MaterialIcons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';
import { useState } from 'react';
import { Alert, Modal, Pressable, StyleSheet, Switch, TextInput, View } from 'react-native';
import { Button, Card, ScreenContainer, ScreenHeader, Text } from '@/components';
import { usePlan } from '@/features/finances/hooks';
import { useReport } from '@/features/report/ReportProvider';
import { useUpdateProfile } from '@/features/me/hooks';
import { useAuthStore } from '@/store/authStore';
import { colors, radius, spacing, text } from '@/theme';
import { initials } from '@/utils/formatters';

export default function ProfileScreen() {
  const router = useRouter();
  const profile = useAuthStore((s) => s.profile);
  const plan = usePlan();
  const signOut = useAuthStore((s) => s.signOut);
  const { openReport } = useReport();
  const biometricsEnabled = useAuthStore((s) => s.biometricsEnabled);
  const setBiometricsEnabled = useAuthStore((s) => s.setBiometricsEnabled);
  const [editing, setEditing] = useState(false);

  const toggleBiometrics = async (value: boolean) => {
    if (!value) {
      setBiometricsEnabled(false);
      return;
    }
    try {
      const LocalAuthentication = await import('expo-local-authentication');
      const hasHardware = await LocalAuthentication.hasHardwareAsync();
      const enrolled = await LocalAuthentication.isEnrolledAsync();
      if (!hasHardware || !enrolled) {
        Alert.alert(
          'No disponible',
          'Tu dispositivo no tiene biometría configurada. Actívala en los ajustes del sistema.',
        );
        return;
      }
      setBiometricsEnabled(true);
    } catch {
      Alert.alert('No disponible', 'La biometría no está disponible en este entorno.');
    }
  };

  const fullName = profile ? `${profile.first_name} ${profile.last_name}`.trim() : 'Usuario';
  const isPremium = plan.data?.is_premium;

  const confirmLogout = () => {
    Alert.alert('Cerrar sesión', '¿Deseas salir de tu cuenta?', [
      { text: 'Cancelar', style: 'cancel' },
      { text: 'Cerrar sesión', style: 'destructive', onPress: signOut },
    ]);
  };

  return (
    <ScreenContainer scroll>
      <View style={{ marginBottom: spacing.lg }}>
        <ScreenHeader title="Perfil" />
      </View>

      <Card style={styles.headerCard}>
        <View style={styles.avatar}>
          <Text variant="h3" color={colors.white}>
            {initials(fullName)}
          </Text>
        </View>
        <View style={styles.flex}>
          <Text variant="h4">{fullName || 'Usuario'}</Text>
          <Text variant="bodySmall" color={colors.gray500}>
            {profile?.email}
          </Text>
          <View style={styles.planChip}>
            <MaterialIcons
              name={isPremium ? 'workspace-premium' : 'star-outline'}
              size={14}
              color={colors.purple}
            />
            <Text variant="caption" color={colors.purple}>
              Plan {isPremium ? 'Premium' : 'Gratis'}
            </Text>
          </View>
        </View>
        <Pressable onPress={() => setEditing(true)} hitSlop={8}>
          <MaterialIcons name="edit" size={20} color={colors.gray400} />
        </Pressable>
      </Card>

      {/* Uso del plan */}
      {plan.data ? (
        <Card style={{ marginTop: spacing.md }}>
          <Text variant="h5" style={{ marginBottom: spacing.sm }}>
            Uso de tu plan
          </Text>
          <UsageRow
            label="Ingresos"
            used={plan.data.usage.incomes}
            limit={plan.data.quotas.incomes}
          />
          <UsageRow
            label="Gastos fijos"
            used={plan.data.usage.fixed_expenses}
            limit={plan.data.quotas.fixed_expenses}
          />
          <UsageRow label="Metas" used={plan.data.usage.goals} limit={plan.data.quotas.goals} />
        </Card>
      ) : null}

      {/* Menú */}
      <Card padded={false} style={{ marginTop: spacing.md }}>
        <MenuRow icon="person-outline" label="Editar perfil" onPress={() => setEditing(true)} />
        <Divider />
        <MenuRow icon="workspace-premium" label="Suscripción" onPress={() => router.push('/(app)/subscription')} />
        <Divider />
        <MenuRow icon="notifications-none" label="Notificaciones" onPress={() => router.push('/(app)/notifications')} />
        <Divider />
        <MenuRow icon="insights" label="Reportes e insights" onPress={() => router.push('/(app)/insights')} />
        <Divider />
        <MenuRow icon="lock-outline" label="Cambiar contraseña" onPress={() => router.push('/(app)/change-password')} />
        <Divider />
        <View style={styles.menuRow}>
          <MaterialIcons name="fingerprint" size={22} color={colors.gray600} />
          <Text variant="bodyLarge" style={styles.flex}>
            Desbloqueo biométrico
          </Text>
          <Switch
            value={biometricsEnabled}
            onValueChange={toggleBiometrics}
            trackColor={{ true: colors.purple, false: colors.gray300 }}
            thumbColor={colors.white}
          />
        </View>
        <Divider />
        <MenuRow icon="help-outline" label="Ayuda" onPress={() => Alert.alert('Ayuda', 'soporte@quho.app')} />
        <Divider />
        <MenuRow community icon="bug-outline" label="Reportar un problema" onPress={openReport} />
      </Card>

      <Button
        title="Cerrar sesión"
        variant="outline"
        icon="logout"
        onPress={confirmLogout}
        style={{ marginTop: spacing.xl }}
      />

      <Pressable
        style={styles.deleteRow}
        onPress={() => router.push('/(app)/delete-account')}
        hitSlop={8}
      >
        <MaterialIcons name="delete-outline" size={18} color={colors.red} />
        <Text variant="bodyMedium" color={colors.red}>
          Eliminar cuenta
        </Text>
      </Pressable>

      <EditProfileModal visible={editing} onClose={() => setEditing(false)} />
    </ScreenContainer>
  );
}

function UsageRow({ label, used, limit }: { label: string; used: number; limit: number | null }) {
  const pct = limit ? Math.min((used / limit) * 100, 100) : 0;
  return (
    <View style={styles.usageRow}>
      <View style={styles.usageHeader}>
        <Text variant="bodyMedium" color={colors.gray600}>
          {label}
        </Text>
        <Text variant="bodySmall" color={colors.gray500}>
          {used}
          {limit ? ` / ${limit}` : ' · ilimitado'}
        </Text>
      </View>
      {limit ? (
        <View style={styles.track}>
          <View style={[styles.fill, { width: `${pct}%` }]} />
        </View>
      ) : null}
    </View>
  );
}

function MenuRow({
  icon,
  label,
  onPress,
  community = false,
}: {
  // `community` usa MaterialCommunityIcons (p. ej. "bug-outline", un bug nítido);
  // por defecto MaterialIcons. Por eso el tipo es string laxo + cast en el render.
  icon: string;
  label: string;
  onPress: () => void;
  community?: boolean;
}) {
  return (
    <Pressable style={styles.menuRow} onPress={onPress}>
      {community ? (
        <MaterialCommunityIcons
          name={icon as keyof typeof MaterialCommunityIcons.glyphMap}
          size={22}
          color={colors.gray600}
        />
      ) : (
        <MaterialIcons
          name={icon as keyof typeof MaterialIcons.glyphMap}
          size={22}
          color={colors.gray600}
        />
      )}
      <Text variant="bodyLarge" style={styles.flex}>
        {label}
      </Text>
      <MaterialIcons name="chevron-right" size={22} color={colors.gray300} />
    </Pressable>
  );
}

function EditProfileModal({ visible, onClose }: { visible: boolean; onClose: () => void }) {
  const profile = useAuthStore((s) => s.profile);
  const update = useUpdateProfile();
  const [firstName, setFirstName] = useState(profile?.first_name ?? '');
  const [lastName, setLastName] = useState(profile?.last_name ?? '');
  const [phone, setPhone] = useState(profile?.phone ?? '');

  const onSave = () => {
    update.mutate(
      { first_name: firstName, last_name: lastName, phone },
      { onSuccess: onClose },
    );
  };

  return (
    <Modal visible={visible} transparent animationType="slide" onRequestClose={onClose}>
      <Pressable style={styles.backdrop} onPress={onClose} />
      <View style={styles.sheet}>
        <View style={styles.handle} />
        <Text variant="h4" style={{ marginVertical: spacing.md }}>
          Editar perfil
        </Text>
        <Field label="Nombre" value={firstName} onChangeText={setFirstName} />
        <Field label="Apellido" value={lastName} onChangeText={setLastName} />
        <Field label="Teléfono" value={phone ?? ''} onChangeText={setPhone} keyboardType="phone-pad" />
        {update.isError ? (
          <Text variant="bodySmall" color={colors.red}>
            {update.error?.message}
          </Text>
        ) : null}
        <Button title="Guardar" onPress={onSave} loading={update.isPending} style={{ marginTop: spacing.md }} />
      </View>
    </Modal>
  );
}

function Field({
  label,
  value,
  onChangeText,
  keyboardType,
}: {
  label: string;
  value: string;
  onChangeText: (v: string) => void;
  keyboardType?: 'phone-pad' | 'default';
}) {
  return (
    <View style={{ marginBottom: spacing.sm }}>
      <Text variant="caption" color={colors.gray600} style={{ marginBottom: spacing.xxs }}>
        {label}
      </Text>
      <TextInput
        value={value}
        onChangeText={onChangeText}
        keyboardType={keyboardType}
        style={[styles.input, text.bodyMedium(colors.gray900)]}
        placeholderTextColor={colors.gray400}
      />
    </View>
  );
}

function Divider() {
  return <View style={styles.menuDivider} />;
}

const styles = StyleSheet.create({
  flex: { flex: 1 },
  headerCard: { flexDirection: 'row', alignItems: 'center', gap: spacing.md },
  avatar: {
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: colors.purple,
    alignItems: 'center',
    justifyContent: 'center',
  },
  planChip: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
    backgroundColor: colors.purplePale,
    alignSelf: 'flex-start',
    paddingHorizontal: spacing.xs,
    paddingVertical: 2,
    borderRadius: 999,
    marginTop: spacing.xs,
  },
  usageRow: { marginBottom: spacing.sm },
  usageHeader: { flexDirection: 'row', justifyContent: 'space-between', marginBottom: spacing.xxs },
  track: { height: 6, borderRadius: 3, backgroundColor: colors.gray100, overflow: 'hidden' },
  fill: { height: 6, borderRadius: 3, backgroundColor: colors.purple },
  menuRow: { flexDirection: 'row', alignItems: 'center', gap: spacing.sm, padding: spacing.md },
  deleteRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: spacing.xs,
    marginTop: spacing.lg,
    paddingVertical: spacing.sm,
  },
  menuDivider: { height: 1, backgroundColor: colors.gray100, marginLeft: spacing.md + 22 + spacing.sm },
  backdrop: { flex: 1, backgroundColor: '#00000055' },
  sheet: {
    backgroundColor: colors.white,
    borderTopLeftRadius: radius.xl,
    borderTopRightRadius: radius.xl,
    padding: spacing.lg,
    paddingBottom: spacing.xxl,
  },
  handle: { width: 40, height: 4, borderRadius: 2, backgroundColor: colors.gray300, alignSelf: 'center' },
  input: {
    backgroundColor: colors.gray50,
    borderRadius: radius.xs,
    borderWidth: 1.5,
    borderColor: colors.gray200,
    paddingHorizontal: spacing.md,
    height: 52,
  },
});
