import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import * as finApi from '@/api/finances';
import { getPlan } from '@/api/me';
import type { ApiError } from '@/types/api';

export function useCategories() {
  return useQuery({
    queryKey: ['categories'],
    queryFn: finApi.listCategories,
    staleTime: 5 * 60_000,
  });
}

export function useBudgetSummary(month: string) {
  return useQuery({
    queryKey: ['budget', 'summary', month],
    queryFn: () => finApi.getBudgetSummary(month),
  });
}

export function usePlan() {
  return useQuery({ queryKey: ['plan'], queryFn: getPlan, staleTime: 60_000 });
}

export function useIncomes() {
  return useQuery({ queryKey: ['incomes'], queryFn: finApi.listIncomes });
}

export function useFixedExpenses() {
  return useQuery({ queryKey: ['fixed-expenses'], queryFn: finApi.listFixedExpenses });
}

export function useGoals() {
  return useQuery({ queryKey: ['goals'], queryFn: finApi.listGoals });
}

export function useCreateIncome() {
  const qc = useQueryClient();
  return useMutation<finApi.Income, ApiError, { name: string; amount: string; frequency: string }>({
    mutationFn: finApi.createIncome,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['incomes'] });
      qc.invalidateQueries({ queryKey: ['budget'] });
    },
  });
}

export function useCreateFixedExpense() {
  const qc = useQueryClient();
  return useMutation<
    finApi.FixedExpense,
    ApiError,
    { name: string; amount: string; frequency: string; category?: number; due_day?: number }
  >({
    mutationFn: finApi.createFixedExpense,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['fixed-expenses'] });
      qc.invalidateQueries({ queryKey: ['budget'] });
    },
  });
}

export function useCreateGoal() {
  const qc = useQueryClient();
  return useMutation<finApi.Goal, ApiError, { name: string; target_amount: string; target_date?: string }>({
    mutationFn: finApi.createGoal,
    onSuccess: () => qc.invalidateQueries({ queryKey: ['goals'] }),
  });
}

export function useDeleteIncome() {
  const qc = useQueryClient();
  return useMutation<void, ApiError, number>({
    mutationFn: finApi.deleteIncome,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['incomes'] });
      qc.invalidateQueries({ queryKey: ['budget'] });
    },
  });
}

export function useDeleteFixedExpense() {
  const qc = useQueryClient();
  return useMutation<void, ApiError, number>({
    mutationFn: finApi.deleteFixedExpense,
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['fixed-expenses'] });
      qc.invalidateQueries({ queryKey: ['budget'] });
    },
  });
}

export function useDeleteGoal() {
  const qc = useQueryClient();
  return useMutation<void, ApiError, number>({
    mutationFn: finApi.deleteGoal,
    onSuccess: () => qc.invalidateQueries({ queryKey: ['goals'] }),
  });
}
