import 'package:flutter/material.dart';

enum GlassIntensity { subtle, medium, prominent }

@immutable
class GlassTheme extends ThemeExtension<GlassTheme> {
  const GlassTheme({
    required this.isDark,
    required this.surfaceLight,
    required this.surfaceMedium,
    required this.surfaceHeavy,
    required this.greenTint,
    required this.border,
    required this.emergencyTint,
    required this.gradientStart,
    required this.gradientMid,
    required this.gradientEnd,
    required this.navTint,
    required this.textOnGlass,
    required this.textOnGlassMuted,
  });

  final bool isDark;
  final Color surfaceLight;
  final Color surfaceMedium;
  final Color surfaceHeavy;
  final Color greenTint;
  final Color border;
  final Color emergencyTint;
  final Color gradientStart;
  final Color gradientMid;
  final Color gradientEnd;
  final Color navTint;
  final Color textOnGlass;
  final Color textOnGlassMuted;

  static const light = GlassTheme(
    isDark: false,
    surfaceLight: Color(0xB8FFFFFF),
    surfaceMedium: Color(0xCCFFFFFF),
    surfaceHeavy: Color(0xE0FFFFFF),
    greenTint: Color(0x8C0F3D26),
    border: Color(0x59FFFFFF),
    emergencyTint: Color(0x26B91C1C),
    gradientStart: Color(0xFFF0F4F8),
    gradientMid: Color(0xFFE8F5E9),
    gradientEnd: Color(0xFFDCEEE3),
    navTint: Color(0xE60F3D26),
    textOnGlass: Color(0xFF1E293B),
    textOnGlassMuted: Color(0xFF64748B),
  );

  static const dark = GlassTheme(
    isDark: true,
    surfaceLight: Color(0x1AFFFFFF),
    surfaceMedium: Color(0x26FFFFFF),
    surfaceHeavy: Color(0x33FFFFFF),
    greenTint: Color(0xCC0A2E1C),
    border: Color(0x33FFFFFF),
    emergencyTint: Color(0x33B91C1C),
    gradientStart: Color(0xFF0A1F14),
    gradientMid: Color(0xFF0F2E1E),
    gradientEnd: Color(0xFF142818),
    navTint: Color(0xF20A2E1C),
    textOnGlass: Color(0xFFF1F5F9),
    textOnGlassMuted: Color(0xFF94A3B8),
  );

  Color surfaceFor(GlassIntensity intensity) {
    switch (intensity) {
      case GlassIntensity.subtle:
        return surfaceLight;
      case GlassIntensity.medium:
        return surfaceMedium;
      case GlassIntensity.prominent:
        return surfaceHeavy;
    }
  }

  double blurFor(GlassIntensity intensity) {
    switch (intensity) {
      case GlassIntensity.subtle:
        return GlassTokens.blurLight;
      case GlassIntensity.medium:
        return GlassTokens.blurMedium;
      case GlassIntensity.prominent:
        return GlassTokens.blurHeavy;
    }
  }

  @override
  GlassTheme copyWith({
    bool? isDark,
    Color? surfaceLight,
    Color? surfaceMedium,
    Color? surfaceHeavy,
    Color? greenTint,
    Color? border,
    Color? emergencyTint,
    Color? gradientStart,
    Color? gradientMid,
    Color? gradientEnd,
    Color? navTint,
    Color? textOnGlass,
    Color? textOnGlassMuted,
  }) {
    return GlassTheme(
      isDark: isDark ?? this.isDark,
      surfaceLight: surfaceLight ?? this.surfaceLight,
      surfaceMedium: surfaceMedium ?? this.surfaceMedium,
      surfaceHeavy: surfaceHeavy ?? this.surfaceHeavy,
      greenTint: greenTint ?? this.greenTint,
      border: border ?? this.border,
      emergencyTint: emergencyTint ?? this.emergencyTint,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientMid: gradientMid ?? this.gradientMid,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      navTint: navTint ?? this.navTint,
      textOnGlass: textOnGlass ?? this.textOnGlass,
      textOnGlassMuted: textOnGlassMuted ?? this.textOnGlassMuted,
    );
  }

  @override
  GlassTheme lerp(GlassTheme? other, double t) {
    if (other == null) return this;
    return GlassTheme(
      isDark: t < 0.5 ? isDark : other.isDark,
      surfaceLight: Color.lerp(surfaceLight, other.surfaceLight, t)!,
      surfaceMedium: Color.lerp(surfaceMedium, other.surfaceMedium, t)!,
      surfaceHeavy: Color.lerp(surfaceHeavy, other.surfaceHeavy, t)!,
      greenTint: Color.lerp(greenTint, other.greenTint, t)!,
      border: Color.lerp(border, other.border, t)!,
      emergencyTint: Color.lerp(emergencyTint, other.emergencyTint, t)!,
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientMid: Color.lerp(gradientMid, other.gradientMid, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
      navTint: Color.lerp(navTint, other.navTint, t)!,
      textOnGlass: Color.lerp(textOnGlass, other.textOnGlass, t)!,
      textOnGlassMuted: Color.lerp(textOnGlassMuted, other.textOnGlassMuted, t)!,
    );
  }
}

class GlassTokens {
  GlassTokens._();

  static const double radiusGlassSm = 20;
  static const double radiusGlassMd = 24;
  static const double radiusGlassLg = 32;

  static const double blurLight = 12;
  static const double blurMedium = 20;
  static const double blurHeavy = 32;

  static const Color primaryGreen = Color(0xFF0F3D26);
  static const Color secondaryGreen = Color(0xFF7DB343);
  static const Color accentGreen = Color(0xFF1B5E3C);

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, accentGreen, secondaryGreen],
  );

  static List<BoxShadow> ambientShadow({Color? color, double opacity = 0.12}) {
    final shadowColor = (color ?? primaryGreen).withValues(alpha: opacity);
    return [
      BoxShadow(
        color: shadowColor,
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> floatingShadow({Color? color}) {
    return [
      BoxShadow(
        color: (color ?? primaryGreen).withValues(alpha: 0.25),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ];
  }
}
