class User {
  final String username;
  String password;
  final bool isAdmin;
  bool isDeactivated;
  
  User({
    required this.username,
    required this.password,
    this.isAdmin = false,
    this.isDeactivated = false,
  });
}
