class Review {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar; // initials or icon
  final double rating;
  final String comment;
  final DateTime createdAt;
  final int likes;
  bool isHidden;

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
  });
}
