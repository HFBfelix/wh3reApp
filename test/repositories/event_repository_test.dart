import 'package:flutter_test/flutter_test.dart';
import 'package:wh3re/models/response_model.dart';

/// Tests unitaires de la logique métier sérialisable (sans mock Supabase ici).
void main() {
  group('submitResponse payload', () {
    test('answers map respects contract', () {
      final answers = {
        'lieu': AnswerEntry(value: 'restaurant', weight: AnswerWeight.wished),
        'budget': AnswerEntry(value: 'moins de 30€', weight: AnswerWeight.redhibitory),
      };

      final model = ResponseModel(
        id: '',
        eventId: 'evt',
        userId: 'usr',
        answers: answers,
      );

      final json = model.toUpsertJson()['answers'] as Map<String, dynamic>;
      expect(json['lieu']['weight'], 'wished');
      expect(json['budget']['weight'], 'redhibitory');
    });
  });
}
