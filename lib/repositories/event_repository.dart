import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wh3re/core/errors/repository_exception.dart';
import 'package:wh3re/models/event_model.dart';
import 'package:wh3re/models/member_model.dart';
import 'package:wh3re/models/question_model.dart';
import 'package:wh3re/models/response_model.dart';
import 'package:wh3re/models/suggestion_model.dart';
import 'package:wh3re/repositories/suggestions_repository.dart';
import 'package:wh3re/services/supabase_service.dart';

/// Accès données événements, membres et réponses.
class EventRepository {
  EventRepository({
    SupabaseService? supabase,
    SuggestionsRepository? suggestionsRepository,
  })  : _supabase = supabase ?? SupabaseService.instance,
        _suggestions = suggestionsRepository ?? SuggestionsRepository();

  final SupabaseService _supabase;
  final SuggestionsRepository _suggestions;

  static const _eventsTable = 'events';
  static const _membersTable = 'event_members';
  static const _responsesTable = 'responses';
  static const _questionsTable = 'questions_template';

  String? get _userId => _supabase.currentUserId;

  void _requireAuth() {
    if (_userId == null) throw const AuthRequiredException();
  }

  /// Crée un événement — `invite_token` généré côté Supabase.
  Future<EventModel> createEvent({
    required String name,
    String? description,
    String? ambiance,
    EventStatus status = EventStatus.draft,
  }) async {
    _requireAuth();

    try {
      final data = await _supabase.client
          .from(_eventsTable)
          .insert({
            'creator_id': _userId,
            'name': name,
            if (description != null) 'description': description,
            if (ambiance != null) 'ambiance': ambiance,
            'status': status.toJson(),
          })
          .select()
          .single();

      final event = EventModel.fromJson(Map<String, dynamic>.from(data));

      await _insertDefaultQuestions(event.id);
      await _ensureCreatorMembership(event.id);

      return event;
    } on PostgrestException catch (e) {
      throw DataSourceException(e.message, cause: e);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw DataSourceException('Impossible de créer l\'événement.', cause: e);
    }
  }

  Future<void> _insertDefaultQuestions(String eventId) async {
    final payload = defaultQuestionsPayload()
        .map((q) => {...q, 'event_id': eventId})
        .toList();

    await _supabase.client.from(_questionsTable).insert(payload);
  }

  Future<void> _ensureCreatorMembership(String eventId) async {
    final userId = _userId;
    if (userId == null) return;

    await _supabase.client.from(_membersTable).upsert(
      {
        'event_id': eventId,
        'user_id': userId,
        'role': MemberRole.creator.toJson(),
      },
      onConflict: 'event_id,user_id',
    );
  }

  /// Questions du sondage triées par [sort_order].
  Future<List<QuestionModel>> getQuestionsForEvent(String eventId) async {
    _requireAuth();

    try {
      final rows = await _supabase.client
          .from(_questionsTable)
          .select()
          .eq('event_id', eventId)
          .order('sort_order');

      return (rows as List)
          .map((row) => QuestionModel.fromJson(Map<String, dynamic>.from(row)))
          .toList();
    } on PostgrestException catch (e) {
      throw DataSourceException(e.message, cause: e);
    }
  }

  /// Réponse existante de l'utilisateur connecté.
  Future<ResponseModel?> getUserResponseForEvent(String eventId) async {
    _requireAuth();
    final userId = _userId!;

    try {
      final data = await _supabase.client
          .from(_responsesTable)
          .select()
          .eq('event_id', eventId)
          .eq('user_id', userId)
          .maybeSingle();

      if (data == null) return null;
      return ResponseModel.fromJson(Map<String, dynamic>.from(data));
    } on PostgrestException catch (e) {
      throw DataSourceException(e.message, cause: e);
    }
  }

  /// `has_responded` sur `event_members` — mis à jour par trigger SQL.
  Future<bool> hasUserResponded(String eventId) async {
    _requireAuth();
    final userId = _userId!;

    try {
      final data = await _supabase.client
          .from(_membersTable)
          .select('has_responded')
          .eq('event_id', eventId)
          .eq('user_id', userId)
          .maybeSingle();

      if (data == null) return false;
      return data['has_responded'] as bool? ?? false;
    } on PostgrestException catch (e) {
      throw DataSourceException(e.message, cause: e);
    }
  }

