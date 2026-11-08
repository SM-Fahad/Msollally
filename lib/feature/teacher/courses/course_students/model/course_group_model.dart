class CourseGroupMember {
  final int id;
  final String name;
  final String avatar;

  const CourseGroupMember({
    required this.id,
    required this.name,
    required this.avatar,
  });

  factory CourseGroupMember.fromJson(Map<String, dynamic> json) {
    final profile = CourseGroupModel._asMap(json['profile']);
    final name = CourseGroupModel._asString(
      json['fullName'],
      fallback: CourseGroupModel._asString(
        profile['fullName'],
        fallback: CourseGroupModel._asString(
          json['username'],
          fallback: 'Student',
        ),
      ),
    );

    return CourseGroupMember(
      id: CourseGroupModel._asInt(json['id']),
      name: name.isEmpty ? 'Student' : name,
      avatar: CourseGroupModel._asString(
        json['profilePicture'],
        fallback: CourseGroupModel._asString(profile['profilePicture']),
      ),
    );
  }
}

class CourseGroupModel {
  final int id;
  final int? chatId;
  final int courseId;
  final String name;
  final List<int> memberIds;
  final List<CourseGroupMember> members;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CourseGroupModel({
    required this.id,
    required this.chatId,
    required this.courseId,
    required this.name,
    required this.memberIds,
    required this.members,
    required this.createdAt,
    required this.updatedAt,
  });

  int get memberCount =>
      memberIds.isNotEmpty ? memberIds.length : members.length;

  String get avatar => members.isNotEmpty ? members.first.avatar : '';

  String get memberLabel {
    final count = memberCount;
    if (count == 0) {
      return 'No members yet';
    }
    if (count == 1) {
      return '1 member';
    }
    return '$count members';
  }

  factory CourseGroupModel.fromJson(Map<String, dynamic> json) {
    final membersPayload = _extractMembers(json);
    final members = membersPayload.map(CourseGroupMember.fromJson).toList();
    final memberIds = _extractMemberIds(json, members);
    final chat = _asMap(json['chat'] ?? json['room'] ?? json['conversation']);

    return CourseGroupModel(
      id: _asInt(json['id']),
      chatId:
          _asNullableInt(json['chatId']) ??
          _asNullableInt(json['chat_id']) ??
          _asNullableInt(chat['id']) ??
          _asNullableInt(chat['chatId']) ??
          _asNullableInt(chat['chat_id']),
      courseId: _asInt(json['courseId']),
      name: _asString(json['name'], fallback: 'Group'),
      memberIds: memberIds,
      members: members,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  static List<Map<String, dynamic>> _extractMembers(Map<String, dynamic> json) {
    final dynamic rawMembers =
        json['members'] ??
        json['groupMembers'] ??
        json['users'] ??
        json['students'];

    if (rawMembers is! List) {
      return const <Map<String, dynamic>>[];
    }

    return rawMembers.whereType<Map>().map((item) {
      final map = Map<String, dynamic>.from(item);
      if (map['student'] is Map) {
        return Map<String, dynamic>.from(map['student'] as Map);
      }
      if (map['user'] is Map) {
        return Map<String, dynamic>.from(map['user'] as Map);
      }
      if (map['member'] is Map) {
        return Map<String, dynamic>.from(map['member'] as Map);
      }
      return map;
    }).toList();
  }

  static List<int> _extractMemberIds(
    Map<String, dynamic> json,
    List<CourseGroupMember> members,
  ) {
    final dynamic rawMemberIds = json['memberIds'] ?? json['member_ids'];
    if (rawMemberIds is List) {
      final values = rawMemberIds.map(_asInt).where((id) => id != 0).toList();
      if (values.isNotEmpty) {
        return values;
      }
    }

    return members.map((member) => member.id).where((id) => id != 0).toList();
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const <String, dynamic>{};
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _asNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }
    final parsed = _asInt(value);
    return parsed == 0 ? null : parsed;
  }

  static String _asString(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == 'null') {
      return fallback;
    }
    return text;
  }

  static DateTime? _parseDateTime(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }
}
