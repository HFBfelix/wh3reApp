import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wh3re/core/supabase_client.dart';

/// Singleton d'accès aux services Supabase pour toute l'application.
final class SupabaseService {
  SupabaseService._();

  static final SupabaseService instance = SupabaseService._();

  SupabaseClient get client => SupabaseClientManager.client;

  GoTrueClient get auth => client.auth;

  User? get currentUser => auth.currentUser;

  String? get currentUserId => currentUser?.id;

  bool get isAuthenticated => currentSession != null;

  Session? get currentSession => SupabaseClientManager.currentSession;
}
