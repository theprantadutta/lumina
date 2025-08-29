import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  // Base spacing unit - 4px
  static const double baseSpacing = 4.0;
  static const double spacing8 = baseSpacing * 2;
  static const double spacing12 = baseSpacing * 3;
  static const double spacing16 = baseSpacing * 4;
  static const double spacing24 = baseSpacing * 6;
  static const double spacing32 = baseSpacing * 8;
  static const double spacing48 = baseSpacing * 12;
  static const double spacing64 = baseSpacing * 16;

  // Border radius values
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusCircular = 999.0;

  // Light Theme
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryPurple,
      onPrimary: Colors.white,
      secondary: AppColors.secondaryOrange,
      onSecondary: Colors.white,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.neutralDark,
      surfaceContainer: AppColors.neutralMedium,
      error: AppColors.error,
      onError: Colors.white,
    ),
    textTheme: _buildTextTheme(AppColors.neutralDark),
    appBarTheme: _buildAppBarTheme(Brightness.light),
    elevatedButtonTheme: _buildElevatedButtonTheme(),
    outlinedButtonTheme: _buildOutlinedButtonTheme(),
    textButtonTheme: _buildTextButtonTheme(),
    cardTheme: _buildCardTheme(),
    inputDecorationTheme: _buildInputDecorationTheme(Brightness.light),
    bottomNavigationBarTheme: _buildBottomNavTheme(Brightness.light),
    floatingActionButtonTheme: _buildFABTheme(),
    dividerTheme: const DividerThemeData(
      color: AppColors.neutralMedium,
      thickness: 1,
    ),
    scaffoldBackgroundColor: AppColors.neutralLight,
  );

  // Dark Theme
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryBlue,
      onPrimary: Colors.white,
      secondary: AppColors.secondaryRed,
      onSecondary: Colors.white,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.neutralLight,
      surfaceContainer: AppColors.neutralDarker,
      error: AppColors.error,
      onError: Colors.white,
    ),
    textTheme: _buildTextTheme(AppColors.neutralLight),
    appBarTheme: _buildAppBarTheme(Brightness.dark),
    elevatedButtonTheme: _buildElevatedButtonTheme(),
    outlinedButtonTheme: _buildOutlinedButtonTheme(),
    textButtonTheme: _buildTextButtonTheme(),
    cardTheme: _buildCardTheme(),
    inputDecorationTheme: _buildInputDecorationTheme(Brightness.dark),
    bottomNavigationBarTheme: _buildBottomNavTheme(Brightness.dark),
    floatingActionButtonTheme: _buildFABTheme(),
    dividerTheme: const DividerThemeData(
      color: AppColors.neutralDarker,
      thickness: 1,
    ),
    scaffoldBackgroundColor: AppColors.surfaceDark,
  );

  // Text Theme Builder
  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(color: textColor),
      displayMedium: AppTypography.displayMedium.copyWith(color: textColor),
      displaySmall: AppTypography.displaySmall.copyWith(color: textColor),
      headlineLarge: AppTypography.headlineLarge.copyWith(color: textColor),
      headlineMedium: AppTypography.headlineMedium.copyWith(color: textColor),
      headlineSmall: AppTypography.headlineSmall.copyWith(color: textColor),
      titleLarge: AppTypography.titleLarge.copyWith(color: textColor),
      titleMedium: AppTypography.titleMedium.copyWith(color: textColor),
      titleSmall: AppTypography.titleSmall.copyWith(color: textColor),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: textColor),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: textColor),
      bodySmall: AppTypography.bodySmall.copyWith(color: textColor),
      labelLarge: AppTypography.labelLarge.copyWith(color: textColor),
      labelMedium: AppTypography.labelMedium.copyWith(color: textColor),
      labelSmall: AppTypography.labelSmall.copyWith(color: textColor),
    );
  }

  // AppBar Theme
  static AppBarTheme _buildAppBarTheme(Brightness brightness) {
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 2,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: brightness == Brightness.light
          ? AppColors.neutralDark
          : AppColors.neutralLight,
      titleTextStyle: AppTypography.titleLarge.copyWith(
        color: brightness == Brightness.light
            ? AppColors.neutralDark
            : AppColors.neutralLight,
      ),
      iconTheme: IconThemeData(
        color: brightness == Brightness.light
            ? AppColors.neutralDark
            : AppColors.neutralLight,
      ),
      systemOverlayStyle: brightness == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
    );
  }

  // Button Themes
  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: AppTypography.buttonText,
        padding: const EdgeInsets.symmetric(
          horizontal: spacing24,
          vertical: spacing16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        elevation: 2,
        shadowColor: Colors.black26,
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        textStyle: AppTypography.buttonText,
        padding: const EdgeInsets.symmetric(
          horizontal: spacing24,
          vertical: spacing16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        side: const BorderSide(width: 1.5, color: AppColors.primaryPurple),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: AppTypography.buttonText,
        padding: const EdgeInsets.symmetric(
          horizontal: spacing16,
          vertical: spacing12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
    );
  }

  // Card Theme
  static CardThemeData _buildCardTheme() {
    return CardThemeData(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
      margin: const EdgeInsets.all(spacing8),
    );
  }

  // Input Decoration Theme
  static InputDecorationTheme _buildInputDecorationTheme(
    Brightness brightness,
  ) {
    return InputDecorationTheme(
      filled: true,
      fillColor: brightness == Brightness.light
          ? AppColors.neutralMedium
          : AppColors.neutralDarker,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacing16,
      ),
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: brightness == Brightness.light
            ? AppColors.neutralDark.withValues(alpha: 0.6)
            : AppColors.neutralLight.withValues(alpha: 0.6),
      ),
    );
  }

  // Bottom Navigation Theme
  static BottomNavigationBarThemeData _buildBottomNavTheme(
    Brightness brightness,
  ) {
    return BottomNavigationBarThemeData(
      backgroundColor: brightness == Brightness.light
          ? AppColors.surfaceLight
          : AppColors.surfaceDark,
      selectedItemColor: AppColors.primaryPurple,
      unselectedItemColor: brightness == Brightness.light
          ? AppColors.neutralDark.withValues(alpha: 0.6)
          : AppColors.neutralLight.withValues(alpha: 0.6),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: AppTypography.labelSmall,
      unselectedLabelStyle: AppTypography.labelSmall,
    );
  }

  // Floating Action Button Theme
  static FloatingActionButtonThemeData _buildFABTheme() {
    return const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryPurple,
      foregroundColor: Colors.white,
      elevation: 4,
      focusElevation: 6,
      hoverElevation: 6,
      highlightElevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radiusLarge)),
      ),
    );
  }
}
