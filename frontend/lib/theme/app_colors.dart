// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary Professional Colors
  static const Color primary = Color(0xFF1E3A8A); // Deep Professional Blue
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryAccent = Color(0xFF2563EB);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF0F766E); // Professional Teal
  static const Color secondaryLight = Color(0xFF14B8A6);
  
  // Neutral Colors
  static const Color dark = Color(0xFF0F172A); // Slate 900
  static const Color darkGray = Color(0xFF1E293B); // Slate 800
  static const Color mediumGray = Color(0xFF475569); // Slate 600
  static const Color lightGray = Color(0xFF94A3B8); // Slate 400
  static const Color veryLightGray = Color(0xFFF1F5F9); // Slate 100
  static const Color white = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color info = Color(0xFF3B82F6); // Blue 500
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark, Color(0xFF1E40AF)],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryAccent],
  );
  
  static const LinearGradient professionalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF), Color(0xFF2563EB)],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
  );
  
  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 30,
      offset: Offset(0, 8),
    ),
  ];
  
  // Text Colors - for proper contrast
  static Color textOnLight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? AppColors.white 
        : AppColors.dark;
  }
  
  static Color textOnDark(BuildContext context) {
    return AppColors.white;
  }
  
  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? AppColors.lightGray 
        : AppColors.mediumGray;
  }
  
  static Color textMuted(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? AppColors.mediumGray 
        : AppColors.lightGray;
  }
}

