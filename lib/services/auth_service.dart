import 'dart:convert';
import '../models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Khởi tạo client kết nối Supabase
  final _supabase = supabase.Supabase.instance.client;

  // // Temporary hardcoded users
  // final List<User> _users = [
  //   User(userId: 1, username: 'user', password: '123', fullName: 'Regular User', email: 'user@example.com', isAdmin: false),
  //   User(userId: 2, username: 'admin', password: '456', fullName: 'Admin User', email: 'admin@example.com', isAdmin: true),
  // ];

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // Check if user is already logged in
  Future<bool> checkLoginStatus() async {
final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('current_user_data');
    
    if (userDataString != null) {
      try {
        final userData = jsonDecode(userDataString);
        _currentUser = User.fromJson(userData);
        
        // Tùy chọn: Bạn có thể fetch lại DB ở đây để check xem user có bị Admin khóa (isactive=false) trong lúc họ đang offline không.
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<bool> login(String username, String password) async {
    try {
      // Truy vấn Supabase, đối chiếu trực tiếp với bảng Users
      final response = await _supabase
          .from('users') // Tên bảng trong Postgres thường tự chuyển thành chữ thường
          .select()
          .eq('username', username)
          .eq('password', password)
          .maybeSingle(); // Trả về 1 record duy nhất hoặc null

      // Nếu không tìm thấy dòng nào khớp username & password
      if (response == null) {
        return false;
      }

      final user = User.fromJson(response);
      
      // Kiểm tra trạng thái kích hoạt của tài khoản
      if (user.isDeactivated) {
        return false; // Tài khoản đã bị vô hiệu hóa
      }
     
      _currentUser = user;
      
      // Lưu trạng thái đăng nhập
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user_data', jsonEncode(user.toJson()));
      
      return true;
    } catch (e) {
      // In lỗi ra console để debug nếu có sự cố mạng hoặc cấu hình sai
      print('Login Exception: $e');
      return false;
    }
  }

  // Lấy danh sách tất cả người dùng (Dành cho Admin Dashboard)
  Future<List<User>> getAllUsers() async {
    try {
      final response = await _supabase.from('users').select();
      final List<User> users = (response as List<dynamic>)
          .map((json) => User.fromJson(json))
          .toList();
      return users;
    } catch (e) {
      print('Get All Users Error: $e');
      return [];
    }
  }

  /// Đổi mật khẩu người dùng (Dành cho Admin)
  Future<bool> resetPassword(int userId, String newPassword) async {
    try {
      await _supabase
          .from('users')
          .update({'password': newPassword}) // Mã hóa mật khẩu nếu cần thiết ở đây
          .eq('userid', userId);
      return true;
    } catch (e) {
      print('Lỗi Reset Mật Khẩu: $e');
      return false;
    }
  }

  // Đổi trạng thái User (Dành cho Admin)
  Future<void> toggleUserStatus(int userId) async {
    try {
      // Admin không thể tự khóa tài khoản của chính mình
      if (_currentUser?.userId == userId) return;

      // Lấy trạng thái hiện tại
      final userResponse = await _supabase
          .from('users')
          .select('isactive')
          .eq('userid', userId)
          .single();
          
      final currentStatus = userResponse['isactive'] as bool;

      // Cập nhật đảo ngược trạng thái
      await _supabase
          .from('users')
          .update({'isactive': !currentStatus})
          .eq('userid', userId);
          
    } catch (e) {
      print('Toggle Status Error: $e');
    }
  }

  // Xử lý Đăng ký
  Future<bool> register(String username, String password) async {
    try {
      // Bảng Users bắt buộc (NOT NULL) có FullName và Email. 
      // Do UI chưa có 2 trường này, ta tạm tạo giá trị mặc định.
      final dummyEmail = '$username@temp.com';
      final dummyFullName = username;

      await _supabase.from('users').insert({
        'fullname': dummyFullName,
        'email': dummyEmail,
        'username': username,
        'password': password, // Mật khẩu đang được lưu plain-text theo cấu trúc hiện tại
        'role': 'user',
        'isactive': true,
      });

      return true;
    } on supabase.PostgrestException catch (e) {
      // Bắt lỗi trùng lặp Username hoặc Email (ràng buộc UNIQUE trong schema)
      print('Register DB Error: ${e.message}');
      return false;
    } catch (e) {
      print('Register Exception: $e');
      return false;
    }
  }

  // Xử lý Đăng xuất
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_data');
  }
}
