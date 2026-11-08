class CourseStudentChatModel {
  final int id;
  final int? chatId;
  final int courseId;
  final int studentId;
  final String name;
  final String phoneNumber;
  final String status;
  final double progress;
  final String? grade;
  final DateTime? enrolledAt;
  final String lastMessage;
  final String time;
  final String avatar;
  final int unreadCount;
  final bool isMuted;
  final bool isGroup;
  final int recieverId;

  CourseStudentChatModel({
    required this.id,
    required this.chatId,
    required this.courseId,
    required this.studentId,
    required this.name,
    required this.phoneNumber,
    required this.status,
    required this.progress,
    required this.grade,
    required this.enrolledAt,
    required this.lastMessage,
    required this.time,
    required this.avatar,
    this.unreadCount = 0,
    this.isMuted = false,
    this.isGroup = false,
    this.recieverId = 1,
  });

  factory CourseStudentChatModel.fromJson(Map<String, dynamic> json) {
    final student = _asMap(json['student']);
    final profile = _asMap(student['profile']);
    final chat = _asMap(json['chat']);
    final studentName = _asString(
      profile['fullName'],
      fallback: _asString(student['username']),
    );
    final phoneNumber = _asString(student['phoneNumber']);
    final status = _asString(json['status'], fallback: 'active');
    final progress = _asDouble(json['progress']);
    final enrolledAt = _parseDateTime(json['enrolledAt']);
    final avatar = _asString(profile['profilePicture']);

    return CourseStudentChatModel(
      id: _asInt(json['id']),
      chatId: _asNullableInt(json['chatId']) ?? _asNullableInt(chat['id']),
      courseId: _asInt(json['courseId']),
      studentId: _asInt(json['studentId'], fallback: _asInt(student['id'])),
      name: studentName.isEmpty ? 'Student' : studentName,
      phoneNumber: phoneNumber,
      status: status,
      progress: progress,
      grade: _asNullableString(json['grade']),
      enrolledAt: enrolledAt,
      lastMessage: phoneNumber.isNotEmpty
          ? phoneNumber
          : _buildProgressLabel(status: status, progress: progress),
      time: formatDisplayTime(enrolledAt),
      avatar: avatar,
      isGroup: _asBool(
        json['isGroup'],
        fallback:
            status.toLowerCase() == 'group' ||
            _asString(chat['type']).toLowerCase() == 'group' ||
            _asString(chat['type']).toLowerCase() == 'group_chat',
      ),
      recieverId: _asInt(student['id'], fallback: _asInt(json['studentId'])),
    );
  }

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'S';
    }
    if (parts.length == 1) {
      return _firstLetter(parts.first);
    }
    return '${_firstLetter(parts.first)}${_firstLetter(parts.last)}'
        .toUpperCase();
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

  static String _asString(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty || text == 'null') {
      return fallback;
    }
    return text;
  }

  static String? _asNullableString(dynamic value) {
    final text = _asString(value);
    return text.isEmpty ? null : text;
  }

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static int? _asNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }
    final parsed = _asInt(value);
    return parsed == 0 ? null : parsed;
  }

  static double _asDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  static bool _asBool(dynamic value, {bool fallback = false}) {
    if (value is bool) {
      return value;
    }
    if (value == null) {
      return fallback;
    }
    final text = value.toString().trim().toLowerCase();
    if (text.isEmpty || text == 'null') {
      return fallback;
    }
    if (text == 'true' || text == '1' || text == 'yes') {
      return true;
    }
    if (text == 'false' || text == '0' || text == 'no') {
      return false;
    }
    return fallback;
  }

  static String formatDisplayTime(DateTime? value) {
    if (value == null) {
      return '';
    }

    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final suffix = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  static String _buildProgressLabel({
    required String status,
    required double progress,
  }) {
    final percent = progress % 1 == 0
        ? progress.toInt().toString()
        : progress.toStringAsFixed(1);
    return '${status.toUpperCase()} • $percent% progress';
  }

  static String _firstLetter(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'S';
    }
    return trimmed[0].toUpperCase();
  }
}
