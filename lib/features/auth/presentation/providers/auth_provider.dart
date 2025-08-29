import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Auth loading provider
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Auth error provider
final authErrorProvider = StateProvider<String?>((ref) => null);

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Update display name
  Future<void> updateDisplayName({required String displayName}) async {
    await _auth.currentUser?.updateDisplayName(displayName);
  }

  // Update profile picture
  Future<void> updatePhotoURL({required String photoURL}) async {
    await _auth.currentUser?.updatePhotoURL(photoURL);
  }

  // Delete user account
  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }

  // Reauthenticate user
  Future<void> reauthenticateWithCredential({
    required AuthCredential credential,
  }) async {
    await _auth.currentUser?.reauthenticateWithCredential(credential);
  }

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Get auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}