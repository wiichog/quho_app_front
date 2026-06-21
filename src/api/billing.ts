/**
 * Endpoints de billing (apps/billing, /api/v1/billing/).
 */
import { api } from './client';

export interface Subscription {
  plan_code: string;
  status: string;
  subscription: {
    id: number;
    status: string;
    plan_code: string;
    current_period_end: string;
    cancel_at_period_end: boolean;
  } | null;
}

export async function getSubscription(): Promise<Subscription> {
  const { data } = await api.get<Subscription>('/billing/subscription/');
  return data;
}

export async function createCheckoutSession(
  interval: 'monthly' | 'yearly' = 'monthly',
): Promise<{ checkout_url: string; session_id: string }> {
  const { data } = await api.post('/billing/checkout-session/', { plan: 'premium', interval });
  return data;
}
