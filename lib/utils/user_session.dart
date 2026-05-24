class UserSession {
  static final UserSession _instance =
    UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  static String _userName = '';
  static String _userEmail = '';
  static bool _isLoggedIn = false;

  String get userName => _userName;
  String get userEmail => _userEmail;
  bool get isLoggedIn => _isLoggedIn;

  void login(String name, String email) {
    _userName = name;
    _userEmail = email;
    _isLoggedIn = true;
  }

  void logout() {
    _userName = '';
    _userEmail = '';
    _isLoggedIn = false;
  }

  String get firstName {
    if (_userName.isEmpty) return 'Guest';
    return _userName.split(' ').first;
  }
}
