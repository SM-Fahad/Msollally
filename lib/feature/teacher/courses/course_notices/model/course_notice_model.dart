class CourseNotice {
  final int id;
  final int courseId;
  final String title;
  final String notice;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CourseNotice({
    required this.id,
    required this.courseId,
    required this.title,
    required this.notice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CourseNotice.fromJson(Map<String, dynamic> json) {
    return CourseNotice(
      id: _parseInt(json['id']),
      courseId: _parseInt(json['courseId']),
      title: (json['title'] ?? '').toString(),
      notice: (json['notice'] ?? json['message'] ?? '').toString(),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  CourseNotice copyWith({
    int? id,
    int? courseId,
    String? title,
    String? notice,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseNotice(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      notice: notice ?? this.notice,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
  return DateTime.tryParse(value.toString());
}
