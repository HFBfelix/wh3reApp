import { useEffect, useState } from 'react';
import { View, Text, ActivityIndicator, Alert, StyleSheet } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useAuthStore } from '@/stores/authStore';
import { useEventStore } from '@/stores/eventStore';
import { joinEventByToken } from '@/services/events';
import { Colors } from '@/constants/theme';

export default function JoinScreen() {
  const { token } = useLocalSearchParams<{ token: string }>();
  const router = useRouter();
  const session = useAuthStore((s) => s.session);
  const isInitialized = useAuthStore((s) => s.isInitialized);
  const setPendingJoinToken = useEventStore((s) => s.setPendingJoinToken);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!token || !isInitialized) return;

    if (!session) {
      setPendingJoinToken(token);
      router.replace('/(auth)/login');
      return;
    }

    let cancelled = false;

    (async () => {
      try {
        const event = await joinEventByToken(token);
        if (cancelled) return;
        router.replace(`/(app)/polling/answer/${event.id}`);
      } catch (e) {
        if (cancelled) return;
        const message = e instanceof Error ? e.message : 'Impossible de rejoindre cet événement.';
        setError(message);
        Alert.alert('Invitation', message, [
          { text: 'OK', onPress: () => router.replace('/(app)/dashboard') },
        ]);
      }
    })();

    return () => {
      cancelled = true;
    };
  }, [token, session, isInitialized, router, setPendingJoinToken]);

  return (
    <View style={styles.root}>
      <ActivityIndicator size="large" color={Colors.primary} />
      <Text style={styles.text}>
        {error ?? 'Connexion à l\'événement…'}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  root: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: Colors.background,
    padding: 24,
  },
  text: { marginTop: 16, color: Colors.textSecondary, textAlign: 'center' },
});
