import 'package:wh3re/models/geo_point.dart';

/// Statut du cycle de vie d'un événement.
enum EventStatus {
  draft,
  polling,
  decided,
  archived;

  static EventStatus fromString(String value) =>
      EventStatus.values.firstWhere(
        (s) => s.name == value,
        orElse: () => EventStatus.draft,
      );

  String toJson() => name;
}

/// Événement de groupe (`public.events`).
class EventModel {
  const EventModel({
    required this.id,
    required this.creatorId,
    required this.name,
    this.description,
    this.ambiance,
    this.status = EventStatus.draft,
    this.inviteToken,
    this.finalPlaceId,
    this.finalPlaceName,
    this.finalPlaceAddress,
    this.finalPlaceLocation,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String creatorId;
  final String name;
  final String? description;
  final String? ambiance;
  final EventStatus status;
  final String? inviteToken;
  final String? finalPlaceId;
  final String? finalPlaceName;
  final String? finalPlaceAddress;
  final GeoPoint? finalPlaceLocation;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory EventModel.fromJson(Map<String, dynamic> json) {
    GeoPoint? location;
    final rawLocation = json['final_place_location'];
    if (rawLocation != null) {
      try {
        location = GeoPoint.fromJson(rawLocation);
      } on Object {
        location = null;
      }
    }

    return EventModel(
      id: json['id'] as String,
      creatorId: json['creator_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      ambiance: json['ambiance'] as String?,
      status: EventStatus.fromString(json['status'] as String? ?? 'draft'),
      inviteToken: json['invite_token'] as String?,
      finalPlaceId: json['final_place_id'] as String?,
      finalPlaceName: json['final_place_name'] as String?,
      finalPlaceAddress: json['final_place_address'] as String?,
      finalPlaceLocation: location,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'creator_id': creatorId,
        'name': name,
        if (description != null) 'description': description,
        if (ambiance != null) 'ambiance': ambiance,
        'status': status.toJson(),
        if (inviteToken != null) 'invite_token': inviteToken,
        if (finalPlaceId != null) 'final_place_id': finalPlaceId,
        if (finalPlaceName != null) 'final_place_name': finalPlaceName,
        if (finalPlaceAddress != null) 'final_place_address': finalPlaceAddress,
        if (finalPlaceLocation != null)
          'final_place_location': finalPlaceLocation!.toJson(),
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };

  /// Payload d'insertion (sans id ni invite_token — générés par Supabase).
  Map<String, dynamic> toInsertJson() => {
        'creator_id': creatorId,
        'name': name,
        if (description != null) 'description': description,
        if (ambiance != null) 'ambiance': ambiance,
        'status': status.toJson(),
      };
}
