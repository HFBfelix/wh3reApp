import 'package:flutter_test/flutter_test.dart';
import 'package:wh3re/models/event_model.dart';
import 'package:wh3re/models/geo_point.dart';

void main() {
  group('EventModel', () {
    test('fromJson / toJson round-trip', () {
      final json = {
        'id': 'evt-1',
        'creator_id': 'user-1',
        'name': 'Apéro équipe',
        'description': 'Vendredi',
        'ambiance': 'festif',
        'status': 'polling',
        'invite_token': 'abc123',
        'final_place_id': 'place-1',
        'final_place_name': 'Le Comptoir',
        'final_place_address': '10 rue de Paris',
        'final_place_location': {
          'type': 'Point',
          'coordinates': [2.3522, 48.8566],
        },
        'created_at': '2026-05-15T10:00:00.000Z',
        'updated_at': '2026-05-15T11:00:00.000Z',
      };

      final model = EventModel.fromJson(json);
      expect(model.id, 'evt-1');
      expect(model.status, EventStatus.polling);
      expect(model.finalPlaceLocation?.latitude, closeTo(48.8566, 0.0001));
      expect(model.finalPlaceLocation?.longitude, closeTo(2.3522, 0.0001));

      final encoded = model.toJson();
      expect(encoded['name'], 'Apéro équipe');
      expect(encoded['status'], 'polling');
    });

    test('toInsertJson excludes server-generated fields', () {
      const model = EventModel(
        id: 'x',
        creatorId: 'user-1',
        name: 'Test',
      );
      final insert = model.toInsertJson();
      expect(insert.containsKey('id'), false);
      expect(insert.containsKey('invite_token'), false);
      expect(insert['creator_id'], 'user-1');
    });
  });

  group('GeoPoint', () {
    test('fromJson GeoJSON format', () {
      final point = GeoPoint.fromJson({
        'type': 'Point',
        'coordinates': [2.35, 48.85],
      });
      expect(point.longitude, 2.35);
      expect(point.latitude, 48.85);
    });
  });
}
