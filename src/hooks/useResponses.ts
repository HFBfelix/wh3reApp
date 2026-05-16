import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  fetchQuestions,
  fetchResponses,
  fetchMembers,
  hasUserResponded,
  submitResponse,
} from '@/services/events';
import { supabase } from '@/services/supabase';
import type { ResponseAnswers } from '@/types/response';

export function usePollQuestions(eventId: string) {
  return useQuery({
    queryKey: ['questions', eventId],
    queryFn: () => fetchQuestions(eventId),
    enabled: !!eventId,
  });
}

export function useHasResponded(eventId: string) {
  return useQuery({
    queryKey: ['hasResponded', eventId],
    queryFn: () => hasUserResponded(eventId),
    enabled: !!eventId,
  });
}

export function usePollResults(eventId: string) {
  const membersQuery = useQuery({
    queryKey: ['members', eventId],
    queryFn: () => fetchMembers(eventId),
    enabled: !!eventId,
  });

  const responsesQuery = useQuery({
    queryKey: ['responses', eventId],
    queryFn: () => fetchResponses(eventId),
    enabled: !!eventId,
  });

  return {
    members: membersQuery,
    responses: responsesQuery,
    isLoading: membersQuery.isLoading || responsesQuery.isLoading,
    isError: membersQuery.isError || responsesQuery.isError,
    error: membersQuery.error ?? responsesQuery.error,
    refetch: () => {
      membersQuery.refetch();
      responsesQuery.refetch();
    },
  };
}

export function useSubmitResponse(eventId: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (answers: ResponseAnswers) => submitResponse(eventId, answers),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['hasResponded', eventId] });
      queryClient.invalidateQueries({ queryKey: ['members', eventId] });
      queryClient.invalidateQueries({ queryKey: ['responses', eventId] });
    },
  });
}

export function subscribePollRealtime(eventId: string, onChange: () => void): () => void {
  const channel = supabase
    .channel(`poll-${eventId}`)
    .on(
      'postgres_changes',
      { event: '*', schema: 'public', table: 'responses', filter: `event_id=eq.${eventId}` },
      onChange,
    )
    .on(
      'postgres_changes',
      { event: '*', schema: 'public', table: 'event_members', filter: `event_id=eq.${eventId}` },
      onChange,
    )
    .subscribe();
  return () => {
    void supabase.removeChannel(channel);
  };
}
