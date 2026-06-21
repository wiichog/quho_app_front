import { useQuery } from '@tanstack/react-query';
import * as gamApi from '@/api/gamification';

export function usePointsSummary() {
  return useQuery({ queryKey: ['gam', 'summary'], queryFn: gamApi.getPointsSummary });
}

export function useBadges() {
  return useQuery({ queryKey: ['gam', 'badges'], queryFn: gamApi.getBadges });
}

export function useActiveMissions() {
  return useQuery({ queryKey: ['gam', 'missions'], queryFn: gamApi.getActiveMissions });
}
