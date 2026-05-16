import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wh3re/models/event_model.dart';
import 'package:wh3re/providers/events_provider.dart';

void main() {
  group('DashboardTab filtering', () {
    test('creations vs invitations split by creatorId', () {
      const userId = 'user-1';
      final events = [
        const EventModel(id: '1', creatorId: userId, name: 'Mine'),
        const EventModel(id: '2', creatorId: 'other', name: 'Invite'),
      ];

      final creations = events.where((e) => e.creatorId == userId).toList();
      final invitations = events.where((e) => e.creatorId != userId).toList();

      expect(creations, hasLength(1));
      expect(creations.first.name, 'Mine');
      expect(invitations, hasLength(1));
      expect(invitations.first.name, 'Invite');
    });
  });

  group('dashboardTabProvider', () {
    test('defaults to creations', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(dashboardTabProvider), DashboardTab.creations);
    });
  });
}
