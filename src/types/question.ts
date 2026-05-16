export type QuestionType = 'lieu' | 'ambiance' | 'budget' | 'date' | 'custom';

export interface QuestionOption {
  value: string;
  label: string;
  emoji?: string;
}

export interface Question {
  id: string;
  eventId: string;
  questionType: QuestionType;
  questionLabel: string;
  options: QuestionOption[];
  sortOrder: number;
}

export const DEFAULT_QUESTIONS_PAYLOAD = [
  {
    question_type: 'lieu',
    question_label: 'Quel type de lieu préférez-vous ?',
    sort_order: 0,
    options: [
      { value: 'restaurant', label: 'Restaurant', emoji: '🍽️' },
      { value: 'bar', label: 'Bar', emoji: '🍸' },
      { value: 'parc', label: 'Parc', emoji: '🌳' },
      { value: 'salle', label: 'Salle', emoji: '🏛️' },
    ],
  },
  {
    question_type: 'budget',
    question_label: 'Quel budget par personne ?',
    sort_order: 1,
    options: [
      { value: 'moins de 30€', label: 'Moins de 30€', emoji: '💶' },
      { value: '30-50€', label: '30 à 50€', emoji: '💳' },
      { value: '50€+', label: 'Plus de 50€', emoji: '✨' },
    ],
  },
  {
    question_type: 'ambiance',
    question_label: 'Quelle ambiance recherchez-vous ?',
    sort_order: 2,
    options: [
      { value: 'cosy', label: 'Cosy', emoji: '🕯️' },
      { value: 'festif', label: 'Festif', emoji: '🎉' },
      { value: 'chill', label: 'Chill', emoji: '😌' },
    ],
  },
  {
    question_type: 'date',
    question_label: 'Quand souhaitez-vous vous retrouver ?',
    sort_order: 3,
    options: [
      { value: 'vendredi soir', label: 'Vendredi soir', emoji: '🌙' },
      { value: 'samedi', label: 'Samedi', emoji: '☀️' },
      { value: 'dimanche', label: 'Dimanche', emoji: '🌤️' },
    ],
  },
] as const;
