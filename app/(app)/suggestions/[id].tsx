import { useState } from 'react';
import {
  View,
  Text,
  ScrollView,
  Image,
  Pressable,
  Alert,
  StyleSheet,
  Dimensions,
} from 'react-native';
import MapView, { Marker } from 'react-native-maps';
import { useLocalSearchParams, useRouter } from 'expo-router';
import * as Haptics from 'expo-haptics';
import { ScreenHeader } from '@/components/ScreenHeader';
import { QueryStateView } from '@/components/QueryStateView';
import { Wh3reButton } from '@/components/Wh3reButton';
import {
  useSuggestions,
  useIsEventCreator,
  useGenerateSuggestions,
  useSelectFinalPlace,
} from '@/hooks/useSuggestions';
import type { PlaceSuggestion } from '@/types/suggestion';
import { Colors, Radius } from '@/constants/theme';

const { width } = Dimensions.get('window');

function SuggestionCard({
  suggestion,
  showSelect,
  isSelecting,
  onSelect,
}: {
  suggestion: PlaceSuggestion;
  showSelect: boolean;
  isSelecting: boolean;
  onSelect: () => void;
}) {
  return (
    <View style={styles.card}>
      {suggestion.photoUrl ? (
        <Image source={{ uri: suggestion.photoUrl }} style={styles.photo} />
      ) : (
        <View style={[styles.photo, styles.photoPlaceholder]}>
          <Text style={styles.photoPlaceholderText}>📍</Text>
        </View>
      )}
      <View style={styles.cardBody}>
        <View style={styles.rankBadge}>
          <Text style={styles.rankText}>#{suggestion.rank}</Text>
        </View>
        <Text style={styles.placeName}>{suggestion.placeName}</Text>
        <Text style={styles.placeAddr} numberOfLines={2}>
          {suggestion.placeAddress}
        </Text>
        {suggestion.matchScore != null ? (
          <Text style={styles.score}>Score : {Math.round(suggestion.matchScore)}%</Text>
        ) : null}
        {suggestion.matchRationale ? (
          <Text style={styles.rationale}>{suggestion.matchRationale}</Text>
        ) : null}
        {showSelect ? (
          <Wh3reButton
            label={suggestion.isSelected ? 'Lieu retenu' : 'Choisir ce lieu'}
            onPress={onSelect}
            isLoading={isSelecting}
            disabled={suggestion.isSelected}
            style={{ marginTop: 12 }}
          />
        ) : null}
      </View>
    </View>
  );
}

export default function SuggestionsScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();
  const suggestionsQuery = useSuggestions(id);
  const creatorQuery = useIsEventCreator(id);
  const generateMutation = useGenerateSuggestions(id);
  const selectMutation = useSelectFinalPlace(id);
  const [selectingId, setSelectingId] = useState<string | null>(null);

  const isCreator = creatorQuery.data === true;
  const topThree = (suggestionsQuery.data ?? []).slice(0, 3);

  const mapRegion = (() => {
    const withLoc = topThree.filter((s) => s.placeLocation);
    if (withLoc.length === 0) {
      return {
        latitude: 48.8566,
        longitude: 2.3522,
        latitudeDelta: 0.08,
        longitudeDelta: 0.08,
      };
    }
    const lat =
      withLoc.reduce((s, p) => s + (p.placeLocation?.latitude ?? 0), 0) / withLoc.length;
    const lng =
      withLoc.reduce((s, p) => s + (p.placeLocation?.longitude ?? 0), 0) / withLoc.length;
    return { latitude: lat, longitude: lng, latitudeDelta: 0.06, longitudeDelta: 0.06 };
  })();

  const onSelect = async (suggestion: PlaceSuggestion) => {
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    setSelectingId(suggestion.id);
    try {
      await selectMutation.mutateAsync(suggestion);
      Alert.alert('Lieu retenu', `« ${suggestion.placeName} » est le lieu final !`);
      router.replace(`/(app)/event/${id}`);
    } catch (e) {
      Alert.alert('Erreur', e instanceof Error ? e.message : 'Validation impossible.');
    } finally {
      setSelectingId(null);
    }
  };

  return (
    <View style={styles.root}>
      <ScreenHeader title="Suggestions du groupe" />
      <QueryStateView
        isLoading={suggestionsQuery.isLoading || creatorQuery.isLoading}
        isError={suggestionsQuery.isError}
        error={suggestionsQuery.error}
        onRetry={() => suggestionsQuery.refetch()}
        isEmpty={!suggestionsQuery.isLoading && topThree.length === 0}
        emptyMessage={
          isCreator
            ? 'Aucune suggestion pour le moment.\nGénérez les 3 propositions IA après les votes.'
            : 'Aucune suggestion disponible.\nLe créateur les génèrera après les votes.'
        }
      >
        <ScrollView contentContainerStyle={styles.scroll}>
          <Text style={styles.heading}>Les 3 lieux recommandés</Text>
          <Text style={styles.sub}>
            {isCreator
              ? 'Choisissez le lieu qui fera l\'unanimité.'
              : 'Le créateur validera le lieu final.'}
          </Text>

          {isCreator && topThree.length === 0 ? (
            <Wh3reButton
              label="Générer les suggestions (IA)"
              isLoading={generateMutation.isPending}
              onPress={() => generateMutation.mutate()}
              style={{ marginBottom: 20 }}
            />
          ) : null}

          {topThree.length > 0 ? (
            <MapView style={styles.map} region={mapRegion}>
              {topThree.map(
                (s) =>
                  s.placeLocation && (
                    <Marker
                      key={s.id}
                      coordinate={{
                        latitude: s.placeLocation.latitude,
                        longitude: s.placeLocation.longitude,
                      }}
                      title={s.placeName}
                    />
                  ),
              )}
            </MapView>
          ) : null}

          {topThree.map((s) => (
            <SuggestionCard
              key={s.id}
              suggestion={s}
              showSelect={isCreator}
              isSelecting={selectingId === s.id}
              onSelect={() => onSelect(s)}
            />
          ))}
        </ScrollView>
      </QueryStateView>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: Colors.background },
  scroll: { padding: 16, paddingBottom: 40 },
  heading: { fontSize: 22, fontWeight: '700', color: Colors.textPrimary },
  sub: { marginTop: 6, color: Colors.textSecondary, marginBottom: 16 },
  map: {
    width: width - 32,
    height: 200,
    borderRadius: Radius.card,
    marginBottom: 20,
  },
  card: {
    borderRadius: Radius.card,
    borderWidth: 1,
    borderColor: Colors.border,
    backgroundColor: Colors.surface,
    marginBottom: 16,
    overflow: 'hidden',
  },
  photo: { width: '100%', height: 140 },
  photoPlaceholder: {
    backgroundColor: Colors.primarySurface,
    alignItems: 'center',
    justifyContent: 'center',
  },
  photoPlaceholderText: { fontSize: 40 },
  cardBody: { padding: 16 },
  rankBadge: {
    alignSelf: 'flex-start',
    backgroundColor: Colors.primary,
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 8,
    marginBottom: 8,
  },
  rankText: { color: Colors.textOnPrimary, fontWeight: '700', fontSize: 12 },
  placeName: { fontSize: 18, fontWeight: '700', color: Colors.textPrimary },
  placeAddr: { marginTop: 4, fontSize: 14, color: Colors.textSecondary },
  score: { marginTop: 8, fontWeight: '600', color: Colors.primary },
  rationale: { marginTop: 6, fontSize: 13, color: Colors.textSecondary, lineHeight: 18 },
});
