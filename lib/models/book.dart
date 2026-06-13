class Book {
  final int id; // Đổi sang int để khớp với SERIAL PRIMARY KEY
  final String title;
  final String author;
  final String? coverImage;
  final String? description;
  final double rating;
  final List<String> tags; // Trong schema thực tế có thể lấy từ bảng BookTags liên kết qua Tags
  final List<Chapter> chapters;
  bool isHidden;

  Book({
    required this.id,
    required this.title,
    required this.author,
    this.coverImage,
    this.description,
    required this.rating,
    this.tags = const [],
    this.chapters = const [],
    this.isHidden = false,
  });

  factory Book.fromJson(Map<String, dynamic> json, {List<Chapter> chapters = const []}) {
    // Tính toán số điểm rating trung bình từ TotalScore và TotalVotes
    final int totalVotes = json['totalvotes'] ?? 0;
    final int totalScore = json['totalscore'] ?? 0;
    final double calculatedRating = totalVotes > 0 ? totalScore / totalVotes : 0.0;

    return Book(
      id: json['bookid'],
      title: json['title'],
      author: json['author'],
      coverImage: json['imageurl'],
      description: json['description'],
      rating: calculatedRating,
      isHidden: json['ishidden'] ?? false,
      chapters: chapters,
      tags: [], // Tùy chọn xử lý n-n với bảng Tags sau này
    );
  }

  Book copyWith({
    int? id,
    String? title,
    String? author,
    String? coverImage,
    String? description,
    double? rating,
    List<String>? tags,
    List<Chapter>? chapters,
    bool? isHidden,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      coverImage: coverImage ?? this.coverImage,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
      chapters: chapters ?? this.chapters, // Cho phép thay thế danh sách chương mới
      isHidden: isHidden ?? this.isHidden,
    );
  }
}

class Chapter {
  final int id;
  final int bookId;
  final int chapterNumber;
  final String title;
  final String? content;
  final String? fileUrl;

  Chapter({
    required this.id,
    required this.bookId,
    required this.chapterNumber,
    required this.title,
    this.content,
    this.fileUrl,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['volumeid'],
      bookId: json['bookid'],
      chapterNumber: json['volumeno'],
      title: json['title'],
      content: json['content'],
      fileUrl: json['fileurl'],
    );
  }
}