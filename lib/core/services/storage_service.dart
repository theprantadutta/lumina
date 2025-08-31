import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Storage keys
class StorageKeys {
  static const String isOnboardingCompleted = 'is_onboarding_completed';
  static const String isFirstLaunch = 'is_first_launch';
  static const String lastLoginDate = 'last_login_date';
}

// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// Onboarding state provider
final onboardingStateProvider = FutureProvider<bool>((ref) async {
  final storageService = ref.watch(storageServiceProvider);
  return await storageService.isOnboardingCompleted();
});

class StorageService {
  static SharedPreferences? _prefs;
  
  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  
  SharedPreferences get _preferences {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call StorageService.init() first.');
    }
    return _prefs!;
  }

  // Onboarding methods
  Future<bool> isOnboardingCompleted() async {
    return _preferences.getBool(StorageKeys.isOnboardingCompleted) ?? false;
  }

  Future<void> setOnboardingCompleted() async {
    await _preferences.setBool(StorageKeys.isOnboardingCompleted, true);
  }

  // First launch methods
  Future<bool> isFirstLaunch() async {
    final isFirst = _preferences.getBool(StorageKeys.isFirstLaunch) ?? true;
    if (isFirst) {
      await _preferences.setBool(StorageKeys.isFirstLaunch, false);
    }
    return isFirst;
  }

  // Login tracking
  Future<void> setLastLoginDate() async {
    await _preferences.setString(
      StorageKeys.lastLoginDate, 
      DateTime.now().toIso8601String(),
    );
  }

  Future<DateTime?> getLastLoginDate() async {
    final dateString = _preferences.getString(StorageKeys.lastLoginDate);
    return dateString != null ? DateTime.parse(dateString) : null;
  }

  // Clear all data (for logout/reset)
  Future<void> clearAll() async {
    await _preferences.clear();
  }

  // Clear specific key
  Future<void> remove(String key) async {
    await _preferences.remove(key);
  }
}