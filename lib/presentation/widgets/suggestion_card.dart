import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wh3re/core/constants/app_colors.dart';
import 'package:wh3re/models/suggestion_model.dart';
import 'package:wh3re/presentation/widgets/wh3re_primary_button.dart';

/// Carte élégante pour une suggestion de lieu.
class SuggestionCard extends StatelessWidget {
  const SuggestionCard({
    super.key,
    required this.suggestion,
    required this.showSelectButton,
    required this.onSelect,
    this.isSelecting = false,
  });

  final SuggestionModel suggestion;
  final bool showSelectButton;
  final VoidCallback? onSelect;
  final bool isSelecting;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
        border: Border.all(
          color: suggestion.isSelected
              ? AppColors.success
              : AppColors.border,
          width: suggestion.isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PhotoHeader(suggestion: suggestion),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        suggestion.placeName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (suggestion.matchScore != null)
                      _ScoreBadge(score: suggestion.matchScore!),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  suggestion.placeAddress,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                if (suggestion.latitude != null &&
                    suggestion.longitude != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'GPS : ${suggestion.latitude!.toStringAsFixed(5)}, '
                    '${suggestion.longitude!.toStringAsFixed(5)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
                if (suggestion.matchRationale != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    suggestion.matchRationale!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: AppColors.primary,
                    ),
                  ),
                ],
                if (suggestion.isSelected) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Lieu choisi par le groupe',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
                if (showSelectButton && !suggestion.isSelected) ...[
                  const SizedBox(height: 16),
                  Wh3rePrimaryButton(
                    label: 'Sélectionner ce lieu',
                    isLoading: isSelecting,
                    onPressed: onSelect,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoHeader extends StatelessWidget {
  const _PhotoHeader({required this.suggestion});

  final SuggestionModel suggestion;

  @override
  Widget build(BuildContext context) {
    final photoUrl = suggestion.photoUrl;

    return Stack(
      children: [
        SizedBox(
          height: 160,
          width: double.infinity,
          child: photoUrl != null
              ? CachedNetworkImage(
                  imageUrl: photoUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const _PhotoPlaceholder(),
                  errorWidget: (_, __, ___) => const _PhotoPlaceholder(),
                )
              : const _PhotoPlaceholder(),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(
              '${suggestion.rank}',
              style: const TextStyle(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primarySurface, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.place_rounded,
          size: 48,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});

  final double score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${score.toStringAsFixed(0)}%',
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
