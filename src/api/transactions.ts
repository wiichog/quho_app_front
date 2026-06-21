/**
 * Endpoints de transacciones (apps/finances TransactionViewSet).
 * El backend usa `transaction_type` (expense|income|transfer) y montos Money.
 */
import type { MoneyDict } from '@/utils/money';
import { api } from './client';

export type TransactionType = 'expense' | 'income' | 'transfer';

export interface Transaction {
  id: number;
  transaction_type: TransactionType;
  amount: string | number | MoneyDict;
  date: string;
  description: string | null;
  category: number | null;
  category_name: string | null;
  category_icon: string | null;
  category_color: string | null;
  status: string;
  source: string;
  is_ignored?: boolean;
  created_at?: string;
}

export interface Paginated<T> {
  count: number;
  next: string | null;
  previous: string | null;
  results: T[];
}

export interface TransactionFilters {
  transaction_type?: TransactionType;
  status?: string;
  category?: string | number;
  start_date?: string;
  end_date?: string;
  month?: string;
  page?: number;
}

export async function listTransactions(filters: TransactionFilters = {}): Promise<Paginated<Transaction>> {
  const { data } = await api.get<Paginated<Transaction>>('/transactions/', { params: filters });
  return data;
}

export async function getTransaction(id: number): Promise<Transaction> {
  const { data } = await api.get<Transaction>(`/transactions/${id}/`);
  return data;
}

export interface CreateTransactionPayload {
  transaction_type: TransactionType;
  amount: string;
  amount_currency?: string;
  date: string;
  description?: string;
  category?: number | null;
}

export async function createTransaction(payload: CreateTransactionPayload): Promise<Transaction> {
  const { data } = await api.post<Transaction>('/transactions/', payload);
  return data;
}

export async function updateTransaction(
  id: number,
  payload: Partial<CreateTransactionPayload>,
): Promise<Transaction> {
  const { data } = await api.patch<Transaction>(`/transactions/${id}/`, payload);
  return data;
}

export async function deleteTransaction(id: number): Promise<void> {
  await api.delete(`/transactions/${id}/`);
}
