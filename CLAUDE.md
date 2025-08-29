# Lumina - Claude Development Preferences

## Project Context
Lumina is a beautiful mood & wellness tracking Flutter app with stunning animations and Firebase backend. Firebase is already configured and ready to use - no additional Firebase setup needed.

## Development Approach
- **Phase-based development**: Follow the implementation_plan.md phases strictly
- **Animation-first**: Every interaction should be smooth and delightful
- **Accessibility**: WCAG compliance is mandatory
- **Performance**: Maintain 60fps with proper testing

## Important Development Notes
- Run `flutter analyze` regularly to catch issues early
- Run `flutter packages pub run build_runner build --delete-conflicting-outputs` after model changes
- Phase 1: Foundation is completed, ready for Phase 2: Core Features

## Code Preferences

### Architecture
- Use Clean Architecture with feature-based folder structure
- Riverpod for state management (not Bloc)
- GoRouter for navigation
- Freezed for immutable data models

### Dependencies Priority
1. Core: `flutter_riverpod`, `go_router`, `freezed_annotation`, `json_annotation`
2. Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
3. Animation: `rive`, `lottie`, `flutter_animate`
4. UI: `fl_chart`, `shimmer`, `cached_network_image`

### Coding Standards
- Use `const` constructors everywhere possible
- Implement proper error handling with try-catch
- Use meaningful variable names (no abbreviations)
- Follow Dart/Flutter linting rules
- Write unit tests for all business logic

### File Naming
- snake_case for file names
- PascalCase for class names
- camelCase for variables and functions
- Use feature prefixes (e.g., `mood_entry_screen.dart`)

### UI Guidelines
- Material 3 design system with custom gradients
- 4px spacing base unit (4, 8, 12, 16, 24, 32, 48, 64)
- Use AnimatedContainer and AnimatedBuilder for smooth transitions
- Implement Hero animations for navigation
- Always add semantic labels for accessibility

### Animation Guidelines
- Use Curves.elasticOut for mood selections
- Spring physics for button interactions
- Duration: 300-600ms for most animations
- Use Rive for complex character animations
- Lottie for micro-interactions and loading states

## Development Notes
- Firebase is already setup and configured
- Focus on beautiful, therapeutic user experience
- Test on both iOS and Android
- Profile performance with Flutter DevTools
- Gradient-based color system for wellness feel

## Current Phase
Phase 1: Foundation is completed, ready for Phase 2: Core Features - Mood Tracking.