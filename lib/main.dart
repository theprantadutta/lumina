import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumina/core/providers/app_state_notifier.dart';
import 'package:lumina/core/router/app_router.dart';
import 'package:lumina/core/services/storage_service.dart';
import 'package:lumina/core/theme/app_theme.dart';
import 'package:lumina/features/auth/presentation/screens/login_screen.dart';
import 'package:lumina/features/auth/presentation/screens/onboarding_screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await StorageService.init();
  runApp(const ProviderScope(child: LuminaApp()));
}

class LuminaApp extends ConsumerWidget {
  const LuminaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize auth state listener
    ref.watch(authStateListenerProvider);

    final appState = ref.watch(appStateProvider);

    return MaterialApp(
      title: 'Lumina',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: _buildHomeScreen(appState),
    );
  }

  Widget _buildHomeScreen(AppState state) {
    switch (state) {
      case AppState.loading:
      case AppState.splash:
        return const SplashScreen();
      case AppState.onboarding:
        return const OnboardingScreen();
      case AppState.login:
        return const LoginScreen();
      case AppState.dashboard:
        return const MainApp();
    }
  }
}

// Main app with router for authenticated users
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Lumina',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
