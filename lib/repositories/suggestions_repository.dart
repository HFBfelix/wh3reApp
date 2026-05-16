import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wh3re/core/errors/repository_exception.dart';
import 'package:wh3re/models/event_model.dart';
import 'package:wh3re/models/geo_point.dart';
import 'package:wh3re/models/member_model.dart';
import 'package:wh3re/models/suggestion_model.dart';
import 'package:wh3re/services/google_places_photo_service.dart';
import 'package:wh3re/services/supabase_service.dart';

/// Accès aux suggestions finales et décision du créateur.
class SuggestionsRepository {
  SuggestionsRepository({
    SupabaseService? supabase,
    GooglePlacesPhotoService? photoService,
  })  : _supabase = supabase ?? SupabaseService.instance,
        _photoService = photoService ?? GooglePlacesPhotoService();

  final SupabaseService _supabase;
  final GooglePlacesPhotoService _photoService;

  static const _suggestionsTable = 'final_suggestions';
  static const _eventsTable = 'events';
  static const _membersTable = 'event_members';

  String? get _userId => _supabase.currentUserId;

  void _requireAuth() {
    if (_userId == null) throw const AuthRequiredException();
  }

  /// Suggestions triées par [rank] (max 3 affichées en UI).
  Future<List<SuggestionModel>> getSuggestionsForEvent(String eventId) async {
    _requireAuth();

    try {
      final rows = await _supabase.client
          .from(_suggestionsTable)
          .select()
          .eq('event_id', eventId)
          .order('rank');

      final suggestions = (rows as List)
          .map((row) => SuggestionModel.fromJson(Map<String, dynamic>.from(row)))
          .toList();

      final withPhotos = <SuggestionModel>[];
      for (final suggestion in suggestions) {
        final photoUrl = await _photoService.fetchPhotoUrl(suggestion.placeId);
        withPhotos.add(suggestion.copyWith(photoUrl: photoUrl));
      }

      return withPhotos;
    } on PostgrestException catch (e) {
      throw DataSourceException(e.message, cause: e);
    }
  }

  /// Vérifie si l'utilisateur connecté est le créateur de l'événement.
  Future<bool> isCurrentUserCreator(String eventId) async {
    _requireAuth();
    final userId = _userId!;

    try {
      final event = await _supabase.client
          .from(_eventsTable)
          .select('creator_id')
          .eq('id', eventId)
          .maybeSingle();

      if (event != null && event['creator_id'] == userId) return true;

      final member = await _supabase.client
          .from(_membersTable)
          .select('role')
          .eq('event_id', eventId)
          .eq('user_id', userId)
          .maybeSingle();

      return member?['role'] == MemberRole.creator.toJson();
    } on PostgrestException catch (e) {
      throw DataSourceException(e.message, cause: e);
    }
  }

  /// Sélectionne le lieu final : met à jour `events` + marque la suggestion.
  Future<EventModel> selectFinalPlace({
    required String eventId,
    required SuggestionModel suggestion,
  }) async {
    _requireAuth();

    final isCreator = await isCurrentUserCreator(eventId);
    if (!isCreator) {
      throw const DataSourceException(
        'Seul le créateur peut sélectionner le lieu final.',
      );
    }

    if (suggestion.placeLocation == null) {
      throw const DataSourceException(
        'Cette suggestion n\'a pas de coordonnées GPS.',
      );
    }

    try {
      final location = suggestion.placeLocation!;

      await _supabase.client.from(_eventsTable).update({
        'final_place_id': suggestion.placeId,
        'final_place_name': suggestion.placeName,
        'final_place_address': suggestion.placeAddress,
        'final_place_location': location.toJson(),
        'status': EventStatus.decided.toJson(),
      }).eq('id', eventId);

      await _supabase.client
          .from(_suggestionsTable)
          .update({'is_selected': false})
          .eq('event_id', eventId);

      await _supabase.client
          .from(_suggestionsTable)
          .update({'is_selected': true})
          .eq('id', suggestion.id);

      final eventRow = await _supabase.client
          .from(_eventsTable)
          .select()
          .eq('id', eventId)
          .single();

      return EventModel.fromJson(Map<String, dynamic>.from(eventRow));
    } on PostgrestException catch (e) {
      throw DataSourceException(e.message, cause: e);
    }
  }
}
