import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lumina/core/theme/app_colors.dart';
import 'package:lumina/core/theme/app_typography.dart';

/// Theme service for dark mode and theme management
class ThemeService {
  static const String _themePrefsKey = 'app_theme_mode';
  static const String _dynamicThemeKey = 'dynamic_theme';
  static const String _accessibilityKey = 'accessibility_mode';
  
  static SharedPreferences? _prefs;
  static final ValueNotifier<ThemeMode> _themeModeNotifier = ValueNotifier(ThemeMode.system);
  static final ValueNotifier<bool> _dynamicThemeNotifier = ValueNotifier(false);
  static final ValueNotifier<bool> _accessibilityModeNotifier = ValueNotifier(false);

  /// Initialize theme service
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadThemePreferences();
  }

  /// Load saved theme preferences
  static Future<void> _loadThemePreferences() async {
    final themeModeIndex = _prefs?.getInt(_themePrefsKey) ?? ThemeMode.system.index;
    _themeModeNotifier.value = ThemeMode.values[themeModeIndex];
    
    _dynamicThemeNotifier.value = _prefs?.getBool(_dynamicThemeKey) ?? false;
    _accessibilityModeNotifier.value = _prefs?.getBool(_accessibilityKey) ?? false;
  }

  /// Theme mode getters
  static ValueNotifier<ThemeMode> get themeModeNotifier => _themeModeNotifier;
  static ValueNotifier<bool> get dynamicThemeNotifier => _dynamicThemeNotifier;
  static ValueNotifier<bool> get accessibilityModeNotifier => _accessibilityModeNotifier;

  static ThemeMode get themeMode => _themeModeNotifier.value;
  static bool get isDynamicTheme => _dynamicThemeNotifier.value;
  static bool get isAccessibilityMode => _accessibilityModeNotifier.value;

  /// Set theme mode
  static Future<void> setThemeMode(ThemeMode mode) async {
    _themeModeNotifier.value = mode;
    await _prefs?.setInt(_themePrefsKey, mode.index);
    _updateSystemUI();
  }

  /// Toggle between light and dark mode
  static Future<void> toggleTheme() async {
    final newMode = themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    await setThemeMode(newMode);
  }

  /// Set dynamic theming
  static Future<void> setDynamicTheme(bool enabled) async {
    _dynamicThemeNotifier.value = enabled;
    await _prefs?.setBool(_dynamicThemeKey, enabled);
  }

  /// Set accessibility mode
  static Future<void> setAccessibilityMode(bool enabled) async {
    _accessibilityModeNotifier.value = enabled;
    await _prefs?.setBool(_accessibilityKey, enabled);
  }

  /// Update system UI based on current theme
  static void _updateSystemUI() {
    final brightness = _getCurrentBrightness();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: brightness == Brightness.light 
            ? Brightness.dark 
            : Brightness.light,
        statusBarBrightness: brightness,
        systemNavigationBarColor: brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF1A1A1A),
        systemNavigationBarIconBrightness: brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
    );
  }

  /// Get current brightness based on theme mode
  static Brightness _getCurrentBrightness() {
    switch (themeMode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness;
    }
  }

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryPurple,
        primaryContainer: AppColors.primaryBlue,
        secondary: AppColors.secondaryOrange,
        secondaryContainer: AppColors.secondaryRed,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textDark,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: AppColors.textDark),
        titleTextStyle: TextStyle(
          color: AppColors.textDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primaryPurple.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryPurple,
          side: const BorderSide(color: AppColors.primaryPurple),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutralLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: AppColors.neutralDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: AppTypography.lightTextTheme,
      scaffoldBackgroundColor: AppColors.neutralLight,
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryPurple,
        primaryContainer: AppColors.primaryBlue,
        secondary: AppColors.secondaryOrange,
        secondaryContainer: AppColors.secondaryRed,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textLight,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: AppColors.textLight),
        titleTextStyle: TextStyle(
          color: AppColors.textLight,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.neutralDarker,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.primaryPurple.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryPurple,
          side: const BorderSide(color: AppColors.primaryPurple),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutralDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryPurple, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: AppColors.textMedium,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      textTheme: AppTypography.darkTextTheme,
      scaffoldBackgroundColor: AppColors.surfaceDark,
    );
  }

  /// Accessibility enhanced theme
  static ThemeData getAccessibilityTheme(ThemeData baseTheme) {
    return baseTheme.copyWith(
      textTheme: baseTheme.textTheme.copyWith(
        bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(
          fontSize: 18, // Increased from default 16
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: baseTheme.textTheme.bodyMedium?.copyWith(
          fontSize: 16, // Increased from default 14
          fontWeight: FontWeight.w500,
        ),
        bodySmall: baseTheme.textTheme.bodySmall?.copyWith(
          fontSize: 14, // Increased from default 12
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: baseTheme.elevatedButtonTheme.style?.copyWith(
          minimumSize: WidgetStateProperty.all(const Size(0, 56)), // Increased height
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          ),
        ),
      ),
    );
  }

  /// Get current theme based on mode and settings
  static ThemeData getCurrentTheme(BuildContext context) {
    ThemeData baseTheme;
    
    final brightness = MediaQuery.of(context).platformBrightness;
    
    switch (themeMode) {
      case ThemeMode.light:
        baseTheme = lightTheme;
        break;
      case ThemeMode.dark:
        baseTheme = darkTheme;
        break;
      case ThemeMode.system:
        baseTheme = brightness == Brightness.dark ? darkTheme : lightTheme;
        break;
    }

    // Apply accessibility enhancements if enabled
    if (isAccessibilityMode) {
      baseTheme = getAccessibilityTheme(baseTheme);
    }

    return baseTheme;
  }

  /// Theme-aware color helpers
  static Color getContrastColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppColors.textDark
        : AppColors.textLight;
  }

  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppColors.surfaceLight
        : AppColors.surfaceDark;
  }

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppColors.surfaceLight
        : AppColors.neutralDarker;
  }

  /// Adaptive colors for mood tracking
  static Color getMoodColor(double moodValue, {required BuildContext context}) {
    // Base mood colors
    final colors = [
      AppColors.moodDepressed,
      AppColors.moodSad,
      AppColors.moodAnxious,
      AppColors.moodNeutral,
      AppColors.moodContent,
      AppColors.moodHappy,
      AppColors.moodEcstatic,
    ];

    final index = ((moodValue - 1) / 9 * (colors.length - 1)).round().clamp(0, colors.length - 1);
    Color baseColor = colors[index];

    // Adjust for dark theme
    if (Theme.of(context).brightness == Brightness.dark) {
      // Make colors slightly lighter/more vibrant in dark mode
      final hsl = HSLColor.fromColor(baseColor);
      baseColor = hsl.withLightness((hsl.lightness * 1.2).clamp(0.0, 1.0)).toColor();
    }

    return baseColor;
  }

  /// Generate gradient for mood values
  static LinearGradient getMoodGradient(double moodValue, {required BuildContext context}) {
    final primaryColor = getMoodColor(moodValue, context: context);
    final secondaryColor = HSLColor.fromColor(primaryColor)
        .withHue((HSLColor.fromColor(primaryColor).hue + 30) % 360)
        .toColor();

    return LinearGradient(
      colors: [primaryColor, secondaryColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}