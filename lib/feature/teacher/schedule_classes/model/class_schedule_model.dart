class ClassScheduleModel {
  const ClassScheduleModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int userId;
  final String title;
  final String description;

  /// Date-only string from API: "yyyy-MM-dd"
  final String date;

  /// Time string from API: "HH:mm:ss"
  final String startTime;

  /// Time string from API: "HH:mm:ss"
  final String endTime;

  final DateTime createdAt;
  final DateTime updatedAt;

  factory ClassScheduleModel.fromJson(Map<String, dynamic> json) {
    return ClassScheduleModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      date: (json['date'] as String?) ?? '',
      startTime: (json['startTime'] as String?) ?? '',
      endTime: (json['endTime'] as String?) ?? '',
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  /// Converts the "yyyy-MM-dd" date string to a [DateTime].
  DateTime get dateTime {
    return DateTime.tryParse(date) ?? DateTime.now();
  }

  /// Converts the "HH:mm:ss" time string to a [DateTime] anchored on [dateTime].
  DateTime get startDateTime {
    return _combineDateAndTime(dateTime, startTime);
  }

  /// Converts the "HH:mm:ss" time string to a [DateTime] anchored on [dateTime].
  DateTime get endDateTime {
    return _combineDateAndTime(dateTime, endTime);
  }

  static DateTime _combineDateAndTime(DateTime date, String timeStr) {
    final parts = timeStr.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final second = parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0;
    return DateTime(date.year, date.month, date.day, hour, minute, second);
  }
}
