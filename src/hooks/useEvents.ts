import { useEffect } from 'react';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import { fetchEventsForUser, subscribeToEvents } from '@/services/events';
import { useAuthStore } from '@/stores/authStore';
import type { EventRecord } from '@/types/event';

export const EVENTS_QUERY_KEY = ['events', 'user'] as const;

export function useEvents() {
  const userId = useAuthStore((s) => s.user?.id);
  const queryClient = useQueryClient();

  const query = useQuery({
    queryKey: [...EVENTS_QUERY_KEY, userId],
    queryFn: fetchEventsForUser,
    enabled: !!userId,
  });

  useEffect(() => {
    if (!userId) return;
    const unsubscribe = subscribeToEvents(() => {
      queryClient.invalidateQueries({ queryKey: EVENTS_QUERY_KEY });
    });
    return unsubscribe;
  }, [userId, queryClient]);

  const created =
    query.data?.filter((e) => e.creatorId === userId) ?? ([] as EventRecord[]);
  const invited =
    query.data?.filter((e) => e.creatorId !== userId) ?? ([] as EventRecord[]);

  return {
    ...query,
    created,
    invited,
    all: query.data ?? [],
  };
}
