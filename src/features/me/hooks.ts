import { useMutation, useQueryClient } from '@tanstack/react-query';
import { deleteAccount, updateProfile } from '@/api/me';
import { useAuthStore } from '@/store/authStore';
import type { ApiError, UserProfile } from '@/types/api';

export function useUpdateProfile() {
  const qc = useQueryClient();
  return useMutation<UserProfile, ApiError, Partial<UserProfile>>({
    mutationFn: updateProfile,
    onSuccess: (profile) => {
      useAuthStore.setState({ profile });
      qc.invalidateQueries({ queryKey: ['plan'] });
    },
  });
}

/**
 * Borrado de cuenta in-app (requisito de App Store 5.1.1(v)).
 * Tras eliminar en el backend, cierra la sesión y limpia el estado local.
 */
export function useDeleteAccount() {
  const qc = useQueryClient();
  const signOut = useAuthStore((s) => s.signOut);
  return useMutation<void, ApiError, string>({
    mutationFn: deleteAccount,
    onSuccess: async () => {
      qc.clear();
      await signOut();
    },
  });
}
