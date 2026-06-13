class User {
  final int userId;
  final String username;
  final String password;
  final String fullName;
  final String email;
  final bool isAdmin;
  final bool isDeactivated;
  final String? avatarUrl;

  User({
    required this.userId,
    required this.username,
    required this.password,
    required this.fullName,
    required this.email,
    this.isAdmin = false,
    this.isDeactivated = false,
    this.avatarUrl,
  });

  // Chuyển đổi từ dữ liệu JSON của Supabase sang Object User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userid'],
      username: json['username'],
      password: json['password'],
      fullName: json['fullname'],
      email: json['email'],
      isAdmin: json['role'] == 'admin',
      isDeactivated: json['isactive'] == false, // Cột isactive = true là đang hoạt động
      avatarUrl: json['avatarurl'],
    );
  }

  // Chuyển đổi từ Object User sang JSON để lưu vào SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'userid': userId,
      'username': username,
      'password': password,
      'fullname': fullName,
      'email': email,
      'role': isAdmin ? 'admin' : 'user',
      'isactive': !isDeactivated,
      'avatarurl': avatarUrl,
    };
  }
}
