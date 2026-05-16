import 'package:flutter_test/flutter_test.dart';
import 'package:wh3re/models/response_model.dart';

void main() {
  group('submitResponse JSON contract', () {
    test('uses question_id as keys with value and weight', () {
      const questionId = '550e8400-e29b-41d4-a716-446655440000';

      final answers = {
        questionId: AnswerEntry(
          value: 'restaurant',
          weight: AnswerWeight.wished,
        ),
      };

      final json = answers.map((k, v) => MapEntry(k, v.toJson()));

      expect(json.keys.single, questionId);
      expect(json[questionId], {
        'value': 'restaurant',
        'weight': 'wished',
      });
    });

    test('supports all weight enums', () {
      for (final weight in AnswerWeight.values) {
        final entry = AnswerEntry(value: 'test', weight: weight);
        expect(entry.toJson()['weight'], weight.toJson());
      }
    });
  });
}
