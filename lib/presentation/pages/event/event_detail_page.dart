import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wh3re/core/constants/app_colors.dart';
import 'package:wh3re/models/event_model.dart';
import 'package:wh3re/providers/poll_provider.dart';
import 'package:wh3re/repositories/repository_providers.dart';
import 'package:wh3re/presentation/widgets/shimmer_loader.dart';

class EventDetailPage extends ConsumerWidget {
  const EventDetailPage({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventFuture = ref.watch(_eventProvider(eventId));
    final responseStatus = ref.watch(memberResponseStatusProvider(eventId));

    return eventFuture.when(
      loading: () => const Scaffold(
        body: ShimmerLoader(itemCount: 1),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Erreur : $error')),
      ),
      data: (event) {
        if (event == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Événement introuvable')),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Hero(
              tag: 'event_${event.id}',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  event.name,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded),
                tooltip: 'Inviter',
                onPressed: () => context.push('/events/${event.id}/invite'),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              responseStatus.when(
                loading: () => const _ResponseStatusCard.loading(),
                error: (_, __) => const SizedBox.shrink(),
                data: (status) => _ResponseStatusCard(
                  hasResponded: status.hasResponded,
                  onVote: () => context.push('/events/$eventId/poll'),
                ),
              ),
              const SizedBox(height: 20),
              if (event.description != null) ...[
                Text(
                  event.description!,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (event.ambiance != null)
                _InfoRow(
                  icon: Icons.mood_rounded,
                  label: 'Ambiance',
                  value: event.ambiance!,
                ),
              _InfoRow(
                icon: Icons.flag_rounded,
                label: 'Événement',
                value: _statusLabel(event.status),
              ),
              const SizedBox(height: 24),
              _SuggestionsCta(
                eventId: eventId,
                status: event.status,
                hasFinalPlace: event.finalPlaceName != null,
              ),
            ],
          ),
        );
      },
    );
  }

  String _statusLabel(EventStatus status) => switch (status) {
        EventStatus.draft => 'Brouillon',
        EventStatus.polling => 'Sondage en cours',
        EventStatus.decided => 'Lieu décidé',
        EventStatus.archived => 'Archivé',
      };
}

final _eventProvider = FutureProvider.family<EventModel?, String>((ref, id) {
  return ref.watch(eventRepositoryProvider).getEventById(id);
});

class _ResponseStatusCard extends StatelessWidget {
  const _ResponseStatusCard({
    required this.hasResponded,
    this.onVote,
    this.isLoading = false,
  });

  const _ResponseStatusCard.loading()
      : hasResponded = false,
        onVote = null,
        isLoading = true;

  final bool hasResponded;
  final VoidCallback? onVote;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppColors.radiusCard),
        ),
      );
    }

    if (hasResponded) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(AppColors.radiusCard),
          border: Border.all(color: AppColors.success.withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statut : A répondu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Vos préférences ont bien été prises en compte.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.poll_rounded, color: AppColors.primary, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Statut : En attente de votre avis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onVote,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppColors.radiusCard),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Répondre au sondage',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionsCta extends StatelessWidget {
  const _SuggestionsCta({
    required this.eventId,
    required this.status,
    required this.hasFinalPlace,
  });

  final String eventId;
  final EventStatus status;
  final bool hasFinalPlace;

  @override
  Widget build(BuildContext context) {
    if (hasFinalPlace || status == EventStatus.decided) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(AppColors.radiusCard),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.primary),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Lieu final choisi — consultez les détails dans Suggestions.',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => context.push('/events/$eventId/suggestions'),
        icon: const Icon(Icons.map_rounded, color: AppColors.primary),
        label: const Text(
          'Voir les suggestions de lieux',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.radiusCard),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Text(
            '$label : ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
