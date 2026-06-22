/**
 * Endpoints de autenticación (apps/users/urls/auth.py).
 * Contratos verificados contra los serializers/views reales del backend.
 */
import { CURRENCY } from '@/constants/app';
import type { AuthResponse } from '@/types/api';
import { api } from './client';

export interface LoginPayload {
  identifier: string; // email, phone o username
  password: string;
}

export async function login(payload: LoginPayload): Promise<AuthResponse> {
  const { data } = await api.post<AuthResponse>('/auth/login/', payload);
  return data;
}

export interface RegisterPayload {
  email: string;
  password: string;
  first_name: string;
  last_name: string;
  phone?: string;
}

export async function register(payload: RegisterPayload): Promise<{ message: string }> {
  const { data } = await api.post('/auth/register/', {
    ...payload,
    country: 'MX',
    currency: CURRENCY.default,
    terms_accepted: true, // requerido por el backend
  });
  return data;
}

/** El backend espera `token` (no `code`). */
export async function verifyEmail(token: string): Promise<{ message: string }> {
  const { data } = await api.post('/auth/verify/', { token });
  return data;
}

export async function requestPasswordReset(email: string): Promise<{ message: string }> {
  const { data } = await api.post('/auth/password/reset/request/', { email });
  return data;
}

/** El backend espera `{ token, new_password }`. */
export async function confirmPasswordReset(
  token: string,
  newPassword: string,
): Promise<{ message: string }> {
  const { data } = await api.post('/auth/password/reset/confirm/', {
    token,
    new_password: newPassword,
  });
  return data;
}

export async function logout(refresh: string): Promise<void> {
  await api.post('/auth/logout/', { refresh });
}

export async function changePassword(
  currentPassword: string,
  newPassword: string,
): Promise<{ message: string }> {
  const { data } = await api.post('/auth/password/change/', {
    current_password: currentPassword,
    new_password: newPassword,
  });
  return data;
}

export type SocialProvider = 'google' | 'apple' | 'facebook';

export async function socialAuth(
  provider: SocialProvider,
  payload: { access_token?: string; id_token?: string; authorization_code?: string },
): Promise<AuthResponse> {
  const { data } = await api.post<AuthResponse>(`/auth/social/${provider}/`, payload);
  return data;
}
