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
  final List<String> mediaUrls;
  final bool isAnnouncement;
  final String moderationStatus;
  final String? moderationReason;
  final List<String> moderationCategories;

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
    this.mediaUrls = const [],
    this.isAnnouncement = false,
    this.moderationStatus = 'APPROVED',
    this.moderationReason,
    this.moderationCategories = const [],
  });

  List<String> get effectiveMediaUrls {
    if (mediaUrls.isNotEmpty) {
      return mediaUrls
          .where((u) => u.isNotEmpty && !u.contains('example.com'))
          .toList();
    }
    if (imageUrl != null &&
        imageUrl!.isNotEmpty &&
        !imageUrl!.contains('example.com')) {
      return [imageUrl!];
    }
    return const [];
  }

  factory StudentProfilePostModel.fromJson(Map<String, dynamic> json) {
    String? resolveAuthor(Map<String, dynamic> source) {
      final profile = source['profile'] is Map<String, dynamic>
          ? source['profile'] as Map<String, dynamic>
          : null;
      final name =
          (profile != null ? profile['fullName'] : null) ??
          source['fullName'] ??
          source['name'] ??
          source['username'];
      return name?.toString();
    }

    String? resolveAvatar(Map<String, dynamic> source) {
      final profile = source['profile'] is Map<String, dynamic>
          ? source['profile'] as Map<String, dynamic>
          : null;
      final avatar =
          (profile != null ? profile['profilePicture'] : null) ??
          source['profilePicture'] ??
          source['avatar'] ??
          source['photo'];
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

    final rawMediaUrls = (json['mediaUrls'] is List)
        ? (json['mediaUrls'] as List)
              .map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList()
        : <String>[];
    if (rawMediaUrls.isEmpty &&
        imageUrl != null &&
        imageUrl.toString().isNotEmpty) {
      rawMediaUrls.add(imageUrl.toString());
    }

    final rawModerationCategories = (json['moderationCategories'] is List)
        ? (json['moderationCategories'] as List)
              .map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList()
        : <String>[];

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
      isLiked: (json['isLikedByMe'] ?? json['isLiked'] ?? false) == true,
      likes: (json['likes'] is List) ? json['likes'] : [],
      imageUrl:
          imageUrl?.toString() ??
          (rawMediaUrls.isNotEmpty ? rawMediaUrls.first : null),
      mediaUrls: rawMediaUrls,
      isAnnouncement: json['isAnnouncement'] == true,
      moderationStatus: json['moderationStatus']?.toString() ?? 'APPROVED',
      moderationReason: json['moderationReason']?.toString(),
      moderationCategories: rawModerationCategories,
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
    List<String>? mediaUrls,
    bool? isAnnouncement,
    String? moderationStatus,
    String? moderationReason,
    List<String>? moderationCategories,
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
      mediaUrls: mediaUrls ?? this.mediaUrls,
      isAnnouncement: isAnnouncement ?? this.isAnnouncement,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      moderationReason: moderationReason ?? this.moderationReason,
      moderationCategories: moderationCategories ?? this.moderationCategories,
    );
  }
}
