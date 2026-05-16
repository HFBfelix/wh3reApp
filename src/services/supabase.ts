import AsyncStorage from '@react-native-async-storage/async-storage';
import { createClient } from '@supabase/supabase-js';
import type { Session, User } from '@supabase/supabase-js';
import 'react-native-url-polyfill/auto';

const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL ?? '';
const supabaseAnonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY ?? '';

if (!supabaseUrl || !supabaseAnonKey) {
  console.warn(
    '[Wh3re] EXPO_PUBLIC_SUPABASE_URL et EXPO_PUBLIC_SUPABASE_ANON_KEY sont requis dans .env',
  );
}

/**
 * Client Supabase unique pour toute l'application.
 * Persistance de session via AsyncStorage (standard Expo).
 */
export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    storage: AsyncStorage,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
});

export type { Session, User };

/** Récupère la session courante (null si déconnecté). */
export async function getCurrentSession(): Promise<Session | null> {
  const { data, error } = await supabase.auth.getSession();
  if (error) {
    console.error('[Wh3re] getSession error:', error.message);
    return null;
  }
  return data.session;
}

/** Utilisateur connecté. */
export async function getCurrentUser(): Promise<User | null> {
  const session = await getCurrentSession();
  return session?.user ?? null;
}

/** Écoute les changements d'état auth (login, logout, refresh). */
export function onAuthStateChange(
  callback: (session: Session | null) => void,
) {
  const { data } = supabase.auth.onAuthStateChange((_event, session) => {
    callback(session);
  });
  return data.subscription;
}
