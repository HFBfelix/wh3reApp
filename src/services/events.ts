import { supabase } from '@/services/supabase';
import { AuthRequiredError, EventNotFoundError, AppError } from '@/lib/errors';
import {
  mapEvent,
  mapMember,
  mapQuestion,
  mapResponse,
  mapSuggestion,
  answersToJson,
} from '@/lib/mappers';
import type { EventRecord } from '@/types/event';
import type { EventMember } from '@/types/member';
import type { Question } from '@/types/question';
import { DEFAULT_QUESTIONS_PAYLOAD } from '@/types/question';
import type { ResponseAnswers, ResponseRecord } from '@/types/response';
import type { PlaceSuggestion } from '@/types/suggestion';

async function getUserId(): Promise<string> {
  const { data } = await supabase.auth.getUser();
  if (!data.user) throw new AuthRequiredError();
  return data.user.id;
}

export async function fetchEventsForUser(): Promise<EventRecord[]> {
  const userId = await getUserId();

  const { data: created, error: e1 } = await supabase
    .from('events')
    .select('*')
    .eq('creator_id', userId);
  if (e1) throw new AppError(e1.message, e1);

  const { data: memberRows, error: e2 } = await supabase
    .from('event_members')
    .select('event_id')
    .eq('user_id', userId);
  if (e2) throw new AppError(e2.message, e2);

  const memberIds = (memberRows ?? []).map((r) => r.event_id as string);
  const byId = new Map<string, EventRecord>();

  for (const row of created ?? []) {
    const event = mapEvent(row as Record<string, unknown>);
    byId.set(event.id, event);
  }

  if (memberIds.length > 0) {
    const { data: invited, error: e3 } = await supabase
      .from('events')
      .select('*')
      .in('id', memberIds);
    if (e3) throw new AppError(e3.message, e3);
    for (const row of invited ?? []) {
      const event = mapEvent(row as Record<string, unknown>);
      byId.set(event.id, event);
    }
  }

  return Array.from(byId.values()).sort((a, b) => {
    const ad = new Date(a.updatedAt ?? a.createdAt ?? 0).getTime();
    const bd = new Date(b.updatedAt ?? b.createdAt ?? 0).getTime();
    return bd - ad;
  });
}

export async function fetchEventById(eventId: string): Promise<EventRecord | null> {
  await getUserId();
  const { data, error } = await supabase.from('events').select('*').eq('id', eventId).maybeSingle();
  if (error) throw new AppError(error.message, error);
  if (!data) return null;
  return mapEvent(data as Record<string, unknown>);
}

export async function createEvent(params: {
  name: string;
  description?: string;
  ambiance?: string;
}): Promise<EventRecord> {
  const userId = await getUserId();

  const { data, error } = await supabase
    .from('events')
    .insert({
      creator_id: userId,
      name: params.name,
      description: params.description ?? null,
      ambiance: params.ambiance ?? null,
      status: 'draft',
    })
    .select()
    .single();

  if (error) throw new AppError(error.message, error);
  const event = mapEvent(data as Record<string, unknown>);

  await supabase.from('questions_template').insert(
    DEFAULT_QUESTIONS_PAYLOAD.map((q) => ({ ...q, event_id: event.id })),
  );

  await supabase.from('event_members').upsert(
    { event_id: event.id, user_id: userId, role: 'creator' },
    { onConflict: 'event_id,user_id' },
  );

  return event;
}

export async function updateEvent(
  eventId: string,
  params: { name?: string; description?: string; ambiance?: string; status?: string },
): Promise<EventRecord> {
  await getUserId();
  const { data, error } = await supabase
    .from('events')
    .update({
      ...(params.name != null && { name: params.name }),
      ...(params.description != null && { description: params.description }),
      ...(params.ambiance != null && { ambiance: params.ambiance }),
      ...(params.status != null && { status: params.status }),
    })
    .eq('id', eventId)
    .select()
    .single();
  if (error) throw new AppError(error.message, error);
  return mapEvent(data as Record<string, unknown>);
}

export async function joinEventByToken(token: string): Promise<EventRecord> {
  const userId = await getUserId();

  const { data: eventRow, error } = await supabase
    .from('events')
    .select('*')
    .eq('invite_token', token)
    .maybeSingle();

  if (error) throw new AppError(error.message, error);
  if (!eventRow) throw new EventNotFoundError('Événement introuvable pour ce lien.');

  const event = mapEvent(eventRow as Record<string, unknown>);
  if (event.creatorId === userId) return event;

  const { error: insertError } = await supabase.from('event_members').insert({
    event_id: event.id,
    user_id: userId,
    role: 'guest',
  });

  if (insertError && insertError.code !== '23505') {
    throw new AppError(insertError.message, insertError);
  }

  return event;
}

