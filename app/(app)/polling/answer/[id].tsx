import { useState, useMemo } from 'react';
import { View, Text, Alert, StyleSheet } from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { ScreenHeader } from '@/components/ScreenHeader';
import { QueryStateView } from '@/components/QueryStateView';
import { Wh3reButton } from '@/components/Wh3reButton';
import { SwipeableQuestionDeck } from '@/components/SwipeableQuestionDeck';
import {
  usePollQuestions,
  useSubmitResponse,
} from '@/hooks/useResponses';
import type { AnswerEntry, ResponseAnswers, WeightEnum } from '@/types/response';
import { Colors, Radius } from '@/constants/theme';

export default function PollAnswerScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();
  const questionsQuery = usePollQuestions(id);
  const submitMutation = useSubmitResponse(id);
  const [answers, setAnswers] = useState<Record<string, AnswerEntry | undefined>>({});
  const [success, setSuccess] = useState(false);

  const isComplete = useMemo(() => {
    const qs = questionsQuery.data ?? [];
    return qs.every((q) => {
      const a = answers[q.id];
      return a?.value && a?.weight;
    });
  }, [questionsQuery.data, answers]);

  const selectValue = (questionId: string, value: string) => {
    setAnswers((prev) => ({
      ...prev,
      [questionId]: {
        value,
        weight: prev[questionId]?.weight ?? 'indifferent',
      },
    }));
  };

  const selectWeight = (questionId: string, weight: WeightEnum) => {
    setAnswers((prev) => {
      const current = prev[questionId];
      if (!current?.value) return prev;
      return { ...prev, [questionId]: { ...current, weight } };
    });
  };

  const submit = async () => {
    const payload: ResponseAnswers = {};
    for (const [qid, entry] of Object.entries(answers)) {
      if (entry?.value && entry.weight) payload[qid] = entry;
    }
    try {
      await submitMutation.mutateAsync(payload);
      setSuccess(true);
    } catch (e) {
      Alert.alert('Erreur', e instanceof Error ? e.message : 'Échec de l\'envoi.');
    }
  };

  if (success) {
    return (
      <View style={styles.root}>
        <View style={styles.success}>
          <Text style={styles.successEmoji}>🎉</Text>
          <Text style={styles.successTitle}>Merci pour vos réponses !</Text>
          <Text style={styles.successSub}>Le groupe peut maintenant avancer vers le lieu idéal.</Text>
          <Wh3reButton
            label="Retour à l'événement"
            onPress={() => router.replace(`/(app)/event/${id}`)}
            style={{ marginTop: 24 }}
          />
        </View>
      </View>
    );
  }

  return (
    <View style={styles.root}>
      <ScreenHeader title="Votre avis compte" />
      <QueryStateView
        isLoading={questionsQuery.isLoading}
        isError={questionsQuery.isError}
        error={questionsQuery.error}
        onRetry={() => questionsQuery.refetch()}
        isEmpty={!questionsQuery.isLoading && (questionsQuery.data?.length ?? 0) === 0}
        emptyMessage="Aucune question configurée pour cet événement."
      >
        {questionsQuery.data && questionsQuery.data.length > 0 ? (
          <>
            <SwipeableQuestionDeck
              questions={questionsQuery.data}
              answers={answers}
              onSelectValue={selectValue}
              onSelectWeight={selectWeight}
            />
            <View style={styles.footer}>
              <Wh3reButton
                label="Envoyer mes réponses"
                isLoading={submitMutation.isPending}
                onPress={submit}
                disabled={!isComplete}
              />
            </View>
          </>
        ) : null}
      </QueryStateView>
    </View>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: Colors.background },
  footer: { padding: 16, paddingBottom: 24 },
  success: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    padding: 32,
  },
  successEmoji: { fontSize: 56 },
  successTitle: {
    marginTop: 16,
    fontSize: 22,
    fontWeight: '700',
    color: Colors.textPrimary,
    textAlign: 'center',
  },
  successSub: {
    marginTop: 8,
    fontSize: 15,
    color: Colors.textSecondary,
    textAlign: 'center',
    lineHeight: 22,
  },
});
