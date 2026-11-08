class TeacherSessionModel {
  final int id;
  final String ipAddress;
  final String userAgent;
  final DateTime? issuedAt;
  final DateTime? expiresAt;
  final bool isCurrentSession;
  final TeacherSessionUser? user;

  const TeacherSessionModel({
    required this.id,
    required this.ipAddress,
    required this.userAgent,
    required this.issuedAt,
    required this.expiresAt,
    required this.isCurrentSession,
    required this.user,
  });

  factory TeacherSessionModel.fromJson(Map<String, dynamic> json) {
    return TeacherSessionModel(
      id: _parseInt(json['id']),
      ipAddress: (json['ipAddress'] ?? '').toString(),
      userAgent: (json['userAgent'] ?? '').toString(),
      issuedAt: _parseDate(json['issuedAt']),
      expiresAt: _parseDate(json['expiresAt']),
      isCurrentSession: json['isCurrentSession'] == true,
      user: _parseUser(json['user']),
    );
  }

  static TeacherSessionUser? _parseUser(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      return TeacherSessionUser.fromJson(raw);
    }
    if (raw is Map) {
      return TeacherSessionUser.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }
}

class TeacherSessionUser {
  final int id;
  final String phoneNumber;
  final String role;

  const TeacherSessionUser({
    required this.id,
    required this.phoneNumber,
    required this.role,
  });

  factory TeacherSessionUser.fromJson(Map<String, dynamic> json) {
    return TeacherSessionUser(
      id: _parseInt(json['id']),
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
    );
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}
