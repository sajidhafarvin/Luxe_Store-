import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? _errorMessage;

  AuthProvider() {
    // Listen to authentication state changes
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Getters
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  String? get userEmail => _user?.email;
  String? get userName => _user?.displayName;
  String? get errorMessage => _errorMessage;

  /// Helper to convert FirebaseAuthException code to user-friendly messages.
  String _friendlyError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'This email is already registered. Please login.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
    }
    return error.message ?? 'Authentication failed. Please try again.';
  }

  /// Sign in using email and password.
  /// Returns [true] if successful, [false] otherwise.
  Future<bool> signInWithEmail(String email, String password) async {
    _errorMessage = null;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during sign-in: ${e.code} - ${e.message}');
      _errorMessage = _friendlyError(e);
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error during sign-in: $e');
      _errorMessage = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Register a new user using email, password, and display name.
  /// Returns [true] if successful, [false] otherwise.
  Future<bool> registerWithEmail(String email, String password, String name) async {
    _errorMessage = null;
    notifyListeners();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      // Update the user profile with the display name
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name.trim());
        // Force reload to update user state locally
        await credential.user!.reload();
        _user = _auth.currentUser;
        notifyListeners();
      }
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during registration: ${e.code} - ${e.message}');
      _errorMessage = _friendlyError(e);
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Error during registration: $e');
      _errorMessage = 'Something went wrong. Please try again.';
      notifyListeners();
      return false;
    }
  }

  /// Sign out the current authenticated user.
  Future<void> signOut() async {
    _errorMessage = null;
    try {
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during sign-out: $e');
      _errorMessage = 'Failed to sign out. Please try again.';
      notifyListeners();
    }
  }
}
