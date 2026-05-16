import type { EventRecord, EventStatus, GeoPoint } from '@/types/event';
import type { EventMember, MemberRole } from '@/types/member';
import type { Question, QuestionOption, QuestionType } from '@/types/question';
import type { AnswerEntry, ResponseAnswers, ResponseRecord, WeightEnum } from '@/types/response';
import type { PlaceSuggestion } from '@/types/suggestion';

export function parseGeoPoint(raw: unknown): GeoPoint | undefined {
  if (!raw || typeof raw !== 'object') return undefined;
  const obj = raw as { coordinates?: number[] };
  if (Array.isArray(obj.coordinates) && obj.coordinates.length >= 2) {
    return { longitude: Number(obj.coordinates[0]), latitude: Number(obj.coordinates[1]) };
  }
  return undefined;
}

export function mapEvent(row: Record<string, unknown>): EventRecord {
  return {
    id: row.id as string,
    creatorId: row.creator_id as string,
    name: row.name as string,
    description: (row.description as string) ?? undefined,
    ambiance: (row.ambiance as string) ?? undefined,
    status: row.status as EventStatus,
    inviteToken: (row.invite_token as string) ?? undefined,
    finalPlaceId: (row.final_place_id as string) ?? undefined,
    finalPlaceName: (row.final_place_name as string) ?? undefined,
    finalPlaceAddress: (row.final_place_address as string) ?? undefined,
    finalPlaceLocation: parseGeoPoint(row.final_place_location),
    createdAt: (row.created_at as string) ?? undefined,
    updatedAt: (row.updated_at as string) ?? undefined,
  };
}

export function mapMember(row: Record<string, unknown>): EventMember {
  const profile = row.profiles as Record<string, unknown> | undefined;
  return {
    id: row.id as string,
    eventId: row.event_id as string,
    userId: row.user_id as string,
    role: row.role as MemberRole,
    hasResponded: (row.has_responded as boolean) ?? false,
    joinedAt: (row.joined_at as string) ?? undefined,
    profile: profile
      ? {
          firstName: (profile.first_name as string) ?? 'Invité',
          avatarUrl: (profile.avatar_url as string) ?? undefined,
        }
      : undefined,
  };
}

export function mapQuestion(row: Record<string, unknown>): Question {
  const rawOptions = row.options;
  const options: QuestionOption[] = [];
  if (Array.isArray(rawOptions)) {
    for (const item of rawOptions) {
      if (item && typeof item === 'object') {
        const o = item as Record<string, unknown>;
        options.push({
          value: o.value as string,
          label: o.label as string,
          emoji: (o.emoji as string) ?? undefined,
        });
      }
    }
  }
  return {
    id: row.id as string,
    eventId: row.event_id as string,
    questionType: row.question_type as QuestionType,
    questionLabel: row.question_label as string,
    options,
    sortOrder: (row.sort_order as number) ?? 0,
  };
}

export function mapResponse(row: Record<string, unknown>): ResponseRecord {
  const rawAnswers = row.answers as Record<string, unknown>;
  const answers: ResponseAnswers = {};
  if (rawAnswers && typeof rawAnswers === 'object') {
    for (const [key, val] of Object.entries(rawAnswers)) {
      if (val && typeof val === 'object') {
        const entry = val as Record<string, unknown>;
        answers[key] = {
          value: entry.value as string,
          weight: entry.weight as WeightEnum,
        };
      }
    }
  }
  return {
    id: row.id as string,
    eventId: row.event_id as string,
    userId: row.user_id as string,
    answers,
    submittedAt: (row.submitted_at as string) ?? undefined,
  };
}

export function mapSuggestion(row: Record<string, unknown>): PlaceSuggestion {
  return {
    id: row.id as string,
    eventId: row.event_id as string,
    placeId: row.place_id as string,
    placeName: row.place_name as string,
    placeAddress: row.place_address as string,
    placeLocation: parseGeoPoint(row.place_location),
    placeTypes: (row.place_types as string[]) ?? [],
    matchScore: row.match_score != null ? Number(row.match_score) : undefined,
    matchRationale: (row.match_rationale as string) ?? undefined,
    rank: (row.rank as number) ?? 1,
    isSelected: (row.is_selected as boolean) ?? false,
  };
}

export function answersToJson(answers: ResponseAnswers): Record<string, AnswerEntry> {
  const result: Record<string, AnswerEntry> = {};
  for (const [questionId, entry] of Object.entries(answers)) {
    result[questionId] = entry;
  }
  return result;
}
