class CourseNoticeModel {
  final int id;
  final int courseId;
  final String title;
  final String note;
  final String creatorName;
  final DateTime? createdAt;
  final bool isImportant;
  final List<String> attachments;

  CourseNoticeModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.note,
    required this.creatorName,
    required this.createdAt,
    this.isImportant = false,
    this.attachments = const [],
  });

  factory CourseNoticeModel.fromJson(Map<String, dynamic> json) {
    final creator = json['creator'];
    String parsedCreator = '';
    if (creator is Map) {
      parsedCreator = (creator['username'] ?? creator['name'] ?? creator['fullName'] ?? '').toString();
    } else if (creator is String) {
      parsedCreator = creator;
    } else if (json['creatorName'] != null) {
      parsedCreator = json['creatorName'].toString();
    } else if (json['creator_name'] != null) {
      parsedCreator = json['creator_name'].toString();
    }

    final rawAttachments = json['attachments'] ?? json['files'] ?? [];
    List<String> parsedAttachments = [];
    if (rawAttachments is List) {
      for (final a in rawAttachments) {
        if (a is String) {
          parsedAttachments.add(a);
        } else if (a is Map && a['url'] != null) {
          parsedAttachments.add(a['url'].toString());
        }
      }
    }

    return CourseNoticeModel(
      id: _readInt(json['id']),
      courseId: _readInt(json['courseId'] ?? json['course_id']),
      title: (json['title'] ?? '').toString(),
      note: (json['notice'] ?? json['note'] ?? json['message'] ?? json['content'] ?? '').toString(),
      creatorName: parsedCreator,
      createdAt: _readDateTime(json['createdAt'] ?? json['created_at']),
      isImportant: json['isImportant'] == true || json['is_important'] == true,
      attachments: parsedAttachments,
    );
  }
}

int _readInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _readDateTime(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
