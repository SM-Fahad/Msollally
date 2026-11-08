class UnionMemberModel {
  final int id;
  final int unionId;
  final int userId;
  final String role;
  final String status;
  final String? position;
  final String? bio;
  final DateTime joinedAt;
  final UnionMemberUser? user;

  const UnionMemberModel({
    required this.id,
    required this.unionId,
    required this.userId,
    required this.role,
    required this.status,
    this.position,
    this.bio,
    required this.joinedAt,
    this.user,
  });

  factory UnionMemberModel.fromJson(Map<String, dynamic> json) {
    return UnionMemberModel(
      id: json['id'] ?? 0,
      unionId: json['unionId'] ?? 0,
      userId: json['userId'] ?? 0,
      role: json['role'] ?? 'member',
      status: json['status'] ?? 'active',
      position: json['position'],
      bio: json['bio'],
      joinedAt: DateTime.tryParse(json['joinedAt'] ?? '') ?? DateTime.now(),
      user: json['user'] != null
          ? UnionMemberUser.fromJson(json['user'])
          : null,
    );
  }
}

class UnionMemberUser {
  final int id;
  final String username;
  final String? profilePicture;
  final String? email;

  const UnionMemberUser({
    required this.id,
    required this.username,
    this.profilePicture,
    this.email,
  });

  factory UnionMemberUser.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] as Map<String, dynamic>?;
    return UnionMemberUser(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      profilePicture: profile?['profilePicture'] ?? json['profilePicture'],
      email: json['email'],
    );
  }
}

class UnionStatsModel {
  final int totalMembers;
  final int totalOfficials;
  final int pendingRequests;
  final Map<String, int> membersByRole;

  const UnionStatsModel({
    required this.totalMembers,
    required this.totalOfficials,
    required this.pendingRequests,
    required this.membersByRole,
  });

  factory UnionStatsModel.fromJson(Map<String, dynamic> json) {
    final roleMap = json['membersByRole'] as Map<String, dynamic>? ?? {};
    return UnionStatsModel(
      totalMembers: json['totalMembers'] ?? 0,
      totalOfficials: json['totalOfficials'] ?? 0,
      pendingRequests: json['pendingRequests'] ?? 0,
      membersByRole: roleMap.map((k, v) => MapEntry(k, (v as num).toInt())),
    );
  }
}

class UnionInvitationModel {
  final int id;
  final int unionId;
  final String unionName;
  final String? unionLogoUrl;
  final String invitedBy;
  final String status;
  final DateTime createdAt;

  const UnionInvitationModel({
    required this.id,
    required this.unionId,
    required this.unionName,
    this.unionLogoUrl,
    required this.invitedBy,
    required this.status,
    required this.createdAt,
  });

  factory UnionInvitationModel.fromJson(Map<String, dynamic> json) {
    final union = json['union'] as Map<String, dynamic>? ?? {};
    final inviter =
        json['inviter'] as Map<String, dynamic>? ??
        json['invitedByUser'] as Map<String, dynamic>? ??
        {};
    return UnionInvitationModel(
      id: json['id'] ?? 0,
      unionId: json['unionId'] ?? union['id'] ?? 0,
      unionName: union['name'] ?? json['unionName'] ?? '',
      unionLogoUrl: union['logoUrl'] ?? json['unionLogoUrl'],
      invitedBy: inviter['username'] ?? json['invitedBy'] ?? 'Unknown',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
