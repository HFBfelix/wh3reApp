import { create } from 'zustand';

export type DashboardTab = 'creations' | 'invitations';

interface EventUIState {
  dashboardTab: DashboardTab;
  pendingJoinToken: string | null;
  postLoginRoute: string | null;
  setDashboardTab: (tab: DashboardTab) => void;
  setPendingJoinToken: (token: string | null) => void;
  setPostLoginRoute: (route: string | null) => void;
  consumePostLoginRoute: () => string | null;
}

export const useEventStore = create<EventUIState>((set, get) => ({
  dashboardTab: 'creations',
  pendingJoinToken: null,
  postLoginRoute: null,
  setDashboardTab: (tab) => set({ dashboardTab: tab }),
  setPendingJoinToken: (token) => set({ pendingJoinToken: token }),
  setPostLoginRoute: (route) => set({ postLoginRoute: route }),
  consumePostLoginRoute: () => {
    const route = get().postLoginRoute;
    set({ postLoginRoute: null });
    return route;
  },
}));
