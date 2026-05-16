import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wh3re/core/constants/app_colors.dart';

void main() {
  group('AppColors', () {
    test('primary brand color is #6A0DAD', () {
      expect(AppColors.primary, const Color(0xFF6A0DAD));
    });

    test('background is white', () {
      expect(AppColors.background, const Color(0xFFFFFFFF));
    });

    test('radius tokens respect design system', () {
      expect(AppColors.radiusCard, greaterThanOrEqualTo(24));
      expect(AppColors.radiusInput, greaterThanOrEqualTo(16));
    });

    test('colorScheme uses primary as brand color', () {
      expect(AppColors.colorScheme.primary, AppColors.primary);
    });

    test('theme scaffold background is white', () {
      expect(AppColors.theme.scaffoldBackgroundColor, AppColors.scaffold);
    });
  });
}
