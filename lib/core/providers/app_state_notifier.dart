import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumina/core/services/storage_service.dart';

enum AppState {
  loading,
  splash,
  onboarding,
  login,
  dashboard,
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier(this._storageService) : super(AppState.loading) {
    _initialize();
  }

  final StorageService _storageService;
  
  Future<void> _initialize() async {
    try {
      await _checkAppState();
    } catch (e) {
      state = AppState.splash;
    }
  }

  Future<void> _checkAppState() async {
    // Check if user is authenticated
    final user = FirebaseAuth.instance.currentUser;
    final isOnboardingCompleted = await _storageService.isOnboardingCompleted();
    
    if (user != null) {
      // User is logged in
      await _storageService.setLastLoginDate();
      state = AppState.dashboard;
    } else if (!isOnboardingCompleted) {
      // First time user or onboarding not completed
      state = AppState.onboarding;
    } else {
      // Returning user, not logged in
      state = AppState.login;
    }
  }

  // Method to refresh state when auth changes
  void refreshState() {
    _checkAppState();
  }

  // Method called when onboarding is completed
  Future<void> completeOnboarding() async {
    await _storageService.setOnboardingCompleted();
    state = AppState.login;
  }

  // Method called when user logs in
  Future<void> userLoggedIn() async {
    await _storageService.setLastLoginDate();
    state = AppState.dashboard;
  }

  // Method called when user logs out
  Future<void> userLoggedOut() async {
    await FirebaseAuth.instance.signOut();
    state = AppState.login;
  }
}

// Provider for the app state notifier
final appStateNotifierProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return AppStateNotifier(storageService);
});

// Provider to listen to auth state changes
final authStateListenerProvider = Provider<void>((ref) {
  final appStateNotifier = ref.watch(appStateNotifierProvider.notifier);
  
  FirebaseAuth.instance.authStateChanges().listen((user) {
    appStateNotifier.refreshState();
  });
  
  return;
});