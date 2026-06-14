import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bookreading/models/book.dart';
import 'package:bookreading/services/auth_service.dart';
import 'package:bookreading/services/api_config.dart';

class BookService {
  static final BookService _instance = BookService._internal();
  factory BookService() => _instance;
  BookService._internal();

  final AuthService _authService = AuthService();
  
  // Cache for favorite books (Static to allow clearing without instance)
  static List<Book>? _favoritesCache;
  static DateTime? _cacheTime;

  static void clearCache() {
    _favoritesCache = null;
    _cacheTime = null;
  }

  Future<List<Book>> getAllBooks({int? categoryId, String? search}) async {
    try {
      var url = Uri.parse(ApiConfig.books).replace(queryParameters: {
        if (categoryId != null) 'categoryId': categoryId.toString(),
        if (search != null) 'search': search,
      });

      // 1. Thêm timeout để tránh treo ứng dụng
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((b) => Book.fromJson(b)).toList();
      } else {
        // Ném lỗi tường minh nếu status code không thành công
        throw Exception('Failed to load books with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Get books error: $e');
      // 2. Ném lại lỗi để UI có thể bắt và xử lý
      throw Exception('Failed to connect to the server. Please check your network connection.');
    }
  }

  Future<List<Book>> adminGetAllBooks() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.admin}/books'),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((b) => Book.fromJson(b)).toList();
      }
      return [];
    } catch (e) {
      print('Admin get books error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.categories));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Get categories error: $e');
      return [];
    }
  }

  Future<Book?> getBookById(String id) async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.books}/$id'));
      if (response.statusCode == 200) {
        return Book.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Get book error: $id, $e');
      return null;
    }
  }

  Future<Chapter?> getChapter(String volumeId) async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.books}/volumes/$volumeId'));
      if (response.statusCode == 200) {
        return Chapter.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Get chapter error: $e');
      return null;
    }
  }

  Future<List<Book>> getFavoriteBooks() async {
    // Cache for 30 seconds
    if (_favoritesCache != null && 
        _cacheTime != null && 
        DateTime.now().difference(_cacheTime!).inSeconds < 30) {
      return _favoritesCache!;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/user/favorites'),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        _favoritesCache = data.map((b) => Book.fromJson(b)).toList();
        _cacheTime = DateTime.now();
        return _favoritesCache!;
      }
      return [];
    } catch (e) {
      print('Get favorites error: $e');
      return [];
    }
  }

  Future<bool> toggleFavorite(String bookId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/user/favorites/$bookId'),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );
      if (response.statusCode == 200) {
        _favoritesCache = null; // Invalidate cache
        return true;
      }
      return false;
    } catch (e) {
      print('Toggle favorite error: $e');
      return false;
    }
  }

  Future<List<dynamic>> getReadingHistory() async {
    if (_authService.token == null) return [];
    
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/user/history'),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      print('Get history failed: ${response.statusCode}');
      return [];
    } catch (e) {
      print('Get history error: $e');
      return [];
    }
  }

  Future<bool> updateReadingHistory(String bookId, String volumeId, int page) async {
    if (_authService.token == null) return false;

    try {
      final body = jsonEncode({
        'bookId': int.parse(bookId),
        'volumeId': (volumeId == '0' || volumeId.isEmpty) ? null : int.tryParse(volumeId),
        'lastReadPage': page,
      });
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/user/history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
        body: body,
      );
      
      print('Update history for Book $bookId: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Update history error: $e');
      return false;
    }
  }

  // Admin methods
  Future<bool> toggleBookVisibility(String bookId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.admin}/toggle-book/$bookId'),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Toggle book visibility error: $e');
      return false;
    }
  }

  Future<bool> addBook(Book book) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.admin}/books'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode({
          'title': book.title,
          'author': book.author,
          'description': book.description,
          'imageUrl': book.coverImage,
          'isCoverFromFile': book.isFromFile,
          'isHidden': book.isHidden,
          'tags': book.tags.map((t) => {'tagName': t}).toList(),
        }),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Add book error: $e');
      return false;
    }
  }

  Future<bool> updateBook(Book book) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.admin}/books/${book.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_authService.token}',
        },
        body: jsonEncode({
          'bookId': int.parse(book.id),
          'title': book.title,
          'author': book.author,
          'description': book.description,
          'imageUrl': book.coverImage,
          'isCoverFromFile': book.isFromFile,
          'isHidden': book.isHidden,
          'tags': book.tags.map((t) => {'tagName': t}).toList(),
        }),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Update book error: $e');
      return false;
    }
  }

  Future<String?> deleteBook(String bookId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.admin}/books/$bookId'),
        headers: {'Authorization': 'Bearer ${_authService.token}'},
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        return null; // Success
      }
      return response.body.isNotEmpty ? response.body : 'Xóa sách thất bại';
    } catch (e) {
      print('Delete book error: $e');
      return 'Lỗi kết nối: $e';
    }
  }

  Future<bool> isFavorite(String bookId) async {
    final favorites = await getFavoriteBooks();
    return favorites.any((b) => b.id == bookId);
  }

  Future<bool> isRead(String bookId) async {
    try {
      final history = await getReadingHistory();
      return history.any((h) => (h['bookId'] ?? h['BookId']).toString() == bookId);
    } catch (e) {
      return false;
    }
  }

  Future<List<Book>> getReadBooks() async {
    try {
      final history = await getReadingHistory();
      if (history.isEmpty) return [];

      // Extract unique book IDs
      final bookIds = history
          .map((h) => (h['bookId'] ?? h['BookId']).toString())
          .where((id) => id != 'null' && id.isNotEmpty)
          .toSet()
          .toList();

      // Fetch all books in parallel
      final bookFutures = bookIds.map((id) => getBookById(id));
      final booksResults = await Future.wait(bookFutures);

      return booksResults.whereType<Book>().toList();
    } catch (e) {
      print('Get read books error: $e');
      return [];
    }
  }
}
