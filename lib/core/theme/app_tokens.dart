import 'package:flutter/material.dart';

/// App color palette
/// 
/// Usage:
/// ```dart
/// Container(color: AppColors.primary)
/// Text('Hello', style: TextStyle(color: AppColors.textPrimary))
/// ```
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF425364);
  static const Color primaryLight = Color(0xFF6B7B8A);
  static const Color primaryDark = Color(0xFF2C3A47);

  // Accent Colors
  static const Color accent = Color(0xFF27CC27);
  static const Color accentLight = Color(0xFF4DD74D);
  static const Color accentDark = Color(0xFF1E9E1E);

  // Semantic Colors
  static const Color success = Color(0xFF27CC27);
  static const Color successLight = Color(0xFFE8F8E8);
  static const Color warning = Color(0xFFFFB84D);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFE74C3C);
  static const Color errorLight = Color(0xFFFDEDEC);
  static const Color info = Color(0xFF3498DB);
  static const Color infoLight = Color(0xFFE8F4FC);

  // Neutral Colors
  static const Color background = Color(0xFFECEEF0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F7F9);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFCBCBCB);

  // Text Colors
  static const Color textPrimary = Color(0xFF2C3A47);
  static const Color textSecondary = Color(0xFF6B7B8A);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // Status Colors (for service tickets)
  static const Color statusOpen = Color(0xFF9E9E9E);
  static const Color statusAccept = Color(0xFF3498DB);
  static const Color statusTravel = Color(0xFFFFB84D);
  static const Color statusService = Color(0xFF9B59B6);
  static const Color statusEntry = Color(0xFF27CC27);

  /// Get status color by status name
  static Color getStatusColor(String? status) {
    switch (status) {
      case 'Open':
        return statusOpen;
      case 'Accept':
        return statusAccept;
      case 'Travel':
        return statusTravel;
      case 'Service':
        return statusService;
      case 'Entry':
        return statusEntry;
      default:
        return statusOpen;
    }
  }
}

/// App spacing constants
/// 
/// Usage:
/// ```dart
/// SizedBox(height: AppSpacing.md)
/// Padding(padding: EdgeInsets.all(AppSpacing.lg))
/// ```
class AppSpacing {
  AppSpacing._();

  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;

  // Common padding presets
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  // Horizontal padding
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXl = EdgeInsets.symmetric(horizontal: xl);

  // Vertical padding
  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);
}

/// Border radius constants
class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 999.0;

  static BorderRadius get radiusXs => BorderRadius.circular(xs);
  static BorderRadius get radiusSm => BorderRadius.circular(sm);
  static BorderRadius get radiusMd => BorderRadius.circular(md);
  static BorderRadius get radiusLg => BorderRadius.circular(lg);
  static BorderRadius get radiusXl => BorderRadius.circular(xl);
  static BorderRadius get radiusFull => BorderRadius.circular(full);
}

/// App shadows
class AppShadows {
  AppShadows._();

  static List<BoxShadow> get small => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get medium => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get large => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}
