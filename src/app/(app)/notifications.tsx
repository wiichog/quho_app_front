import { MaterialIcons } from '@expo/vector-icons';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useRouter } from 'expo-router';
import { useState } from 'react';
import { Alert, FlatList, Pressable, StyleSheet, Switch, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import {
  getNotificationSettings,
  listNotifications,
  markAllNotificationsRead,
  markNotificationRead,
  registerPushToken,
  updateNotificationSettings,
  type AppNotification,
  type NotificationSettings,
} from '@/api/notifications';
import { Button, Card, EmptyState, ListSkeleton, Text } from '@/components';
import { colors, radius, spacing } from '@/theme';
import { relativeDate } from '@/utils/formatters';

const ROWS: { key: keyof NotificationSettings; label: string; desc: string }[] = [
  { key: 'budget_alerts', label: 'Alertas de presupuesto', desc: 'Cuando te acercas a tu límite' },
  { key: 'goal_reminders', label: 'Recordatorios de metas', desc: 'Para mantener tu ahorro al día' },
  { key: 'transaction_confirmations', label: 'Confirmación de movimientos', desc: 'Al registrar ingresos o gastos' },
  { key: 'marketing_emails', label: 'Novedades y promociones', desc: 'Correos ocasionales de QUHO' },
];

const TITLES: Record<string, { title: string; icon: keyof typeof MaterialIcons.glyphMap }> = {
  budget_alert: { title: 'Alerta de presupuesto', icon: 'pie-chart' },
  goal_reminder: { title: 'Recordatorio de meta', icon: 'flag' },
  transaction_confirmation: { title: 'Movimiento registrado', icon: 'receipt-long' },
  welcome: { title: 'Bienvenido a QUHO', icon: 'celebration' },
};

function describe(n: AppNotification) {
  const meta = TITLES[n.template_code] ?? {
    title: n.template_code.replace(/_/g, ' ').replace(/^\w/, (c) => c.toUpperCase()),
    icon: 'notifications' as const,
  };
  const payload = n.payload as { message?: string; body?: string };
  return { ...meta, body: payload?.message || payload?.body || '' };
}

export default function NotificationsScreen() {
  const router = useRouter();
  const [tab, setTab] = useState<'inbox' | 'settings'>('inbox');

  return (
    <SafeAreaView style={styles.safe}>
      <View style={styles.header}>
        <Pressable onPress={() => router.back()} hitSlop={8}>
          <MaterialIcons name="arrow-back" size={24} color={colors.gray700} />
        </Pressable>
        <Text variant="h4">Notificaciones</Text>
        <View style={{ width: 24 }} />
      </View>

      <View style={styles.segment}>
        <SegBtn label="Bandeja" active={tab === 'inbox'} onPress={() => setTab('inbox')} />
        <SegBtn label="Ajustes" active={tab === 'settings'} onPress={() => setTab('settings')} />
      </View>

      {tab === 'inbox' ? <Inbox /> : <SettingsTab />}
    </SafeAreaView>
  );
}

function Inbox() {
  const qc = useQueryClient();
  const inbox = useQuery({ queryKey: ['notif-inbox'], queryFn: listNotifications });
  const read = useMutation({
    mutationFn: markNotificationRead,
    onSuccess: () => qc.invalidateQueries({ queryKey: ['notif-inbox'] }),
  });
  const readAll = useMutation({
    mutationFn: markAllNotificationsRead,
    onSuccess: () => qc.invalidateQueries({ queryKey: ['notif-inbox'] }),
  });

  const items = inbox.data?.results ?? [];
  const unread = inbox.data?.unread ?? 0;

  if (inbox.isLoading) {
    return (
      <View style={styles.body}>
        <ListSkeleton rows={6} />
      </View>
    );
  }

  return (
    <FlatList
      data={items}
      keyExtractor={(n) => String(n.id)}
      contentContainerStyle={styles.body}
      refreshing={inbox.isRefetching}
      onRefresh={inbox.refetch}
      ListHeaderComponent={
        unread > 0 ? (
          <Pressable style={styles.readAll} onPress={() => readAll.mutate()}>
            <MaterialIcons name="done-all" size={16} color={colors.teal} />
            <Text variant="caption" color={colors.teal}>
              Marcar todo como leído ({unread})
            </Text>
          </Pressable>
        ) : null
      }
      ListEmptyComponent={
        <EmptyState
          icon="notifications-none"
          title="Sin notificaciones"
          message="Aquí verás alertas de presupuesto, recordatorios y novedades."
        />
      }
      ItemSeparatorComponent={() => <View style={styles.sep} />}
      renderItem={({ item }) => {
        const { title, icon, body } = describe(item);
        const isUnread = !item.read_at;
        return (
          <Pressable
            style={styles.row}
            onPress={() => isUnread && read.mutate(item.id)}
          >
            <View style={[styles.icon, { backgroundColor: isUnread ? colors.tealPale : colors.gray100 }]}>
              <MaterialIcons name={icon} size={20} color={isUnread ? colors.teal : colors.gray400} />
            </View>
            <View style={styles.flex}>
              <Text variant="h5" color={isUnread ? colors.gray900 : colors.gray600}>
                {title}
              </Text>
              {body ? (
                <Text variant="bodySmall" color={colors.gray500} numberOfLines={2}>
                  {body}
                </Text>
              ) : null}
              <Text variant="caption" color={colors.gray400}>
                {relativeDate(item.created_at)}
              </Text>
            </View>
            {isUnread ? <View style={styles.dot} /> : null}
          </Pressable>
        );
      }}
    />
  );
}

function SettingsTab() {
  const qc = useQueryClient();
  const settings = useQuery({ queryKey: ['notif-settings'], queryFn: getNotificationSettings });
  const [registering, setRegistering] = useState(false);

  const update = useMutation({
    mutationFn: (partial: Partial<NotificationSettings>) => updateNotificationSettings(partial),
    onMutate: async (partial) => {
      await qc.cancelQueries({ queryKey: ['notif-settings'] });
      const prev = qc.getQueryData<NotificationSettings>(['notif-settings']);
      if (prev) qc.setQueryData(['notif-settings'], { ...prev, ...partial });
      return { prev };
    },
    onError: (_e, _v, ctx) => {
      if (ctx?.prev) qc.setQueryData(['notif-settings'], ctx.prev);
    },
    onSettled: () => qc.invalidateQueries({ queryKey: ['notif-settings'] }),
  });

  const enablePush = async () => {
    setRegistering(true);
    try {
      const Notifications = await import('expo-notifications');
      const Device = await import('expo-device');
      const Constants = (await import('expo-constants')).default;
      const { status } = await Notifications.requestPermissionsAsync();
      if (status !== 'granted') {
        Alert.alert('Permiso denegado', 'Activa las notificaciones desde los ajustes del sistema.');
        return;
      }
      const projectId =
        Constants.expoConfig?.extra?.eas?.projectId ?? Constants.easConfig?.projectId;
      const tokenResp = await Notifications.getExpoPushTokenAsync(
        projectId ? { projectId } : undefined,
      );
      await registerPushToken(tokenResp.data, 'fcm', { os: Device.osName, model: Device.modelName });
      Alert.alert('Listo', 'Notificaciones activadas en este dispositivo.');
    } catch {
      Alert.alert(
        'No disponible',
        'Las notificaciones push requieren una build de desarrollo (no funcionan en Expo Go).',
      );
    } finally {
      setRegistering(false);
    }
  };

  if (settings.isLoading || !settings.data) {
    return (
      <View style={styles.body}>
        <ListSkeleton rows={4} />
      </View>
    );
  }

  return (
    <View style={styles.body}>
      <Card padded={false}>
        {ROWS.map((row, i) => (
          <View key={row.key}>
            {i > 0 ? <View style={styles.sep} /> : null}
            <View style={styles.settingRow}>
              <View style={styles.flex}>
                <Text variant="h5">{row.label}</Text>
                <Text variant="bodySmall" color={colors.gray500}>
                  {row.desc}
                </Text>
              </View>
              <Switch
                value={settings.data![row.key]}
                onValueChange={(v) => update.mutate({ [row.key]: v })}
                trackColor={{ true: colors.teal, false: colors.gray300 }}
                thumbColor={colors.white}
              />
            </View>
          </View>
        ))}
      </Card>

      <Button
        title="Activar notificaciones en este dispositivo"
        variant="outline"
        icon="notifications-active"
        onPress={enablePush}
        loading={registering}
        style={{ marginTop: spacing.lg }}
      />
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

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: colors.gray50 },
  flex: { flex: 1 },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: spacing.md,
  },
  segment: {
    flexDirection: 'row',
    backgroundColor: colors.gray100,
    borderRadius: radius.sm,
    padding: 4,
    marginHorizontal: spacing.lg,
    marginBottom: spacing.sm,
  },
  segBtn: { flex: 1, alignItems: 'center', paddingVertical: spacing.sm, borderRadius: radius.xs },
  segBtnActive: { backgroundColor: colors.teal },
  body: { padding: spacing.lg, flexGrow: 1 },
  readAll: { flexDirection: 'row', alignItems: 'center', gap: 6, alignSelf: 'flex-end', marginBottom: spacing.sm },
  row: { flexDirection: 'row', alignItems: 'center', gap: spacing.sm, paddingVertical: spacing.sm },
  icon: { width: 42, height: 42, borderRadius: 21, alignItems: 'center', justifyContent: 'center' },
  dot: { width: 10, height: 10, borderRadius: 5, backgroundColor: colors.teal },
  sep: { height: 1, backgroundColor: colors.gray100 },
  settingRow: { flexDirection: 'row', alignItems: 'center', gap: spacing.sm, padding: spacing.md },
});
