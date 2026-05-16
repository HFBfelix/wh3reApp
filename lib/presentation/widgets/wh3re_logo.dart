import 'package:flutter/material.dart';
import 'package:wh3re/core/constants/app_colors.dart';

/// Logo Wh3re affiché sur les écrans d'authentification.
class Wh3reLogo extends StatelessWidget {
  const Wh3reLogo({
    super.key,
    this.size = 96,
  });

  final double size;

  static const String assetPath = 'assets/images/logo.png';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppColors.radiusCard),
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _FallbackLogo(size: size),
      ),
    );
  }
}

class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppColors.radiusCard),
      ),
      child: const Icon(
        Icons.place_rounded,
        color: AppColors.primary,
        size: 48,
      ),
    );
  }
}
