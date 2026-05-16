import 'package:flutter/services.dart';

/// Wrapper centralisé pour le feedback haptique Wh3re.
abstract final class Wh3reHaptics {
  static Future<void> lightImpact() => HapticFeedback.lightImpact();

  static Future<void> selectionClick() => HapticFeedback.selectionClick();

  static Future<void> mediumImpact() => HapticFeedback.mediumImpact();
}
