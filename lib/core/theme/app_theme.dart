import 'package:flutter/material.dart';
import 'package:burning2026/core/theme/app_colors.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryColor = Color(0xFFE11D48);
  static const Color secondaryColor = Color(0xFFF59E0B);
  static const Color accentColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF5350);
  static const Color warningColor = Color(0xFFFFA726);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color criticalColor = Color(0xFFB71C1C);

  static ThemeData get lightTheme {
    return _baseTheme(Brightness.light, AppColors.light);
  }

  static ThemeData get darkTheme {
    return _baseTheme(Brightness.dark, AppColors.dark);
  }

  static ThemeData _baseTheme(Brightness brightness, AppColors colors) {
    final isLight = brightness == Brightness.light;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        error: errorColor,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: colors.surface,
      extensions: [colors],
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: colors.card,
        elevation: isLight ? 2 : 1,
        shadowColor: isLight ? null : Colors.black38,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isLight
            ? const Color(0xFFE5E7EB)
            : const Color(0xFF334155),
        thickness: 1,
        space: 1,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: colors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: colors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: colors.textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          color: colors.textLight,
        ),
      ),
    );
  }
}
