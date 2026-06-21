/**
 * Endpoints de gamificación (apps/gamification, /api/v1/gamification/).
 */
import { api } from './client';

export interface PointsSummary {
  total_points: number;
  level: { code: string; name: string; color: string };
  next_level_points: number | null;
  points_to_next_level: number;
  streak_days: number;
  longest_streak: number;
  badges_unlocked: number;
  total_badges: number;
}

export interface Badge {
  id: number;
  code: string;
  title: string;
  description: string;
  icon: string | null;
  is_premium_only: boolean;
  unlocked: boolean;
  granted_at: string | null;
}

export interface Mission {
  id: number;
  code: string;
  title: string;
  description: string;
  period: string;
  reward_points: number;
  is_premium_only: boolean;
  progress: Record<string, unknown>;
  completed: boolean;
}

export interface Streak {
  kind: string;
  current_count: number;
  longest_count: number;
  last_increment_at: string | null;
}

export async function getPointsSummary(): Promise<PointsSummary> {
  const { data } = await api.get<PointsSummary>('/gamification/summary/');
  return data;
}

export async function getBadges(): Promise<{ unlocked: Badge[]; locked: Badge[] }> {
  const { data } = await api.get<{ unlocked: Badge[]; locked: Badge[] }>('/gamification/badges/');
  return data;
}

export async function getActiveMissions(): Promise<Mission[]> {
  const { data } = await api.get<Mission[]>('/gamification/missions/active/');
  return data;
}

export async function getStreaks(): Promise<Streak[]> {
  const { data } = await api.get<Streak[]>('/gamification/streaks/');
  return data;
}
