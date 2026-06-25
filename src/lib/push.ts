import Constants from 'expo-constants';
import * as Device from 'expo-device';
import * as Notifications from 'expo-notifications';
import { Platform } from 'react-native';
import { api } from '@/api/client'; // cliente HTTP autenticado

Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowBanner: true,
    shouldShowList: true,
    shouldPlaySound: true,
    shouldSetBadge: false,
  }),
});

/**
 * Obtiene el Expo push token (ExponentPushToken[...]) y lo registra en el backend.
 * Llamar justo después de iniciar sesión. Silencioso en Expo Go / simulador / sin permiso.
 */
export async function registerForPush(): Promise<void> {
  if (!Device.isDevice) return; // no hay push en simulador
  try {
    let { status } = await Notifications.getPermissionsAsync();
    if (status !== 'granted') status = (await Notifications.requestPermissionsAsync()).status;
    if (status !== 'granted') return;

    if (Platform.OS === 'android') {
      await Notifications.setNotificationChannelAsync('default', {
        name: 'default',
        importance: Notifications.AndroidImportance.DEFAULT,
      });
    }

    const projectId = Constants.expoConfig?.extra?.eas?.projectId as string | undefined;
    const { data: token } = await Notifications.getExpoPushTokenAsync(
      projectId ? { projectId } : undefined,
    );
    if (!token) return;

    await api.post('/devices', { push_token: token, platform: Platform.OS });
  } catch {
    // silencioso: Expo Go / simulador / sin permiso
  }
}
