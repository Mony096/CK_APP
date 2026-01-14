import 'package:flutter/material.dart';

extension ThemeExtensions on BuildContext {
  /// Get the current theme's color scheme
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Get the current theme's text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Shorthand getters for common colors
  Color get primaryColor => colors.primary;
  Color get onPrimaryColor => colors.onPrimary;
  Color get surfaceColor => colors.surface;
  Color get onSurfaceColor => colors.onSurface;
  Color get errorColor => colors.error;
  Color get outlineColor => colors.outline;
  
  /// Helper for legacy app bar background or primary container
  Color get appBarBg => colors.primaryContainer;
}
