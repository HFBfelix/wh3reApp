export class AppError extends Error {
  constructor(message: string, public readonly cause?: unknown) {
    super(message);
    this.name = 'AppError';
  }
}

export class AuthRequiredError extends AppError {
  constructor(message = 'Connexion requise.') {
    super(message);
    this.name = 'AuthRequiredError';
  }
}

export class EventNotFoundError extends AppError {
  constructor(message = 'Événement introuvable.') {
    super(message);
    this.name = 'EventNotFoundError';
  }
}

export function getErrorMessage(error: unknown): string {
  if (error instanceof AppError) return error.message;
  if (error instanceof Error) return error.message;
  return 'Une erreur est survenue. Réessayez.';
}
