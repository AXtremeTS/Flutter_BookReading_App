class User {
  final String id;
  final String username;
  final String email;
  String password;
  final bool isAdmin;
  bool isDeactivated;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    this.isAdmin = false,
    this.isDeactivated = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['userId'] ?? json['id'] ?? '').toString(),
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      password: '', // Password usually not returned from API for security
      isAdmin: (json['role'] ?? '').toString().toLowerCase() == 'admin',
      isDeactivated: json['isActive'] == false,
    );
  }
}
