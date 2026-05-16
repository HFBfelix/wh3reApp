import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wh3re/core/constants/app_colors.dart';
import 'package:wh3re/presentation/widgets/wh3re_logo.dart';

/// Layout immersif partagé par login / register / forgot-password.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showLogo = true,
    this.footer,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool showLogo;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showLogo) ...[
                const SizedBox(height: 24),
                const Center(child: Wh3reLogo(size: 88)),
                const SizedBox(height: 32),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppColors.radiusCard),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: AppColors.blurSigmaX,
                    sigmaY: AppColors.blurSigmaY,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.glassBackground,
                      borderRadius:
                          BorderRadius.circular(AppColors.radiusCard),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: child,
                  ),
                ),
              ),
              if (footer != null) ...[
                const SizedBox(height: 24),
                footer!,
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