  /// Flux temps réel — recharge à chaque changement sur `events` ou `event_members`.
  Stream<List<EventModel>> watchEventsForUser() async* {
    _requireAuth();
    final userId = _userId!;

    yield await getEventsForUser();

    final controller = StreamController<List<EventModel>>();
    RealtimeChannel? channel;

    void emitLatest() {
      getEventsForUser().then(
        controller.add,
        onError: controller.addError,
      );
    }

    channel = _supabase.client
        .channel('user_events_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: _eventsTable,
          callback: (_) => emitLatest(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: _membersTable,
          callback: (_) => emitLatest(),
        )
        .subscribe();

    try {
      yield* controller.stream;
    } finally {
      await channel.unsubscribe();
      await controller.close();
    }
  }

  /// Événements dont l'utilisateur est créateur ou membre.
  Future<List<EventModel>> getEventsForUser() async {
    _requireAuth();
    final userId = _userId!;

    try {
      final createdRows = await _supabase.client
          .from(_eventsTable)
          .select()
          .eq('creator_id', userId);

      final memberRows = await _supabase.client
          .from(_membersTable)
          .select('event_id')
          .eq('user_id', userId);

      final memberEventIds = (memberRows as List)
          .map((row) => (row as Map<String, dynamic>)['event_id'] as String)
          .toSet();

      final eventsById = <String, EventModel>{};

      for (final row in createdRows as List) {
        final event = EventModel.fromJson(Map<String, dynamic>.from(row));
        eventsById[event.id] = event;
      }

      if (memberEventIds.isNotEmpty) {
        final invitedRows = await _supabase.client
            .from(_eventsTable)
            .select()
            .inFilter('id', memberEventIds.toList());

        for (final row in invitedRows as List) {
          final event = EventModel.fromJson(Map<String, dynamic>.from(row));
          eventsById[event.id] = event;
        }
      }

      final events = eventsById.values.toList()
        ..sort((a, b) {
          final aDate = a.updatedAt ?? a.createdAt ?? DateTime(1970);
          final bDate = b.updatedAt ?? b.createdAt ?? DateTime(1970);
          return bDate.compareTo(aDate);
        });

      return events;
    } on PostgrestException catch (e) {
      throw DataSourceException(e.message, cause: e);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw DataSourceException(
        'Impossible de charger vos événements.',
        cause: e,
      );
    }
  }

  /// Rejoint un événement via son `invite_token`.
  /// Retourne l'événement rejoint (sans modifier `has_responded` manuellement).
  Future<EventModel> joinEventByToken(String token) async {
    _requireAuth();
    final userId = _userId!;

    try {
      final eventRow = await _supabase.client
          .from(_eventsTable)
          .select()
          .eq('invite_token', token)
          .maybeSingle();

      if (eventRow == null) throw const EventNotFoundException();

      final event = EventModel.fromJson(Map<String, dynamic>.from(eventRow));

      if (event.creatorId == userId) return event;

      final existingMember = await _supabase.client
          .from(_membersTable)
          .select('id')
          .eq('event_id', event.id)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingMember != null) return event;

      await _supabase.client.from(_membersTable).insert({
        'event_id': event.id,
        'user_id': userId,
        'role': MemberRole.guest.toJson(),
      });

      return event;
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        final eventRow = await _supabase.client
            .from(_eventsTable)
            .select()
            .eq('invite_token', token)
            .maybeSingle();
        if (eventRow != null) {
          return EventModel.fromJson(Map<String, dynamic>.from(eventRow));
        }
      }
      throw DataSourceException(e.message, cause: e);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw DataSourceException(
        'Impossible de rejoindre l\'événement.',
        cause: e,
      );
    }
  }

  /// Soumet ou met à jour une réponse — `has_responded` mis à jour par trigger SQL.
  ///
  /// Format JSONB attendu :
  /// `{ "question_id": { "value": "...", "weight": "wished|indifferent|redhibitory" } }`
  Future<ResponseModel> submitResponse({
    required String eventId,
    required Map<String, AnswerEntry> answers,
  }) async {
    _requireAuth();
    final userId = _userId!;

    try {
      final answersJson = <String, dynamic>{};
      for (final entry in answers.entries) {
        answersJson[entry.key] = entry.value.toJson();
      }

      final data = await _supabase.client.from(_responsesTable).upsert(
        {
          'event_id': eventId,
          'user_id': userId,
          'answers': answersJson,
        },
        onConflict: 'event_id,user_id',
      ).select().single();

      return ResponseModel.fromJson(Map<String, dynamic>.from(data));
    } on PostgrestException catch (e) {
      throw DataSourceException(e.message, cause: e);
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw DataSourceException(
        'Impossible d\'enregistrer votre réponse.',
        cause: e,
      );
    }
  }

  /// Suggestions finales avec coordonnées GPS et photos Places.
  Future<List<SuggestionModel>> getSuggestionsForEvent(String eventId) =>
      _suggestions.getSuggestionsForEvent(eventId);

  /// Le créateur sélectionne le lieu → `events.status = decided`.
  Future<EventModel> selectFinalPlace({
    required String eventId,
    required SuggestionModel suggestion,
  }) =>
      _suggestions.selectFinalPlace(
        eventId: eventId,
        suggestion: suggestion,
      );

  Future<bool> isCurrentUserCreator(String eventId) =>
      _suggestions.isCurrentUserCreator(eventId);

  Future<EventModel?> getEventById(String eventId) async {
    _requireAuth();

    try {
      final data = await _supabase.client
          .from(_eventsTable)
          .select()
          .eq('id', eventId)
          .maybeSingle();

      if (data == null) return null;
      return EventModel.fromJson(Map<String, dynamic>.from(data));
    } on PostgrestException catch (e) {
      throw DataSourceException(e.message, cause: e);
    }
  }
}
