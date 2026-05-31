import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

/// Available color scheme choices for the app theme.
enum AppColorScheme {
  blue,
  green,
  purple,
  red,
  orange,
  indigo,
}

/// Helper that maps [AppColorScheme] to [FlexScheme] values and builds
/// [ThemeData] instances via `flex_color_scheme`.
class FlexThemeConfig {
  FlexThemeConfig._();

  static const ThemeMode defaultThemeMode = ThemeMode.system;
  static const AppColorScheme defaultColorScheme = AppColorScheme.green;

  static const FlexSchemeColor iGubatColors = FlexSchemeColor(
    primary: Color(0xFF0F3D26),
    primaryContainer: Color(0xFF1B5E3C),
    secondary: Color(0xFF7DB343),
    secondaryContainer: Color(0xFFA5D172),
    tertiary: Color(0xFF285C42),
    tertiaryContainer: Color(0xFF428765),
    appBarColor: Color(0xFF0F3D26),
    error: Color(0xFFB00020),
  );

  static FlexScheme _toFlex(AppColorScheme scheme) {
    return switch (scheme) {
      AppColorScheme.blue => FlexScheme.blue,
      AppColorScheme.green => FlexScheme.green, // Fallback, but we override it below
      AppColorScheme.purple => FlexScheme.purpleBrown,
      AppColorScheme.red => FlexScheme.red,
      AppColorScheme.orange => FlexScheme.mango,
      AppColorScheme.indigo => FlexScheme.indigo,
    };
  }

  /// Builds a light [ThemeData] for the given colour scheme.
  static ThemeData light(AppColorScheme scheme) {
    return scheme == AppColorScheme.green
        ? FlexThemeData.light(
            colors: iGubatColors,
            useMaterial3: true,
            appBarStyle: FlexAppBarStyle.primary,
          )
        : FlexThemeData.light(
            scheme: _toFlex(scheme),
            useMaterial3: true,
            appBarStyle: FlexAppBarStyle.surface,
          );
  }

  /// Builds a dark [ThemeData] for the given colour scheme.
  static ThemeData dark(AppColorScheme scheme) {
    return scheme == AppColorScheme.green
        ? FlexThemeData.dark(
            colors: iGubatColors,
            useMaterial3: true,
            appBarStyle: FlexAppBarStyle.background,
          )
        : FlexThemeData.dark(
            scheme: _toFlex(scheme),
            useMaterial3: true,
            appBarStyle: FlexAppBarStyle.surface,
          );
  }
}
