class Review {
  final int id;
  final int bookId;
  final int? volumeId;
  final int userId;
  final String userName;
  final String? userAvatar;
  final double rating; // Ánh xạ từ cột score (SMALLINT)
  final String comment; // Ánh xạ từ cột content (TEXT)
  final DateTime createdAt;
  final int likes;
  bool isHidden;

  Review({
    required this.id,
    required this.bookId,
    this.volumeId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.likes = 0,
    this.isHidden = false,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // Lấy thông tin user đi kèm nhờ câu lệnh định dạng Join của Supabase
    final userData = json['users'] as Map<String, dynamic>?;
    
    return Review(
      id: json['commentid'],
      bookId: json['bookid'],
      volumeId: json['volumeid'],
      userId: json['userid'],
      userName: userData?['fullname'] ?? userData?['username'] ?? 'Ẩn danh',
      userAvatar: userData?['avatarurl'],
      rating: (json['score'] ?? 0).toDouble(),
      comment: json['content'] ?? '',
      createdAt: DateTime.parse(json['createdat'] ?? DateTime.now().toString()),
      likes: json['likecount'] ?? 0,
      isHidden: json['ishidden'] ?? false,
    );
  }
}