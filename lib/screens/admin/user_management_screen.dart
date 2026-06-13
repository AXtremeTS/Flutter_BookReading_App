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

  bool _isLoading = true; // Thêm trạng thái loading cho mạng

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // Tách riêng hàm tải dữ liệu thành hàm async độc lập
  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      // Đợi lấy dữ liệu từ Supabase xong
      final users = await _authService.getAllUsers();

      // Kiểm tra mounted trước khi gọi setState trong môi trường async
      if (mounted) {
        setState(() {
          _allUsers = users;
          _filteredUsers = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = _allUsers
          .where(
            (user) => user.username.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  void _showResetPasswordDialog(User user) {
    final controller = TextEditingController();
    bool isResetting = false; // Trạng thái loading nội bộ của dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Không cho bấm ra ngoài khi đang xử lý
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Reset mật khẩu cho ${user.username}'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: isResetting
                  ? null
                  : () async {
                      if (controller.text.trim().isNotEmpty) {
                        setDialogState(() => isResetting = true);

                        // Thực hiện đổi mật khẩu trên Supabase
                        final success = await _authService.resetPassword(
                          user.userId,
                          controller.text.trim(),
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Đã cập nhật mật khẩu thành công'
                                    : 'Lỗi cập nhật mật khẩu',
                              ),
                              backgroundColor: success
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: isResetting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Lưu'),
            ),
          ],
        ),
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
                  backgroundColor: user.isAdmin
                      ? AppColors.primary
                      : Colors.grey,
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
                        value: !user
                            .isDeactivated, // Nếu isDeactivated là false (hoạt động) thì switch bật
                        onChanged: (value) async {
                          // Optimistic UI: Đảo trạng thái hiển thị ngay lập tức cho mượt
                          setState(() {
                            // Mẹo nhỏ: Bạn cần định nghĩa lại hàm copyWith hoặc thay đổi tạm trạng thái
                            // Ở đây mình gọi lại API lấy list để đảm bảo dữ liệu chuẩn nhất từ DB
                            _isLoading = true;
                          });

                          // Thực hiện lệnh gọi DB
                          await _authService.toggleUserStatus(user.userId);

                          // Tải lại danh sách sau khi thay đổi xong
                          await _loadUsers();
                        },
                        activeColor: AppColors.primary,
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
