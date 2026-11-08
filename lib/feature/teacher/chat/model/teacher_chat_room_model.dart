class TeacherChatUserModel {
  final int id;
  final String username;
  final String phoneNumber;
  final String role;

  const TeacherChatUserModel({
    required this.id,
    required this.username,
    required this.phoneNumber,
    required this.role,
  });

  String get displayName => username.trim().isEmpty ? 'User' : username.trim();

  factory TeacherChatUserModel.fromJson(Map<String, dynamic> json) {
    return TeacherChatUserModel(
      id: _asInt(json['id']),
      username: _asString(json['username'], fallback: _asString(json['name'])),
      phoneNumber: _asString(json['phoneNumber']),
      role: _asString(json['role']),
    );
  }
}

class TeacherChatParticipantModel {
  final int id;
  final TeacherChatUserModel user;
  final int? lastReadMessageId;
  final bool isMuted;

  const TeacherChatParticipantModel({
    required this.id,
    required this.user,
    required this.lastReadMessageId,
    required this.isMuted,
  });

  factory TeacherChatParticipantModel.fromJson(Map<String, dynamic> json) {
    return TeacherChatParticipantModel(
      id: _asInt(json['id']),
      user: TeacherChatUserModel.fromJson(_asMap(json['user'])),
      lastReadMessageId: _asNullableInt(json['lastReadMessageId']),
      isMuted: json['isMuted'] is bool ? json['isMuted'] as bool : false,
    );
  }
}

class TeacherChatRoomModel {
  final int id;
  final String type;
  final String name;
  final List<TeacherChatParticipantModel> participants;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TeacherChatRoomModel({
    required this.id,
    required this.type,
    required this.name,
    required this.participants,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isGroup => type.toLowerCase() == 'group';

  factory TeacherChatRoomModel.fromJson(Map<String, dynamic> json) {
    final participants = _asList(
      json['participants'],
    ).map(TeacherChatParticipantModel.fromJson).toList();

    return TeacherChatRoomModel(
      id: _asInt(json['id']),
      type: _asString(json['type'], fallback: 'direct'),
      name: _asString(json['name']),
      participants: participants,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return const <String, dynamic>{};
}

List<Map<String, dynamic>> _asList(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
  return const <Map<String, dynamic>>[];
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _asNullableInt(dynamic value) {
  if (value == null) {
    return null;
  }
  final parsed = _asInt(value);
  return parsed == 0 ? null : parsed;
}

String _asString(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty || text == 'null') {
    return fallback;
  }
  return text;
}

DateTime? _parseDateTime(dynamic value) {
  final raw = value?.toString();
  if (raw == null || raw.isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw);
}
