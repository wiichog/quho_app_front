/**
 * Configuración de entornos para QUHO (port de environment.dart).
 *
 * Override en runtime con la variable EXPO_PUBLIC_API_URL (.env) si se requiere
 * apuntar a un backend distinto (p.ej. una IP LAN para probar en dispositivo físico).
 */
import { Platform } from 'react-native';

type Env = 'development' | 'staging' | 'production';

const current: Env = __DEV__ ? 'development' : 'production';

/**
 * En Android emulador, localhost del backend es 10.0.2.2.
 * En dispositivo físico debes usar la IP LAN de tu máquina vía EXPO_PUBLIC_API_URL.
 */
function devBaseUrl(): string {
  const host = Platform.OS === 'android' ? '10.0.2.2' : 'localhost';
  return `http://${host}:8000/api/v1`;
}

const fallbackByEnv: Record<Env, string> = {
  development: devBaseUrl(),
  staging: 'https://api-staging.quhoapp.com/api/v1',
  production: 'https://api.quhoapp.com/api/v1',
};

export const environment = {
  current,
  isDev: current === 'development',
  isProduction: current === 'production',
  apiBaseUrl: process.env.EXPO_PUBLIC_API_URL || fallbackByEnv[current],
  connectionTimeoutMs: current === 'development' ? 60_000 : 30_000,
  enableLogging: current !== 'production',
};
