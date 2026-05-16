import '../global.css';

import { useEffect, type ReactNode } from 'react';
import { Stack, useRouter, useSegments } from 'expo-router';
import { StatusBar } from 'expo-status-bar';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { useAuthStore } from '@/stores/authStore';
import { useEventStore } from '@/stores/eventStore';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: { retry: 2, staleTime: 30_000 },
  },
});

function AuthGate({ children }: { children: ReactNode }) {
  const router = useRouter();
  const segments = useSegments();
  const { session, isInitialized, isLoading, initialize } = useAuthStore();
  const consumePostLoginRoute = useEventStore((s) => s.consumePostLoginRoute);

  useEffect(() => {
    const unsubscribe = initialize();
    return unsubscribe;
  }, [initialize]);

  useEffect(() => {
    if (!isInitialized || isLoading) return;

    const inAuthGroup = segments[0] === '(auth)';
    const isJoinRoute = segments[0] === 'join';
    const isAuthenticated = !!session;

    if (!isAuthenticated) {
      if (!inAuthGroup && !isJoinRoute) {
        router.replace('/(auth)/login');
      }
      return;
    }

    const postRoute = consumePostLoginRoute();
    if (postRoute) {
      router.replace(postRoute as never);
      return;
    }

    if (isAuthenticated && inAuthGroup) {
      router.replace('/(app)/dashboard');
    }
  }, [session, segments, isInitialized, isLoading, router, consumePostLoginRoute]);

  return <>{children}</>;
}

export default function RootLayout() {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <QueryClientProvider client={queryClient}>
        <AuthGate>
          <StatusBar style="dark" />
          <Stack screenOptions={{ headerShown: false }}>
            <Stack.Screen name="(auth)" />
            <Stack.Screen name="(app)" />
            <Stack.Screen
              name="join/[token]"
              options={{ presentation: 'modal', headerShown: true, title: 'Invitation' }}
            />
          </Stack>
        </AuthGate>
      </QueryClientProvider>
    </GestureHandlerRootView>
  );
}
