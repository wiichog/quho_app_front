import { useMutation, useQueryClient } from '@tanstack/react-query';
import { updateProfile } from '@/api/me';
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
