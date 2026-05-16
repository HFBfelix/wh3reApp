import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wh3re/core/constants/app_colors.dart';
import 'package:wh3re/core/errors/repository_exception.dart';
import 'package:wh3re/models/event_model.dart';
import 'package:wh3re/providers/auth_provider.dart';
import 'package:wh3re/providers/events_provider.dart';
import 'package:wh3re/presentation/widgets/event_card.dart';
import 'package:wh3re/presentation/widgets/shimmer_loader.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(dashboardTabProvider);
    final eventsAsync = ref.watch(dashboardEventsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Wh3re'),
        actions: [
          IconButton(
            tooltip: 'Déconnexion',
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/events/create'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Créer'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          _DashboardToggle(
            selected: tab,
            onChanged: (value) =>
                ref.read(dashboardTabProvider.notifier).state = value,
          ),
          Expanded(
            child: eventsAsync.when(
              loading: () => const ShimmerLoader(),
              error: (error, _) => _ErrorState(
                message: error is RepositoryException
                    ? error.message
                    : 'Impossible de charger les événements.',
                onRetry: () => ref.invalidate(userEventsStreamProvider),
              ),
              data: (events) => _EventsList(
                events: events,
                isCreationsTab: tab == DashboardTab.creations,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardToggle extends StatelessWidget {
  const _DashboardToggle({
    required this.selected,
    required this.onChanged,
  });

  final DashboardTab selected;
  final ValueChanged<DashboardTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppColors.radiusCard),
        ),
        child: Row(
          children: [
            Expanded(
              child: _ToggleButton(
                label: 'Mes Créations',
                isSelected: selected == DashboardTab.creations,
                onTap: () => onChanged(DashboardTab.creations),
              ),
            ),
            Expanded(
              child: _ToggleButton(
                label: 'Mes Invitations',
                isSelected: selected == DashboardTab.invitations,
                onTap: () => onChanged(DashboardTab.invitations),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppColors.radiusCard - 4),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _EventsList extends ConsumerWidget {
  const _EventsList({
    required this.events,
    required this.isCreationsTab,
  });

  final List<EventModel> events;
  final bool isCreationsTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCreationsTab
                    ? Icons.celebration_outlined
                    : Icons.inbox_outlined,
                size: 56,
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                isCreationsTab
                    ? 'Aucun événement créé'
                    : 'Aucune invitation',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isCreationsTab
                    ? 'Appuyez sur Créer pour lancer votre premier événement.'
                    : 'Les événements auxquels vous êtes invité apparaîtront ici.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final userId = ref.watch(currentUserProvider)?.id;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = events[index];
        return EventCard(
          event: event,
          isCreator: event.creatorId == userId,
          onTap: () => context.push('/events/${event.id}'),
        );
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppColors.radiusCard),
                ),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
