import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/features/auth/presentation/screens/login_screen.dart';
import 'package:lumina/features/auth/presentation/screens/signup_screen.dart';
import 'package:lumina/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:lumina/features/mood/presentation/screens/mood_entry_screen.dart';
import 'package:lumina/features/mood/presentation/screens/mood_history_screen.dart';
import 'package:lumina/features/analytics/presentation/screens/analytics_dashboard_screen.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String dashboard = '/dashboard';
  static const String moodEntry = '/mood-entry';
  static const String moodHistory = '/mood-history';
  static const String journal = '/journal';
  static const String analytics = '/analytics';
  static const String profile = '/profile';
  static const String settings = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: dashboard,
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: moodEntry,
            name: 'mood-entry',
            builder: (context, state) => const MoodEntryScreen(),
          ),
          GoRoute(
            path: moodHistory,
            name: 'mood-history',
            builder: (context, state) => const MoodHistoryScreen(),
          ),
          GoRoute(
            path: journal,
            name: 'journal',
            builder: (context, state) => const JournalScreen(),
          ),
          GoRoute(
            path: analytics,
            name: 'analytics',
            builder: (context, state) => const AnalyticsDashboardScreen(),
          ),
          GoRoute(
            path: profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: settings,
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(dashboard),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
}

// Temporary placeholder screens - these will be replaced with actual implementations
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.psychology_alt_rounded,
                size: 120,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              const Text(
                'Lumina',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Track your wellness journey',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => context.go(AppRouter.onboarding),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF8B5CF6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.dashboard_outlined),
      activeIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.mood_outlined),
      activeIcon: Icon(Icons.mood),
      label: 'Mood',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.book_outlined),
      activeIcon: Icon(Icons.book),
      label: 'Journal',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.analytics_outlined),
      activeIcon: Icon(Icons.analytics),
      label: 'Analytics',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  final List<String> _routes = [
    AppRouter.dashboard,
    AppRouter.moodEntry,
    AppRouter.journal,
    AppRouter.analytics,
    AppRouter.profile,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          context.go(_routes[index]);
        },
      ),
    );
  }
}

// Placeholder screens
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(AppRouter.settings),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Dashboard Screen\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      body: const Center(
        child: Text(
          'Journal Screen\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Text(
          'Profile Screen\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
        child: Text(
          'Settings Screen\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
