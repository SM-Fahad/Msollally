// module_model.dart
class CourseFileModel {
  final int id;
  final String name;
  final String url;
  final String type;
  final String mimeType;
  final String displayType;

  CourseFileModel({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.mimeType,
    required this.displayType,
  });
}

class ClassModel {
  final int? id;
  final String title;
  final String time;
  final String location;
  final String status;
  final List<String> topics;
  final String notes;
  final List<CourseFileModel> files;

  ClassModel({
    this.id,
    required this.title,
    required this.time,
    required this.location,
    required this.status,
    required this.topics,
    this.notes = '',
    this.files = const [],
  });
}

class ModuleModel {
  final int? id;
  final String title;
  final String description;
  final double progress;
  final List<CourseFileModel> files;
  final List<ClassModel> classes;

  ModuleModel({
    this.id,
    required this.title,
    this.description = '',
    required this.progress,
    required this.files,
    required this.classes,
  });
}

// exam_model.dart
class ExamModel {
  final String title;
  final String time; // e.g. "10:00 AM, 5th Sep"
  final String location; // e.g. "Room 204"
  final List<String> topics; // topics covered in exam
  final List<String> files; // notes or reference files (pdf, doc, ppt etc.)
  final DateTime examDate;
  final String type; // to calculate remaining days

  ExamModel({
    required this.title,
    required this.time,
    required this.location,
    required this.topics,
    required this.files,
    required this.examDate,
    required this.type,
  });
}

class NoticeModel {
  final String title;
  final String note;

  NoticeModel({required this.title, required this.note});
} // e.g. "12th Sep, 2023"
