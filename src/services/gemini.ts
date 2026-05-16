import {
  runWeightingEngine,
  localFallbackSuggestions,
  buildPlacesTextQuery,
  type WeightingConsensus,
} from '@/utils/weightingEngine';
import type { ResponseAnswers } from '@/types/response';

const GEMINI_URL =
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
const TIMEOUT_MS = 12_000;

export interface GeminiPlacesQueryResult {
  textQuery: string;
  rationale: string;
  fromGemini: boolean;
}

/**
 * Étape 5 — Gemini 1.5 Flash pour optimiser textQuery Places API.
 * Étape 4 — Fallback local via weightingEngine si timeout/erreur.
 */
export async function generatePlacesQuery(
  allResponses: ResponseAnswers[],
  city: string,
): Promise<GeminiPlacesQueryResult> {
  const consensus: WeightingConsensus = runWeightingEngine(allResponses);
  const fallback = localFallbackSuggestions(consensus);
  const fallbackQuery = buildPlacesTextQuery(consensus, city);

  const apiKey = process.env.EXPO_PUBLIC_GEMINI_API_KEY;
  if (!apiKey) {
    return {
      textQuery: fallbackQuery,
      rationale: fallback.rationale,
      fromGemini: false,
    };
  }

  const consensusJson = JSON.stringify({
    topOptions: consensus.topOptions,
    eliminated: consensus.eliminated,
    participantCount: consensus.participantCount,
  });

  const prompt = `Tu es un moteur de recommandation de lieux pour un événement de groupe.

Voici le consensus des préférences du groupe (options éliminées si poids "redhibitory") :
${consensusJson}

Génère une requête de recherche pour la New Places API Google (textQuery)
optimisée pour trouver 3 lieux réels à ${city}.
Réponds UNIQUEMENT en JSON valide, sans markdown, sans explication :
{
  "textQuery": "string — requête optimisée pour Places API",
  "rationale": "string — explication du consensus en 1 phrase"
}`;

  try {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), TIMEOUT_MS);

    const response = await fetch(`${GEMINI_URL}?key=${apiKey}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      signal: controller.signal,
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { temperature: 0.4, maxOutputTokens: 256 },
      }),
    });

    clearTimeout(timeout);

    if (!response.ok) throw new Error(`Gemini HTTP ${response.status}`);

    const body = (await response.json()) as {
      candidates?: { content?: { parts?: { text?: string }[] } }[];
    };

    const rawText = body.candidates?.[0]?.content?.parts?.[0]?.text ?? '';
    const jsonMatch = rawText.match(/\{[\s\S]*\}/);
    if (!jsonMatch) throw new Error('Réponse Gemini invalide');

    const parsed = JSON.parse(jsonMatch[0]) as {
      textQuery?: string;
      rationale?: string;
    };

    return {
      textQuery: parsed.textQuery?.trim() || fallbackQuery,
      rationale: parsed.rationale?.trim() || fallback.rationale,
      fromGemini: true,
    };
  } catch {
    return {
      textQuery: fallbackQuery,
      rationale: fallback.rationale,
      fromGemini: false,
    };
  }
}

/** Suggestion d'ambiance pour la création d'événement (fallback local si pas de clé API). */
export async function suggestEventAmbiance(
  eventName: string,
  description?: string,
): Promise<string> {
  const apiKey = process.env.EXPO_PUBLIC_GEMINI_API_KEY;
  const fallback = description?.trim()
    ? `Ambiance ${description.trim().slice(0, 40)}`
    : `Sortie conviviale autour de « ${eventName.trim()} »`;

  if (!apiKey || !eventName.trim()) return fallback;

  const prompt = `Pour un événement de groupe nommé "${eventName.trim()}"${
    description ? ` (${description.trim()})` : ''
  }, propose UNE courte phrase d'ambiance (max 60 caractères) en français, sans guillemets.`;

  try {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 8000);
    const response = await fetch(`${GEMINI_URL}?key=${apiKey}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      signal: controller.signal,
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { temperature: 0.7, maxOutputTokens: 64 },
      }),
    });
    clearTimeout(timeout);
    if (!response.ok) return fallback;
    const body = (await response.json()) as {
      candidates?: { content?: { parts?: { text?: string }[] } }[];
    };
    const text = body.candidates?.[0]?.content?.parts?.[0]?.text?.trim();
    return text && text.length > 0 ? text.slice(0, 80) : fallback;
  } catch {
    return fallback;
  }
}
