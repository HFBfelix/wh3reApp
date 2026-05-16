import { View, Text, Pressable, FlatList, StyleSheet } from 'react-native';
import { useRouter } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { EventCard } from '@/components/EventCard';
import { QueryStateView } from '@/components/QueryStateView';
import { useEvents } from '@/hooks/useEvents';
import { useAuthStore } from '@/stores/authStore';
import { useEventStore } from '@/stores/eventStore';
import { Colors, Radius } from '@/constants/theme';

export default function DashboardScreen() {
  const router = useRouter();
  const userId = useAuthStore((s) => s.user?.id);
  const signOut = useAuthStore((s) => s.signOut);
  const tab = useEventStore((s) => s.dashboardTab);
  const setTab = useEventStore((s) => s.setDashboardTab);
  const { created, invited, isLoading, isError, error, refetch } = useEvents();

  const isCreations = tab === 'creations';
  const events = isCreations ? created : invited;

  return (
    <SafeAreaView style={styles.safe} edges={['top']}>
      <View style={styles.header}>
        <Text style={styles.brand}>Wh3re</Text>
        <Pressable onPress={() => signOut()} hitSlop={12}>
          <Text style={styles.logout}>Déconnexion</Text>
        </Pressable>
      </View>

      <View style={styles.toggleWrap}>
        <View style={styles.toggle}>
          <Pressable
            style={[styles.toggleBtn, isCreations && styles.toggleBtnActive]}
            onPress={() => setTab('creations')}
          >
            <Text style={[styles.toggleText, isCreations && styles.toggleTextActive]}>
              Mes Créations
            </Text>
          </Pressable>
          <Pressable
            style={[styles.toggleBtn, !isCreations && styles.toggleBtnActive]}
            onPress={() => setTab('invitations')}
          >
            <Text style={[styles.toggleText, !isCreations && styles.toggleTextActive]}>
              Mes Invitations
            </Text>
          </Pressable>
        </View>
      </View>

      <QueryStateView
        isLoading={isLoading}
        isError={isError}
        error={error}
        onRetry={() => refetch()}
        isEmpty={!isLoading && !isError && events.length === 0}
        emptyMessage={
          isCreations
            ? 'Aucun événement créé.\nAppuyez sur Créer pour lancer votre premier événement.'
            : 'Aucune invitation.\nLes événements auxquels vous êtes invité apparaîtront ici.'
        }
      >
        <FlatList
          data={events}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.list}
          ItemSeparatorComponent={() => <View style={{ height: 12 }} />}
          renderItem={({ item }) => (
            <EventCard
              event={item}
              isCreator={item.creatorId === userId}
              onPress={() => router.push(`/(app)/event/${item.id}`)}
            />
          )}
        />
      </QueryStateView>

      <Pressable
        style={styles.fab}
        onPress={() => router.push('/(app)/event/create')}
      >
        <Text style={styles.fabText}>+ Créer</Text>
      </Pressable>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: Colors.background },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingVertical: 12,
  },
  brand: { fontSize: 24, fontWeight: '800', color: Colors.primary },
  logout: { color: Colors.textSecondary, fontWeight: '600' },
  toggleWrap: { paddingHorizontal: 16, marginBottom: 8 },
  toggle: {
    flexDirection: 'row',
    backgroundColor: Colors.surfaceVariant,
    borderRadius: Radius.card,
    padding: 4,
  },
  toggleBtn: {
    flex: 1,
    paddingVertical: 12,
    borderRadius: Radius.card - 4,
    alignItems: 'center',
  },
  toggleBtnActive: { backgroundColor: Colors.primary },
  toggleText: { fontWeight: '600', color: Colors.textSecondary },
  toggleTextActive: { color: Colors.textOnPrimary },
  list: { padding: 16, paddingBottom: 100 },
  fab: {
    position: 'absolute',
    right: 20,
    bottom: 28,
    backgroundColor: Colors.primary,
    paddingHorizontal: 24,
    paddingVertical: 16,
    borderRadius: Radius.card,
    elevation: 4,
    shadowColor: Colors.primary,
    shadowOpacity: 0.3,
    shadowRadius: 8,
    shadowOffset: { width: 0, height: 4 },
  },
  fabText: { color: Colors.textOnPrimary, fontWeight: '700', fontSize: 16 },
});
