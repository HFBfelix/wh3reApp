import 'package:wh3re/models/geo_point.dart';

/// Suggestion de lieu finale (`public.final_suggestions`).
class SuggestionModel {
  const SuggestionModel({
    required this.id,
    required this.eventId,
    required this.placeId,
    required this.placeName,
    required this.placeAddress,
    this.placeLocation,
    this.placeTypes = const [],
    this.matchScore,
    this.matchRationale,
    this.rank = 1,
    this.isSelected = false,
    this.createdAt,
    this.photoUrl,
  });

  final String id;
  final String eventId;
  final String placeId;
  final String placeName;
  final String placeAddress;

  /// Coordonnées GPS WGS84 (latitude / longitude).
  final GeoPoint? placeLocation;
  final List<String> placeTypes;
  final double? matchScore;
  final String? matchRationale;
  final int rank;
  final bool isSelected;
  final DateTime? createdAt;

  /// URL photo (Google Places API — non persistée en base).
  final String? photoUrl;

  double? get latitude => placeLocation?.latitude;
  double? get longitude => placeLocation?.longitude;

  factory SuggestionModel.fromJson(Map<String, dynamic> json) {
    final location = GeoPoint.tryParse(json['place_location']);

    final rawTypes = json['place_types'];
    final types = <String>[];
    if (rawTypes is List) {
      for (final t in rawTypes) {
        if (t != null) types.add(t.toString());
      }
    }

    return SuggestionModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      placeId: json['place_id'] as String,
      placeName: json['place_name'] as String,
      placeAddress: json['place_address'] as String,
      placeLocation: location,
      placeTypes: types,
      matchScore: _toDoubleOrNull(json['match_score']),
      matchRationale: json['match_rationale'] as String?,
      rank: json['rank'] as int? ?? 1,
      isSelected: json['is_selected'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  static double? _toDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'event_id': eventId,
        'place_id': placeId,
        'place_name': placeName,
        'place_address': placeAddress,
        if (placeLocation != null)
          'place_location': placeLocation!.toJson(),
        'place_types': placeTypes,
        if (matchScore != null) 'match_score': matchScore,
        if (matchRationale != null) 'match_rationale': matchRationale,
        'rank': rank,
        'is_selected': isSelected,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };

  SuggestionModel copyWith({
    String? photoUrl,
    bool? isSelected,
  }) {
    return SuggestionModel(
      id: id,
      eventId: eventId,
      placeId: placeId,
      placeName: placeName,
      placeAddress: placeAddress,
      placeLocation: placeLocation,
      placeTypes: placeTypes,
      matchScore: matchScore,
      matchRationale: matchRationale,
      rank: rank,
      isSelected: isSelected ?? this.isSelected,
      createdAt: createdAt,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
