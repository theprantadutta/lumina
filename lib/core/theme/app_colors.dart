import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary gradient colors for wellness theme
  static const primaryPurple = Color(0xFF8B5CF6);
  static const primaryBlue = Color(0xFF3B82F6);

  // Secondary gradient colors
  static const secondaryOrange = Color(0xFFF59E0B);
  static const secondaryRed = Color(0xFFEF4444);

  // Accent colors for mood tracking
  static const accentGreen = Color(0xFF10B981);
  static const accentDarkGreen = Color(0xFF059669);

  // Neutral colors with subtle tints
  static const neutralLight = Color(0xFFFAFAFA);
  static const neutralMedium = Color(0xFFF5F5F5);
  static const neutralDark = Color(0xFF374151);
  static const neutralDarker = Color(0xFF1F2937);

  // Text colors
  static const textDark = Color(0xFF1F2937);
  static const textLight = Color(0xFFFFFFFF);
  static const textMedium = Color(0xFF6B7280);

  // Surface colors
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF1A1A1A);

  // Error and warning colors
  static const error = Color(0xFFDC2626);
  static const warning = Color(0xFFF59E0B);
  static const success = Color(0xFF10B981);

  // Mood tracking colors - 8 mood types
  static const moodEcstatic = Color(0xFFFF6B9D); // Bright pink
  static const moodHappy = Color(0xFF10B981); // Green
  static const moodContent = Color(0xFF3B82F6); // Blue
  static const moodNeutral = Color(0xFF6B7280); // Gray
  static const moodSad = Color(0xFF8B5CF6); // Purple
  static const moodAnxious = Color(0xFFF59E0B); // Orange
  static const moodAngry = Color(0xFFEF4444); // Red
  static const moodDepressed = Color(0xFF4B5563); // Dark gray

  // Gradient definitions
  static const primaryGradient = LinearGradient(
    colors: [primaryPurple, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const secondaryGradient = LinearGradient(
    colors: [secondaryOrange, secondaryRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const accentGradient = LinearGradient(
    colors: [accentGreen, accentDarkGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
