import { MaterialIcons } from '@expo/vector-icons';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useRouter } from 'expo-router';
import { useState } from 'react';
import { Alert, Pressable, StyleSheet, Switch, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import {
  getNotificationSettings,
  registerPushToken,
  updateNotificationSettings,
  type NotificationSettings,
} from '@/api/notifications';
import { Button, Card, Loading, Text } from '@/components';
import { colors, spacing } from '@/theme';

const ROWS: { key: keyof NotificationSettings; label: string; desc: string }[] = [
  { key: 'budget_alerts', label: 'Alertas de presupuesto', desc: 'Cuando te acercas a tu límite' },
  { key: 'goal_reminders', label: 'Recordatorios de metas', desc: 'Para mantener tu ahorro al día' },
  { key: 'transaction_confirmations', label: 'Confirmación de movimientos', desc: 'Al registrar ingresos o gastos' },
  { key: 'marketing_emails', label: 'Novedades y promociones', desc: 'Correos ocasionales de QUHO' },
];

export default function NotificationsScreen() {
  const router = useRouter();
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
      await registerPushToken(tokenResp.data, 'fcm', {
        os: Device.osName,
        model: Device.modelName,
      });
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

  return (
    <SafeAreaView style={styles.safe}>
      <View style={styles.header}>
        <Pressable onPress={() => router.back()} hitSlop={8}>
          <MaterialIcons name="arrow-back" size={24} color={colors.gray700} />
        </Pressable>
        <Text variant="h4">Notificaciones</Text>
        <View style={{ width: 24 }} />
      </View>

      <View style={styles.content}>
        {settings.isLoading || !settings.data ? (
          <Loading />
        ) : (
          <>
            <Card padded={false}>
              {ROWS.map((row, i) => (
                <View key={row.key}>
                  {i > 0 ? <View style={styles.sep} /> : null}
                  <View style={styles.row}>
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
          </>
        )}
      </View>
    </SafeAreaView>
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
  content: { flex: 1, padding: spacing.lg },
  row: { flexDirection: 'row', alignItems: 'center', gap: spacing.sm, padding: spacing.md },
  sep: { height: 1, backgroundColor: colors.gray100, marginHorizontal: spacing.md },
});
