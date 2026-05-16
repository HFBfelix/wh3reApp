import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wh3re/core/errors/repository_exception.dart';
import 'package:wh3re/services/supabase_service.dart';

/// Authentification Supabase Auth — le profil est créé par le trigger `handle_new_user`.
class AuthRepository {
  AuthRepository({SupabaseService? supabase})
      : _supabase = supabase ?? SupabaseService.instance;

  final SupabaseService _supabase;

  GoTrueClient get _auth => _supabase.auth;

  User? get currentUser => _supabase.currentUser;

  bool get isAuthenticated => _supabase.isAuthenticated;

  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  /// Inscription email/mot de passe.
  /// [firstName] est transmis en metadata pour le trigger SQL `handle_new_user`.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String firstName,
  }) async {
    try {
      return await _auth.signUp(
        email: email,
        password: password,
        data: {'first_name': firstName},
      );
    } on AuthException catch (e) {
      throw DataSourceException(e.message, cause: e);
    } catch (e) {
      throw DataSourceException('Échec de l\'inscription.', cause: e);
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw DataSourceException(e.message, cause: e);
    } catch (e) {
      throw DataSourceException('Échec de la connexion.', cause: e);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on AuthException catch (e) {
      throw DataSourceException(e.message, cause: e);
    } catch (e) {
      throw DataSourceException('Échec de la déconnexion.', cause: e);
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw DataSourceException(e.message, cause: e);
    } catch (e) {
      throw DataSourceException(
        'Échec de l\'envoi de l\'email de réinitialisation.',
        cause: e,
      );
    }
  }
}
