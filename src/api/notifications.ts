/**
 * Endpoints de notificaciones (apps/notifications).
 */
import { api } from './client';

export interface NotificationSettings {
  budget_alerts: boolean;
  goal_reminders: boolean;
  transaction_confirmations: boolean;
  marketing_emails: boolean;
}

export async function getNotificationSettings(): Promise<NotificationSettings> {
  const { data } = await api.get<NotificationSettings>('/me/notification-settings/');
  return data;
}

export async function updateNotificationSettings(
  partial: Partial<NotificationSettings>,
): Promise<NotificationSettings> {
  const { data } = await api.patch<NotificationSettings>('/me/notification-settings/', partial);
  return data;
}

export async function registerPushToken(
  token: string,
  provider = 'fcm',
  deviceMeta: Record<string, unknown> = {},
): Promise<void> {
  await api.post('/push/register/', { token, provider, device_meta: deviceMeta });
}

export interface AppNotification {
  id: number;
  template_code: string;
  payload: Record<string, unknown>;
  channel: string;
  status: string;
  read_at: string | null;
  created_at: string;
}

export async function listNotifications(): Promise<AppNotification[]> {
  const { data } = await api.get<AppNotification[]>('/notifications/');
  return data;
}
