class StudentProfilePostModel {
  final int id;
  final String authorName;
  final String? authorAvatarUrl;
  final String content;
  final String? createdAt;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isLiked;
  final List<dynamic> likes;
  final String? imageUrl;

  StudentProfilePostModel({
    required this.id,
    required this.authorName,
    required this.content,
    this.authorAvatarUrl,
    this.createdAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.isLiked = false,
    this.likes = const [],
    this.imageUrl,
  });

  factory StudentProfilePostModel.fromJson(Map<String, dynamic> json) {
    String? resolveAuthor(Map<String, dynamic> source) {
      final name = source['fullName'] ?? source['name'] ?? source['username'];
      return name?.toString();
    }

    String? resolveAvatar(Map<String, dynamic> source) {
      final avatar =
          source['profilePicture'] ?? source['avatar'] ?? source['photo'];
      return avatar?.toString();
    }

    final author = json['author'];
    final user = json['user'];
    String authorName = '';
    String? authorAvatar;

    if (author is Map<String, dynamic>) {
      authorName = resolveAuthor(author) ?? '';
      authorAvatar = resolveAvatar(author);
    } else if (user is Map<String, dynamic>) {
      authorName = resolveAuthor(user) ?? '';
      authorAvatar = resolveAvatar(user);
    }

    if (authorName.isEmpty) {
      authorName = resolveAuthor(json) ?? '';
    }
    if (authorAvatar == null || authorAvatar.isEmpty) {
      authorAvatar = resolveAvatar(json);
    }

    authorName = authorName.isNotEmpty
        ? authorName
        : (json['username'] ?? '').toString();

    final content =
        json['content'] ??
        json['body'] ??
        json['text'] ??
        json['caption'] ??
        '';

    final createdAt = json['createdAt']?.toString();

    final likeCount =
        json['likesCount'] ?? json['likeCount'] ?? json['likes'] ?? 0;
    final commentCount =
        json['commentsCount'] ?? json['commentCount'] ?? json['comments'] ?? 0;
    final shareCount =
        json['sharesCount'] ?? json['shareCount'] ?? json['shares'] ?? 0;

    final imageUrl =
        json['mediaUrl'] ??
        json['imageUrl'] ??
        json['image'] ??
        json['media'] ??
        json['fileUrl'];

    return StudentProfilePostModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      authorName: authorName,
      authorAvatarUrl: authorAvatar,
      content: content.toString(),
      createdAt: createdAt,
      likeCount: likeCount is int ? likeCount : int.tryParse('$likeCount') ?? 0,
      commentCount: commentCount is int
          ? commentCount
          : int.tryParse('$commentCount') ?? 0,
      shareCount: shareCount is int
          ? shareCount
          : int.tryParse('$shareCount') ?? 0,
      isLiked: json['isLikedByMe'] ?? false,
      likes: (json['likes'] is List) ? json['likes'] : [],
      imageUrl: imageUrl?.toString(),
    );
  }

  StudentProfilePostModel copyWith({
    int? id,
    String? authorName,
    String? authorAvatarUrl,
    String? content,
    String? createdAt,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    bool? isLiked,
    List<dynamic>? likes,
    String? imageUrl,
  }) {
    return StudentProfilePostModel(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      isLiked: isLiked ?? this.isLiked,
      likes: likes ?? this.likes,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
