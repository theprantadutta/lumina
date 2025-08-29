import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  AppGradients._();
  
  // Primary gradients for main UI elements
  static const primary = LinearGradient(
    colors: [AppColors.primaryPurple, AppColors.primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
  );
  
  static const primaryReverse = LinearGradient(
    colors: [AppColors.primaryBlue, AppColors.primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
  );
  
  // Secondary gradients for accent elements
  static const secondary = LinearGradient(
    colors: [AppColors.secondaryOrange, AppColors.secondaryRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
  );
  
  // Accent gradients for wellness elements
  static const accent = LinearGradient(
    colors: [AppColors.accentGreen, AppColors.accentDarkGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
  );
  
  // Mood-specific gradients
  static const moodPositive = LinearGradient(
    colors: [AppColors.moodHappy, AppColors.moodContent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const moodNegative = LinearGradient(
    colors: [AppColors.moodAnxious, AppColors.moodAngry],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Subtle gradients for backgrounds
  static const shimmer = LinearGradient(
    colors: [
      Colors.white12,
      Colors.white24,
      Colors.white12,
    ],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
    stops: [0.0, 0.5, 1.0],
  );
  
  static const softPrimary = LinearGradient(
    colors: [
      Color(0x20_8B5CF6),
      Color(0x20_3B82F6),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const glassmorphism = LinearGradient(
    colors: [
      Colors.white24,
      Colors.white12,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Directional variations
  static const primaryVertical = LinearGradient(
    colors: [AppColors.primaryPurple, AppColors.primaryBlue],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const primaryHorizontal = LinearGradient(
    colors: [AppColors.primaryPurple, AppColors.primaryBlue],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  
  static const primaryRadial = RadialGradient(
    colors: [AppColors.primaryPurple, AppColors.primaryBlue],
    center: Alignment.center,
    radius: 1.0,
  );
  
  // Animation gradients with multiple stops
  static const multiColorWellness = LinearGradient(
    colors: [
      AppColors.primaryPurple,
      AppColors.primaryBlue,
      AppColors.accentGreen,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.6, 1.0],
  );
}