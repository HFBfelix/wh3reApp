import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Récupère l'URL d'une photo via la **New Places API v2**.
class GooglePlacesPhotoService {
  GooglePlacesPhotoService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _baseUrl = 'https://places.googleapis.com/v1';

  String? get _apiKey => dotenv.env['GOOGLE_PLACES_API_KEY'];

  /// Retourne une URL de photo ou `null` si indisponible.
  Future<String?> fetchPhotoUrl(String placeId) async {
    final apiKey = _apiKey;
    if (apiKey == null || apiKey.isEmpty || placeId.isEmpty) return null;

    try {
      final detailsUri = Uri.parse('$_baseUrl/places/$placeId');
      final detailsResponse = await _client.get(
        detailsUri,
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': apiKey,
          'X-Goog-FieldMask': 'photos',
        },
      );

      if (detailsResponse.statusCode != 200) return null;

      final body = jsonDecode(detailsResponse.body) as Map<String, dynamic>;
      final photos = body['photos'] as List?;
      if (photos == null || photos.isEmpty) return null;

      final photoName = (photos.first as Map<String, dynamic>)['name'] as String?;
      if (photoName == null || photoName.isEmpty) return null;

      return '$_baseUrl/$photoName/media?maxHeightPx=400&key=$apiKey';
    } on Object {
      return null;
    }
  }

  void dispose() => _client.close();
}
