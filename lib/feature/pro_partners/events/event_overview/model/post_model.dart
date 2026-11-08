class PostModel {
  final String id;
  final String authorName;
  final String authorInitials;
  final String roleLabel; // e.g., Partner
  final String body;
  final String? imageUrl;
  final int likes;
  final int comments;
  final int shares;
  final bool isLiked;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.authorName,
    required this.authorInitials,
    this.roleLabel = '',
    required this.body,
    this.imageUrl,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.isLiked = false,
    required this.createdAt,
  });
}
