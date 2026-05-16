import type { AnswerEntry, ResponseAnswers, WeightEnum } from '@/types/response';

/** Score brut d'une option après pondération. */
export interface OptionScore {
  value: string;
  totalScore: number;
  normalizedScore: number;
  wishedCount: number;
  indifferentCount: number;
}

/** Consensus calculé après élimination des veto. */
export interface WeightingConsensus {
  /** Options éliminées (au moins un veto redhibitory). */
  eliminated: Record<string, string[]>;
  /** Scores des options restantes par dimension (lieu, budget, …). */
  scores: Record<string, OptionScore[]>;
  /** Meilleures options par dimension — top 3 pour fallback local. */
  topOptions: Record<string, OptionScore[]>;
  participantCount: number;
}

const WEIGHT_POINTS: Record<WeightEnum, number> = {
  wished: 2,
  indifferent: 1,
  redhibitory: 0,
};

/**
 * Étape 1 — Élimination dure : toute option marquée "redhibitory"
 * par UN SEUL invité est retirée du pool.
 */
export function eliminateRedhibitoryOptions(
  allResponses: ResponseAnswers[],
): Record<string, string[]> {
  const eliminated: Record<string, Set<string>> = {};

  for (const response of allResponses) {
    for (const [dimension, entry] of Object.entries(response)) {
      if (entry.weight !== 'redhibitory') continue;
      if (!eliminated[dimension]) {
        eliminated[dimension] = new Set();
      }
      eliminated[dimension].add(entry.value);
    }
  }

  const result: Record<string, string[]> = {};
  for (const [dimension, values] of Object.entries(eliminated)) {
    result[dimension] = Array.from(values);
  }
  return result;
}

/**
 * Étape 2 — Scoring : wished = +2, indifferent = +1, absent = 0.
 * Les options éliminées à l'étape 1 sont exclues.
 */
export function scoreOptions(
  allResponses: ResponseAnswers[],
  eliminated: Record<string, string[]>,
): Record<string, OptionScore[]> {
  const accumulator: Record<
    string,
    Record<string, { score: number; wished: number; indifferent: number }>
  > = {};

  for (const response of allResponses) {
    for (const [dimension, entry] of Object.entries(response)) {
      const vetoed = eliminated[dimension] ?? [];
      if (vetoed.includes(entry.value)) continue;

      if (!accumulator[dimension]) accumulator[dimension] = {};
      if (!accumulator[dimension][entry.value]) {
        accumulator[dimension][entry.value] = {
          score: 0,
          wished: 0,
          indifferent: 0,
        };
      }

      const bucket = accumulator[dimension][entry.value];
      bucket.score += WEIGHT_POINTS[entry.weight] ?? 0;
      if (entry.weight === 'wished') bucket.wished += 1;
      if (entry.weight === 'indifferent') bucket.indifferent += 1;
    }
  }

  const participantCount = Math.max(allResponses.length, 1);
  const result: Record<string, OptionScore[]> = {};

  for (const [dimension, options] of Object.entries(accumulator)) {
    result[dimension] = Object.entries(options)
      .map(([value, data]) => ({
        value,
        totalScore: data.score,
        normalizedScore: data.score / participantCount,
        wishedCount: data.wished,
        indifferentCount: data.indifferent,
      }))
      .sort((a, b) => b.normalizedScore - a.normalizedScore);
  }

  return result;
}

/**
 * Étape 3 — Consensus : score normalisé = total / nombre de participants.
 * Retourne le top 3 par dimension pour le fallback local.
 */
export function computeConsensus(
  allResponses: ResponseAnswers[],
): WeightingConsensus {
  const participantCount = allResponses.length;
  const eliminated = eliminateRedhibitoryOptions(allResponses);
  const scores = scoreOptions(allResponses, eliminated);

  const topOptions: Record<string, OptionScore[]> = {};
  for (const [dimension, options] of Object.entries(scores)) {
    topOptions[dimension] = options.slice(0, 3);
  }

  return {
    eliminated,
    scores,
    topOptions,
    participantCount,
  };
}

/**
 * Étape 4 — Fallback local si Gemini indisponible.
 * Retourne les 3 meilleures combinaisons sans appel API externe.
 */
export function localFallbackSuggestions(
  consensus: WeightingConsensus,
): { rationale: string; dimensions: Record<string, string> } {
  const dimensions: Record<string, string> = {};

  for (const [dimension, options] of Object.entries(consensus.topOptions)) {
    if (options.length > 0) {
      dimensions[dimension] = options[0].value;
    }
  }

  const rationale =
    `Consensus local (${consensus.participantCount} participant(s)) — ` +
    `options éliminées par veto : ${Object.keys(consensus.eliminated).length} dimension(s).`;

  return { rationale, dimensions };
}

/**
 * Construit un textQuery pour Google Places à partir du consensus.
 * Utilisé après réponse Gemini ou en fallback direct.
 */
export function buildPlacesTextQuery(
  consensus: WeightingConsensus,
  city: string,
): string {
  const parts: string[] = [];

  for (const options of Object.values(consensus.topOptions)) {
    if (options[0]) parts.push(options[0].value);
  }

  const query = parts.join(' ').trim();
  return query.length > 0
    ? `${query} à ${city}`
    : `lieu de sortie groupe à ${city}`;
}

/** Valide le format d'une entrée de réponse. */
export function isValidAnswerEntry(entry: unknown): entry is AnswerEntry {
  if (typeof entry !== 'object' || entry === null) return false;
  const e = entry as AnswerEntry;
  return (
    typeof e.value === 'string' &&
    (e.weight === 'wished' ||
      e.weight === 'indifferent' ||
      e.weight === 'redhibitory')
  );
}

/** Point d'entrée principal du moteur de pondération. */
export function runWeightingEngine(
  allResponses: ResponseAnswers[],
): WeightingConsensus {
  if (allResponses.length === 0) {
    return {
      eliminated: {},
      scores: {},
      topOptions: {},
      participantCount: 0,
    };
  }
  return computeConsensus(allResponses);
}
