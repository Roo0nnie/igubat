import 'package:flutter/material.dart';
import 'glass_tokens.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0F3D26);
  static const Color secondaryColor = Color(0xFF7DB343);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final glass = isDark ? GlassTheme.dark : GlassTheme.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: isDark ? const Color(0xFF0A1F14) : backgroundColor,
        onSurface: isDark ? const Color(0xFFF1F5F9) : textPrimary,
        brightness: brightness,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : primaryColor,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF142818) : cardColor,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GlassTokens.radiusGlassSm),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: isDark ? Colors.white : textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 28,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          color: isDark ? Colors.white : textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 24,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          color: isDark ? Colors.white : textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 20,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          color: isDark ? Colors.white : textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          color: isDark ? const Color(0xFFE2E8F0) : textPrimary,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: isDark ? const Color(0xFF94A3B8) : textSecondary,
          fontSize: 15,
          height: 1.5,
        ),
        labelSmall: TextStyle(
          color: isDark ? const Color(0xFF94A3B8) : textSecondary,
          fontSize: 10,
          height: 1.3,
        ),
      ),
      extensions: [glass],
    );
  }
}
