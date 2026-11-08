// academics_model.dart
class CourseModel {
  final int? id;
  final String title;
  final String instructor;
  String status;
  double progress;
  final int totalClasses;
  final int attendedClasses;
  final String nextClass;
  final String nextExam;
  final List<ActivityModel> activities;
  final String? courseCode;
  final String? coverImage;
  final String? grade;

  CourseModel({
    this.id,
    required this.title,
    required this.instructor,
    this.status = "In Progress",
    this.progress = 0.0,
    required this.totalClasses,
    required this.attendedClasses,
    required this.nextClass,
    required this.nextExam,
    required this.activities,
    this.courseCode,
    this.coverImage,
    this.grade,
  });
}

class ActivityModel {
  final String type; // "assignment", "postponed", etc.
  final String title;
  final String description;
  final DateTime time;

  ActivityModel({
    required this.type,
    required this.title,
    required this.description,
    required this.time,
  });
}
