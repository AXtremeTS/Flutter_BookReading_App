import '../models/book.dart';
import '../models/review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

class BookService {
  static final BookService _instance = BookService._internal();
  factory BookService() => _instance;
  BookService._internal();

  final _supabase = Supabase.instance.client;
  final AuthService _authService = AuthService();

  // Danh sách lưu trữ tạm thời trên bộ nhớ RAM để tối ưu hiển thị
  List<Book> _allBooks = [];
  List<Book> get allBooks => _allBooks;
  // For favorite and read books tracking
  final Set<int> _favoriteBookIds = {};
  final Set<int> _readBookIds = {};

  /// 1. Tải danh sách tất cả các sách (Bảng Books)
  Future<List<Book>> fetchAllBooks() async {
    try {
      // Lấy sách và nối với bảng Tags thông qua bảng trung gian BookTags
      final response = await _supabase
          .from('books')
          .select('*, booktags(tags(tagname))') // Cú pháp JOIN nhiều-nhiều
          .order('createdat', ascending: false);

      return (response as List<dynamic>).map((json) {
        // Chuyển đổi dữ liệu JSON phức tạp thành danh sách String cho Tags
        List<String> parsedTags = [];
        if (json['booktags'] != null) {
          final tagsList = json['booktags'] as List<dynamic>;
          for (var item in tagsList) {
            if (item['tags'] != null && item['tags']['tagname'] != null) {
              parsedTags.add(item['tags']['tagname'].toString());
            }
          }
        }
        
        // Trả về đối tượng Book (đảm bảo hàm fromJson của bạn không ghi đè tags này)
        return Book.fromJson(json).copyWith(tags: parsedTags);
      }).toList();
    } catch (e) {
      print('Fetch Admin Books Error: $e');
      return [];
    }
  }

  /// 2. Lấy chi tiết sách cùng danh sách các Tập/Chương (Bảng Volumes)
  Future<Book?> fetchBookDetails(int bookId) async {
    try {
      // Tải thông tin sách
      final bookResponse = await _supabase
          .from('books')
          .select()
          .eq('bookid', bookId)
          .single();

      // Tải tất cả các chương thuộc cuốn sách đó
      final volumesResponse = await _supabase
          .from('volumes')
          .select()
          .eq('bookid', bookId)
          .order('volumeno', ascending: true);

      final List<Chapter> chapters = (volumesResponse as List<dynamic>)
          .map((json) => Chapter.fromJson(json))
          .toList();

      return Book.fromJson(bookResponse, chapters: chapters);
    } catch (e) {
      print('Fetch Book Details Error: $e');
      return null;
    }
  }

  /// 3. Lấy danh sách các bình luận của một cuốn sách (Bảng Comments + Users)
  Future<List<Review>> fetchComments(int bookId) async {
    try {
      // Cú pháp đặc biệt tuyển tập cột bảng liên kết: lồng bảng 'users' vào select
      final response = await _supabase
          .from('comments')
          .select('*, users(fullname, username, avatarurl)')
          .eq('bookid', bookId)
          .eq('ishidden', false)
          .order('createdat', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Review.fromJson(json))
          .toList();
    } catch (e) {
      print('Fetch Comments Error: $e');
      return [];
    }
  }

  /// 4. Thêm bình luận mới và chấm điểm (Bảng Comments và tự động kích hoạt Trigger Ratings)
  Future<bool> addComment({
    required int bookId,
    int? volumeId,
    required String content,
    double? ratingScore,
  }) async {
    final user = _authService.currentUser;
    if (user == null) return false;

    try {
      // 4.1 Thêm dữ liệu vào bảng Comments
      await _supabase.from('comments').insert({
        'bookid': bookId,
        'volumeid': volumeId,
        'userid': user.userId,
        'content': content,
        'score': ratingScore?.toInt(),
      });

      // 4.2 Nếu người dùng có đánh giá số sao (ratingScore), thêm hoặc cập nhật bảng Ratings
      // để kích hoạt trigger tự động tính điểm tổng cho cuốn sách ngoài Postgres.
      if (ratingScore != null && ratingScore > 0) {
        await _supabase.from('ratings').upsert({
          'userid': user.userId,
          'bookid': bookId,
          'score': ratingScore.toInt(),
          'updatedat': DateTime.now().toIso8601String(),
        }, onConflict: 'userid,bookid');
      }

      return true;
    } catch (e) {
      print('Add Comment Error: $e');
      return false;
    }
  }

