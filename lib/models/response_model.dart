/// Poids d'une réponse au sondage.
enum AnswerWeight {
  wished,
  indifferent,
  redhibitory;

  static AnswerWeight fromString(String value) =>
      AnswerWeight.values.firstWhere(
        (w) => w.name == value,
        orElse: () => AnswerWeight.indifferent,
      );

  String toJson() => name;
}

/// Une réponse à une question : `{ "value": "...", "weight": "wished" }`.
class AnswerEntry {
  const AnswerEntry({
    required this.value,
    required this.weight,
  });

  final String value;
  final AnswerWeight weight;

  factory AnswerEntry.fromJson(Map<String, dynamic> json) {
    return AnswerEntry(
      value: json['value'] as String,
      weight: AnswerWeight.fromString(json['weight'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'value': value,
        'weight': weight.toJson(),
      };
}

/// Réponse utilisateur à un sondage (`public.responses`).
class ResponseModel {
  const ResponseModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.answers,
    this.submittedAt,
  });

  final String id;
  final String eventId;
  final String userId;

  /// Clé = `question_id` (UUID), valeur = `{value, weight}`.
  final Map<String, AnswerEntry> answers;
  final DateTime? submittedAt;

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'];
    final parsedAnswers = <String, AnswerEntry>{};

    if (rawAnswers is Map) {
      rawAnswers.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          parsedAnswers[key.toString()] = AnswerEntry.fromJson(value);
        } else if (value is Map) {
          parsedAnswers[key.toString()] =
              AnswerEntry.fromJson(Map<String, dynamic>.from(value));
        }
      });
    }

    return ResponseModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      userId: json['user_id'] as String,
      answers: parsedAnswers,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'event_id': eventId,
        'user_id': userId,
        'answers': answers.map((k, v) => MapEntry(k, v.toJson())),
        if (submittedAt != null) 'submitted_at': submittedAt!.toIso8601String(),
      };

  /// Payload upsert — le trigger SQL met à jour `has_responded` sur `event_members`.
  Map<String, dynamic> toUpsertJson() => {
        'event_id': eventId,
        'user_id': userId,
        'answers': answers.map((k, v) => MapEntry(k, v.toJson())),
      };

  /// Accès brut JSONB (compatibilité lecture générique).
  Map<String, dynamic> get answersAsMap =>
      answers.map((k, v) => MapEntry(k, v.toJson()));
}
