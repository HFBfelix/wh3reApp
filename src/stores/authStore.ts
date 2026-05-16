import { create } from 'zustand';
import type { Session, User } from '@supabase/supabase-js';
import { supabase, getCurrentSession, onAuthStateChange } from '@/services/supabase';
import { getErrorMessage } from '@/lib/errors';
import { joinEventByToken } from '@/services/events';
import { useEventStore } from '@/stores/eventStore';

interface AuthState {
  session: Session | null;
  user: User | null;
  isLoading: boolean;
  isInitialized: boolean;
  authActionLoading: boolean;
  authError: string | null;
  initialize: () => () => void;
  signIn: (email: string, password: string) => Promise<boolean>;
  signUp: (email: string, password: string, firstName: string) => Promise<boolean>;
  signOut: () => Promise<void>;
  resetPassword: (email: string) => Promise<boolean>;
  clearAuthError: () => void;
}

export const useAuthStore = create<AuthState>((set, get) => ({
  session: null,
  user: null,
  isLoading: true,
  isInitialized: false,
  authActionLoading: false,
  authError: null,

  clearAuthError: () => set({ authError: null }),

  initialize: () => {
    set({ isLoading: true });
    getCurrentSession().then((session) => {
      set({
        session,
        user: session?.user ?? null,
        isLoading: false,
        isInitialized: true,
      });
    });

    const sub = onAuthStateChange((session) => {
      set({
        session,
        user: session?.user ?? null,
        isLoading: false,
        isInitialized: true,
      });
    });

    return () => sub.unsubscribe();
  },

  signIn: async (email, password) => {
    set({ authActionLoading: true, authError: null });
    try {
      const { error } = await supabase.auth.signInWithPassword({ email, password });
      if (error) throw error;

      const pending = useEventStore.getState().pendingJoinToken;
      if (pending) {
        try {
          const event = await joinEventByToken(pending);
          useEventStore.getState().setPendingJoinToken(null);
          useEventStore.getState().setPostLoginRoute(`/(app)/polling/answer/${event.id}`);
        } catch {
          useEventStore.getState().setPendingJoinToken(null);
        }
      }
      set({ authActionLoading: false });
      return true;
    } catch (e) {
      set({ authActionLoading: false, authError: getErrorMessage(e) });
      return false;
    }
  },

  signUp: async (email, password, firstName) => {
    set({ authActionLoading: true, authError: null });
    try {
      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: { data: { first_name: firstName.trim() } },
      });
      if (error) throw error;
      set({ authActionLoading: false });
      return !!data.session;
    } catch (e) {
      set({ authActionLoading: false, authError: getErrorMessage(e) });
      return false;
    }
  },

  signOut: async () => {
    set({ authActionLoading: true });
    await supabase.auth.signOut();
    set({ authActionLoading: false, session: null, user: null });
  },

  resetPassword: async (email) => {
    set({ authActionLoading: true, authError: null });
    try {
      const { error } = await supabase.auth.resetPasswordForEmail(email);
      if (error) throw error;
      set({ authActionLoading: false });
      return true;
    } catch (e) {
      set({ authActionLoading: false, authError: getErrorMessage(e) });
      return false;
    }
  },
}));
