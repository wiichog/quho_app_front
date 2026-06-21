/**
 * Endpoints del motor de IA (apps/ai_engine, /api/v1/ai/).
 */
import { api } from './client';

export interface ChatMessage {
  id: number;
  role: 'user' | 'assistant' | string;
  content: string;
  created_at: string;
}

export interface FinancialScore {
  month: string;
  score: number | null;
  breakdown: Record<string, unknown>;
}

export interface Insight {
  id: number;
  month: string;
  title: string;
  body: string;
  kind: string;
  score_impact: number;
  is_read: boolean;
  created_at: string;
}

export async function getChatHistory(): Promise<ChatMessage[]> {
  const { data } = await api.get<ChatMessage[]>('/ai/chat/');
  return data;
}

export async function sendChat(message: string): Promise<{ response: string }> {
  const { data } = await api.post<{ response: string }>('/ai/chat/', { message });
  return data;
}

export async function getInsights(month: string): Promise<Insight[]> {
  const { data } = await api.get<Insight[]>(`/ai/insights/${month}/`);
  return data;
}

export async function getScore(month: string): Promise<FinancialScore> {
  const { data } = await api.get<FinancialScore>(`/ai/score/${month}/`);
  return data;
}
