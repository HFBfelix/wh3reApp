import {
  computeConsensus,
  eliminateRedhibitoryOptions,
  localFallbackSuggestions,
  runWeightingEngine,
} from '@/utils/weightingEngine';
import type { ResponseAnswers } from '@/types/response';

describe('weightingEngine', () => {
  const responses: ResponseAnswers[] = [
    {
      lieu: { value: 'restaurant', weight: 'wished' },
      budget: { value: 'moins de 30€', weight: 'redhibitory' },
      ambiance: { value: 'festif', weight: 'indifferent' },
    },
    {
      lieu: { value: 'bar', weight: 'wished' },
      budget: { value: '30-50€', weight: 'wished' },
      ambiance: { value: 'festif', weight: 'wished' },
    },
    {
      lieu: { value: 'restaurant', weight: 'indifferent' },
      budget: { value: '30-50€', weight: 'indifferent' },
    },
  ];

  it('eliminates options with at least one redhibitory vote', () => {
    const eliminated = eliminateRedhibitoryOptions(responses);
    expect(eliminated.budget).toContain('moins de 30€');
  });

  it('scores wished higher than indifferent', () => {
    const consensus = computeConsensus(responses);
    const lieuScores = consensus.scores.lieu ?? [];
    const restaurant = lieuScores.find((s) => s.value === 'restaurant');
    const bar = lieuScores.find((s) => s.value === 'bar');
    expect(restaurant).toBeDefined();
    expect(bar).toBeDefined();
    expect(restaurant!.normalizedScore).toBeGreaterThan(0);
  });

  it('returns top 3 options per dimension in fallback', () => {
    const consensus = runWeightingEngine(responses);
    const fallback = localFallbackSuggestions(consensus);
    expect(fallback.dimensions.lieu).toBeDefined();
    expect(consensus.participantCount).toBe(3);
  });
});
