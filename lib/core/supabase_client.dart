import 'package:supabase_flutter/supabase_flutter.dart';

/// Point d'entrée unique pour l'initialisation et l'accès au client Supabase.
abstract final class SupabaseClientManager {
  static bool _initialized = false;

  /// Initialise le SDK Supabase (à appeler une seule fois au démarrage).
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    if (_initialized) return;

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    _initialized = true;
  }

  /// Client Supabase actif après [initialize].
  static SupabaseClient get client {
    if (!_initialized) {
      throw StateError(
        'Supabase non initialisé. Appelez SupabaseClientManager.initialize() '
        'dans main() avant tout accès.',
      );
    }
    return Supabase.instance.client;
  }

  /// Session utilisateur courante (null si déconnecté).
  static Session? get currentSession => client.auth.currentSession;

  /// Identifiant de l'utilisateur connecté.
  static String? get currentUserId => currentSession?.user.id;
}
