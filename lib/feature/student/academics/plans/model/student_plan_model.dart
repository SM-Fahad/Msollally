class StudentPlanModel {
  final String id;
  final String title;
  final String subtitle;
  final String dateLabel;
  final String timeLabel;
  final String status;
  final Map<String, dynamic> raw;

  const StudentPlanModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.dateLabel,
    required this.timeLabel,
    required this.status,
    required this.raw,
  });

  bool get hasDetailId => id.isNotEmpty;

  factory StudentPlanModel.fromMap(Map<String, dynamic> map) {
    return StudentPlanModel(
      id: _stringValue(map, const ['id', '_id', 'planId']),
      title: _stringValue(map, const [
        'title',
        'name',
        'subject',
        'topic',
        'courseName',
      ]).ifEmpty('Untitled plan'),
      subtitle: _stringValue(map, const [
        'description',
        'summary',
        'instructions',
        'note',
      ]),
      dateLabel: _stringValue(map, const [
        'date',
        'deadline',
        'dueDate',
        'startDate',
        'createdAt',
      ]),
      timeLabel: _stringValue(map, const [
        'time',
        'timeRange',
        'startTime',
        'sessionTime',
      ]),
      status: _stringValue(map, const ['status', 'state']),
      raw: Map<String, dynamic>.from(map),
    );
  }
}

class StudentPlanDetailsModel {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final bool isDefault;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<StudentPlanTaskModel> tasks;
  final Map<String, dynamic> raw;

  const StudentPlanDetailsModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
    required this.tasks,
    required this.raw,
  });

  factory StudentPlanDetailsModel.fromMap(Map<String, dynamic> map) {
    final taskSource = _firstNonNull([
      map['tasks'],
      map['items'],
      map['plans'],
      map['sessions'],
      map['schedule'],
      map['scheduleItems'],
    ]);

    final tasks = _extractTaskList(taskSource);

    return StudentPlanDetailsModel(
      id: _stringValue(map, const ['id', '_id', 'planId']),
      title: _stringValue(map, const [
        'title',
        'name',
        'subject',
        'topic',
        'courseName',
      ]).ifEmpty('Plan details'),
      subtitle: _stringValue(map, const ['subtitle', 'summary']),
      description: _stringValue(map, const [
        'description',
        'details',
        'instructions',
        'note',
      ]),
      isDefault: _boolValue(map, const ['isDefault', 'default']),
      createdAt: _dateTimeValue(map, const ['createdAt']),
      updatedAt: _dateTimeValue(map, const ['updatedAt']),
      tasks: tasks,
      raw: Map<String, dynamic>.from(map),
    );
  }

  static List<StudentPlanTaskModel> _extractTaskList(dynamic source) {
    if (source is List) {
      return source
          .whereType<Map>()
          .map(
            (item) =>
                StudentPlanTaskModel.fromMap(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    if (source is Map<String, dynamic>) {
      final nestedList = _firstNonNull([
        source['items'],
        source['tasks'],
        source['sessions'],
      ]);

      if (nestedList is List) {
        return nestedList
            .whereType<Map>()
            .map(
              (item) =>
                  StudentPlanTaskModel.fromMap(Map<String, dynamic>.from(item)),
            )
            .toList();
      }
    }

    return const [];
  }
}

class StudentPlanTaskModel {
  final String title;
  final String task;
  final String dateLabel;
  final String timeLabel;
  final String status;
  final Map<String, dynamic> raw;

  const StudentPlanTaskModel({
    required this.title,
    required this.task,
    required this.dateLabel,
    required this.timeLabel,
    required this.status,
    required this.raw,
  });

  factory StudentPlanTaskModel.fromMap(Map<String, dynamic> map) {
    return StudentPlanTaskModel(
      title: _stringValue(map, const [
        'title',
        'name',
        'sessionTitle',
        'topic',
      ]),
      task: _stringValue(map, const [
        'task',
        'description',
        'content',
        'instructions',
      ]),
      dateLabel: _stringValue(map, const [
        'date',
        'deadline',
        'dueDate',
        'startDate',
      ]),
      timeLabel: _stringValue(map, const [
        'time',
        'timeRange',
        'startTime',
        'sessionTime',
      ]),
      status: _stringValue(map, const ['status', 'state']),
      raw: Map<String, dynamic>.from(map),
    );
  }
}

String _stringValue(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value == null) {
      continue;
    }
    final normalized = value.toString().trim();
    if (normalized.isNotEmpty && normalized.toLowerCase() != 'null') {
      return normalized;
    }
  }
  return '';
}

dynamic _firstNonNull(List<dynamic> values) {
  for (final value in values) {
    if (value != null) {
      return value;
    }
  }
  return null;
}

bool _boolValue(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is bool) {
      return value;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') {
        return true;
      }
      if (normalized == 'false') {
        return false;
      }
    }
  }
  return false;
}

DateTime? _dateTimeValue(Map<String, dynamic> map, List<String> keys) {
  final rawValue = _stringValue(map, keys);
  if (rawValue.isEmpty) {
    return null;
  }
  return DateTime.tryParse(rawValue);
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
