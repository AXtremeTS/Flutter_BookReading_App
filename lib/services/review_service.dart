import '../models/review.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  // Mock reviews data - later can be replaced with database
  final Map<String, List<Review>> _bookReviews = {
    '1': [
      Review(
        id: 'r1',
        userId: 'user1',
        userName: 'Sarah Johnson',
        userAvatar: 'SJ',
        rating: 5.0,
        comment: 'An absolute masterpiece! The way this book explores human nature is simply brilliant. I couldn\'t put it down.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        likes: 24,
      ),
      Review(
        id: 'r2',
        userId: 'user2',
        userName: 'Michael Chen',
        userAvatar: 'MC',
        rating: 4.5,
        comment: 'Great read with complex characters. The plot kept me engaged throughout. Highly recommend!',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        likes: 15,
      ),
      Review(
        id: 'r3',
        userId: 'user3',
        userName: 'Emma Davis',
        userAvatar: 'ED',
        rating: 5.0,
        comment: 'One of the best books I\'ve read this year. Beautiful prose and thought-provoking themes.',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        likes: 31,
      ),
    ],
    '2': [
      Review(
        id: 'r4',
        userId: 'user4',
        userName: 'Alex Thompson',
        userAvatar: 'AT',
        rating: 4.0,
        comment: 'Fascinating journey into AI and consciousness. Makes you think about the future.',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        likes: 18,
      ),
      Review(
        id: 'r5',
        userId: 'user5',
        userName: 'Lisa Martinez',
        userAvatar: 'LM',
        rating: 5.0,
        comment: 'Mind-blowing! The author\'s vision of AI is both exciting and terrifying.',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        likes: 27,
      ),
    ],
  };

  final Set<String> _likedReviews = {};

  List<Review> getBookReviews(String bookId) {
    return _bookReviews[bookId] ?? [];
  }

  bool isReviewLiked(String reviewId) {
    return _likedReviews.contains(reviewId);
  }

  void toggleReviewLike(String reviewId) {
    if (_likedReviews.contains(reviewId)) {
      _likedReviews.remove(reviewId);
    } else {
      _likedReviews.add(reviewId);
    }
  }

  void addReview(String bookId, Review review) {
    if (_bookReviews[bookId] == null) {
      _bookReviews[bookId] = [];
    }
    _bookReviews[bookId]!.insert(0, review);
  }

  double getAverageRating(String bookId) {
    final reviews = getBookReviews(bookId);
    if (reviews.isEmpty) return 0.0;
    
    final sum = reviews.fold<double>(0, (prev, review) => prev + review.rating);
    return sum / reviews.length;
  }

  int getReviewCount(String bookId) {
    return getBookReviews(bookId).length;
  }
}
