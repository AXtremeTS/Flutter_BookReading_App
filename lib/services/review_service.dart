import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bookreading/models/review.dart';
import 'package:bookreading/services/api_config.dart';
import 'package:bookreading/services/auth_service.dart';

class ReviewService {
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  final AuthService _authService = AuthService();

  Future<List<Review>> getBookReviews(String? bookId, {bool isAdmin = false}) async {
    try {
      String url;
      if (isAdmin) {
        url = bookId != null 
            ? '${ApiConfig.admin}/comments?bookId=$bookId' 
            : '${ApiConfig.admin}/comments';
      } else {
        if (bookId == null) return [];
        url = '${ApiConfig.reviews}/book/$bookId';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: _authService.isLoggedIn ? {'Authorization': 'Bearer ${_authService.token}'} : {},
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((r) => Review.fromJson(r)).toList();
      }
      return [];
    } catch (e) {
      print('Get reviews error: $e');
      return [];
    }
  }

  Future<bool> addReview(String bookId, double rating, String comment) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.reviews),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode({
          'bookId': int.parse(bookId),
          'score': rating.toInt(),
          'content': comment,
        }),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Add review error: $e');
      return false;
    }
  }

  Future<int?> toggleReviewLike(String reviewId) async {
    if (!_authService.isLoggedIn) return null;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.reviews}/$reviewId/like'),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['newLikeCount'];
      }
      return null;
    } catch (e) {
      print('Toggle like error: $e');
      return null;
    }
  }

  Future<bool> toggleReviewVisibility(String reviewId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.admin}/toggle-comment/$reviewId'),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Toggle review visibility error: $e');
      return false;
    }
  }
}
