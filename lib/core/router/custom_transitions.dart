import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom page transitions for smooth navigation
class CustomTransitions {
  static const Duration _duration = Duration(milliseconds: 400);
  static const Curve _curve = Curves.easeInOutCubic;

  /// Slide transition from right to left
  static Page<T> slideFromRight<T extends Object?>(
    Widget child,
    LocalKey key,
  ) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: _curve),
        );
        final offsetAnimation = animation.drive(tween);
        
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  /// Slide transition from bottom to top
  static Page<T> slideFromBottom<T extends Object?>(
    Widget child,
    LocalKey key,
  ) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: _curve),
        );
        final offsetAnimation = animation.drive(tween);
        
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  /// Fade transition with scale
  static Page<T> fadeWithScale<T extends Object?>(
    Widget child,
    LocalKey key,
  ) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnimation = animation.drive(
          Tween<double>(begin: 0.0, end: 1.0).chain(
            CurveTween(curve: _curve),
          ),
        );
        
        final scaleAnimation = animation.drive(
          Tween<double>(begin: 0.8, end: 1.0).chain(
            CurveTween(curve: _curve),
          ),
        );
        
        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Shared element transition for mood entries
  static Page<T> sharedAxisTransition<T extends Object?>(
    Widget child,
    LocalKey key, {
    SharedAxisTransitionType transitionType = SharedAxisTransitionType.horizontal,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransitionWidget(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: transitionType,
          child: child,
        );
      },
    );
  }

  /// Elegant hero transition for detailed views
  static Page<T> heroTransition<T extends Object?>(
    Widget child,
    LocalKey key,
  ) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final opacityAnimation = animation.drive(
          Tween<double>(begin: 0.0, end: 1.0).chain(
            CurveTween(curve: Curves.easeInOut),
          ),
        );
        
        final transformAnimation = animation.drive(
          Tween<double>(begin: 0.95, end: 1.0).chain(
            CurveTween(curve: Curves.elasticOut),
          ),
        );
        
        return FadeTransition(
          opacity: opacityAnimation,
          child: Transform.scale(
            scale: transformAnimation.value,
            child: child,
          ),
        );
      },
    );
  }

  /// Gentle bounce transition for mood selections
  static Page<T> bounceTransition<T extends Object?>(
    Widget child,
    LocalKey key,
  ) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final bounceAnimation = animation.drive(
          Tween<double>(begin: 0.0, end: 1.0).chain(
            CurveTween(curve: Curves.elasticOut),
          ),
        );
        
        return ScaleTransition(
          scale: bounceAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}

/// Custom transition page for implementing transitions
class CustomTransitionPage<T> extends Page<T> {
  final Widget child;
  final RouteTransitionsBuilder transitionsBuilder;

  const CustomTransitionPage({
    required this.child,
    required this.transitionsBuilder,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: transitionsBuilder,
      transitionDuration: CustomTransitions._duration,
      reverseTransitionDuration: CustomTransitions._duration,
    );
  }
}

/// Shared axis transition types
enum SharedAxisTransitionType {
  horizontal,
  vertical,
  scaled,
}

/// Shared axis transition widget implementation
class SharedAxisTransitionWidget extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final SharedAxisTransitionType transitionType;
  final Widget child;

  const SharedAxisTransitionWidget({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.transitionType,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    switch (transitionType) {
      case SharedAxisTransitionType.horizontal:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          )),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-0.3, 0.0),
            ).animate(CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeInOutCubic,
            )),
            child: child,
          ),
        );

      case SharedAxisTransitionType.vertical:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          )),
          child: child,
        );

      case SharedAxisTransitionType.scaled:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
    }
  }
}

/// Route extension for easy transition application
extension CustomRouteExtension on GoRouterState {
  /// Get appropriate transition based on route
  Page<T> getTransitionPage<T extends Object?>(Widget child) {
    final key = ValueKey(uri.toString());
    final location = uri.toString();
    
    // Modal routes (settings, detailed views)
    if (location.contains('settings') || 
        location.contains('detail') ||
        location.contains('entry')) {
      return CustomTransitions.slideFromBottom<T>(child, key);
    }
    
    // Analytics and insights
    if (location.contains('analytics') || 
        location.contains('insights')) {
      return CustomTransitions.fadeWithScale<T>(child, key);
    }
    
    // Mood-related screens
    if (location.contains('mood')) {
      return CustomTransitions.bounceTransition<T>(child, key);
    }
    
    // Profile and social screens
    if (location.contains('profile') || 
        location.contains('social')) {
      return CustomTransitions.heroTransition<T>(child, key);
    }
    
    // Default transition
    return CustomTransitions.slideFromRight<T>(child, key);
  }
}