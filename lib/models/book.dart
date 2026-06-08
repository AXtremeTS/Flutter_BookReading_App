class Book {
  final String id;
  final String title;
  final String author;
  final String coverImage;
  final String description;
  final double rating;
  final List<String> tags;
  final List<Chapter> chapters;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverImage,
    required this.description,
    required this.rating,
    required this.tags,
    required this.chapters,
  });
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
}