  /// 5. Kiểm tra sách có nằm trong danh sách yêu thích của User không (Bảng Favorites)
  Future<bool> isFavorite(int bookId) async {
    final user = _authService.currentUser;
    if (user == null) return false;

    try {
      final response = await _supabase
          .from('favorites')
          .select()
          .eq('userid', user.userId)
          .eq('bookid', bookId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// 6. Bật/Tắt yêu thích sách (Bảng Favorites)
  Future<bool> toggleFavorite(int bookId) async {
    final user = _authService.currentUser;
    if (user == null) return false;

    try {
      final isFav = await isFavorite(bookId);
      if (isFav) {
        // Nếu đã thích thì xóa đi
        await _supabase
            .from('favorites')
            .delete()
            .eq('userid', user.userId)
            .eq('bookid', bookId);
      } else {
        // Chưa thích thì chèn mới vào
        await _supabase.from('favorites').insert({
          'userid': user.userId,
          'bookid': bookId,
        });
      }
      _saveFavorites();
      return true;
    } catch (e) {
      print('Toggle Favorite Error: $e');
      return false;
    }
  }

  /// 7. Cập nhật lịch sử đọc sách khi người dùng mở chương sách (Bảng ReadingHistory)
  Future<void> updateReadingHistory({
    required int bookId,
    int? volumeId,
    int? lastPage,
  }) async {
    final user = _authService.currentUser;
    if (user == null) return;

    try {
      // Sử dụng tính năng upsert để ghi đè lịch sử cũ hoặc tạo lịch sử mới cho người dùng
      await _supabase.from('readinghistory').insert({
        'userid': user.userId,
        'bookid': bookId,
        'volumeid': volumeId,
        'lastreadpage': lastPage,
        'readat': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Update Reading History Error: $e');
    }
  }

  /// 8. Lấy danh sách sách người dùng đã đọc gần đây
  Future<List<Book>> fetchReadingHistory() async {
    final user = _authService.currentUser;
    if (user == null) return [];

    try {
      // Lấy lịch sử và sắp xếp theo thời gian đọc gần nhất (updated_at giảm dần)
      final response = await _supabase
          .from('readinghistory')
          .select('*, books(*)')
          .eq('userid', user.userId)
          .order('readat', ascending: false);

      // Loại bỏ các ID trùng lặp nhưng vẫn giữ nguyên thứ tự thời gian mới nhất
      final historyIds = (response as List<dynamic>)
          .map((item) => item['bookid'] as int)
          .toSet() // Loại bỏ trùng lặp
          .toList();

      // Sắp xếp các đối tượng sách theo đúng thứ tự thời gian đã đọc
      final List<Book> books = [];
      for (var item in historyIds) {
        try {
          final book = _allBooks.firstWhere((b) => b.id == item);
          books.add(book);
        } catch (_) {
          // Bỏ qua nếu không tìm thấy sách tương ứng trong bộ nhớ hệ thống
        }
      }
      return books;
    } catch (e) {
      print('Fetch Reading History Error: $e');
      return [];
    }
  }

  Future<List<Book>> fetchFavoriteBooks() async {
    try {
      final userId = _authService.currentUser?.userId;
      if (userId == null) return [];

      // Lấy danh sách book_id từ bảng user_favorites
      final response = await _supabase
          .from('favorites')
          .select('bookid')
          .eq('userid', userId);

      final favoriteIds = (response as List<dynamic>)
          .map((item) => item['bookid'] as int)
          .toList();

      // Lọc danh sách sách tổng dựa trên các ID yêu thích vừa lấy về
      return _allBooks.where((book) {
        return favoriteIds.contains(book.id);
      }).toList();
    } catch (e) {
      print('Lỗi lấy sách yêu thích từ Supabase: $e');
      return [];
    }
  }

  // ================= TÁC VỤ QUẢN TRỊ (ADMIN) =================

  /// Thêm sách mới vào Supabase
  Future<bool> addBook(Book book) async {
    try {
      final int defaultCategoryId = 1; 

      // 1. Lưu Sách vào bảng Books
      final bookResponse = await _supabase.from('books').insert({
        'title': book.title,
        'author': book.author,
        'description': book.description,
        'imageurl': book.coverImage,
        'categoryid': defaultCategoryId,
        'ishidden': book.isHidden,
      }).select().single();

      final newBookId = bookResponse['bookid'] as int;

      // 2. Xử lý lưu Tags
      if (book.tags.isNotEmpty) {
        await _syncTagsForBook(newBookId, book.tags);
      }

      return true;
    } catch (e) {
      print('Lỗi thêm sách: $e');
      return false;
    }
  }

  /// Cập nhật thông tin sách hiện có
  Future<bool> updateBook(Book book) async {
    try {
      // 1. Cập nhật thông tin cơ bản của Sách
      await _supabase.from('books').update({
        'title': book.title,
        'author': book.author,
        'description': book.description,
        'imageurl': book.coverImage,
        'ishidden': book.isHidden,
      }).eq('bookid', book.id); // Đảm bảo ID là số nguyên

      // 2. Xóa toàn bộ liên kết Tags cũ của sách này
      final bookIdInt = book.id;
      await _supabase.from('booktags').delete().eq('bookid', bookIdInt);

      // 3. Tạo lại liên kết Tags mới
      if (book.tags.isNotEmpty) {
        await _syncTagsForBook(bookIdInt, book.tags);
      }

      return true;
    } catch (e) {
      print('Lỗi cập nhật sách: $e');
      return false;
    }
  }

  /// Xóa sách khỏi Supabase
  Future<bool> deleteBook(int bookId) async {
    try {
      // Do PostgreSQL đã có ON DELETE CASCADE ở các bảng BookTags, Volumes, Comments, v.v.
      // Bạn chỉ cần xóa ở bảng Books, dữ liệu liên quan sẽ tự động bị xóa sạch.
      await _supabase.from('books').delete().eq('bookid', bookId);
      return true;
    } catch (e) {
      print('Lỗi xóa sách: $e');
      return false;
    }
  }

  /// Hàm hỗ trợ: Đồng bộ danh sách tên Thể loại (String) vào Database
  Future<void> _syncTagsForBook(int bookId, List<String> tagNames) async {
    for (String tagName in tagNames) {
      final trimmedTag = tagName.trim();
      if (trimmedTag.isEmpty) continue;

      int currentTagId;

      // A. Kiểm tra xem Tag này đã tồn tại trong DB chưa
      final existingTag = await _supabase
          .from('tags')
          .select('tagid')
          .ilike('tagname', trimmedTag) // Tìm kiếm không phân biệt hoa thường
          .maybeSingle();

      if (existingTag != null) {
        currentTagId = existingTag['tagid'] as int;
      } else {
        // B. Nếu chưa có, tạo Tag mới
        final newTag = await _supabase.from('tags').insert({
          'tagname': trimmedTag
        }).select('tagid').single();
        currentTagId = newTag['tagid'] as int;
      }

      // C. Liên kết TagId và BookId vào bảng trung gian
      await _supabase.from('booktags').upsert({
        'bookid': bookId,
        'tagid': currentTagId,
      });
    }
  }

  /// Bật/Tắt trạng thái ẩn của sách (Chỉ Admin)
  Future<bool> toggleBookVisibility(int bookId) async {
    try {
      // Lấy trạng thái ishidden hiện tại
      final response = await _supabase
          .from('books')
          .select('ishidden')
          .eq('bookid', bookId)
          .single();

      final currentStatus = response['ishidden'] as bool;

      // Cập nhật đảo ngược trạng thái
      await _supabase
          .from('books')
          .update({'ishidden': !currentStatus})
          .eq('bookid', bookId);

      return true;
    } catch (e) {
      print('Lỗi thay đổi trạng thái hiển thị: $e');
      return false;
    }
  }

  List<Book> get favoriteBooks =>
      _allBooks.where((book) => _favoriteBookIds.contains(book.id)).toList();

  List<Book> get readBooks =>
      _allBooks.where((book) => _readBookIds.contains(book.id)).toList();

  // bool isFavorite(int bookId) => _favoriteBookIds.contains(bookId);
  bool isRead(int bookId) => _readBookIds.contains(bookId);

  void markAsRead(int bookId) {
    _readBookIds.add(bookId);
    _saveReadBooks();
  }

  String get _favoritesKey {
    final username = _authService.currentUser?.username ?? 'default';
    return 'favorites_$username';
  }

  String get _readBooksKey {
    final username = _authService.currentUser?.username ?? 'default';
    return 'read_allBooks_$username';
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _favoritesKey,
      _favoriteBookIds.map((id) => id.toString()).toList(),
    );
  }

  Future<void> _saveReadBooks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _readBooksKey,
      _readBookIds.map((id) => id.toString()).toList(),
    );
  }

  Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    _favoriteBookIds.clear();
    _readBookIds.clear();

    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    final readBooks = prefs.getStringList(_readBooksKey) ?? [];

    _favoriteBookIds.addAll(favorites.map(int.parse));
    _readBookIds.addAll(readBooks.map(int.parse));
  }

  List<Book> searchBooks(String query) {
    final books = allBooks;
    if (query.isEmpty) return books;

    query = query.toLowerCase();
    return books.where((book) {
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
  }

  List<Book> filterByTags(List<String> tags) {
    final books = allBooks;
    if (tags.isEmpty) return books;

    return books.where((book) {
      return book.tags.any((tag) => tags.contains(tag));
    }).toList();
  }

  Book? getBookById(int id) {
    try {
      return _allBooks.firstWhere((book) => book.id == id);
    } catch (e) {
      return null;
    }
  }

  List<String> getAllTags() {
    final tags = <String>{};
    for (var book in _allBooks) {
      tags.addAll(book.tags);
    }
    return tags.toList()..sort();
  }
}
