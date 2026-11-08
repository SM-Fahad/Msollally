import 'package:get/get.dart';

class TeacherStudentEnrollmentModel {
  TeacherStudentEnrollmentModel({
    required this.id,
    required this.courseId,
    required this.courseTitle,
    required this.courseCode,
    required this.studentId,
    required this.name,
    required this.username,
    required this.phoneNumber,
    required this.profilePicture,
    required this.studentCode,
    required this.status,
    required this.progress,
    required this.grade,
    required this.enrolledAt,
  });

  final int id;
  final int courseId;
  final String courseTitle;
  final String courseCode;
  final int studentId;
  final String name;
  final String username;
  final String phoneNumber;
  final String profilePicture;
  final String studentCode;
  final String status;
  final num progress;
  final String? grade;
  final DateTime? enrolledAt;
  final RxBool isSelected = false.obs;

  factory TeacherStudentEnrollmentModel.fromJson(Map<String, dynamic> json) {
    final course = _asMap(json['course']);
    final student = _asMap(json['student']);
    final profile = _asMap(student['profile']);

    final fullName = (profile['fullName'] ?? '').toString().trim();
    final username = (student['username'] ?? '').toString().trim();

    return TeacherStudentEnrollmentModel(
      id: _parseInt(json['id']),
      courseId: _parseInt(json['courseId']),
      courseTitle: (course['title'] ?? 'Untitled course').toString(),
      courseCode: (course['courseCode'] ?? '').toString(),
      studentId: _parseInt(json['studentId']),
      name: fullName.isNotEmpty ? fullName : username,
      username: username,
      phoneNumber: (student['phoneNumber'] ?? '').toString(),
      profilePicture: (profile['profilePicture'] ?? '').toString(),
      studentCode: (profile['studentID'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      progress: _parseNum(json['progress']),
      grade: json['grade']?.toString(),
      enrolledAt: _parseDate(json['enrolledAt']),
    );
  }

  String get searchLabel =>
      '$name $username $phoneNumber $courseTitle $courseCode $studentCode'
          .toLowerCase();

  String get subtitle {
    final parts = <String>[
      courseTitle,
      if (courseCode.trim().isNotEmpty) courseCode.trim(),
      if (studentCode.trim().isNotEmpty) studentCode.trim(),
    ];
    return parts.join(' • ');
  }

  String get fallbackAvatarText {
    final source = name.trim().isNotEmpty ? name.trim() : username.trim();
    if (source.isEmpty) return '?';
    return source[0].toUpperCase();
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

num _parseNum(dynamic value) {
  if (value is num) return value;
  return num.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
