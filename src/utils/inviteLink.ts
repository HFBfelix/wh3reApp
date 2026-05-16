const BASE_URL = 'https://wh3re.app';

/** Lien Universal / App Link pour rejoindre un événement. */
export function buildJoinUrl(inviteToken: string): string {
  return `${BASE_URL}/join/${inviteToken}`;
}

/** Extrait le token depuis une URL Wh3re. */
export function parseJoinToken(url: string): string | null {
  try {
    const parsed = new URL(url);
    const segments = parsed.pathname.split('/').filter(Boolean);
    if (segments[0] === 'join' && segments[1]) {
      return segments[1];
    }
    return null;
  } catch {
    if (url.startsWith('/join/')) {
      const token = url.replace('/join/', '');
      return token.length > 0 ? token : null;
    }
    return null;
  }
}
