import 'package:flutter_test/flutter_test.dart';
import 'package:wh3re/models/response_model.dart';

void main() {
  group('ResponseModel', () {
    test('fromJson parses answers map with weights', () {
      final json = {
        'id': 'resp-1',
        'event_id': 'evt-1',
        'user_id': 'user-1',
        'answers': {
          'lieu': {'value': 'restaurant', 'weight': 'wished'},
          'budget': {'value': '30-50€', 'weight': 'redhibitory'},
        },
        'submitted_at': '2026-05-15T12:00:00.000Z',
      };

      final model = ResponseModel.fromJson(json);
      expect(model.answers['lieu']?.value, 'restaurant');
      expect(model.answers['lieu']?.weight, AnswerWeight.wished);
      expect(model.answers['budget']?.weight, AnswerWeight.redhibitory);
    });

    test('toUpsertJson serializes answers', () {
      final model = ResponseModel(
        id: 'r1',
        eventId: 'e1',
        userId: 'u1',
        answers: {
          'date': AnswerEntry(value: 'vendredi', weight: AnswerWeight.indifferent),
        },
      );
      final upsert = model.toUpsertJson();
      expect(upsert['answers']['date']['weight'], 'indifferent');
    });
  });
}
