import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Temporary hardcoded users
  final List<User> _users = [
    User(username: 'user', password: '123', isAdmin: false),
    User(username: 'admin', password: '456', isAdmin: true),
  ];

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // Check if user is already logged in
  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('logged_in_user');
    
    if (username != null) {
      try {
        _currentUser = _users.firstWhere((u) => u.username == username);
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<bool> login(String username, String password) async {
    try {
      final user = _users.firstWhere(
        (u) => u.username == username && u.password == password,
      );
      _currentUser = user;
      
      // Save login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('logged_in_user', username);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  bool register(String username, String password) {
    // Check if username already exists
    final exists = _users.any((u) => u.username == username);
    if (exists) {
      return false;
    }

    // Add new user
    _users.add(User(username: username, password: password));
    return true;
  }

  Future<void> logout() async {
    _currentUser = null;
    
    // Clear login state
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_in_user');
  }
}
