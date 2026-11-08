class UnionModel {
  final int id;
  final String name;
  final String description;
  final String category;
  final String? logoUrl;
  final String? coverImageUrl;
  final int createdBy;
  final UnionCreatorModel? creator;
  final String status;
  final int memberCount;
  final int officialCount;
  final String? website;
  final String? email;
  final String? contactNumber;
  final List<String> tags;
  final Map<String, dynamic>? socialLinks;
  final bool isVerified;
  final bool isPublic;
  final bool allowJoinRequests;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserMembership? userMembership;

  UnionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.logoUrl,
    this.coverImageUrl,
    required this.createdBy,
    this.creator,
    required this.status,
    required this.memberCount,
    required this.officialCount,
    this.website,
    this.email,
    this.contactNumber,
    required this.tags,
    this.socialLinks,
    required this.isVerified,
    required this.isPublic,
    required this.allowJoinRequests,
    required this.createdAt,
    required this.updatedAt,
    this.userMembership,
  });

  factory UnionModel.fromJson(Map<String, dynamic> json) {
    return UnionModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      logoUrl: json['logoUrl'],
      coverImageUrl: json['coverImageUrl'],
      createdBy: json['createdBy'] ?? 0,
      creator: json['creator'] != null
          ? UnionCreatorModel.fromJson(json['creator'])
          : null,
      status: json['status'] ?? '',
      memberCount: json['memberCount'] ?? 0,
      officialCount: json['officialCount'] ?? 0,
      website: json['website'],
      email: json['email'],
      contactNumber: json['contactNumber'],
      tags: List<String>.from(json['tags'] ?? []),
      socialLinks: json['socialLinks'],
      isVerified: json['isVerified'] ?? false,
      isPublic: json['isPublic'] ?? true,
      allowJoinRequests: json['allowJoinRequests'] ?? true,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      userMembership: json['userMembership'] != null
          ? UserMembership.fromJson(json['userMembership'])
          : null,
    );
  }
}

class UnionCreatorModel {
  final int id;
  final String username;
  final String? phoneNumber;
  final bool isPhoneVerified;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;

  UnionCreatorModel({
    required this.id,
    required this.username,
    this.phoneNumber,
    required this.isPhoneVerified,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UnionCreatorModel.fromJson(Map<String, dynamic> json) {
    return UnionCreatorModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      phoneNumber: json['phoneNumber'],
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      role: json['role'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class UserMembership {
  final int id;
  final int unionId;
  final int userId;
  final String role;
  final String status;
  final String? position;
  final String? bio;
  final DateTime joinedAt;

  UserMembership({
    required this.id,
    required this.unionId,
    required this.userId,
    required this.role,
    required this.status,
    this.position,
    this.bio,
    required this.joinedAt,
  });

  factory UserMembership.fromJson(Map<String, dynamic> json) {
    return UserMembership(
      id: json['id'] ?? 0,
      unionId: json['unionId'] ?? 0,
      userId: json['userId'] ?? 0,
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      position: json['position'],
      bio: json['bio'],
      joinedAt: DateTime.parse(
        json['joinedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class UnionResponseModel {
  final List<UnionModel> unions;
  final List<UnionModel> forYou;
  final List<UnionModel> yourUnions;
  final int total;
  final int page;
  final int totalPages;

  UnionResponseModel({
    required this.unions,
    required this.forYou,
    required this.yourUnions,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  factory UnionResponseModel.fromJson(Map<String, dynamic> json) {
    return UnionResponseModel(
      unions: (json['unions'] as List? ?? [])
          .map((e) => UnionModel.fromJson(e))
          .toList(),
      forYou: (json['forYou'] as List? ?? [])
          .map((e) => UnionModel.fromJson(e))
          .toList(),
      yourUnions: (json['yourUnions'] as List? ?? [])
          .map((e) => UnionModel.fromJson(e))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}
