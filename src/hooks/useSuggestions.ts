import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import {
  fetchSuggestions,
  fetchResponses,
  isEventCreator,
  selectFinalPlace,
} from '@/services/events';
import { generatePlacesQuery } from '@/services/gemini';
import { searchPlacesText, fetchPlacePhotoUrl, toSuggestionDraft } from '@/services/places';
import { supabase } from '@/services/supabase';
import { mapSuggestion } from '@/lib/mappers';
import type { PlaceSuggestion } from '@/types/suggestion';
import type { ResponseAnswers } from '@/types/response';

export function useSuggestions(eventId: string) {
  return useQuery({
    queryKey: ['suggestions', eventId],
    queryFn: async () => {
      const suggestions = await fetchSuggestions(eventId);
      const withPhotos = await Promise.all(
        suggestions.map(async (s) => {
          const photoUrl = await fetchPlacePhotoUrl(s.placeId);
          return { ...s, photoUrl: photoUrl ?? undefined };
        }),
      );
      return withPhotos;
    },
    enabled: !!eventId,
  });
}

export function useIsEventCreator(eventId: string) {
  return useQuery({
    queryKey: ['isCreator', eventId],
    queryFn: () => isEventCreator(eventId),
    enabled: !!eventId,
  });
}

export async function generateAndPersistSuggestions(
  eventId: string,
  city = 'Paris',
): Promise<PlaceSuggestion[]> {
  const responses = await fetchResponses(eventId);
  const allAnswers: ResponseAnswers[] = responses.map((r) => r.answers);
  const { textQuery, rationale } = await generatePlacesQuery(allAnswers, city);
  const places = await searchPlacesText(textQuery, 3);

  await supabase.from('final_suggestions').delete().eq('event_id', eventId);

  const rows = places.slice(0, 3).map((place, index) => {
    const draft = toSuggestionDraft(
      eventId,
      place,
      index + 1,
      Math.max(100 - index * 8, 70),
      rationale,
    );
    return {
      event_id: draft.eventId,
      place_id: draft.placeId,
      place_name: draft.placeName,
      place_address: draft.placeAddress,
      place_location: draft.placeLocation
        ? {
            type: 'Point',
            coordinates: [draft.placeLocation.longitude, draft.placeLocation.latitude],
          }
        : null,
      place_types: draft.placeTypes,
      match_score: draft.matchScore,
      match_rationale: draft.matchRationale,
      rank: draft.rank,
      is_selected: false,
    };
  });

  const { data, error } = await supabase.from('final_suggestions').insert(rows).select('*');
  if (error) throw new Error(error.message);

  return (data ?? []).map((row) => mapSuggestion(row as Record<string, unknown>));
}

export function useGenerateSuggestions(eventId: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: () => generateAndPersistSuggestions(eventId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['suggestions', eventId] });
    },
  });
}

export function useSelectFinalPlace(eventId: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (suggestion: PlaceSuggestion) => selectFinalPlace(eventId, suggestion),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['suggestions', eventId] });
      queryClient.invalidateQueries({ queryKey: ['event', eventId] });
      queryClient.invalidateQueries({ queryKey: ['events', 'user'] });
    },
  });
}
