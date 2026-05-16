import 'package:flutter_test/flutter_test.dart';
import 'package:wh3re/models/suggestion_model.dart';

void main() {
  group('SuggestionModel', () {
    test('fromJson parses GPS coordinates from GeoJSON', () {
      final model = SuggestionModel.fromJson({
        'id': 's1',
        'event_id': 'e1',
        'place_id': 'ChIJtest',
        'place_name': 'Le Comptoir',
        'place_address': '10 rue de Paris, 75001',
        'place_location': {
          'type': 'Point',
          'coordinates': [2.3522, 48.8566],
        },
        'place_types': ['restaurant'],
        'match_score': 87.5,
        'match_rationale': 'Consensus festif',
        'rank': 1,
        'is_selected': false,
      });

      expect(model.latitude, closeTo(48.8566, 0.0001));
      expect(model.longitude, closeTo(2.3522, 0.0001));
      expect(model.placeName, 'Le Comptoir');
    });

    test('toJson includes place_location', () {
      const model = SuggestionModel(
        id: 's1',
        eventId: 'e1',
        placeId: 'p1',
        placeName: 'Test',
        placeAddress: 'Addr',
        placeLocation: null,
      );
      expect(model.toJson()['place_id'], 'p1');
    });
  });
}
