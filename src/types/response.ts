/** Poids d'une réponse au sondage — contrat immuable. */
export type WeightEnum = 'wished' | 'indifferent' | 'redhibitory';

export interface AnswerEntry {
  value: string;
  weight: WeightEnum;
}

/** Clé = type de question ou question_id, valeur = { value, weight } */
export type ResponseAnswers = Record<string, AnswerEntry>;

export interface ResponseRecord {
  id: string;
  eventId: string;
  userId: string;
  answers: ResponseAnswers;
  submittedAt?: string;
}
