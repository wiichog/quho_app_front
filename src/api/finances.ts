/**
 * Endpoints de finanzas: categorías, ingresos, gastos fijos, metas, presupuesto.
 * (apps/finances/urls.py)
 */
import type { MoneyDict } from '@/utils/money';
import { api } from './client';
import type { Paginated } from './transactions';

export interface Category {
  id: number;
  slug: string;
  display_name: string;
  icon: string | null;
  color: string | null;
  parent_id: number | null;
  parent_name: string | null;
  full_path: string;
  is_system: boolean;
}

export async function listCategories(): Promise<Category[]> {
  const { data } = await api.get<Paginated<Category> | Category[]>('/categories/');
  return Array.isArray(data) ? data : data.results;
}

export interface Income {
  id: number;
  name: string;
  amount: string | number;
  frequency: string;
  normalized_monthly_display: MoneyDict;
  is_active: boolean;
  created_at: string;
}

export async function listIncomes(): Promise<Income[]> {
  const { data } = await api.get<Paginated<Income> | Income[]>('/incomes/');
  return Array.isArray(data) ? data : data.results;
}

export async function createIncome(payload: {
  name: string;
  amount: string;
  frequency: string;
}): Promise<Income> {
  const { data } = await api.post<Income>('/incomes/', payload);
  return data;
}

export async function updateIncome(
  id: number,
  payload: { name?: string; amount?: string; frequency?: string },
): Promise<Income> {
  const { data } = await api.patch<Income>(`/incomes/${id}/`, payload);
  return data;
}

export async function deleteIncome(id: number): Promise<void> {
  await api.delete(`/incomes/${id}/`);
}

export interface FixedExpense {
  id: number;
  name: string;
  amount: string | number;
  frequency: string;
  category_id: number | null;
  category_name: string | null;
  due_day: number | null;
  normalized_monthly_display: MoneyDict;
  is_active: boolean;
}

export async function listFixedExpenses(): Promise<FixedExpense[]> {
  const { data } = await api.get<Paginated<FixedExpense> | FixedExpense[]>('/fixed-expenses/');
  return Array.isArray(data) ? data : data.results;
}

export async function createFixedExpense(payload: {
  name: string;
  amount: string;
  frequency: string;
  category?: number;
  due_day?: number;
}): Promise<FixedExpense> {
  const { data } = await api.post<FixedExpense>('/fixed-expenses/', payload);
  return data;
}

export async function updateFixedExpense(
  id: number,
  payload: { name?: string; amount?: string; frequency?: string; category?: number; due_day?: number },
): Promise<FixedExpense> {
  const { data } = await api.patch<FixedExpense>(`/fixed-expenses/${id}/`, payload);
  return data;
}

export async function deleteFixedExpense(id: number): Promise<void> {
  await api.delete(`/fixed-expenses/${id}/`);
}

export interface Goal {
  id: number;
  name: string;
  target_amount: string | number | MoneyDict;
  target_date: string | null;
  linked_account: number | null;
  linked_account_name: string | null;
  status: string;
  progress_percentage: number;
  created_at: string;
}

export async function listGoals(): Promise<Goal[]> {
  const { data } = await api.get<Paginated<Goal> | Goal[]>('/goals/');
  return Array.isArray(data) ? data : data.results;
}

export async function createGoal(payload: {
  name: string;
  target_amount: string;
  target_date?: string;
}): Promise<Goal> {
  const { data } = await api.post<Goal>('/goals/', payload);
  return data;
}

export async function updateGoal(
  id: number,
  payload: { name?: string; target_amount?: string; target_date?: string },
): Promise<Goal> {
  const { data } = await api.patch<Goal>(`/goals/${id}/`, payload);
  return data;
}

export async function completeGoal(id: number): Promise<Goal> {
  const { data } = await api.post<Goal>(`/goals/${id}/complete/`, {});
  return data;
}

export async function deleteGoal(id: number): Promise<void> {
  await api.delete(`/goals/${id}/`);
}

// ---------- Presupuesto ----------
export interface BudgetCategoryRow {
  category: string;
  spent: number;
  budgeted?: number;
  percentage: number;
  [key: string]: unknown;
}

interface MoneyAmount {
  amount: number | string;
  currency: string;
}

/** Respuesta de /budget/{month}/summary/ (ExecutionAggregator + category_breakdown). */
export interface BudgetSummary {
  month?: string;
  theoretical?: {
    total_income: MoneyAmount;
    total_expense: MoneyAmount;
    savings_target: MoneyAmount;
  };
  execution?: {
    total_income: MoneyAmount;
    total_expense: MoneyAmount;
    net: MoneyAmount;
    [key: string]: unknown;
  };
  category_breakdown?: BudgetCategoryRow[];
  [key: string]: unknown;
}

export async function getBudgetSummary(month: string): Promise<BudgetSummary> {
  const { data } = await api.get<BudgetSummary>(`/budget/${month}/summary/`);
  return data;
}

export async function getFinancesOverview(month: string): Promise<Record<string, unknown>> {
  const { data } = await api.get(`/finances/overview/${month}/`);
  return data;
}
