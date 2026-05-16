import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wh3re/models/event_model.dart';
import 'package:wh3re/providers/auth_provider.dart';
import 'package:wh3re/repositories/repository_providers.dart';

/// Onglet actif du dashboard.
enum DashboardTab {
  creations,
  invitations,
}

/// Onglet sélectionné sur le dashboard.
final dashboardTabProvider =
    StateProvider<DashboardTab>((ref) => DashboardTab.creations);

/// Liste temps réel de tous les événements accessibles à l'utilisateur.
final userEventsStreamProvider = StreamProvider<List<EventModel>>((ref) {
  final userId = ref.watch(currentUserProvider)?.id;
  if (userId == null) return const Stream.empty();

  final repository = ref.watch(eventRepositoryProvider);
  return repository.watchEventsForUser();
});

/// Événements créés par l'utilisateur connecté.
final createdEventsProvider = Provider<AsyncValue<List<EventModel>>>((ref) {
  final userId = ref.watch(currentUserProvider)?.id;
  final eventsAsync = ref.watch(userEventsStreamProvider);

  return eventsAsync.whenData((events) {
    if (userId == null) return <EventModel>[];
    return events.where((e) => e.creatorId == userId).toList();
  });
});

/// Événements où l'utilisateur est invité (membre, non créateur).
final invitedEventsProvider = Provider<AsyncValue<List<EventModel>>>((ref) {
  final userId = ref.watch(currentUserProvider)?.id;
  final eventsAsync = ref.watch(userEventsStreamProvider);

  return eventsAsync.whenData((events) {
    if (userId == null) return <EventModel>[];
    return events.where((e) => e.creatorId != userId).toList();
  });
});

/// Liste filtrée selon l'onglet actif du dashboard.
final dashboardEventsProvider = Provider<AsyncValue<List<EventModel>>>((ref) {
  final tab = ref.watch(dashboardTabProvider);
  return tab == DashboardTab.creations
      ? ref.watch(createdEventsProvider)
      : ref.watch(invitedEventsProvider);
});
