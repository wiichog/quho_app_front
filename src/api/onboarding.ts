/**
 * Endpoints de onboarding conversacional (apps/users/urls/onboarding.py).
 * Flujo: start -> conversation* -> complete. Asistido por Claude en el backend.
 */
import { api } from './client';

export interface OnboardingStart {
  session_id: string;
  status: string;
  message: string;
  completeness: number;
}

export interface OnboardingTurn {
  session_id?: string;
  status?: string;
  response?: string;
  message?: string;
  completeness?: number;
  extracted_data?: Record<string, unknown>;
}

export interface OnboardingMessage {
  id: number;
  role: 'user' | 'assistant' | string;
  content: string;
  created_at: string;
}

export interface OnboardingStatusResponse {
  session_id: string;
  status: string;
  completeness: number;
  conversation_history: OnboardingMessage[];
  summary: unknown;
  extractions: unknown[];
}

export interface OnboardingComplete {
  success: boolean;
  message: string;
  comprehension_score: number;
  budget_id: number;
  recommendations?: string[];
  practical_tips?: string[];
  initial_challenges?: unknown[];
  [key: string]: unknown;
}

export async function startOnboarding(): Promise<OnboardingStart> {
  const { data } = await api.post<OnboardingStart>('/onboarding/start/');
  return data;
}

export async function sendOnboardingMessage(message: string): Promise<OnboardingTurn> {
  const { data } = await api.post<OnboardingTurn>('/onboarding/conversation/', { message });
  return data;
}

export async function getOnboardingStatus(): Promise<OnboardingStatusResponse> {
  const { data } = await api.get<OnboardingStatusResponse>('/onboarding/status/');
  return data;
}

export async function completeOnboarding(): Promise<OnboardingComplete> {
  const { data } = await api.post<OnboardingComplete>('/onboarding/complete/', { accepted: true });
  return data;
}
