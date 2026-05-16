import type { GeoPoint } from './event';

export interface PlaceSuggestion {
  id: string;
  eventId: string;
  placeId: string;
  placeName: string;
  placeAddress: string;
  placeLocation?: GeoPoint;
  placeTypes?: string[];
  matchScore?: number;
  matchRationale?: string;
  rank: number;
  isSelected: boolean;
  photoUrl?: string;
}
