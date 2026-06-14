import 'package:bookreading/services/auth_service.dart';
import 'package:bookreading/services/review_service.dart';
import 'package:bookreading/services/book_service.dart';
import 'package:bookreading/models/book.dart';
import 'package:bookreading/models/review.dart';
import 'package:bookreading/utils/app_colors.dart';
import 'package:bookreading/screens/reading_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final AuthService _authService = AuthService();
  final TextEditingController _commentController = TextEditingController();
  double _userRating = 0;

  bool _isFavorite = false;
  bool _isRead = false;
  List<Review> _reviews = [];
  bool _isLoadingData = true;
  
  final Map<String, bool> _isLiking = {};

  late Book _currentBook;

  @override
  void initState() {
    super.initState();
    _currentBook = widget.book;
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() => _isLoadingData = true);
    }

    try {
      final results = await Future.wait([
        _bookService.getBookById(widget.book.id),
        _bookService.isFavorite(widget.book.id),
        _bookService.isRead(widget.book.id),
        _reviewService.getBookReviews(widget.book.id),
      ]);

      if (mounted) {
        setState(() {
          if (results[0] != null) {
            _currentBook = results[0] as Book;
          }
          _isFavorite = results[1] as bool;
          _isRead = results[2] as bool;
          _reviews = results[3] as List<Review>;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      print('Error loading book details: $e');
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  
  Future<void> _handleLike(Review review) async {
    if (!_authService.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to like comments.'),
          backgroundColor: AppColors.accentMagenta,
        ),
      );
      return;
    }
    
    if (_isLiking[review.id] == true) return;

    setState(() {
      _isLiking[review.id] = true;
    });

    try {
      final newLikeCount = await _reviewService.toggleReviewLike(review.id);
      if (newLikeCount != null) {
        setState(() {
          review.isLiked = !review.isLiked;
          review.likes = newLikeCount;
        });
      }
    } finally {
      if(mounted) {
        setState(() {
          _isLiking[review.id] = false;
        });
      }
    }
  }


  Future<void> _confirmDeleteBook() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
              'Are you sure you want to delete this book? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style:
                  TextButton.styleFrom(foregroundColor: AppColors.accentMagenta),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final error = await _bookService.deleteBook(_currentBook.id);
      if (!mounted) return;

      if (error == null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book deleted successfully.'),
            backgroundColor: AppColors.semanticSuccess,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.accentMagenta,
          ),
        );
      }
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
                      // Handle
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
                        'Write a Review',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Rating Stars
                      Text(
                        'Your Rating',
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

                      // Comment Field
                      Text(
                        'Your Review',
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
                          hintText: 'Share your thoughts about this book...',
                          hintStyle: GoogleFonts.inter(
                            color: AppColors.ink.withValues(alpha: 0.4),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_userRating > 0 &&
                                _commentController.text.trim().isNotEmpty) {
                              final success = await _reviewService.addReview(
                                  _currentBook.id,
                                  _userRating,
                                  _commentController.text.trim());

                              if (success) {
                                Navigator.pop(context);
                                _loadData(); // Refresh reviews

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Review posted successfully!',
                                      style: GoogleFonts.inter(fontSize: 16),
                                    ),
                                    backgroundColor: AppColors.semanticSuccess,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Text(
                            'Submit Review',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
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
    if (_isLoadingData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back,
                    color: AppColors.ink, size: 20),
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
                onPressed: () async {
                  final success =
                      await _bookService.toggleFavorite(_currentBook.id);
                  if (success) {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                  }
                },
              ),
              if (_authService.isLoggedIn && _authService.currentUser!.isAdmin)
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.canvas.withValues(alpha: 0.95),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentMagenta.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: AppColors.accentMagenta,
                      size: 20,
                    ),
                  ),
                  onPressed: _confirmDeleteBook,
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                _currentBook.coverImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.blockLilac,
                    child: const Center(
                      child: Icon(Icons.book, size: 100, color: AppColors.ink),
                    ),
                  );
                },
              ),
            ),
          ),

          // Book Details
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
                        // Title
                        Text(
                          _currentBook.title,
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            letterSpacing: -0.5,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Author
                        Text(
                          'by ${_currentBook.author}',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: AppColors.ink.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Rating
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              return Icon(
                                index < _currentBook.rating.floor()
                                    ? Icons.star
                                    : (index < _currentBook.rating
                                        ? Icons.star_half
                                        : Icons.star_border),
                                color: const Color(0xFFFFB800),
                                size: 24,
                              );
                            }),
                            const SizedBox(width: 8),
                            Text(
                              _currentBook.rating.toStringAsFixed(1),
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Tags with subtle shadow
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _currentBook.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.blockLime,
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                tag,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.ink,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // Description
                        Text(
                          'Description',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _currentBook.description,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.6,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Start Reading Button with Shadow
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              // We don't have volume id yet, just use first volume for start reading
                              final firstVolumeId =
                                  _currentBook.chapters.isNotEmpty
                                      ? _currentBook.chapters.first.id
                                      : '0';
                              
                              // We MUST await this to ensure history is saved before navigating back or continuing
                              await _bookService.updateReadingHistory(
                                  _currentBook.id, firstVolumeId, 0);
                              
                              if (!mounted) return;
                              
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ReadingScreen(book: _currentBook),
                                ),
                              ).then((_) => _loadData());
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Text(
                              _isRead ? 'Continue Reading' : 'Start Reading',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Chapters List
                        Text(
                          'Chapters',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // Chapter Items with hover effect
                  ..._currentBook.chapters.asMap().entries.map((entry) {
                    final chapter = entry.value;
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 300 + (entry.key * 50)),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(20 * (1 - value), 0),
                            child: InkWell(
                              onTap: () async {
                                // Use first chapter for now when clicking a chapter in the list
                                // (should ideally use the actual chapter id)
                                await _bookService.updateReadingHistory(
                                    _currentBook.id, chapter.id, 0);
                                    
                                if (!mounted) return;
                                
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ReadingScreen(
                                      book: _currentBook,
                                      initialChapter: chapter.chapterNumber - 1,
                                    ),
                                  ),
                                ).then((_) => _loadData());
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.canvas,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppColors.hairlineSoft,
                                    ),
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
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        chapter.title,
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: AppColors.ink,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reviews & Ratings',
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_reviews.length} reviews',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.ink.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.blockLime
                                        .withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _showAddReviewDialog,
                                icon: const Icon(Icons.rate_review),
                                label: Text(
                                  'Write Review',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.blockLime,
                                  foregroundColor: AppColors.ink,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Reviews List
                        ..._reviews.asMap().entries.map((entry) {
                          final review = entry.value;
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration:
                                Duration(milliseconds: 400 + (entry.key * 100)),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: _ReviewCard(
                                    review: review,
                                    isLiking: _isLiking[review.id] ?? false,
                                    onLike: () => _handleLike(review),
                                  ),
                                ),
                              );
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
  final bool isLiking;
  final VoidCallback onLike;

  const _ReviewCard({
    required this.review,
    required this.isLiking,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final isLiked = review.isLiked;
    final timeAgo = _formatTimeAgo(review.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.hairline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // User Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.blockLilac, AppColors.blockPink],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blockLilac.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    review.userAvatar,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
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
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        // Star Rating
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating.floor()
                                ? Icons.star
                                : (index < review.rating
                                    ? Icons.star_half
                                    : Icons.star_border),
                            color: const Color(0xFFFFB800),
                            size: 16,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          timeAgo,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
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

          // Comment
          Text(
            review.comment,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.6,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 16),

          // Like Button
          Row(
            children: [
              InkWell(
                onTap: isLiking ? null : onLike, // Disable button when liking
                borderRadius: BorderRadius.circular(50),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
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
                      isLiking
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentMagenta),
                            )
                          : Icon(
                              isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                              size: 16,
                              color: isLiked ? AppColors.accentMagenta : AppColors.ink,
                            ),
                      const SizedBox(width: 6),
                      Text(
                        '${review.likes}',
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
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final localDateTime = dateTime.toLocal();
    final difference = now.difference(localDateTime);

    if (difference.inDays > 30) {
      return DateFormat('MMM d, yyyy').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
