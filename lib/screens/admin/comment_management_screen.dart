import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/book.dart';
import '../../models/review.dart';
import '../../services/review_service.dart';

class CommentManagementScreen extends StatefulWidget {
  final Book book;
  const CommentManagementScreen({super.key, required this.book});

  @override
  State<CommentManagementScreen> createState() =>
      _CommentManagementScreenState();
}

class _CommentManagementScreenState extends State<CommentManagementScreen> {
  final ReviewService _reviewService = ReviewService();
  List<Review> _reviews = [];
  bool _isLoading = true; // Trạng thái chờ tải bình luận

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  // Gọi API tải bình luận với tham số isAdmin = true để thấy cả bình luận bị ẩn
  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    try {
      final reviews = await _reviewService.getBookReviews(
        widget.book.id,
        isAdmin: true,
      );
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Bật/Tắt ẩn bình luận và làm mới danh sách
  Future<void> _toggleVisibility(int commentId) async {
    // Gọi hàm Stored Procedure hoặc hàm update IsHidden từ Supabase (bạn cần có hàm toggleReviewVisibility trong ReviewService)
    await _reviewService.toggleReviewVisibility(widget.book.id, commentId);

    // Tải lại danh sách để UI cập nhật theo Database
    await _loadReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bình luận: ${widget.book.title}',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reviews.isEmpty
          ? const Center(child: Text('Không có bình luận nào'))
          : ListView.builder(
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final review = _reviews[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      (review.userAvatar != null &&
                              review.userAvatar!.isNotEmpty)
                          ? review.userAvatar!.substring(0, 1).toUpperCase()
                          : review.userName.substring(0, 1).toUpperCase(),
                    ),
                  ),
                  title: Text(
                    review.userName,
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            Icons.star,
                            size: 16,
                            color: i < review.rating
                                ? Colors.amber
                                : Colors.grey[300],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(review.comment),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      review.isHidden ? Icons.visibility_off : Icons.visibility,
                      color: review.isHidden ? Colors.red : Colors.green,
                    ),
                    onPressed: () {
                      setState(() async {
                        _toggleVisibility(
                          review.id,
                        );
                        _loadReviews();
                      });
                    },
                  ),
                );
              },
            ),
    );
  }
}
