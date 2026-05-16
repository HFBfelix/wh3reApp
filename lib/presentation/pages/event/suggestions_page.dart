import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wh3re/core/constants/app_colors.dart';
import 'package:wh3re/core/errors/repository_exception.dart';
import 'package:wh3re/core/utils/haptics.dart';
import 'package:wh3re/models/suggestion_model.dart';
import 'package:wh3re/providers/suggestions_provider.dart';
import 'package:wh3re/presentation/widgets/shimmer_loader.dart';
import 'package:wh3re/presentation/widgets/suggestion_card.dart';
import 'package:wh3re/presentation/widgets/suggestions_map.dart';

/// Vue des 3 suggestions IA + carte + décision créateur.
class SuggestionsPage extends ConsumerStatefulWidget {
  const SuggestionsPage({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<SuggestionsPage> createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends ConsumerState<SuggestionsPage> {
  String? _selectingSuggestionId;

  Future<void> _onSelect(SuggestionModel suggestion) async {
    await Wh3reHaptics.mediumImpact();
    setState(() => _selectingSuggestionId = suggestion.id);

    final event = await ref
        .read(selectPlaceControllerProvider(widget.eventId).notifier)
        .selectPlace(suggestion);

    if (!mounted) return;
    setState(() => _selectingSuggestionId = null);

    if (event != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('« ${suggestion.placeName} » est le lieu retenu !'),
        ),
      );
      context.go('/events/${widget.eventId}');
    } else {
      final error = ref.read(selectPlaceControllerProvider(widget.eventId)).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is RepositoryException
                ? error.message
                : 'Impossible de valider ce lieu.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final suggestionsAsync =
        ref.watch(eventSuggestionsProvider(widget.eventId));
    final isCreatorAsync = ref.watch(isEventCreatorProvider(widget.eventId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Suggestions du groupe'),
      ),
      body: suggestionsAsync.when(
        loading: () => const ShimmerLoader(itemCount: 3),
        error: (error, _) => _SuggestionsError(
          message: error is RepositoryException
              ? error.message
              : 'Impossible de charger les suggestions.',
          onRetry: () =>
              ref.invalidate(eventSuggestionsProvider(widget.eventId)),
        ),
        data: (suggestions) {
          if (suggestions.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Aucune suggestion disponible pour le moment.\n'
                  'Le moteur IA les génèrera après les votes.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            );
          }

          final topThree = suggestions.take(3).toList();
          final isCreator = isCreatorAsync.valueOrNull ?? false;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Les 3 lieux recommandés',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isCreator
                            ? 'Choisissez le lieu qui fera l\'unanimité.'
                            : 'Le créateur validera le lieu final.',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SuggestionsMap(suggestions: topThree),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final suggestion = topThree[index];
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        index == topThree.length - 1 ? 24 : 16,
                      ),
                      child: SuggestionCard(
                        suggestion: suggestion,
                        showSelectButton: isCreator,
                        isSelecting: _selectingSuggestionId == suggestion.id,
                        onSelect: () => _onSelect(suggestion),
                      ),
                    );
                  },
                  childCount: topThree.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SuggestionsError extends StatelessWidget {
  const _SuggestionsError({
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
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
