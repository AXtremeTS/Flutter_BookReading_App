import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bookreading/models/user.dart';
import 'package:bookreading/services/api_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  String? _token;
  
  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _currentUser != null;

  // Check if user is already logged in
  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
    
    if (_token != null && !JwtDecoder.isExpired(_token!)) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(_token!);
        _currentUser = _parseUserFromToken(decodedToken);
        print('Logged in as: ${_currentUser?.username} (ID: ${_currentUser?.id})');
        return true;
      } catch (e) {
        print('Check login error: $e');
        return false;
      }
    }
    return false;
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _token!);
        
        // Use user info from response body first, then fallback to token
        if (data['userId'] != null || data['id'] != null) {
          _currentUser = User.fromJson(data);
        } else {
          Map<String, dynamic> decodedToken = JwtDecoder.decode(_token!);
          _currentUser = _parseUserFromToken(decodedToken);
        }
        
        print('Login success: ${_currentUser?.username} (ID: ${_currentUser?.id})');
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  User _parseUserFromToken(Map<String, dynamic> decodedToken) {
    // Standard .NET Claim Types
    const String nameIdentifierKey = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier';
    const String nameKey = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name';
    const String emailKey = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress';
    const String roleKey = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';

    return User(
      id: (decodedToken[nameIdentifierKey] ?? decodedToken['sub'] ?? '').toString(),
      username: (decodedToken[nameKey] ?? decodedToken['unique_name'] ?? '').toString(),
      email: (decodedToken[emailKey] ?? decodedToken['email'] ?? '').toString(),
      password: '',
      isAdmin: (decodedToken[roleKey] ?? '').toString().toLowerCase() == 'admin',
    );
  }

  Future<bool> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': username,
          'email': '$username@example.com',
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        
        if (_token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', _token!);
          
          if (data['userId'] != null || data['id'] != null) {
            _currentUser = User.fromJson(data);
          } else {
            Map<String, dynamic> decodedToken = JwtDecoder.decode(_token!);
            _currentUser = _parseUserFromToken(decodedToken);
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  Future<bool> resetPassword(String username, String email, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.auth}/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'newPassword': newPassword,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Reset password error: $e');
      return false;
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.admin}/users'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((u) => User.fromJson(u)).toList();
      }
      return [];
    } catch (e) {
      print('Get users error: $e');
      return [];
    }
  }

  Future<bool> toggleUserStatus(String username) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.admin}/toggle-user/$username'),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Toggle user error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}
