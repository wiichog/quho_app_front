/**
 * Estado de sesión (zustand). Reemplaza AuthBloc + SessionManager de Flutter.
 */
import AsyncStorage from '@react-native-async-storage/async-storage';
import { create } from 'zustand';
import * as authApi from '@/api/auth';
import { getProfile } from '@/api/me';
import {
  clearTokens,
  getAccessToken,
  getRefreshToken,
  setTokens,
} from '@/api/tokenStorage';
import { STORAGE_KEYS } from '@/constants/app';
import type { AuthResponse, AuthUser, UserProfile } from '@/types/api';

type Status = 'loading' | 'authenticated' | 'unauthenticated';

interface SessionMeta {
  plan: string;
  onboardingCompleted: boolean;
}

interface AuthState {
  status: Status;
  user: AuthUser | null;
  profile: UserProfile | null;
  plan: string;
  onboardingCompleted: boolean;

  bootstrap: () => Promise<void>;
  signIn: (res: AuthResponse) => Promise<void>;
  signOut: () => Promise<void>;
  setOnboardingCompleted: (done: boolean) => Promise<void>;
  refreshProfile: () => Promise<void>;
  handleSessionExpired: () => void;
}

const SESSION_META_KEY = 'session_meta';

function isOnboardingDone(status?: string): boolean {
  return status === 'complete' || status === 'functional';
}

async function persistMeta(meta: SessionMeta): Promise<void> {
  await AsyncStorage.setItem(SESSION_META_KEY, JSON.stringify(meta));
}

async function readMeta(): Promise<SessionMeta> {
  const raw = await AsyncStorage.getItem(SESSION_META_KEY);
  if (!raw) return { plan: 'free', onboardingCompleted: false };
  try {
    return JSON.parse(raw) as SessionMeta;
  } catch {
    return { plan: 'free', onboardingCompleted: false };
  }
}

export const useAuthStore = create<AuthState>((set, get) => ({
  status: 'loading',
  user: null,
  profile: null,
  plan: 'free',
  onboardingCompleted: false,

  bootstrap: async () => {
    const token = await getAccessToken();
    if (!token) {
      set({ status: 'unauthenticated' });
      return;
    }
    try {
      const profile = await getProfile(); // valida el token (refresh automático si aplica)
      const meta = await readMeta();
      // /me/ ahora devuelve onboarding_status; es la fuente de verdad si está presente.
      const onboardingCompleted = profile.onboarding_status
        ? isOnboardingDone(profile.onboarding_status)
        : meta.onboardingCompleted;
      set({
        status: 'authenticated',
        profile,
        plan: meta.plan,
        onboardingCompleted,
      });
    } catch {
      await clearTokens();
      set({ status: 'unauthenticated', user: null, profile: null });
    }
  },

  signIn: async (res) => {
    await setTokens(res.access, res.refresh);
    const onboardingCompleted = isOnboardingDone(res.user.onboarding_status);
    await persistMeta({ plan: res.user.plan, onboardingCompleted });
    set({
      status: 'authenticated',
      user: res.user,
      plan: res.user.plan,
      onboardingCompleted,
    });
    // Cargar perfil completo en segundo plano.
    get().refreshProfile().catch(() => undefined);
  },

  signOut: async () => {
    const refresh = await getRefreshToken();
    if (refresh) {
      await authApi.logout(refresh).catch(() => undefined);
    }
    await clearTokens();
    await AsyncStorage.multiRemove([SESSION_META_KEY, STORAGE_KEYS.userName]);
    set({ status: 'unauthenticated', user: null, profile: null, plan: 'free', onboardingCompleted: false });
  },

  setOnboardingCompleted: async (done) => {
    const meta = await readMeta();
    await persistMeta({ ...meta, onboardingCompleted: done });
    set({ onboardingCompleted: done });
  },

  refreshProfile: async () => {
    const profile = await getProfile();
    set({ profile });
  },

  handleSessionExpired: () => {
    clearTokens().catch(() => undefined);
    set({ status: 'unauthenticated', user: null, profile: null });
  },
}));
