import { useQuery } from '@tanstack/react-query';
import { fetchEventById } from '@/services/events';

export function useEvent(eventId: string) {
  return useQuery({
    queryKey: ['event', eventId],
    queryFn: () => fetchEventById(eventId),
    enabled: !!eventId,
  });
}
