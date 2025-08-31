import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lumina/features/mood/presentation/screens/beautiful_mood_entry_screen.dart';
import 'package:lumina/features/mood/presentation/screens/mood_history_screen.dart';
import 'package:lumina/features/analytics/presentation/screens/beautiful_analytics_screen.dart';
import 'package:lumina/shared/widgets/beautiful_bottom_nav.dart';
import 'package:lumina/core/router/custom_transitions.dart';

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
    initialLocation: dashboard,
    debugLogDiagnostics: true,
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: dashboard,
            name: 'dashboard',
            pageBuilder: (context, state) => 
                state.getTransitionPage(const DashboardScreen()),
          ),
          GoRoute(
            path: moodEntry,
            name: 'mood-entry',
            pageBuilder: (context, state) => 
                state.getTransitionPage(const BeautifulMoodEntryScreen()),
          ),
          GoRoute(
            path: moodHistory,
            name: 'mood-history',
            pageBuilder: (context, state) => 
                state.getTransitionPage(const MoodHistoryScreen()),
          ),
          GoRoute(
            path: journal,
            name: 'journal',
            pageBuilder: (context, state) => 
                state.getTransitionPage(const JournalScreen()),
          ),
          GoRoute(
            path: analytics,
            name: 'analytics',
            pageBuilder: (context, state) => 
                state.getTransitionPage(const BeautifulAnalyticsScreen()),
          ),
          GoRoute(
            path: profile,
            name: 'profile',
            pageBuilder: (context, state) => 
                state.getTransitionPage(const ProfileScreen()),
          ),
          GoRoute(
            path: settings,
            name: 'settings',
            pageBuilder: (context, state) => 
                state.getTransitionPage(const SettingsScreen()),
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

// Splash screen that shows while determining app state
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
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.psychology_alt_rounded,
                size: 120,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'Lumina',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Track your wellness journey',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              SizedBox(height: 48),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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

  final List<BeautifulBottomNavItem> _navItems = [
    const BeautifulBottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    const BeautifulBottomNavItem(
      icon: Icons.favorite_outline_rounded,
      activeIcon: Icons.favorite_rounded,
      label: 'Mood',
    ),
    const BeautifulBottomNavItem(
      icon: Icons.edit_note_outlined,
      activeIcon: Icons.edit_note_rounded,
      label: 'Journal',
    ),
    const BeautifulBottomNavItem(
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights_rounded,
      label: 'Analytics',
    ),
    const BeautifulBottomNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
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
      extendBody: true,
      bottomNavigationBar: BeautifulBottomNav(
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
