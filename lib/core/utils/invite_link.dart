/// Génération et parsing des liens d'invitation Wh3re.
abstract final class InviteLink {
  static const String baseUrl = 'https://wh3re.app';

  /// Lien Universal / App Link pour rejoindre un événement.
  static String joinUrl(String inviteToken) => '$baseUrl/join/$inviteToken';

  /// Extrait le token depuis une URI `https://wh3re.app/join/:token`.
  static String? parseTokenFromUri(Uri uri) {
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
}
