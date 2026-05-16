import type { GeoPoint } from '@/types/event';
import type { PlaceSuggestion } from '@/types/suggestion';

const PLACES_SEARCH_URL = 'https://places.googleapis.com/v1/places:searchText';
const FIELD_MASK =
  'places.id,places.displayName,places.formattedAddress,places.location,places.types,places.rating';

export interface PlacesSearchResult {
  placeId: string;
  name: string;
  address: string;
  location?: GeoPoint;
  types: string[];
  rating?: number;
}

/**
 * New Google Places API v2 — POST places:searchText uniquement.
 */
export async function searchPlacesText(
  textQuery: string,
  maxResultCount = 5,
): Promise<PlacesSearchResult[]> {
  const apiKey = process.env.EXPO_PUBLIC_GOOGLE_PLACES_API_KEY;
  if (!apiKey) throw new Error('EXPO_PUBLIC_GOOGLE_PLACES_API_KEY manquant');

  const response = await fetch(PLACES_SEARCH_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask': FIELD_MASK,
    },
    body: JSON.stringify({
      textQuery,
      languageCode: 'fr',
      maxResultCount,
    }),
  });

  if (!response.ok) {
    const errText = await response.text();
    throw new Error(`Places API: ${response.status} — ${errText}`);
  }

  const data = (await response.json()) as {
    places?: {
      id?: string;
      displayName?: { text?: string };
      formattedAddress?: string;
      location?: { latitude?: number; longitude?: number };
      types?: string[];
      rating?: number;
    }[];
  };

  return (data.places ?? []).map((p) => ({
    placeId: p.id ?? '',
    name: p.displayName?.text ?? 'Lieu',
    address: p.formattedAddress ?? '',
    location:
      p.location?.latitude != null && p.location?.longitude != null
        ? { latitude: p.location.latitude, longitude: p.location.longitude }
        : undefined,
    types: p.types ?? [],
    rating: p.rating,
  }));
}

export async function fetchPlacePhotoUrl(placeId: string): Promise<string | null> {
  const apiKey = process.env.EXPO_PUBLIC_GOOGLE_PLACES_API_KEY;
  if (!apiKey || !placeId) return null;

  try {
    const detailsRes = await fetch(`https://places.googleapis.com/v1/places/${placeId}`, {
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': apiKey,
        'X-Goog-FieldMask': 'photos',
      },
    });
    if (!detailsRes.ok) return null;
    const body = (await detailsRes.json()) as {
      photos?: { name?: string }[];
    };
    const photoName = body.photos?.[0]?.name;
    if (!photoName) return null;
    return `https://places.googleapis.com/v1/${photoName}/media?maxHeightPx=400&key=${apiKey}`;
  } catch {
    return null;
  }
}

export function toSuggestionDraft(
  eventId: string,
  place: PlacesSearchResult,
  rank: number,
  matchScore: number,
  rationale: string,
): Omit<PlaceSuggestion, 'id' | 'isSelected'> {
  return {
    eventId,
    placeId: place.placeId,
    placeName: place.name,
    placeAddress: place.address,
    placeLocation: place.location,
    placeTypes: place.types,
    matchScore,
    matchRationale: rationale,
    rank,
  };
}
