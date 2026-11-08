class PostModel {
  final int id;
  final String content;
  final String? mediaUrl;
  final Author author;
  final int likeCount;
  final int commentCount;
  final String postableType;
  final int postableId;
  final bool isAnnouncement;
  final bool isLiked;
  final List<dynamic> likes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostModel({
    required this.id,
    required this.content,
    this.mediaUrl,
    required this.author,
    required this.likeCount,
    required this.commentCount,
    required this.postableType,
    required this.postableId,
    required this.isAnnouncement,
    required this.isLiked,
    required this.likes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      content: json['content'] ?? '',
      mediaUrl: json['mediaUrl'],
      author: json['author'] != null
          ? Author.fromJson(json['author'])
          : Author(
              id: 0,
              username: 'Unknown',
              fullName: 'Unknown',
              isPhoneVerified: false,
              role: '',
              isAccRefered: false,
              isReferEnabled: false,
              isFreemiumClaimed: false,
              friendsCount: 0,
              proPartnerName: 'N/A',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      postableType: json['postableType'] ?? 'Wall',
      postableId: json['postableId'] ?? 0,
      isAnnouncement: json['isAnnouncement'] ?? false,
      isLiked: json['isLikedByMe'] ?? false,
      likes: (json['likes'] is List) ? json['likes'] : [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  PostModel copyWith({
    int? id,
    String? content,
    String? mediaUrl,
    Author? author,
    int? likeCount,
    int? commentCount,
    String? postableType,
    int? postableId,
    bool? isAnnouncement,
    bool? isLiked,
    List<dynamic>? likes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      author: author ?? this.author,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      postableType: postableType ?? this.postableType,
      postableId: postableId ?? this.postableId,
      isAnnouncement: isAnnouncement ?? this.isAnnouncement,
      isLiked: isLiked ?? this.isLiked,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Author {
  final int id;
  final String username;
  final String fullName;
  final String? profilePicture;
  final String? phoneNumber;
  final bool isPhoneVerified;
  final String role;
  final bool isAccRefered;
  final bool isReferEnabled;
  final dynamic premiumUntil;
  final bool isFreemiumClaimed;
  final dynamic billingInterval;
  final int friendsCount;
  final String proPartnerName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic lastLoginAt;

  Author({
    required this.id,
    required this.username,
    required this.fullName,
    this.profilePicture,
    this.phoneNumber,
    required this.isPhoneVerified,
    required this.role,
    required this.isAccRefered,
    required this.isReferEnabled,
    this.premiumUntil,
    required this.isFreemiumClaimed,
    this.billingInterval,
    required this.friendsCount,
    required this.proPartnerName,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'];
    final profilePicture =
        (profile != null ? profile['profilePicture'] : null) ??
        json['profilePicture'] ??
        json['avatar'] ??
        json['photo'];
    return Author(
      id: json['id'],
      username: json['username'] ?? '',
      fullName: (profile != null ? profile['fullName'] : null) ??
                json['fullName'] ??
                json['username'] ?? '',
      profilePicture: profilePicture?.toString(),
      phoneNumber: json['phoneNumber'],
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      role: json['role'] ?? '',
      isAccRefered: json['is_acc_refered'] ?? false,
      isReferEnabled: json['isReferEnabled'] ?? false,
      premiumUntil: json['premiumUntil'],
      isFreemiumClaimed: json['isFreemiumClaimed'] ?? false,
      billingInterval: json['billingInterval'],
      friendsCount: json['friendsCount'] ?? 0,
      proPartnerName: json['proPartnerName'] ?? 'N/A',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      lastLoginAt: json['lastLoginAt'],
    );
  }
  Author copyWith({
    int? id,
    String? username,
    String? fullName,
    String? profilePicture,
    String? phoneNumber,
    bool? isPhoneVerified,
    String? role,
    bool? isAccRefered,
    bool? isReferEnabled,
    dynamic premiumUntil,
    bool? isFreemiumClaimed,
    dynamic billingInterval,
    int? friendsCount,
    String? proPartnerName,
    DateTime? createdAt,
    DateTime? updatedAt,
    dynamic lastLoginAt,
  }) {
    return Author(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      profilePicture: profilePicture ?? this.profilePicture,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      role: role ?? this.role,
      isAccRefered: isAccRefered ?? this.isAccRefered,
      isReferEnabled: isReferEnabled ?? this.isReferEnabled,
      premiumUntil: premiumUntil ?? this.premiumUntil,
      isFreemiumClaimed: isFreemiumClaimed ?? this.isFreemiumClaimed,
      billingInterval: billingInterval ?? this.billingInterval,
      friendsCount: friendsCount ?? this.friendsCount,
      proPartnerName: proPartnerName ?? this.proPartnerName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
