import { useState, useCallback } from 'react';
import { View, Text, Pressable, StyleSheet, Dimensions } from 'react-native';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
  runOnJS,
} from 'react-native-reanimated';
import { Gesture, GestureDetector } from 'react-native-gesture-handler';
import * as Haptics from 'expo-haptics';
import type { Question } from '@/types/question';
import type { AnswerEntry, WeightEnum } from '@/types/response';
import { WeightSelector } from '@/components/WeightSelector';
import { Colors, Radius } from '@/constants/theme';

const { width: SCREEN_WIDTH } = Dimensions.get('window');
const SWIPE_THRESHOLD = SCREEN_WIDTH * 0.25;

interface SwipeableQuestionDeckProps {
  questions: Question[];
  answers: Record<string, AnswerEntry | undefined>;
  onSelectValue: (questionId: string, value: string) => void;
  onSelectWeight: (questionId: string, weight: WeightEnum) => void;
}

export function SwipeableQuestionDeck({
  questions,
  answers,
  onSelectValue,
  onSelectWeight,
}: SwipeableQuestionDeckProps) {
  const [index, setIndex] = useState(0);
  const translateX = useSharedValue(0);

  const goNext = useCallback(() => {
    setIndex((i) => Math.min(i + 1, questions.length - 1));
    translateX.value = 0;
  }, [questions.length, translateX]);

  const goPrev = useCallback(() => {
    setIndex((i) => Math.max(i - 1, 0));
    translateX.value = 0;
  }, [translateX]);

  const question = questions[index];
  const draft = answers[question.id];
  const progress = `${index + 1} / ${questions.length}`;

  const pan = Gesture.Pan()
    .onUpdate((e) => {
      translateX.value = e.translationX;
    })
    .onEnd((e) => {
      if (e.translationX < -SWIPE_THRESHOLD && index < questions.length - 1) {
        runOnJS(Haptics.impactAsync)(Haptics.ImpactFeedbackStyle.Medium);
        runOnJS(goNext)();
      } else if (e.translationX > SWIPE_THRESHOLD && index > 0) {
        runOnJS(Haptics.impactAsync)(Haptics.ImpactFeedbackStyle.Medium);
        runOnJS(goPrev)();
      }
      translateX.value = withSpring(0);
    });

  const cardStyle = useAnimatedStyle(() => ({
    transform: [{ translateX: translateX.value }],
  }));

  const selectOption = async (value: string) => {
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    onSelectValue(question.id, value);
  };

  return (
    <View style={styles.wrap}>
      <Text style={styles.progress}>{progress}</Text>
      <GestureDetector gesture={pan}>
        <Animated.View style={[styles.card, cardStyle]}>
          <Text style={styles.questionLabel}>{question.questionLabel}</Text>
          <Text style={styles.hint}>Glissez ← → pour changer de question</Text>
          <View style={styles.options}>
            {question.options.map((opt) => {
              const selected = draft?.value === opt.value;
              return (
                <Pressable
                  key={opt.value}
                  onPress={() => selectOption(opt.value)}
                  style={[styles.option, selected && styles.optionSelected]}
                >
                  {opt.emoji ? <Text style={styles.emoji}>{opt.emoji}</Text> : null}
                  <Text style={[styles.optionLabel, selected && styles.optionLabelSelected]}>
                    {opt.label}
                  </Text>
                </Pressable>
              );
            })}
          </View>
          {draft?.value ? (
            <View style={styles.weightBlock}>
              <Text style={styles.weightTitle}>Importance de ce choix</Text>
              <WeightSelector
                selected={draft.weight ?? 'indifferent'}
                onChange={(w) => onSelectWeight(question.id, w)}
              />
            </View>
          ) : null}
        </Animated.View>
      </GestureDetector>
      <View style={styles.navRow}>
        <Pressable
          onPress={goPrev}
          disabled={index === 0}
          style={[styles.navBtn, index === 0 && styles.navDisabled]}
        >
          <Text style={styles.navText}>Précédent</Text>
        </Pressable>
        <Pressable
          onPress={goNext}
          disabled={index >= questions.length - 1}
          style={[styles.navBtn, index >= questions.length - 1 && styles.navDisabled]}
        >
          <Text style={styles.navText}>Suivant</Text>
        </Pressable>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { flex: 1, padding: 16 },
  progress: {
    textAlign: 'center',
    fontSize: 13,
    fontWeight: '600',
    color: Colors.textTertiary,
    marginBottom: 12,
  },
  card: {
    flex: 1,
    backgroundColor: Colors.surface,
    borderRadius: Radius.card,
    borderWidth: 1,
    borderColor: Colors.border,
    padding: 20,
    shadowColor: Colors.primary,
    shadowOpacity: 0.08,
    shadowRadius: 16,
    shadowOffset: { width: 0, height: 8 },
    elevation: 4,
  },
  questionLabel: {
    fontSize: 20,
    fontWeight: '700',
    color: Colors.textPrimary,
    lineHeight: 28,
  },
  hint: { marginTop: 8, fontSize: 12, color: Colors.textTertiary },
  options: { marginTop: 20, gap: 10 },
  option: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
    padding: 14,
    borderRadius: Radius.input,
    borderWidth: 1,
    borderColor: Colors.border,
    backgroundColor: Colors.surfaceVariant,
  },
  optionSelected: {
    borderColor: Colors.primary,
    backgroundColor: Colors.primarySurface,
  },
  emoji: { fontSize: 22 },
  optionLabel: { fontSize: 16, color: Colors.textPrimary, fontWeight: '500' },
  optionLabelSelected: { color: Colors.primary, fontWeight: '700' },
  weightBlock: { marginTop: 24 },
  weightTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: Colors.textSecondary,
    marginBottom: 12,
  },
  navRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 16,
    paddingBottom: 8,
  },
  navBtn: { padding: 12 },
  navDisabled: { opacity: 0.35 },
  navText: { color: Colors.primary, fontWeight: '600', fontSize: 15 },
});
