class CourseModule {
  final int id;
  final int courseId;
  final String title;
  final String description;
  final int orderIndex;
  final DateTime? startDate;
  final DateTime? createdAt;
  final double progress;
  final bool isCompleted;
  final List<CourseClass> classes;
  final List<ModuleFile> files;

  const CourseModule({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.orderIndex,
    required this.startDate,
    required this.createdAt,
    required this.progress,
    required this.isCompleted,
    required this.classes,
    required this.files,
  });

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    return CourseModule(
      id: _parseInt(json['id']),
      courseId: _parseInt(json['courseId']),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      orderIndex: _parseInt(json['orderIndex']),
      startDate: _parseDate(json['startDate']),
      createdAt: _parseDate(json['createdAt']),
      progress: _parseDouble(json['progress']),
      isCompleted: json['isCompleted'] == true,
      classes: _parseClassList(json['classes']),
      files: _parseFileList(json['files']),
    );
  }

  CourseModule copyWith({
    int? id,
    int? courseId,
    String? title,
    String? description,
    int? orderIndex,
    DateTime? startDate,
    DateTime? createdAt,
    double? progress,
    bool? isCompleted,
    List<CourseClass>? classes,
    List<ModuleFile>? files,
  }) {
    return CourseModule(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      orderIndex: orderIndex ?? this.orderIndex,
      startDate: startDate ?? this.startDate,
      createdAt: createdAt ?? this.createdAt,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      classes: classes ?? this.classes,
      files: files ?? this.files,
    );
  }

  List<String> get fileTypes {
    if (files.isEmpty) return const <String>[];
    return files.map((file) => file.fileType).toList();
  }

  static List<CourseClass> _parseClassList(dynamic raw) {
    if (raw is! List) return const <CourseClass>[];
    return raw
        .whereType<Map>()
        .map((item) => CourseClass.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static List<ModuleFile> _parseFileList(dynamic raw) {
    if (raw is! List) return const <ModuleFile>[];
    return raw
        .whereType<Map>()
        .map((item) => ModuleFile.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}

class CourseClass {
  final int id;
  final String title;
  final String classroom;
  final String topic;
  final String notes;
  final DateTime? startTime;
  final DateTime? endTime;
  final int orderIndex;
  final List<String> topics;
  final List<ClassFile> files;

  const CourseClass({
    required this.id,
    required this.title,
    required this.classroom,
    required this.topic,
    required this.notes,
    required this.startTime,
    required this.endTime,
    required this.orderIndex,
    required this.topics,
    required this.files,
  });

  factory CourseClass.fromJson(Map<String, dynamic> json) {
    return CourseClass(
      id: _parseInt(json['id']),
      title:
          (json['title'] ?? json['name'] ?? json['topic'] ?? 'Untitled class')
              .toString(),
      classroom:
          (json['classroom'] ??
                  json['hall'] ??
                  json['location'] ??
                  json['room'] ??
                  'TBA')
              .toString(),
      topic: (json['topic'] ?? '').toString(),
      notes: (json['notes'] ?? '').toString(),
      startTime: _parseDate(
        json['startTime'] ??
            json['time'] ??
            json['schedule'] ??
            json['startDate'],
      ),
      endTime: _parseDate(json['endTime']),
      orderIndex: _parseInt(json['orderIndex']),
      topics: _parseStringList(json['topics']),
      files: _parseClassFileList(
        json['files'] ?? json['classFiles'] ?? json['attachments'],
      ),
    );
  }

  CourseClass copyWith({
    int? id,
    String? title,
    String? classroom,
    String? topic,
    String? notes,
    DateTime? startTime,
    DateTime? endTime,
    int? orderIndex,
    List<String>? topics,
    List<ClassFile>? files,
  }) {
    return CourseClass(
      id: id ?? this.id,
      title: title ?? this.title,
      classroom: classroom ?? this.classroom,
      topic: topic ?? this.topic,
      notes: notes ?? this.notes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      orderIndex: orderIndex ?? this.orderIndex,
      topics: topics ?? this.topics,
      files: files ?? this.files,
    );
  }

  String get time {
    final start = startTime;
    final end = endTime;
    if (start == null) return 'Not scheduled';
    final startText = _formatTime(start);
    if (end == null) return startText;
    return '$startText - ${_formatTime(end)}';
  }

  String get hall => classroom;
}

class ClassFile {
  final int id;
  final String name;
  final String fileUrl;
  final String type;
  final int size;
  final String mimeType;

  const ClassFile({
    required this.id,
    required this.name,
    required this.fileUrl,
    required this.type,
    required this.size,
    required this.mimeType,
  });

  factory ClassFile.fromJson(Map<String, dynamic> json) {
    return ClassFile(
      id: _parseInt(json['id']),
      name: (json['name'] ?? '').toString(),
      fileUrl: (json['fileUrl'] ?? json['url'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      size: _parseInt(json['size']),
      mimeType: (json['mimeType'] ?? '').toString(),
    );
  }

  String get fileType {
    final normalizedType = type.toLowerCase().trim();
    if (normalizedType.isNotEmpty) {
      if (normalizedType == 'jpeg' ||
          normalizedType == 'jpg' ||
          normalizedType == 'png') {
        return 'image';
      }
      return normalizedType;
    }

    final lowerMime = mimeType.toLowerCase();
    if (lowerMime.contains('pdf')) return 'pdf';
    if (lowerMime.startsWith('image/')) return 'image';
    if (lowerMime.startsWith('video/')) return 'video';
    if (lowerMime.contains('word') || lowerMime.contains('document')) {
      return 'doc';
    }
    if (lowerMime.contains('presentation') || lowerMime.contains('powerpoint')) {
      return 'ppt';
    }
    if (lowerMime.contains('spreadsheet') || lowerMime.contains('excel') || lowerMime.contains('csv')) {
      return 'xls';
    }
    if (lowerMime.contains('text')) return 'txt';

    if (name.contains('.')) {
      final inferred = name.split('.').last.toLowerCase();
      if (inferred == 'ppt' || inferred == 'pptx') return 'ppt';
      if (inferred == 'xls' || inferred == 'xlsx' || inferred == 'csv') return 'xls';
      if (inferred == 'doc' || inferred == 'docx') return 'doc';
    }

    return 'file';
  }
}

class ModuleFile {
  final int id;
  final String name;
  final String url;
  final String extension;
  final String type;

  const ModuleFile({
    required this.id,
    required this.name,
    required this.url,
    required this.extension,
    required this.type,
  });

  factory ModuleFile.fromJson(Map<String, dynamic> json) {
    final String rawName = (json['name'] ?? json['title'] ?? '').toString();
    final String rawUrl = (json['url'] ?? json['fileUrl'] ?? '').toString();
    final String rawExtension = (json['extension'] ?? '').toString();
    final String rawType = (json['type'] ?? '').toString();

    return ModuleFile(
      id: _parseInt(json['id']),
      name: rawName,
      url: rawUrl,
      extension: rawExtension,
      type: rawType,
    );
  }

  String get fileType {
    final String normalized = extension.toLowerCase().trim();
    if (normalized == 'pdf') return 'pdf';
    if (normalized == 'jpg' ||
        normalized == 'jpeg' ||
        normalized == 'png' ||
        normalized == 'webp') {
      return 'image';
    }
    if (normalized == 'mp4' || normalized == 'mov' || normalized == 'avi') {
      return 'video';
    }
    if (normalized == 'doc' || normalized == 'docx') return 'doc';
    if (normalized == 'ppt' || normalized == 'pptx') return 'ppt';
    if (normalized == 'xls' || normalized == 'xlsx' || normalized == 'csv') return 'xls';
    if (normalized == 'txt') return 'txt';

    final String normalizedType = type.toLowerCase().trim();
    if (normalizedType.isNotEmpty) {
      return normalizedType;
    }

    if (name.contains('.')) {
      final inferred = name.split('.').last.toLowerCase();
      if (inferred == 'pdf') return 'pdf';
      if (inferred == 'jpg' ||
          inferred == 'jpeg' ||
          inferred == 'png' ||
          inferred == 'webp') {
        return 'image';
      }
      if (inferred == 'mp4' || inferred == 'mov' || inferred == 'avi') {
        return 'video';
      }
      if (inferred == 'doc' || inferred == 'docx') return 'doc';
      if (inferred == 'ppt' || inferred == 'pptx') return 'ppt';
      if (inferred == 'xls' || inferred == 'xlsx' || inferred == 'csv') return 'xls';
      if (inferred == 'txt') return 'txt';
    }

    return 'file';
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _parseDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

List<String> _parseStringList(dynamic raw) {
  if (raw is List) {
    return raw
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList();
  }
  return const <String>[];
}

List<ClassFile> _parseClassFileList(dynamic raw) {
  if (raw is! List) return const <ClassFile>[];
  return raw
      .whereType<Map>()
      .map((item) => ClassFile.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

String _formatTime(DateTime value) {
  final localValue = value.toLocal();
  final hour = localValue.hour % 12 == 0 ? 12 : localValue.hour % 12;
  final minute = localValue.minute.toString().padLeft(2, '0');
  final suffix = localValue.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}
