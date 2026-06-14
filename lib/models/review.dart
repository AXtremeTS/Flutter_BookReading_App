class Review {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar; // initials or icon
  final double rating;
  final String comment;
  final DateTime createdAt;
  int likes;
  bool isHidden;
  bool isLiked = false;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.likes = 0,
    this.isHidden = false,
    this.isLiked = false,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: (json['commentId'] ?? json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      userName: json['username'] ?? 'Anonymous',
      userAvatar: (json['username'] != null && json['username'].toString().isNotEmpty)
          ? json['username'].toString()[0].toUpperCase()
          : '?',
      rating: (json['score'] as num?)?.toDouble() ?? 0.0,
      comment: json['content'] ?? json['commentText'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString().endsWith('Z') ? json['createdAt'] : json['createdAt'].toString() + 'Z')
          : DateTime.now(),
      likes: json['likeCount'] ?? json['likes'] ?? 0,
      isHidden: json['isHidden'] ?? false,
    );
  }
}



