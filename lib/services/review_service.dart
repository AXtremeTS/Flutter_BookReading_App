import '../models/review.dart';
import 'auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final _supabase = Supabase.instance.client;
  final _authService = AuthService();
  final Set<String> _likedReviews = {};
  // In-memory cache for book reviews (keyed by bookId)
  final Map<int, List<Review>> _bookReviews = {};

  /// Lấy danh sách bình luận của một cuốn sách (Join với bảng Users)
  Future<List<Review>> getBookReviews(int bookId, {bool isAdmin = false}) async {
    try {
      // 1. Tạo query cơ bản với các filter ban đầu
      var query = _supabase
          .from('comments')
          .select('*, users(fullname, username, avatarurl)')
          .eq('bookid', bookId);

      // 2. Thêm filter có điều kiện
      if (!isAdmin) {
        query = query.eq('ishidden', false);
      }

      // 3. Áp dụng order (modifier) ở bước cuối cùng và await kết quả
      final response = await query.order('createdat', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Review.fromJson(json))
          .toList();
    } catch (e) {
      print('Get Reviews Error: $e');
      return [];
    }
  }

  /// Lấy danh sách ID các bình luận mà người dùng hiện tại đã Like
  Future<Set<int>> getLikedReviewIds(int bookId) async {
    final user = _authService.currentUser;
    if (user == null) return {};

    try {
      // Chỉ lấy commentid từ CommentLikes do User hiện tại thực hiện
      final response = await _supabase
          .from('commentlikes')
          .select('commentid')
          .eq('userid', user.userId);
          
      return (response as List<dynamic>)
          .map((e) => e['commentid'] as int)
          .toSet();
    } catch (e) {
      return {};
    }
  }

  /// Toggle Trạng thái Like cho 1 Bình luận
  Future<bool> toggleReviewLike(int commentId) async {
    final user = _authService.currentUser;
    if (user == null) return false;

    try {
      // Kiểm tra xem User đã like bình luận này chưa
      final existing = await _supabase
          .from('commentlikes')
          .select()
          .eq('commentid', commentId)
          .eq('userid', user.userId)
          .maybeSingle();

      if (existing != null) {
        // Nếu đã like -> Xóa like
        await _supabase
            .from('commentlikes')
            .delete()
            .eq('commentid', commentId)
            .eq('userid', user.userId);
        return false; // Trả về trạng thái "chưa like"
      } else {
        // Nếu chưa like -> Thêm like mới
        await _supabase.from('commentlikes').insert({
          'commentid': commentId,
          'userid': user.userId,
        });
        return true; // Trả về trạng thái "đã like"
      }
    } catch (e) {
      print('Toggle Like Error: $e');
      return false;
    }
  }

  /// Thêm bình luận mới và chấm điểm (Cập nhật cả bảng Comments và Ratings)
  Future<bool> addReview(int bookId, double rating, String commentContent) async {
    final user = _authService.currentUser;
    if (user == null) return false;

    try {
      // 1. Lưu nội dung bình luận
      await _supabase.from('comments').insert({
        'bookid': bookId,
        'userid': user.userId,
        'content': commentContent,
        'score': rating > 0 ? rating.toInt() : null, // Chỉ gán điểm nếu có chấm sao
      });

      // 2. Lưu vào bảng Ratings nếu người dùng có chọn số sao
      // Upsert để ghi đè điểm nếu user đã từng rate cuốn này rồi
      if (rating > 0) {
        await _supabase.from('ratings').upsert({
          'userid': user.userId,
          'bookid': bookId,
          'score': rating.toInt(),
          'updatedat': DateTime.now().toIso8601String(),
        }, onConflict: 'userid,bookid');
      }

      return true;
    } catch (e) {
      print('Add Review Error: $e');
      return false;
    }
  }

  Future<void> toggleReviewVisibility(int bookId, int reviewId) async {
    try {
      // 1. Lấy trạng thái ẩn hiện hiện tại
      final res = await _supabase
          .from('reviews') // hoặc tên bảng comment của bạn
          .select('ishidden')
          .eq('reviewid', reviewId)
          .single();

      bool currentHidden = res['ishidden'] ?? false;

      // 2. Cập nhật đảo ngược trạng thái (True -> False, False -> True)
      await _supabase
          .from('reviews')
          .update({'ishidden': !currentHidden})
          .eq('reviewid', reviewId);
    } catch (e) {
      print("Lỗi ẩn bình luận: $e");
    }
  }

  bool isReviewLiked(int reviewId) {
    return _likedReviews.contains(reviewId);
  }

  Future<double> getAverageRating(int bookId) async {
    final reviews = await getBookReviews(bookId);
    if (reviews.isEmpty) return 0.0;

    final sum = reviews.fold<double>(0, (prev, review) => prev + review.rating);
    return sum / reviews.length;
  }

  Future<int> getReviewCount(int bookId) async {
    final reviews = await getBookReviews(bookId);
    return reviews.length;
  }
}