class TeacherHomeDashboardModel {
  final List<TeacherDashboardCourse> courses;
  final TeacherDashboardStatistics statistics;
  final List<TeacherUpcomingClass> upcomingClasses;

  const TeacherHomeDashboardModel({
    required this.courses,
    required this.statistics,
    required this.upcomingClasses,
  });

  factory TeacherHomeDashboardModel.fromJson(Map<String, dynamic> json) {
    return TeacherHomeDashboardModel(
      courses: _parseCourseList(json['courses']),
      statistics: TeacherDashboardStatistics.fromJson(
        _asMap(json['statistics']),
      ),
      upcomingClasses: _parseUpcomingClassList(json['upcomingClasses']),
    );
  }

  static List<TeacherDashboardCourse> _parseCourseList(dynamic raw) {
    if (raw is! List) return const <TeacherDashboardCourse>[];
    return raw
        .whereType<Map>()
        .map(
          (item) =>
              TeacherDashboardCourse.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  static List<TeacherUpcomingClass> _parseUpcomingClassList(dynamic raw) {
    if (raw is! List) return const <TeacherUpcomingClass>[];
    return raw
        .whereType<Map>()
        .map(
          (item) =>
              TeacherUpcomingClass.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const <String, dynamic>{};
  }
}

class TeacherDashboardCourse {
  final int id;
  final String title;
  final String courseCode;
  final String status;
  final int enrolledCount;
  final int activeEnrollments;

  const TeacherDashboardCourse({
    required this.id,
    required this.title,
    required this.courseCode,
    required this.status,
    required this.enrolledCount,
    required this.activeEnrollments,
  });

  factory TeacherDashboardCourse.fromJson(Map<String, dynamic> json) {
    return TeacherDashboardCourse(
      id: _asInt(json['id']),
      title: (json['title'] ?? '').toString(),
      courseCode: (json['courseCode'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      enrolledCount: _asInt(json['enrolledCount']),
      activeEnrollments: _asInt(json['activeEnrollments']),
    );
  }
}

class TeacherDashboardStatistics {
  final int totalCourses;
  final int publishedCourses;
  final int totalStudents;
  final int pendingSubmissions;

  const TeacherDashboardStatistics({
    required this.totalCourses,
    required this.publishedCourses,
    required this.totalStudents,
    required this.pendingSubmissions,
  });

  factory TeacherDashboardStatistics.fromJson(Map<String, dynamic> json) {
    return TeacherDashboardStatistics(
      totalCourses: _asInt(json['totalCourses']),
      publishedCourses: _asInt(json['publishedCourses']),
      totalStudents: _asInt(json['totalStudents']),
      pendingSubmissions: _asInt(json['pendingSubmissions']),
    );
  }
}

class TeacherUpcomingClass {
  final int id;
  final String title;
  final DateTime? startTime;
  final DateTime? endTime;
  final String classroom;
  final String courseName;

  const TeacherUpcomingClass({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.classroom,
    required this.courseName,
  });

  factory TeacherUpcomingClass.fromJson(Map<String, dynamic> json) {
    return TeacherUpcomingClass(
      id: _asInt(json['id']),
      title: (json['title'] ?? '').toString(),
      startTime: _parseDate(json['startTime']),
      endTime: _parseDate(json['endTime']),
      classroom: (json['classroom'] ?? '').toString(),
      courseName: (json['courseName'] ?? '').toString(),
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}
