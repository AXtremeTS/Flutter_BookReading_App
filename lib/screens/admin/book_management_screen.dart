import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../../models/book.dart';
import '../../services/book_service.dart';
import '../../utils/app_colors.dart';
import 'add_edit_book_screen.dart';
import 'comment_management_screen.dart';

class BookManagementScreen extends StatefulWidget {
  const BookManagementScreen({super.key});

  @override
  State<BookManagementScreen> createState() => _BookManagementScreenState();
}

class _BookManagementScreenState extends State<BookManagementScreen> {
  final BookService _bookService = BookService();
  List<Book> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  // Tách riêng hàm async để tải dữ liệu thay vì bọc trong setState
  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    try {
      // Hàm này giả định trong BookService đã được viết để tải toàn bộ sách (kể cả sách bị ẩn)
      final books = await _bookService.fetchAllBooks();
      if (mounted) {
        setState(() {
          _books = books;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tải danh sách sách: $e')));
      }
    }
  }

  /// Thực hiện xóa sách bất đồng bộ trên Supabase
  void _deleteBook(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa cuốn sách này khỏi hệ thống Cloud?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Đóng dialog trước
              setState(() => _isLoading = true);
              try {
                // Gọi hàm xóa sách trong Service (Trả về boolean hoặc throw lỗi)
                final success = await _bookService.deleteBook(id);

                // Tải lại danh sách sau khi xóa thành công
                await _loadBooks();
                if (mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Xóa sách thành công!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Xóa sách thất bại!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Khối logic xử lý hình ảnh chung cho cả Asset, Network và File
  Widget _buildCoverImage(String? cover) {
    if (cover == null || cover.isEmpty) {
      return Container(
        width: 50,
        height: 75,
        color: Colors.grey[300],
        child: const Icon(Icons.book, color: Colors.grey),
      );
    }
    if (cover.startsWith('assets/')) {
      return Image.asset(cover, width: 50, height: 75, fit: BoxFit.cover);
    }
    if (cover.startsWith('http')) {
      return Image.network(
        cover,
        width: 50,
        height: 75,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 50,
          height: 75,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image),
        ),
      );
    }
    return Image.file(
      File(cover),
      width: 50,
      height: 75,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: 50,
        height: 75,
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Hiển thị vòng xoay loading khi đang gọi API
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _books.isEmpty
          ? const Center(child: Text("Không có cuốn sách nào trong thư viện"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _books.length,
              itemBuilder: (context, index) {
                final book = _books[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildCoverImage(book.coverImage),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            book.title,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            book.isHidden
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: book.isHidden ? Colors.orange : Colors.grey,
                            size: 20,
                          ),
                          tooltip: book.isHidden
                              ? 'Đang ẩn. Nhấn để hiện'
                              : 'Đang hiện. Nhấn để ẩn',
                          onPressed: () async {
                            // Lưu ý: Đổi book.id sang kiểu int hoặc dùng int.parse(book.id) tùy model
                            final bookIdInt = book.id;
                            if (bookIdInt > 0) {
                              setState(() => _isLoading = true);
                              final success = await _bookService
                                  .toggleBookVisibility(bookIdInt);
                              if (success) {
                                await _loadBooks(); // Tải lại danh sách
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      book.isHidden
                                          ? 'Đã hiển thị sách'
                                          : 'Đã ẩn sách',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                setState(() => _isLoading = false);
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    subtitle: Text(book.author),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.comment, color: Colors.green),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CommentManagementScreen(book: book),
                              ),
                            );
                          },
                          tooltip: 'Quản lý bình luận',
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddEditBookScreen(book: book),
                              ),
                            );
                            if (result == true) _loadBooks();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteBook(book.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditBookScreen()),
          );
          if (result == true) _loadBooks(); // Load lại DS sau khi thêm sách
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
