import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/book.dart';
import '../models/review.dart';
import '../utils/app_colors.dart';
import '../services/book_service.dart';
import '../services/review_service.dart';
import 'reading_screen.dart';
import 'package:intl/intl.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final BookService _bookService = BookService();
  final ReviewService _reviewService = ReviewService();
  final TextEditingController _commentController = TextEditingController();

  double _userRating = 0;
  bool _isLoading = true;
  bool _isFavorite = false;

  List<Review> _reviews = [];
  Set<int> _likedReviewIds = {};
  List<Chapter> _chapters = [];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  /// Tải thông tin từ Supabase khi vừa mở màn hình
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    // Chạy song song nhiều API để tải dữ liệu nhanh hơn
    final results = await Future.wait([
      _bookService.isFavorite(widget.book.id),
      _reviewService.getBookReviews(widget.book.id),
      _reviewService.getLikedReviewIds(widget.book.id),
      _bookService
          .fetchBookDetails(widget.book.id)
          .then((book) => book?.chapters),
      _bookService.isFavorite(widget.book.id)
    ]);

    if (mounted) {
      setState(() {
        _isFavorite = results[0] as bool;
        _reviews = results[1] as List<Review>;
        _likedReviewIds = results[2] as Set<int>;
        _chapters = results[3] as List<Chapter>;
        _isFavorite = results[4] as bool;
        _isLoading = false;
      });
    }
  }

  void _handleFavoriteToggle() async {
    // Lưu lại trạng thái cũ phòng trường hợp lỗi mạng thì hoàn tác (revert)
    final originalStatus = _isFavorite;
    
    // Cập nhật giao diện lập tức để tạo cảm giác mượt mà (Optimistic UI)
    setState(() {
      _isFavorite = !_isFavorite;
    });

    // Gọi lên Server cập nhật dữ liệu thực tế
    final success = await _bookService.toggleFavorite(widget.book.id);
    
    if (!success) {
      // Nếu lỗi mạng/server, hoàn tác lại trạng thái cũ và thông báo
      setState(() {
        _isFavorite = originalStatus;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể cập nhật trạng thái yêu thích. Vui lòng thử lại!')),
      );
    }
  }

  void _submitReview() async {
    if (_commentController.text.trim().isEmpty) return;

    final success = await _reviewService.addReview(
      widget.book.id,
      _userRating,
      _commentController.text.trim(),
    );

    if (success && mounted) {
      _commentController.clear();
      Navigator.pop(context);
      // Tải lại danh sách bình luận
      _loadInitialData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bình luận đã được gửi thành công!',
            style: GoogleFonts.inter(fontSize: 16),
          ),
          backgroundColor: AppColors.semanticSuccess,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showAddReviewDialog() {
    setState(() {
      _userRating = 0;
      _commentController.clear();
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        'Viết bình luận',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Đánh giá của bạn',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                _userRating = (index + 1).toDouble();
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                index < _userRating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: const Color(0xFFFFB800),
                                size: 40,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Nội dung',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _commentController,
                        maxLines: 5,
                        style: GoogleFonts.inter(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Chia sẻ cảm nhận về cuốn sách...',
                          hintStyle: GoogleFonts.inter(
                            color: AppColors.ink.withValues(alpha: 0.4),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed:
                            (_userRating > 0 &&
                                _commentController.text.trim().isNotEmpty)
                            ? _submitReview
                            : null,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Text(
                          'Gửi Bình Luận',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Cover Image
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.canvas.withValues(alpha: 0.95),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.ink,
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.canvas.withValues(alpha: 0.95),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _isFavorite
                            ? AppColors.accentMagenta.withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.2),
                        blurRadius: _isFavorite ? 12 : 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite
                        ? AppColors.accentMagenta
                        : AppColors.ink,
                    size: 20,
                  ),
                ),
                onPressed: _handleFavoriteToggle,
              ),
            ],
            flexibleSpace: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: () {
                final cover = widget.book.coverImage;
                if (cover == null || cover.isEmpty) {
                  return Container(
                    color: AppColors.blockLilac,
                    child: const Center(
                      child: Icon(Icons.book, size: 80, color: AppColors.ink),
                    ),
                  );
                }
                // 1. Nếu là ảnh asset local
                if (cover.startsWith('assets/')) {
                  return Image.asset(cover, fit: BoxFit.cover);
                }
                // 2. Nếu là ảnh URL từ Supabase mạng
                if (cover.startsWith('http')) {
                  return Image.network(
                    cover,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.blockLilac,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 80,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  );
                }
                // // 3. Nếu là ảnh File do admin up từ máy
                // return Image.file(File(cover), fit: BoxFit.cover);
              }(),
            ),
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.canvas,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.book.title,
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            letterSpacing: -0.5,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'by ${widget.book.author}',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            color: AppColors.ink.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Start Reading Button
                        ElevatedButton(
                          onPressed: () {
                            // Cập nhật lịch sử đọc chương đầu tiên trên Database
                            if (widget.book.chapters.isNotEmpty) {
                              _bookService.updateReadingHistory(
                                bookId: widget.book.id,
                                volumeId: widget.book.chapters[0].id,
                              );
                            }

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ReadingScreen(
                                  book: widget.book,
                                  chapters: _chapters,
                                  initialChapter: 0,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Text(
                            'Bắt đầu đọc',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        Text(
                          'Danh sách chương',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // Chapters List
                  ..._chapters.asMap().entries.map((entry) {
                    final index = entry.key;
                    final chapter = entry.value;
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ReadingScreen(
                              book: widget
                                  .book, // Truyền kèm cả danh sách chương đã load vào màn hình đọc
                              chapters: _chapters,
                              initialChapter: index,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppColors.hairlineSoft),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSoft,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${chapter.chapterNumber}',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                chapter.title,
                                style: GoogleFonts.inter(fontSize: 16),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.ink,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // Reviews Section
                  Container(
                    color: AppColors.surfaceSoft,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Đánh giá & Bình luận',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _showAddReviewDialog,
                              icon: const Icon(Icons.rate_review),
                              label: const Text('Viết Đánh Giá'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.blockLime,
                                foregroundColor: AppColors.ink,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                textStyle: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Reviews List
                        ..._reviews.map((review) {
                          final isLiked = _likedReviewIds.contains(review.id);
                          return _ReviewCard(
                            review: review,
                            isLiked: isLiked,
                            onLike: () async {
                              // Đổi UI lập tức để mượt mà
                              setState(() {
                                if (isLiked) {
                                  _likedReviewIds.remove(review.id);
                                } else {
                                  _likedReviewIds.add(review.id);
                                }
                              });
                              // Gọi API chạy ngầm
                              await _reviewService.toggleReviewLike(review.id);
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  final bool isLiked;
  final VoidCallback onLike;

  const _ReviewCard({
    required this.review,
    required this.isLiked,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final timeAgo = _formatTimeAgo(review.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.blockLilac, AppColors.blockPink],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.userName.substring(0, 1).toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            color: const Color(0xFFFFB800),
                            size: 16,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          timeAgo,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.ink.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            review.comment,
            style: GoogleFonts.inter(fontSize: 15, height: 1.6),
          ),
          const SizedBox(height: 16),

          InkWell(
            onTap: onLike,
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isLiked ? AppColors.blockPink : AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: isLiked
                      ? AppColors.accentMagenta.withValues(alpha: 0.3)
                      : AppColors.hairline,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    size: 16,
                    color: isLiked ? AppColors.accentMagenta : AppColors.ink,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    // Cộng đệm thêm 1 (logic local) nếu User vừa nhấn Like
                    '${review.likes + (isLiked ? 1 : 0)}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isLiked ? AppColors.accentMagenta : AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 30)
      return DateFormat('MMM d, yyyy').format(dateTime);
    if (difference.inDays > 0) return '${difference.inDays} ngày trước';
    if (difference.inHours > 0) return '${difference.inHours} giờ trước';
    if (difference.inMinutes > 0) return '${difference.inMinutes} phút trước';
    return 'Vừa xong';
  }
}
