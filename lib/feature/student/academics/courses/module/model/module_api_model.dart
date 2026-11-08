import 'package:intl/intl.dart';
import 'module_model.dart';

class ModuleApiModel {
  final int id;
  final int courseId;
  final String title;
  final String description;
  final int progress;
  final bool isCompleted;
  final List<ModuleClassApiModel> classes;
  final List<ModuleFileApiModel> files;

  ModuleApiModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.progress,
    required this.isCompleted,
    required this.classes,
    required this.files,
  });

  factory ModuleApiModel.fromJson(Map<String, dynamic> json) {
    return ModuleApiModel(
      id: _readInt(json['id']),
      courseId: _readInt(json['courseId']),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      progress: _readInt(json['progress']).clamp(0, 100),
      isCompleted: json['isCompleted'] == true,
      classes: (json['classes'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ModuleClassApiModel.fromJson)
          .toList(),
      files: (json['files'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ModuleFileApiModel.fromJson)
          .toList(),
    );
  }

  ModuleModel toUiModel() {
    return ModuleModel(
      id: id,
      title: title,
      description: description,
      progress: progress / 100,
      files: files
          .map((file) => CourseFileModel(
                id: file.id,
                name: file.name,
                url: file.fileUrl,
                type: file.type,
                mimeType: file.mimeType,
                displayType: file.displayType,
              ))
          .toList(),
      classes: classes.map((item) => item.toUiModel()).toList(),
    );
  }
}

class ModuleClassApiModel {
  final int id;
  final String title;
  final String classroom;
  final String topic;
  final String notes;
  final DateTime? startTime;
  final DateTime? endTime;
  final List<String> topics;
  final List<ModuleFileApiModel> files;

  ModuleClassApiModel({
    required this.id,
    required this.title,
    required this.classroom,
    required this.topic,
    required this.notes,
    required this.startTime,
    required this.endTime,
    required this.topics,
    required this.files,
  });

  factory ModuleClassApiModel.fromJson(Map<String, dynamic> json) {
    return ModuleClassApiModel(
      id: _readInt(json['id']),
      title: (json['title'] ?? '').toString(),
      classroom: (json['classroom'] ?? '').toString(),
      topic: (json['topic'] ?? '').toString(),
      notes: (json['notes'] ?? '').toString(),
      startTime: _readDateTime(json['startTime']),
      endTime: _readDateTime(json['endTime']),
      topics: (json['topics'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList(),
      files: (json['files'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(ModuleFileApiModel.fromJson)
          .toList(),
    );
  }

  ClassModel toUiModel() {
    return ClassModel(
      id: id,
      title: title,
      time: _formatTimeRange(startTime, endTime),
      location: classroom.isNotEmpty ? classroom : 'TBA',
      status: _resolveStatus(startTime, endTime),
      topics: topics.isNotEmpty
          ? topics
          : (topic.trim().isNotEmpty ? <String>[topic] : <String>[]),
      notes: notes,
      files: files
          .map((file) => CourseFileModel(
                id: file.id,
                name: file.name,
                url: file.fileUrl,
                type: file.type,
                mimeType: file.mimeType,
                displayType: file.displayType,
              ))
          .toList(),
    );
  }
}

class ModuleFileApiModel {
  final int id;
  final String name;
  final String fileUrl;
  final String type;
  final String mimeType;

  ModuleFileApiModel({
    required this.id,
    required this.name,
    required this.fileUrl,
    required this.type,
    required this.mimeType,
  });

  factory ModuleFileApiModel.fromJson(Map<String, dynamic> json) {
    return ModuleFileApiModel(
      id: _readInt(json['id']),
      name: (json['name'] ?? '').toString(),
      fileUrl: (json['fileUrl'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      mimeType: (json['mimeType'] ?? '').toString(),
    );
  }

  String get displayType {
    final normalizedType = type.toLowerCase();
    final normalizedMime = mimeType.toLowerCase();
    if (normalizedType.contains('image') || normalizedMime.contains('image')) {
      return 'img';
    }
    if (normalizedType.contains('pdf') || normalizedMime.contains('pdf')) {
      return 'pdf';
    }
    if (normalizedType.contains('video') || normalizedMime.contains('video')) {
      return 'video';
    }
    if (normalizedType.contains('ppt') ||
        normalizedMime.contains('presentation')) {
      return 'ppt';
    }
    if (normalizedType.contains('doc') ||
        normalizedMime.contains('word') ||
        normalizedMime.contains('document')) {
      return 'doc';
    }
    return 'file';
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

String _formatTimeRange(DateTime? start, DateTime? end) {
  if (start == null) return 'Schedule not available';
  final localStart = start.toLocal();
  final dateText = DateFormat('EEE, MMM d, yyyy').format(localStart);
  final startText = DateFormat('h:mm a').format(localStart);
  if (end == null) {
    return '$dateText\n$startText';
  }
  final endText = DateFormat('h:mm a').format(end.toLocal());
  return '$dateText\n$startText - $endText';
}

String _resolveStatus(DateTime? start, DateTime? end) {
  final now = DateTime.now().toUtc();
  if (start == null) return 'Not Started';
  if (end != null && end.isBefore(now)) return 'Completed';
  if (start.isBefore(now)) return 'In Progress';
  return 'Not Started';
}
