class PostModel {
  final int id;
  final String content;
  final String? mediaUrl;
  final List<String> mediaUrls;
  final Author author;
  final int likeCount;
  final int commentCount;
  final String postableType;
  final int postableId;
  final bool isAnnouncement;
  final String moderationStatus;
  final String? moderationReason;
  final List<String> moderationCategories;
  final bool isLiked;
  final List<dynamic> likes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostModel({
    required this.id,
    required this.content,
    this.mediaUrl,
    this.mediaUrls = const [],
    required this.author,
    required this.likeCount,
    required this.commentCount,
    required this.postableType,
    required this.postableId,
    required this.isAnnouncement,
    this.moderationStatus = 'APPROVED',
    this.moderationReason,
    this.moderationCategories = const [],
    required this.isLiked,
    required this.likes,
    required this.createdAt,
    required this.updatedAt,
  });

  List<String> get effectiveMediaUrls {
    if (mediaUrls.isNotEmpty) {
      return mediaUrls
          .where((u) => u.isNotEmpty && !u.contains('example.com'))
          .toList();
    }
    if (mediaUrl != null &&
        mediaUrl!.isNotEmpty &&
        !mediaUrl!.contains('example.com')) {
      return [mediaUrl!];
    }
    return const [];
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
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

    final rawModerationCategories = (json['moderationCategories'] is List)
        ? (json['moderationCategories'] as List)
              .map((e) => e?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList()
        : <String>[];

    return PostModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      content: json['content']?.toString() ?? '',
      mediaUrl: rawMediaUrl ?? (rawMediaUrls.isNotEmpty ? rawMediaUrls.first : null),
      mediaUrls: rawMediaUrls,
      author: json['author'] != null && json['author'] is Map<String, dynamic>
          ? Author.fromJson(json['author'] as Map<String, dynamic>)
          : Author(
              id: json['authorId'] is int
                  ? json['authorId']
                  : int.tryParse('${json['authorId']}') ?? 0,
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
      likeCount: json['likeCount'] is int
          ? json['likeCount']
          : int.tryParse('${json['likeCount']}') ?? 0,
      commentCount: json['commentCount'] is int
          ? json['commentCount']
          : int.tryParse('${json['commentCount']}') ?? 0,
      postableType: json['postableType']?.toString() ?? 'Wall',
      postableId: json['postableId'] is int
          ? json['postableId']
          : int.tryParse('${json['postableId']}') ?? 0,
      isAnnouncement: json['isAnnouncement'] == true,
      moderationStatus: json['moderationStatus']?.toString() ?? 'APPROVED',
      moderationReason: json['moderationReason']?.toString(),
      moderationCategories: rawModerationCategories,
      isLiked: (json['isLikedByMe'] ?? json['isLiked'] ?? false) == true,
      likes: (json['likes'] is List) ? json['likes'] : [],
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  PostModel copyWith({
    int? id,
    String? content,
    String? mediaUrl,
    List<String>? mediaUrls,
    Author? author,
    int? likeCount,
    int? commentCount,
    String? postableType,
    int? postableId,
    bool? isAnnouncement,
    String? moderationStatus,
    String? moderationReason,
    List<String>? moderationCategories,
    bool? isLiked,
    List<dynamic>? likes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      author: author ?? this.author,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      postableType: postableType ?? this.postableType,
      postableId: postableId ?? this.postableId,
      isAnnouncement: isAnnouncement ?? this.isAnnouncement,
      moderationStatus: moderationStatus ?? this.moderationStatus,
      moderationReason: moderationReason ?? this.moderationReason,
      moderationCategories: moderationCategories ?? this.moderationCategories,
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
  final String? designation;
  final bool isVerified;
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
    this.designation,
    this.isVerified = false,
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
    final profile = json['profile'] is Map<String, dynamic>
        ? json['profile'] as Map<String, dynamic>
        : null;
    final profilePicture =
        (profile != null ? profile['profilePicture'] : null) ??
        json['profilePicture'] ??
        json['avatar'] ??
        json['photo'];
    return Author(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      username: json['username']?.toString() ?? '',
      fullName:
          ((profile != null ? profile['fullName'] : null) ??
                  json['fullName'] ??
                  json['username'] ??
                  '')
              .toString(),
      profilePicture: profilePicture?.toString(),
      designation: (profile != null ? profile['designation'] : json['designation'])
          ?.toString(),
      isVerified:
          (profile != null ? profile['isVerified'] : json['isVerified']) ==
          true,
      phoneNumber: json['phoneNumber']?.toString(),
      isPhoneVerified: json['isPhoneVerified'] == true,
      role: json['role']?.toString() ?? '',
      isAccRefered: json['is_acc_refered'] == true,
      isReferEnabled: json['isReferEnabled'] == true,
      premiumUntil: json['premiumUntil'],
      isFreemiumClaimed: json['isFreemiumClaimed'] == true,
      billingInterval: json['billingInterval'],
      friendsCount: json['friendsCount'] is int
          ? json['friendsCount']
          : int.tryParse('${json['friendsCount']}') ?? 0,
      proPartnerName: json['proPartnerName']?.toString() ?? 'N/A',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      lastLoginAt: json['lastLoginAt'],
    );
  }

  Author copyWith({
    int? id,
    String? username,
    String? fullName,
    String? profilePicture,
    String? designation,
    bool? isVerified,
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
      designation: designation ?? this.designation,
      isVerified: isVerified ?? this.isVerified,
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
