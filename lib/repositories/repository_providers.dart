import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wh3re/repositories/auth_repository.dart';
import 'package:wh3re/repositories/event_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository();
});
