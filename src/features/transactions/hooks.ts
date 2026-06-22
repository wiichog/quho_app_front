import {
  useInfiniteQuery,
  useMutation,
  useQuery,
  useQueryClient,
} from '@tanstack/react-query';
import * as txApi from '@/api/transactions';
import type { ApiError } from '@/types/api';

const KEY = 'transactions';
const PAGE_SIZE = 25;

export function useTransactions(filters: txApi.TransactionFilters = {}) {
  return useQuery({
    queryKey: [KEY, filters],
    queryFn: () => txApi.listTransactions(filters),
  });
}

/** Lista paginada con scroll infinito (limit/offset de DRF). */
export function useInfiniteTransactions(filters: txApi.TransactionFilters = {}) {
  return useInfiniteQuery({
    queryKey: [KEY, 'infinite', filters],
    queryFn: ({ pageParam = 0 }) =>
      txApi.listTransactions({ ...filters, limit: PAGE_SIZE, offset: pageParam }),
    initialPageParam: 0,
    getNextPageParam: (lastPage, allPages) => {
      const loaded = allPages.reduce((n, p) => n + p.results.length, 0);
      return lastPage.next ? loaded : undefined;
    },
  });
}

export function useTransaction(id: number) {
  return useQuery({
    queryKey: [KEY, 'detail', id],
    queryFn: () => txApi.getTransaction(id),
    enabled: Number.isFinite(id),
  });
}

function invalidateAll(qc: ReturnType<typeof useQueryClient>) {
  qc.invalidateQueries({ queryKey: [KEY] });
  qc.invalidateQueries({ queryKey: ['budget'] });
}

export function useCreateTransaction() {
  const qc = useQueryClient();
  return useMutation<txApi.Transaction, ApiError, txApi.CreateTransactionPayload>({
    mutationFn: txApi.createTransaction,
    onSuccess: () => invalidateAll(qc),
  });
}

export function useUpdateTransaction() {
  const qc = useQueryClient();
  return useMutation<
    txApi.Transaction,
    ApiError,
    { id: number; payload: Partial<txApi.CreateTransactionPayload> }
  >({
    mutationFn: ({ id, payload }) => txApi.updateTransaction(id, payload),
    onSuccess: () => invalidateAll(qc),
  });
}

export function useDeleteTransaction() {
  const qc = useQueryClient();
  return useMutation<void, ApiError, number>({
    mutationFn: txApi.deleteTransaction,
    onSuccess: () => invalidateAll(qc),
  });
}
