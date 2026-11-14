class PostWallModel {
  final int id;
  final int authorId;
  final String imageUrl;
  final String title;
  final String subtitle;
  final int time;
  final String status;
  final String? statusImageUrl;
  final List<String> mediaUrls;
  final bool isAnnouncement;
  final String moderationStatus;
  final String? moderationReason;
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
    this.mediaUrls = const [],
    this.isAnnouncement = false,
    this.moderationStatus = 'APPROVED',
    this.moderationReason,
    required this.like,
    required this.comment,
    required this.share,
    this.isLiked = false,
    this.likes = const [],
  });

  List<String> get effectiveMediaUrls {
    if (mediaUrls.isNotEmpty) {
      return mediaUrls
          .where((u) => u.isNotEmpty && !u.contains('example.com'))
          .toList();
    }
    if (statusImageUrl != null &&
        statusImageUrl!.isNotEmpty &&
        !statusImageUrl!.contains('example.com')) {
      return [statusImageUrl!];
    }
    return const [];
  }

  PostWallModel copyWith({
    int? id,
    int? authorId,
    String? imageUrl,
    String? title,
    String? subtitle,
    int? time,
    String? status,
    String? statusImageUrl,
    List<String>? mediaUrls,
    bool? isAnnouncement,
    String? moderationStatus,
    String? moderationReason,
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
      mediaUrls: mediaUrls ?? this.mediaUrls,
      isAnnouncement: isAnnouncement ?? this.isAnnouncement,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      moderationReason: moderationReason ?? this.moderationReason,
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
    final profileImage = (profile['profilePicture'] ?? '').toString();
    final createdAt = json['createdAt'] != null
        ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
        : DateTime.now();
    final difference = DateTime.now().difference(createdAt).inHours;

    final rawMediaUrl = json['mediaUrl']?.toString();
    final rawMediaUrls = (json['mediaUrls'] is List)
        ? (json['mediaUrls'] as List)
              .map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList()
        : <String>[];
    if (rawMediaUrls.isEmpty &&
        rawMediaUrl != null &&
        rawMediaUrl.isNotEmpty) {
      rawMediaUrls.add(rawMediaUrl);
    }

    return PostWallModel(
      id: json['id'] ?? 0,
      authorId: author['id'] ?? json['authorId'] ?? 0,
      imageUrl: profileImage.isNotEmpty
          ? profileImage
          : 'https://i.pravatar.cc/150?img=3',
      title: fullName.toString(),
      subtitle: (profile['designation'] ?? author['role'] ?? '').toString(),
      time: difference,
      status: (json['content'] ?? '').toString(),
      statusImageUrl:
          rawMediaUrl ?? (rawMediaUrls.isNotEmpty ? rawMediaUrls.first : null),
      mediaUrls: rawMediaUrls,
      isAnnouncement: json['isAnnouncement'] == true,
      moderationStatus: (json['moderationStatus'] ?? 'APPROVED').toString(),
      moderationReason: json['moderationReason']?.toString(),
      like: json['likeCount'] ?? 0,
      comment: json['commentCount'] ?? 0,
      share: 0,
      isLiked: json['isLikedByMe'] ?? false,
      likes: (json['likes'] is List) ? json['likes'] : [],
    );
  }
}
