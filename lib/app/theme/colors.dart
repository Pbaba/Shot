import 'package:flutter/material.dart';

/// Design tokens defining Shot's visual identity.
abstract class AppColors {
  /// Warm off-white background
  static const Color background = Color(0xFFF7F5F0);

  /// Surface card color (pure white with subtle warmth)
  static const Color surface = Color(0xFFFFFFFF);

  /// Near-black primary text
  static const Color textPrimary = Color(0xFF171717);

  /// Muted secondary text
  static const Color textSecondary = Color(0xFF6E6E6E);

  /// Subtle border lines
  static const Color border = Color(0xFFE5E2DC);

  /// Muted olive accent
  static const Color olive = Color(0xFF71816A);

  /// Dark olive for pressed / active states
  static const Color oliveDark = Color(0xFF566350);

  /// Restrained muted green for "KEEP" feedback
  static const Color keepGreen = Color(0xFF5E7D63);

  /// Restrained muted red for "DELETE" feedback
  static const Color deleteRed = Color(0xFFA65B53);

  /// Light tint for keep background badges
  static const Color keepTint = Color(0xFFEAF1EC);

  /// Light tint for delete background badges
  static const Color deleteTint = Color(0xFFF7ECEB);
}
