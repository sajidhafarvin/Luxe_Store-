import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthViewModel extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = '';
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    if (email.contains('@') && password.length >= 6) {
      _currentUser = User(id: '1', name: 'Fashion User', email: email, profileImageUrl: 'https://via.placeholder.com/150/2563EB/FFFFFF?text=FU');
      _setLoading(false);
      return true;
    } else {
      _errorMessage = 'Invalid email or password (min 6 chars)';
      _setLoading(false);
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
