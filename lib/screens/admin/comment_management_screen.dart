import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/book.dart';
import '../../models/review.dart';
import '../../services/review_service.dart';

class CommentManagementScreen extends StatefulWidget {
  final Book? book;
  const CommentManagementScreen({super.key, this.book});

  @override
  State<CommentManagementScreen> createState() => _CommentManagementScreenState();
}

class _CommentManagementScreenState extends State<CommentManagementScreen> {
  final ReviewService _reviewService = ReviewService();
  List<Review> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final reviews = await _reviewService.getBookReviews(widget.book?.id, isAdmin: true);
    if (mounted) {
      setState(() {
        _reviews = reviews;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.book != null ? 'Bình luận: ${widget.book!.title}' : 'Quản lý bình luận',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: _reviews.isEmpty
          ? const Center(child: Text('Không có bình luận nào'))
          : ListView.builder(
              itemCount: _reviews.length,
              itemBuilder: (context, index) {
                final review = _reviews[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(review.userAvatar),
                  ),
                  title: Text(review.userName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (i) => Icon(
                          Icons.star,
                          size: 16,
                          color: i < review.rating ? Colors.amber : Colors.grey,
                        )),
                      ),
                      Text(review.comment),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      review.isHidden ? Icons.visibility_off : Icons.visibility,
                      color: review.isHidden ? Colors.red : Colors.green,
                    ),
                    onPressed: () async {
                      final success = await _reviewService.toggleReviewVisibility(review.id);
                      if (success) {
                        _loadReviews();
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
