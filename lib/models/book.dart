class Book {
  final String id;
  final String title;
  final String author;
  final String coverImage;
  final String description;
  final double rating;
  final List<String> tags;
  final List<Chapter> chapters;
  bool isHidden;
  final bool isFromFile;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverImage,
    required this.description,
    required this.rating,
    required this.tags,
    required this.chapters,
    this.isHidden = false,
    this.isFromFile = false,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: (json['bookId'] ?? json['id'] ?? '').toString(),
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      coverImage: json['imageUrl'] ?? json['coverImage'] ?? '',
      description: json['description'] ?? '',
      rating: (json['averageScore'] ?? json['rating'] as num?)?.toDouble() ?? 0.0,
      tags: (json['tags'] as List<dynamic>?)?.map((e) {
            if (e is Map) return e['tagName']?.toString() ?? '';
            return e.toString();
          }).toList() ??
          [],
      chapters: ((json['volumes'] ?? json['chapters']) as List<dynamic>?)
              ?.map((e) => Chapter.fromJson(e))
              .toList() ??
          [],
      isHidden: json['isHidden'] ?? false,
      isFromFile: json['isCoverFromFile'] ?? false,
    );
  }
}

class Chapter {
  final String id;
  final String title;
  final String content;
  final int chapterNumber;

  Chapter({
    required this.id,
    required this.title,
    required this.content,
    required this.chapterNumber,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: (json['volumeId'] ?? json['id'] ?? '').toString(),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      chapterNumber: json['volumeNo'] ?? json['chapterNumber'] ?? 0,
    );
  }
}
