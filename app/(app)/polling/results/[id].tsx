import { useEffect } from 'react';
import { View, Text, FlatList, StyleSheet } from 'react-native';
import { useLocalSearchParams } from 'expo-router';
import { ScreenHeader } from '@/components/ScreenHeader';
import { QueryStateView } from '@/components/QueryStateView';
import { MemberAvatarStack } from '@/components/MemberAvatarStack';
import { usePollResults, subscribePollRealtime } from '@/hooks/useResponses';
import { runWeightingEngine } from '@/utils/weightingEngine';
import { Colors, Radius } from '@/constants/theme';

export default function PollResultsScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const { members, responses, isLoading, isError, error, refetch } = usePollResults(id);

  useEffect(() => {
    if (!id) return;
    return subscribePollRealtime(id, () => refetch());
  }, [id, refetch]);

  const consensus =
    responses.data && responses.data.length > 0
      ? runWeightingEngine(responses.data.map((r) => r.answers))
      : null;

  return (
    <View style={styles.root}>
      <ScreenHeader title="Résultats du sondage" />
      <QueryStateView
        isLoading={isLoading}
        isError={isError}
        error={error}
        onRetry={() => refetch()}
      >
        <View style={styles.summary}>
          <Text style={styles.summaryTitle}>Participation</Text>
          {members.data ? (
            <>
              <MemberAvatarStack members={members.data} />
              <Text style={styles.summaryMeta}>
                {members.data.filter((m) => m.hasResponded).length} / {members.data.length}{' '}
                membres ont répondu
              </Text>
            </>
          ) : null}
        </View>

        {consensus ? (
          <View style={styles.consensus}>
            <Text style={styles.sectionTitle}>Consensus du groupe</Text>
            {Object.entries(consensus.topOptions).map(([dimension, options]) => (
              <View key={dimension} style={styles.dimensionBlock}>
                <Text style={styles.dimensionLabel}>{dimension}</Text>
                {options.slice(0, 3).map((opt) => (
                  <View key={opt.value} style={styles.optionRow}>
                    <Text style={styles.optionLabel}>{opt.value}</Text>
                    <Text style={styles.optionScore}>
                      {Math.round(opt.normalizedScore * 100)}%
                    </Text>
                  </View>
                ))}
              </View>
            ))}
            {Object.keys(consensus.eliminated).length > 0 ? (
              <Text style={styles.veto}>
                Options éliminées (rédhibitoire) :{' '}
                {Object.entries(consensus.eliminated)
                  .map(([dim, vals]) => `${dim}: ${vals.join(', ')}`)
                  .join(' · ')}
              </Text>
            ) : null}
          </View>
        ) : null}

        <Text style={[styles.sectionTitle, styles.listTitle]}>Statut des membres</Text>
        <FlatList
          data={members.data ?? []}
          keyExtractor={(m) => m.id}
          contentContainerStyle={styles.list}
          renderItem={({ item }) => (
            <View style={styles.memberRow}>
              <Text style={styles.memberName}>{item.profile?.firstName ?? 'Invité'}</Text>
              <View
                style={[
                  styles.badge,
                  item.hasResponded ? styles.badgeOk : styles.badgePending,
                ]}
              >
                <Text
                  style={[
                    styles.badgeText,
                    item.hasResponded ? styles.badgeTextOk : styles.badgeTextPending,
                  ]}
                >
                  {item.hasResponded ? 'A répondu' : 'En attente'}
                </Text>
              </View>
            </View>
          )}
        />
      </QueryStateView>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: Colors.background },
  summary: {
    margin: 16,
    padding: 20,
    borderRadius: Radius.card,
    backgroundColor: Colors.primarySurface,
    borderWidth: 1,
    borderColor: Colors.border,
  },
  summaryTitle: { fontSize: 16, fontWeight: '700', marginBottom: 12 },
  summaryMeta: { marginTop: 8, fontSize: 13, color: Colors.textSecondary },
  consensus: {
    marginHorizontal: 16,
    marginBottom: 16,
    padding: 20,
    borderRadius: Radius.card,
    borderWidth: 1,
    borderColor: Colors.border,
    backgroundColor: Colors.surface,
  },
  sectionTitle: { fontSize: 16, fontWeight: '700', color: Colors.textPrimary },
  dimensionBlock: { marginTop: 12 },
  dimensionLabel: {
    fontSize: 13,
    fontWeight: '600',
    color: Colors.textSecondary,
    textTransform: 'capitalize',
    marginBottom: 4,
  },
  listTitle: { marginHorizontal: 16, marginBottom: 8 },
  optionRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 12,
    paddingBottom: 8,
    borderBottomWidth: 1,
    borderBottomColor: Colors.border,
  },
  optionLabel: { flex: 1, fontSize: 15, color: Colors.textPrimary },
  optionScore: { fontWeight: '700', color: Colors.primary },
  veto: { marginTop: 12, fontSize: 12, color: Colors.error },
  list: { paddingHorizontal: 16, paddingBottom: 32 },
  memberRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 14,
    borderBottomWidth: 1,
    borderBottomColor: Colors.border,
  },
  memberName: { fontSize: 16, fontWeight: '500' },
  badge: { paddingHorizontal: 12, paddingVertical: 6, borderRadius: 12 },
  badgeOk: { backgroundColor: Colors.successLight },
  badgePending: { backgroundColor: Colors.surfaceVariant },
  badgeText: { fontSize: 12, fontWeight: '700' },
  badgeTextOk: { color: Colors.success },
  badgeTextPending: { color: Colors.textSecondary },
});
