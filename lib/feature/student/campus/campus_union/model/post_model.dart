class PostWallModel {
  final int id;
  final int authorId;
  final String imageUrl;
  final String title;
  final String subtitle;
  final int time;
  final String status;
  final String? statusImageUrl;
  final int like;
  final int comment;
  final int share;
  final bool isLiked;
  final List<dynamic> likes;

  PostWallModel({
    this.id = 0,
    required this.authorId,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.status,
    this.statusImageUrl,
    required this.like,
    required this.comment,
    required this.share,
    this.isLiked = false,
    this.likes = const [],
  });

  PostWallModel copyWith({
    int? id,
    int? authorId,
    String? imageUrl,
    String? title,
    String? subtitle,
    int? time,
    String? status,
    String? statusImageUrl,
    int? like,
    int? comment,
    int? share,
    bool? isLiked,
    List<dynamic>? likes,
  }) {
    return PostWallModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      time: time ?? this.time,
      status: status ?? this.status,
      statusImageUrl: statusImageUrl ?? this.statusImageUrl,
      like: like ?? this.like,
      comment: comment ?? this.comment,
      share: share ?? this.share,
      isLiked: isLiked ?? this.isLiked,
      likes: likes ?? this.likes,
    );
  }

  factory PostWallModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] ?? {};
    final profile = author['profile'] ?? {};
    final fullName =
        profile['fullName'] ?? author['username'] ?? 'Unknown User';
    final profileImage = profile['profilePicture'] ?? '';
    final createdAt = json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now();
    final difference = DateTime.now().difference(createdAt).inHours;

    return PostWallModel(
      id: json['id'] ?? 0,
      authorId: author['id'] ?? 0,
      imageUrl: profileImage.isNotEmpty
          ? profileImage
          : 'https://i.pravatar.cc/150?img=3',
      title: fullName,
      subtitle: profile['designation'] ?? author['role'] ?? '',
      time: difference,
      status: json['content'] ?? '',
      statusImageUrl: json['mediaUrl'],
      like: json['likeCount'] ?? 0,
      comment: json['commentCount'] ?? 0,
      share: 0,
      isLiked: json['isLikedByMe'] ?? false,
      likes: (json['likes'] is List) ? json['likes'] : [],
    );
  }
}
