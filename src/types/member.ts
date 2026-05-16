export type MemberRole = 'creator' | 'guest';

export interface EventMember {
  id: string;
  eventId: string;
  userId: string;
  role: MemberRole;
  hasResponded: boolean;
  joinedAt?: string;
  profile?: {
    firstName: string;
    avatarUrl?: string;
  };
}
