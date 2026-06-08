class User {
  final String username;
  final String password;
  final bool isAdmin;

  User({
    required this.username,
    required this.password,
    this.isAdmin = false,
  });
}
