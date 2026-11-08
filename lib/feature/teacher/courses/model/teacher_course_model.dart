import 'package:flutter/widgets.dart';
import 'package:msollaally/core/const/appcolors.dart';
import 'package:msollaally/feature/teacher/courses/course_module/model/course_module_model.dart';

class TeacherCourseModel {
  final int id;
  final String title;
  final String description;
  final String courseCode;
  final int students;
  final String status;
  final String coverImage;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final List<CourseModule> modules;
  final double progress;
  final Color color;
  final bool isPublic;

  const TeacherCourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.courseCode,
    required this.students,
    required this.status,
    required this.coverImage,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.modules,
    required this.progress,
    required this.isPublic,
    this.color = AppColors.primaryButtonColor,
  });

  factory TeacherCourseModel.fromJson(Map<String, dynamic> json) {
    final modules = _parseModules(json['modules']);
    final progress = modules.isEmpty
        ? 0.0
        : modules
                  .map((module) => module.progress.clamp(0, 100))
                  .reduce((a, b) => a + b) /
              modules.length /
              100;

    return TeacherCourseModel(
      id: _parseInt(json['id']),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      courseCode: (json['courseCode'] ?? '').toString(),
      students: _parseInt(json['enrolledCount']),
      status: (json['status'] ?? 'draft').toString(),
      coverImage: (json['coverImage'] ?? '').toString(),
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      createdAt: _parseDate(json['createdAt']),
      modules: modules,
      progress: progress.clamp(0.0, 1.0),
      isPublic: json['isPublic'] == true,
    );
  }

  TeacherCourseModel copyWith({
    int? id,
    String? title,
    String? description,
    String? courseCode,
    int? students,
    String? status,
    String? coverImage,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    List<CourseModule>? modules,
    double? progress,
    Color? color,
    bool? isPublic,
  }) {
    return TeacherCourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      courseCode: courseCode ?? this.courseCode,
      students: students ?? this.students,
      status: status ?? this.status,
      coverImage: coverImage ?? this.coverImage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      modules: modules ?? this.modules,
      progress: progress ?? this.progress,
      color: color ?? this.color,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  int get moduleCount => modules.length;

  bool get isDraft => status.toLowerCase() == 'draft';
}

List<CourseModule> _parseModules(dynamic raw) {
  if (raw is! List) return const <CourseModule>[];
  return raw
      .whereType<Map>()
      .map((item) => CourseModule.fromJson(Map<String, dynamic>.from(item)))
      .toList();
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
