/**
 * Hooks de autenticación (react-query) que conectan la API con el authStore.
 */
import { useMutation } from '@tanstack/react-query';
import * as authApi from '@/api/auth';
import { useAuthStore } from '@/store/authStore';
import type { ApiError } from '@/types/api';

export function useLogin() {
  const signIn = useAuthStore((s) => s.signIn);
  return useMutation<Awaited<ReturnType<typeof authApi.login>>, ApiError, authApi.LoginPayload>({
    mutationFn: authApi.login,
    onSuccess: (res) => signIn(res),
  });
}

export function useRegister() {
  return useMutation<{ message: string }, ApiError, authApi.RegisterPayload>({
    mutationFn: authApi.register,
  });
}

export function useVerifyEmail() {
  return useMutation<{ message: string }, ApiError, string>({
    mutationFn: authApi.verifyEmail,
  });
}

export function useRequestPasswordReset() {
  return useMutation<{ message: string }, ApiError, string>({
    mutationFn: authApi.requestPasswordReset,
  });
}

export function useConfirmPasswordReset() {
  return useMutation<{ message: string }, ApiError, { token: string; newPassword: string }>({
    mutationFn: ({ token, newPassword }) => authApi.confirmPasswordReset(token, newPassword),
  });
}
