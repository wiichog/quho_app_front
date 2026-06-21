/**
 * Endpoints de perfil/plan (apps/users/urls/profile.py).
 */
import type { UserPlan, UserProfile } from '@/types/api';
import { api } from './client';

export async function getProfile(): Promise<UserProfile> {
  const { data } = await api.get<UserProfile>('/me/');
  return data;
}

export async function updateProfile(payload: Partial<UserProfile>): Promise<UserProfile> {
  const { data } = await api.patch<UserProfile>('/me/', payload);
  return data;
}

export async function getPlan(): Promise<UserPlan> {
  const { data } = await api.get<UserPlan>('/me/plan/');
  return data;
}

export interface ReferralLink {
  referral_code: string;
  referral_link: string;
  total_referrals: number;
  active_referrals: number;
}

export async function getReferralLink(): Promise<ReferralLink> {
  const { data } = await api.post<ReferralLink>('/me/referrals/link/');
  return data;
}

export async function deleteAccount(password: string): Promise<void> {
  await api.post('/me/delete-account/', { password, confirmation: 'DELETE' });
}