export async function fetchQuestions(eventId: string): Promise<Question[]> {
  await getUserId();
  const { data, error } = await supabase
    .from('questions_template')
    .select('*')
    .eq('event_id', eventId)
    .order('sort_order');
  if (error) throw new AppError(error.message, error);
  return (data ?? []).map((r) => mapQuestion(r as Record<string, unknown>));
}

export async function fetchMembers(eventId: string): Promise<EventMember[]> {
  await getUserId();
  const { data, error } = await supabase
    .from('event_members')
    .select('*, profiles(first_name, avatar_url)')
    .eq('event_id', eventId);
  if (error) throw new AppError(error.message, error);
  return (data ?? []).map((r) => mapMember(r as Record<string, unknown>));
}

export async function hasUserResponded(eventId: string): Promise<boolean> {
  const userId = await getUserId();
  const { data, error } = await supabase
    .from('event_members')
    .select('has_responded')
    .eq('event_id', eventId)
    .eq('user_id', userId)
    .maybeSingle();
  if (error) throw new AppError(error.message, error);
  return (data?.has_responded as boolean) ?? false;
}

export async function submitResponse(
  eventId: string,
  answers: ResponseAnswers,
): Promise<ResponseRecord> {
  const userId = await getUserId();
  const { data, error } = await supabase
    .from('responses')
    .upsert(
      {
        event_id: eventId,
        user_id: userId,
        answers: answersToJson(answers),
      },
      { onConflict: 'event_id,user_id' },
    )
    .select()
    .single();
  if (error) throw new AppError(error.message, error);
  return mapResponse(data as Record<string, unknown>);
}

export async function fetchResponses(eventId: string): Promise<ResponseRecord[]> {
  await getUserId();
  const { data, error } = await supabase.from('responses').select('*').eq('event_id', eventId);
  if (error) throw new AppError(error.message, error);
  return (data ?? []).map((r) => mapResponse(r as Record<string, unknown>));
}

export async function fetchSuggestions(eventId: string): Promise<PlaceSuggestion[]> {
  await getUserId();
  const { data, error } = await supabase
    .from('final_suggestions')
    .select('*')
    .eq('event_id', eventId)
    .order('rank');
  if (error) throw new AppError(error.message, error);
  return (data ?? []).map((r) => mapSuggestion(r as Record<string, unknown>));
}

export async function isEventCreator(eventId: string): Promise<boolean> {
  const userId = await getUserId();
  const { data } = await supabase.from('events').select('creator_id').eq('id', eventId).maybeSingle();
  if (data?.creator_id === userId) return true;
  const { data: member } = await supabase
    .from('event_members')
    .select('role')
    .eq('event_id', eventId)
    .eq('user_id', userId)
    .maybeSingle();
  return member?.role === 'creator';
}

export async function selectFinalPlace(
  eventId: string,
  suggestion: PlaceSuggestion,
): Promise<EventRecord> {
  const isCreator = await isEventCreator(eventId);
  if (!isCreator) throw new AppError('Seul le créateur peut sélectionner le lieu final.');
  if (!suggestion.placeLocation) throw new AppError('Coordonnées GPS manquantes.');

  const loc = suggestion.placeLocation;
  const { error: e1 } = await supabase
    .from('events')
    .update({
      final_place_id: suggestion.placeId,
      final_place_name: suggestion.placeName,
      final_place_address: suggestion.placeAddress,
      final_place_location: {
        type: 'Point',
        coordinates: [loc.longitude, loc.latitude],
      },
      status: 'decided',
    })
    .eq('id', eventId);
  if (e1) throw new AppError(e1.message, e1);

  await supabase.from('final_suggestions').update({ is_selected: false }).eq('event_id', eventId);
  await supabase.from('final_suggestions').update({ is_selected: true }).eq('id', suggestion.id);

  const event = await fetchEventById(eventId);
  if (!event) throw new EventNotFoundError();
  return event;
}

export function subscribeToEvents(onChange: () => void): () => void {
  const channel = supabase
    .channel('events-realtime')
    .on('postgres_changes', { event: '*', schema: 'public', table: 'events' }, onChange)
    .on('postgres_changes', { event: '*', schema: 'public', table: 'event_members' }, onChange)
    .subscribe();

  return () => {
    supabase.removeChannel(channel);
  };
}
