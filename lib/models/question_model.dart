/// Type de question configurable par le créateur.
enum QuestionType {
  lieu,
  ambiance,
  budget,
  date,
  custom;

  static QuestionType fromString(String value) =>
      QuestionType.values.firstWhere(
        (t) => t.name == value,
        orElse: () => QuestionType.custom,
      );

  String toJson() => name;
}

/// Option de réponse (`questions_template.options` JSONB).
class QuestionOption {
  const QuestionOption({
    required this.value,
    required this.label,
    this.emoji,
  });

  final String value;
  final String label;
  final String? emoji;

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      value: json['value'] as String,
      label: json['label'] as String,
      emoji: json['emoji'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'value': value,
        'label': label,
        if (emoji != null) 'emoji': emoji,
      };
}

/// Question de sondage (`public.questions_template`).
class QuestionModel {
  const QuestionModel({
    required this.id,
    required this.eventId,
    required this.questionType,
    required this.questionLabel,
    required this.options,
    this.sortOrder = 0,
  });

  final String id;
  final String eventId;
  final QuestionType questionType;
  final String questionLabel;
  final List<QuestionOption> options;
  final int sortOrder;

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final options = <QuestionOption>[];

    if (rawOptions is List) {
      for (final item in rawOptions) {
        if (item is Map<String, dynamic>) {
          options.add(QuestionOption.fromJson(item));
        } else if (item is Map) {
          options.add(QuestionOption.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return QuestionModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      questionType: QuestionType.fromString(json['question_type'] as String),
      questionLabel: json['question_label'] as String,
      options: options,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'event_id': eventId,
        'question_type': questionType.toJson(),
        'question_label': questionLabel,
        'options': options.map((o) => o.toJson()).toList(),
        'sort_order': sortOrder,
      };
}

/// Questions par défaut insérées à la création d'un événement.
List<Map<String, dynamic>> defaultQuestionsPayload() => [
      {
        'question_type': 'lieu',
        'question_label': 'Quel type de lieu préférez-vous ?',
        'sort_order': 0,
        'options': [
          {'value': 'restaurant', 'label': 'Restaurant', 'emoji': '🍽️'},
          {'value': 'bar', 'label': 'Bar', 'emoji': '🍸'},
          {'value': 'parc', 'label': 'Parc', 'emoji': '🌳'},
          {'value': 'salle', 'label': 'Salle', 'emoji': '🏛️'},
        ],
      },
      {
        'question_type': 'budget',
        'question_label': 'Quel budget par personne ?',
        'sort_order': 1,
        'options': [
          {'value': 'moins de 30€', 'label': 'Moins de 30€', 'emoji': '💶'},
          {'value': '30-50€', 'label': '30 à 50€', 'emoji': '💳'},
          {'value': '50€+', 'label': 'Plus de 50€', 'emoji': '✨'},
        ],
      },
      {
        'question_type': 'ambiance',
        'question_label': 'Quelle ambiance recherchez-vous ?',
        'sort_order': 2,
        'options': [
          {'value': 'cosy', 'label': 'Cosy', 'emoji': '🕯️'},
          {'value': 'festif', 'label': 'Festif', 'emoji': '🎉'},
          {'value': 'chill', 'label': 'Chill', 'emoji': '😌'},
        ],
      },
      {
        'question_type': 'date',
        'question_label': 'Quand souhaitez-vous vous retrouver ?',
        'sort_order': 3,
        'options': [
          {'value': 'vendredi soir', 'label': 'Vendredi soir', 'emoji': '🌙'},
          {'value': 'samedi', 'label': 'Samedi', 'emoji': '☀️'},
          {'value': 'dimanche', 'label': 'Dimanche', 'emoji': '🌤️'},
        ],
      },
    ];
