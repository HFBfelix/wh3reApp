import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// Callback : rejoint l'événement via token et retourne l'`eventId`.
typedef JoinEventHandler = Future<String> Function(String token);

/// Gestion des Universal Links (iOS) et App Links (Android) via [AppLinks].
///
/// Format : `https://wh3re.app/join/:token` → `joinEventByToken` → `/events/:eventId`.
class DeepLinkService {
  DeepLinkService({AppLinks? appLinks}) : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;
  GoRouter? _router;
  StreamSubscription<Uri>? _subscription;
  JoinEventHandler? _joinHandler;

  /// Token d'invitation en attente (utilisateur non connecté).
  String? _pendingJoinToken;

  String? get pendingJoinToken => _pendingJoinToken;

  void attachRouter(GoRouter router) {
    _router = router;
  }

  /// Branche le repository — appelé depuis [goRouterProvider].
  void setJoinHandler(JoinEventHandler handler) {
    _joinHandler = handler;
  }

  /// À appeler dans [main] **avant** [runApp].
  Future<void> init() async {
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _pendingUri = initialUri;
    }

    await _subscription?.cancel();
    _subscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (Object error) {
        debugPrint('DeepLinkService: erreur stream — $error');
      },
    );
  }

  Uri? _pendingUri;

  void consumePendingLink() {
    final uri = _pendingUri;
    if (uri == null) return;
    _pendingUri = null;
    unawaited(_handleUri(uri));
  }

  /// Consomme un token stocké après connexion (deep link reçu hors session).
  Future<void> consumePendingJoinToken() async {
    final token = _pendingJoinToken;
    if (token == null) return;
    _pendingJoinToken = null;
    await _processJoinToken(token);
  }

  void savePendingJoinToken(String token) {
    _pendingJoinToken = token;
  }

  Future<void> _handleUri(Uri uri) async {
    final token = extractJoinToken(uri);
    if (token != null) {
      await _processJoinToken(token);
      return;
    }

    final router = _router;
    final location = mapUriToGoRoute(uri);
    if (router != null && location != null) {
      router.go(location);
    } else if (location != null) {
      _pendingUri = uri;
    }
  }

  Future<void> _processJoinToken(String token) async {
    final router = _router;
    final handler = _joinHandler;

    if (handler == null) {
      _pendingJoinToken = token;
      router?.go('/join/$token');
      return;
    }

    try {
      final eventId = await handler(token);
      router?.go('/events/$eventId');
    } on Object catch (error) {
      debugPrint('DeepLinkService: échec join — $error');
      router?.go('/join/$token');
    }
  }

  /// Extrait le token depuis une URI Wh3re.
  @visibleForTesting
  static String? extractJoinToken(Uri uri) {
    final segments = uri.pathSegments;
    if (segments.length >= 2 && segments[0] == 'join') {
      final token = segments[1];
      return token.isEmpty ? null : token;
    }
    if (uri.path.startsWith('/join/')) {
      final token = uri.path.replaceFirst('/join/', '');
      return token.isEmpty ? null : token;
    }
    return null;
  }

  /// Convertit une URI Wh3re en chemin GoRouter interne (hors join traité à part).
  @visibleForTesting
  static String? mapUriToGoRoute(Uri uri) {
    if (extractJoinToken(uri) != null) return null;
    return uri.path.isNotEmpty ? uri.path : null;
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
