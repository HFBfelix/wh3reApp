/// Erreur métier remontée par la couche [lib/repositories].
sealed class RepositoryException implements Exception {
  const RepositoryException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'RepositoryException: $message';
}

/// Aucune session Supabase Auth active.
final class AuthRequiredException extends RepositoryException {
  const AuthRequiredException([
    super.message = 'Connexion requise pour effectuer cette action.',
  ]);
}

/// Événement introuvable (token invalide ou supprimé).
final class EventNotFoundException extends RepositoryException {
  const EventNotFoundException([
    super.message = 'Événement introuvable pour ce lien d\'invitation.',
  ]);
}

/// L'utilisateur est déjà membre de l'événement.
final class AlreadyMemberException extends RepositoryException {
  const AlreadyMemberException([
    super.message = 'Vous participez déjà à cet événement.',
  ]);
}

/// Erreur générique Supabase / réseau.
final class DataSourceException extends RepositoryException {
  const DataSourceException(super.message, {super.cause});
}
