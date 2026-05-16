export type EventStatus = 'draft' | 'polling' | 'decided' | 'archived';

export interface GeoPoint {
  latitude: number;
  longitude: number;
}

export interface EventRecord {
  id: string;
  creatorId: string;
  name: string;
  description?: string;
  ambiance?: string;
  status: EventStatus;
  inviteToken?: string;
  finalPlaceId?: string;
  finalPlaceName?: string;
  finalPlaceAddress?: string;
  finalPlaceLocation?: GeoPoint;
  createdAt?: string;
  updatedAt?: string;
}
