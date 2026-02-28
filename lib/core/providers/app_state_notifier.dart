import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lumina/core/services/storage_service.dart';

part 'app_state_notifier.g.dart';

enum AppState {
  loading,
  splash,
  onboarding,
  login,
  dashboard,
}

@Riverpod(keepAlive: true)
class AppStateNotifier extends _$AppStateNotifier {
  late StorageService _storageService;

  @override
  AppState build() {
    _storageService = ref.watch(storageServiceProvider);
    _initialize();
    return AppState.loading;
  }

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

// Provider to listen to auth state changes
@Riverpod(keepAlive: true)
void authStateListener(Ref ref) {
  final appStateNotifier = ref.watch(appStateProvider.notifier);

  FirebaseAuth.instance.authStateChanges().listen((user) {
    appStateNotifier.refreshState();
  });
}
