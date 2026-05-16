import { View, Text, ScrollView, Pressable, Alert, StyleSheet } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useQuery } from '@tanstack/react-query';
import { ScreenHeader } from '@/components/ScreenHeader';
import { QueryStateView } from '@/components/QueryStateView';
import { MemberAvatarStack } from '@/components/MemberAvatarStack';
import { Wh3reButton } from '@/components/Wh3reButton';
import { useEvent } from '@/hooks/useEvent';
import { useHasResponded } from '@/hooks/useResponses';
import { fetchMembers, updateEvent, isEventCreator } from '@/services/events';
import { useAuthStore } from '@/stores/authStore';
import { Colors, Radius } from '@/constants/theme';

const STATUS_LABELS: Record<string, string> = {
  draft: 'Brouillon',
  polling: 'Sondage en cours',
  decided: 'Lieu décidé',
  archived: 'Archivé',
};

export default function EventDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();
  const userId = useAuthStore((s) => s.user?.id);
  const eventQuery = useEvent(id);
  const respondedQuery = useHasResponded(id);
  const membersQuery = useQuery({
    queryKey: ['members', id],
    queryFn: () => fetchMembers(id),
    enabled: !!id,
  });
  const creatorQuery = useQuery({
    queryKey: ['isCreator', id],
    queryFn: () => isEventCreator(id),
    enabled: !!id,
  });

  const event = eventQuery.data;
  const isCreator = event?.creatorId === userId || creatorQuery.data === true;
  const isLoading = eventQuery.isLoading || respondedQuery.isLoading;
  const isError = eventQuery.isError;

  const launchPolling = async () => {
    try {
      await updateEvent(id, { status: 'polling' });
      await eventQuery.refetch();
      Alert.alert('Sondage lancé', 'Les invités peuvent maintenant voter.');
    } catch (e) {
      Alert.alert('Erreur', e instanceof Error ? e.message : 'Échec du lancement.');
    }
  };

  return (
    <View style={styles.root}>
      <ScreenHeader
        title={event?.name ?? 'Événement'}
        rightAction={
          isCreator ? (
            <Pressable onPress={() => router.push(`/(app)/event/invite/${id}`)}>
              <Text style={styles.share}>Partager</Text>
            </Pressable>
          ) : undefined
        }
      />
      <QueryStateView
        isLoading={isLoading}
        isError={isError}
        error={eventQuery.error}
        onRetry={() => eventQuery.refetch()}
      >
        {!event ? (
          <View style={styles.center}>
            <Text style={styles.muted}>Événement introuvable</Text>
          </View>
        ) : (
          <ScrollView contentContainerStyle={styles.scroll}>
            {respondedQuery.data ? (
              <View style={[styles.statusCard, styles.statusOk]}>
                <Text style={styles.statusTitle}>Statut : A répondu</Text>
                <Text style={styles.statusSub}>Vos préférences ont bien été prises en compte.</Text>
              </View>
            ) : (
              <View style={[styles.statusCard, styles.statusPending]}>
                <Text style={styles.statusTitle}>Statut : En attente de votre avis</Text>
                <Wh3reButton
                  label="Répondre au sondage"
                  onPress={() => router.push(`/(app)/polling/answer/${id}`)}
                  style={{ marginTop: 12 }}
                />
              </View>
            )}

            {event.description ? (
              <Text style={styles.description}>{event.description}</Text>
            ) : null}
            {event.ambiance ? (
              <Text style={styles.info}>🎭 Ambiance : {event.ambiance}</Text>
            ) : null}
            <Text style={styles.info}>📋 {STATUS_LABELS[event.status] ?? event.status}</Text>

            {membersQuery.data && membersQuery.data.length > 0 ? (
              <View style={styles.membersBlock}>
                <Text style={styles.sectionTitle}>Membres</Text>
                <MemberAvatarStack members={membersQuery.data} />
                <Text style={styles.memberCount}>
                  {membersQuery.data.filter((m) => m.hasResponded).length} /{' '}
                  {membersQuery.data.length} ont répondu
                </Text>
              </View>
            ) : null}

            {isCreator ? (
              <View style={styles.actions}>
                <Wh3reButton
                  label="Modifier l'événement"
                  variant="outline"
                  onPress={() => router.push(`/(app)/event/edit/${id}`)}
                  style={styles.actionBtn}
                />
                <Wh3reButton
                  label="Inviter des participants"
                  variant="outline"
                  onPress={() => router.push(`/(app)/event/invite/${id}`)}
                  style={styles.actionBtn}
                />
                {event.status === 'draft' ? (
                  <Wh3reButton label="Lancer le sondage" onPress={launchPolling} style={styles.actionBtn} />
                ) : null}
                <Wh3reButton
                  label="Voir les résultats"
                  variant="outline"
                  onPress={() => router.push(`/(app)/polling/results/${id}`)}
                  style={styles.actionBtn}
                />
                <Wh3reButton
                  label="Suggestions de lieux (IA)"
                  onPress={() => router.push(`/(app)/suggestions/${id}`)}
                  style={styles.actionBtn}
                />
              </View>
            ) : (
              <Pressable
                style={styles.suggestionsLink}
                onPress={() => router.push(`/(app)/suggestions/${id}`)}
              >
                <Text style={styles.suggestionsLinkText}>Voir les suggestions de lieux</Text>
              </Pressable>
            )}

            {event.finalPlaceName ? (
              <View style={styles.finalPlace}>
                <Text style={styles.finalTitle}>Lieu retenu</Text>
                <Text style={styles.finalName}>{event.finalPlaceName}</Text>
                {event.finalPlaceAddress ? (
                  <Text style={styles.finalAddr}>{event.finalPlaceAddress}</Text>
                ) : null}
              </View>
            ) : null}
          </ScrollView>
        )}
      </QueryStateView>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: Colors.background },
  scroll: { padding: 24, paddingBottom: 40 },
  center: { flex: 1, alignItems: 'center', justifyContent: 'center' },
  muted: { color: Colors.textSecondary },
  share: { color: Colors.primary, fontWeight: '600', fontSize: 14, paddingRight: 8 },
  statusCard: { borderRadius: Radius.card, padding: 20, marginBottom: 20 },
  statusOk: { backgroundColor: Colors.successLight, borderWidth: 1, borderColor: Colors.success },
  statusPending: { backgroundColor: Colors.primarySurface, borderWidth: 1, borderColor: Colors.primary },
  statusTitle: { fontSize: 16, fontWeight: '700', color: Colors.textPrimary },
  statusSub: { marginTop: 4, fontSize: 13, color: Colors.textSecondary },
  description: { fontSize: 16, lineHeight: 24, color: Colors.textSecondary, marginBottom: 12 },
  info: { fontSize: 15, color: Colors.textPrimary, marginBottom: 8 },
  membersBlock: { marginTop: 20, marginBottom: 8 },
  sectionTitle: { fontSize: 16, fontWeight: '700', marginBottom: 12 },
  memberCount: { marginTop: 8, fontSize: 13, color: Colors.textSecondary },
  actions: { marginTop: 24, gap: 12 },
  actionBtn: { marginBottom: 0 },
  suggestionsLink: {
    marginTop: 24,
    padding: 16,
    borderRadius: Radius.card,
    borderWidth: 2,
    borderColor: Colors.primary,
    alignItems: 'center',
  },
  suggestionsLinkText: { color: Colors.primary, fontWeight: '700' },
  finalPlace: {
    marginTop: 24,
    padding: 16,
    borderRadius: Radius.card,
    backgroundColor: Colors.primarySurface,
  },
  finalTitle: { fontSize: 12, fontWeight: '600', color: Colors.primary },
  finalName: { fontSize: 18, fontWeight: '700', marginTop: 4 },
  finalAddr: { fontSize: 14, color: Colors.textSecondary, marginTop: 4 },
});
