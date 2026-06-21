/**
 * Almacenamiento seguro de tokens (expo-secure-store) + bus de sesión expirada.
 * Reemplaza flutter_secure_storage + SessionManager de la app Flutter.
 */
import * as SecureStore from 'expo-secure-store';
import { STORAGE_KEYS } from '@/constants/app';

let accessTokenCache: string | null = null;

export async function getAccessToken(): Promise<string | null> {
  if (accessTokenCache) return accessTokenCache;
  accessTokenCache = await SecureStore.getItemAsync(STORAGE_KEYS.accessToken);
  return accessTokenCache;
}

export async function getRefreshToken(): Promise<string | null> {
  return SecureStore.getItemAsync(STORAGE_KEYS.refreshToken);
}

export async function setTokens(access: string, refresh?: string): Promise<void> {
  accessTokenCache = access;
  await SecureStore.setItemAsync(STORAGE_KEYS.accessToken, access);
  if (refresh) {
    await SecureStore.setItemAsync(STORAGE_KEYS.refreshToken, refresh);
  }
}

export async function clearTokens(): Promise<void> {
  accessTokenCache = null;
  await SecureStore.deleteItemAsync(STORAGE_KEYS.accessToken);
  await SecureStore.deleteItemAsync(STORAGE_KEYS.refreshToken);
}

// ---- Bus de sesión expirada ----
type Listener = () => void;
const sessionExpiredListeners = new Set<Listener>();

export function onSessionExpired(listener: Listener): () => void {
  sessionExpiredListeners.add(listener);
  return () => sessionExpiredListeners.delete(listener);
}

export function notifySessionExpired(): void {
  sessionExpiredListeners.forEach((l) => l());
}
