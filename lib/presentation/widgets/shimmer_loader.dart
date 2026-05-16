import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wh3re/core/constants/app_colors.dart';

/// Placeholder animé pendant le chargement (pattern loading / error / data).
class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({
    super.key,
    this.itemCount = 3,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.shimmerBase,
            borderRadius: BorderRadius.circular(AppColors.radiusCard),
          ),
        ),
      ),
    );
  }
}
