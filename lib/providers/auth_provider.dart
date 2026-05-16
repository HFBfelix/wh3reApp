import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wh3re/core/errors/repository_exception.dart';
import 'package:wh3re/repositories/auth_repository.dart';
import 'package:wh3re/repositories/repository_providers.dart';
import 'package:wh3re/providers/deep_link_provider.dart';
import 'package:wh3re/services/deep_link_service.dart';

/// Flux d'état Supabase Auth (`onAuthStateChange`).
final authStateProvider = StreamProvider<AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

/// Utilisateur connecté (null si déconnecté).
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull?.session?.user;
});

/// Session active.
final currentSessionProvider = Provider<Session?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull?.session;
});

/// Indique si l'utilisateur est authentifié.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentSessionProvider) != null;
});

/// Notifie GoRouter lors d'un changement de session (redirect automatique).
final authRouterRefreshProvider = Provider<AuthRouterRefresh>((ref) {
  final refresh = AuthRouterRefresh(ref);
  ref.onDispose(refresh.dispose);
  return refresh;
});

/// Écoute les changements Auth et déclenche [notifyListeners] pour GoRouter.
final class AuthRouterRefresh extends ChangeNotifier {
  AuthRouterRefresh(Ref ref) {
    _subscription = ref
        .read(authRepositoryProvider)
        .authStateChanges
        .listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}

/// Actions d'authentification (connexion, inscription, déconnexion).
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  AuthRepository get _repository => _ref.read(authRepositoryProvider);

  DeepLinkService get _deepLinks => _ref.read(deepLinkServiceProvider);

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.signIn(email: email, password: password);
      await _deepLinks.consumePendingJoinToken();
    });
  }

  /// [firstName] → metadata `first_name` pour le trigger SQL `handle_new_user`.
  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.signUp(
        email: email,
        password: password,
        firstName: firstName.trim(),
      );
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.signOut);
  }

  Future<void> resetPassword({required String email}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.resetPassword(email: email),
    );
  }

  void clearError() {
    if (state.hasError) state = const AsyncData(null);
  }
}

/// Message d'erreur lisible pour l'UI.
String authErrorMessage(Object error) {
  if (error is DataSourceException) return error.message;
  if (error is AuthException) return error.message;
  return 'Une erreur est survenue. Réessayez.';
}
