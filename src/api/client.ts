/**
 * Cliente HTTP de QUHO (axios). Port de api_client.dart + interceptores.
 * - Adjunta Bearer token.
 * - Refresca automáticamente en 401 (single-flight) vía /auth/token/refresh/.
 * - Normaliza errores DRF a ApiError.
 */
import axios, {
  AxiosError,
  AxiosInstance,
  AxiosRequestConfig,
  InternalAxiosRequestConfig,
} from 'axios';
import { environment } from '@/config/environment';
import { ERROR_MESSAGES } from '@/constants/app';
import type { ApiError } from '@/types/api';
import {
  clearTokens,
  getAccessToken,
  getRefreshToken,
  notifySessionExpired,
  setTokens,
} from './tokenStorage';

export const api: AxiosInstance = axios.create({
  baseURL: environment.apiBaseUrl,
  timeout: environment.connectionTimeoutMs,
  headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
});

// ---------- Request: Bearer ----------
api.interceptors.request.use(async (config: InternalAxiosRequestConfig) => {
  const token = await getAccessToken();
  if (token) config.headers.Authorization = `Bearer ${token}`;
  if (environment.enableLogging) {
    // eslint-disable-next-line no-console
    console.log(`➡️  ${config.method?.toUpperCase()} ${config.url}`);
  }
  return config;
});

// ---------- Response: refresh en 401 ----------
let refreshPromise: Promise<string | null> | null = null;

async function refreshAccessToken(): Promise<string | null> {
  const refresh = await getRefreshToken();
  if (!refresh) return null;
  try {
    // Instancia limpia para evitar recursión de interceptores.
    const res = await axios.post(
      `${environment.apiBaseUrl}/auth/token/refresh/`,
      { refresh },
      { headers: { 'Content-Type': 'application/json' } },
    );
    const access = res.data?.access as string | undefined;
    if (!access) return null;
    await setTokens(access, res.data?.refresh);
    return access;
  } catch {
    return null;
  }
}

api.interceptors.response.use(
  (response) => response,
  async (error: AxiosError) => {
    const original = error.config as (AxiosRequestConfig & { _retry?: boolean }) | undefined;

    if (error.response?.status === 401 && original && !original._retry) {
      original._retry = true;
      // single-flight: solo un refresh concurrente
      if (!refreshPromise) refreshPromise = refreshAccessToken();
      const newToken = await refreshPromise;
      refreshPromise = null;

      if (newToken) {
        original.headers = { ...original.headers, Authorization: `Bearer ${newToken}` };
        return api.request(original);
      }
      await clearTokens();
      notifySessionExpired();
    }

    return Promise.reject(normalizeError(error));
  },
);

// ---------- Normalización de errores ----------
export function normalizeError(error: unknown): ApiError {
  if (axios.isAxiosError(error)) {
    const status = error.response?.status ?? 0;
    const data = error.response?.data as Record<string, unknown> | undefined;

    if (status === 0) {
      return { status, message: ERROR_MESSAGES.network, raw: error.message };
    }
    if (error.code === 'ECONNABORTED') {
      return { status, message: ERROR_MESSAGES.timeout };
    }

    // DRF: { detail }, { error }, { non_field_errors: [...] }, o { campo: [...] }
    let message: string = ERROR_MESSAGES.generic;
    const fields: Record<string, string[]> = {};
    if (data) {
      if (typeof data.detail === 'string') message = data.detail;
      else if (typeof data.error === 'string') message = data.error;
      else if (Array.isArray((data as any).non_field_errors)) {
        message = (data as any).non_field_errors[0];
      } else {
        for (const [key, val] of Object.entries(data)) {
          if (Array.isArray(val)) {
            fields[key] = val as string[];
            if (message === ERROR_MESSAGES.generic) message = String(val[0]);
          } else if (typeof val === 'string' && message === ERROR_MESSAGES.generic) {
            message = val;
          }
        }
      }
    }
    if (status === 401 && message === ERROR_MESSAGES.generic) {
      message = ERROR_MESSAGES.unauthorized;
    }
    return { status, message, fields: Object.keys(fields).length ? fields : undefined, raw: data };
  }
  return { status: 0, message: ERROR_MESSAGES.generic, raw: error };
}
