import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color surface;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;
  final Color textLight;

  const AppColors({
    required this.surface,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.textLight,
  });

  static const light = AppColors(
    surface: Color(0xFFF8FAFC),
    card: Colors.white,
    textPrimary: Color(0xFF1A1A2E),
    textSecondary: Color(0xFF6B7280),
    textLight: Color(0xFF9CA3AF),
  );

  static const dark = AppColors(
    surface: Color(0xFF0F172A),
    card: Color(0xFF1E293B),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF94A3B8),
    textLight: Color(0xFF64748B),
  );

  @override
  AppColors copyWith({
    Color? surface,
    Color? card,
    Color? textPrimary,
    Color? textSecondary,
    Color? textLight,
  }) {
    return AppColors(
      surface: surface ?? this.surface,
      card: card ?? this.card,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textLight: textLight ?? this.textLight,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textLight: Color.lerp(textLight, other.textLight, t)!,
    );
  }
}

extension AppColorsExtension on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
