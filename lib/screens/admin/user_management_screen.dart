import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final AuthService _authService = AuthService();
  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await _authService.getAllUsers();
    if (mounted) {
      setState(() {
        _allUsers = users;
        _filteredUsers = _allUsers;
      });
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = _allUsers
          .where((user) =>
              user.username.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _showResetPasswordDialog(User user) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset mật khẩu cho ${user.username}'),
        content: TextField(
          controller: passwordController,
          decoration: const InputDecoration(
            labelText: 'Mật khẩu mới',
            border: OutlineInputBorder(),
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text.isNotEmpty) {
                final success = await _authService.resetPassword(
                  user.username, 
                  user.email, 
                  passwordController.text
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success 
                        ? 'Reset mật khẩu thành công' 
                        : 'Lỗi khi reset mật khẩu'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm người dùng...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: _filterUsers,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredUsers.length,
            itemBuilder: (context, index) {
              final user = _filteredUsers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: user.isAdmin ? AppColors.primary : Colors.grey,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  user.username,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(user.isAdmin ? 'Quản trị viên' : 'Người dùng'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.lock_reset, color: Colors.blue),
                      onPressed: () => _showResetPasswordDialog(user),
                      tooltip: 'Reset mật khẩu',
                    ),
                    if (!user.isAdmin)
                      Switch(
                        value: !user.isDeactivated,
                        onChanged: (value) async {
                          final success = await _authService.toggleUserStatus(user.username);
                          if (success) {
                            _loadUsers();
                          }
                        },
                        activeThumbColor: AppColors.primary,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
