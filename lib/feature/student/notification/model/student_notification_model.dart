import 'package:intl/intl.dart';

class StudentNotificationModel {
  final int id;
  final int? userId;
  final String type;
  final String category;
  final String priority;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final String? actionUrl;
  final String? imageUrl;
  final bool isRead;
  final bool isArchived;
  final DateTime? readAt;
  final DateTime? archivedAt;
  final int? actorId;
  final Map<String, dynamic>? actor;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StudentNotificationModel({
    required this.id,
    this.userId,
    required this.type,
    required this.category,
    required this.priority,
    required this.title,
    required this.message,
    this.data,
    this.actionUrl,
    this.imageUrl,
    required this.isRead,
    required this.isArchived,
    this.readAt,
    this.archivedAt,
    this.actorId,
    this.actor,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
  });

  StudentNotificationModel copyWith({
    int? id,
    int? userId,
    String? type,
    String? category,
    String? priority,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    String? actionUrl,
    String? imageUrl,
    bool? isRead,
    bool? isArchived,
    DateTime? readAt,
    DateTime? archivedAt,
    int? actorId,
    Map<String, dynamic>? actor,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentNotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      actionUrl: actionUrl ?? this.actionUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      isRead: isRead ?? this.isRead,
      isArchived: isArchived ?? this.isArchived,
      readAt: readAt ?? this.readAt,
      archivedAt: archivedAt ?? this.archivedAt,
      actorId: actorId ?? this.actorId,
      actor: actor ?? this.actor,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory StudentNotificationModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final Map<String, dynamic>? dataMap = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : null;

    final rawActor = json['actor'] ?? json['sender'] ?? json['creator'] ?? json['faculty'];
    final Map<String, dynamic>? actorMap = rawActor is Map
        ? Map<String, dynamic>.from(rawActor)
        : (rawActor is String && rawActor.trim().isNotEmpty ? {'name': rawActor.trim()} : null);

    return StudentNotificationModel(
      id: _parseInt(json['id']),
      userId: _tryParseInt(json['userId'] ?? json['user_id']),
      type: json['type']?.toString() ?? '',
      category: json['category']?.toString() ?? 'all',
      priority: json['priority']?.toString() ?? 'normal',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: dataMap,
      actionUrl: (json['actionUrl'] ?? json['action_url'])?.toString(),
      imageUrl: (json['imageUrl'] ?? json['image_url'])?.toString(),
      isRead: json['isRead'] == true || json['is_read'] == true,
      isArchived: json['isArchived'] == true || json['is_archived'] == true,
      readAt: _parseDate(json['readAt'] ?? json['read_at']),
      archivedAt: _parseDate(json['archivedAt'] ?? json['archived_at']),
      actorId: _tryParseInt(json['actorId'] ?? json['actor_id']),
      actor: actorMap,
      expiresAt: _parseDate(json['expiresAt'] ?? json['expires_at']),
      createdAt: _parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  String? get senderName {
    if (actor != null) {
      final name = actor!['fullName'] ??
          actor!['name'] ??
          actor!['username'] ??
          actor!['displayName'];
      if (name != null && name.toString().trim().isNotEmpty) {
        return name.toString().trim();
      }
    }
    if (data != null) {
      final sender = data!['sender'] ??
          data!['from'] ??
          data!['actor'] ??
          data!['faculty'] ??
          data!['teacher'];
      if (sender is Map) {
        final name = sender['fullName'] ??
            sender['name'] ??
            sender['username'] ??
            sender['displayName'];
        if (name != null && name.toString().trim().isNotEmpty) {
          return name.toString().trim();
        }
      } else if (sender is String && sender.trim().isNotEmpty) {
        return sender.trim();
      }

      final directSender = data!['senderName'] ??
          data!['sender_name'] ??
          data!['facultyName'] ??
          data!['faculty_name'] ??
          data!['teacherName'] ??
          data!['teacher_name'] ??
          data!['creatorName'] ??
          data!['creator_name'] ??
          data!['authorName'] ??
          data!['author_name'] ??
          data!['fromName'] ??
          data!['from_name'];
      if (directSender != null && directSender.toString().trim().isNotEmpty) {
        return directSender.toString().trim();
      }
    }
    return null;
  }

  String? get campaignName {
    if (data != null) {
      final name = data!['campaignName'] ??
          data!['campaign_name'] ??
          data!['campaignTitle'] ??
          data!['campaign_title'] ??
          data!['eventName'] ??
          data!['event_name'] ??
          data!['title'];
      if (name != null && name.toString().trim().isNotEmpty) {
        return name.toString().trim();
      }
      if (data!['campaign'] is Map) {
        final c = data!['campaign'] as Map;
        final cTitle = c['title'] ?? c['name'] ?? c['campaignTitle'];
        if (cTitle != null && cTitle.toString().trim().isNotEmpty) {
          return cTitle.toString().trim();
        }
      }
    }
    if (type.toLowerCase().contains('campaign') && title.trim().isNotEmpty) {
      return title.trim();
    }
    return null;
  }

  String get displayTime {
    final timestamp = createdAt;
    if (timestamp == null) {
      return '';
    }

    final localTime = timestamp.toLocal();
    final difference = DateTime.now().difference(localTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} day ago';
    }

    return DateFormat('dd MMM yyyy').format(localTime);
  }

  static int _parseInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _tryParseInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '');
  }

  static DateTime? _parseDate(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }
}

class StudentNotificationListResponse {
  final List<StudentNotificationModel> notifications;
  final int total;
  final int unreadCount;
  final int page;
  final int totalPages;

  const StudentNotificationListResponse({
    required this.notifications,
    required this.total,
    required this.unreadCount,
    required this.page,
    required this.totalPages,
  });

  factory StudentNotificationListResponse.fromJson(Map<String, dynamic> json) {
    final dataNode = json['data'] is Map ? json['data'] : json;
    final metaNode = json['meta'] is Map ? json['meta'] : json;

    final rawNotifications =
        dataNode['notifications'] ??
        json['notifications'] ??
        (json['data'] is List ? json['data'] : []);

    var parsedNotifications = rawNotifications is List
        ? rawNotifications
              .whereType<Map>()
              .map(
                (item) => StudentNotificationModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : const <StudentNotificationModel>[];

    final manualUnreadCount = parsedNotifications
        .where((n) => !n.isRead)
        .length;

    int? explicitUnreadCount =
        int.tryParse(dataNode['unreadCount']?.toString() ?? '') ??
        int.tryParse(dataNode['unread_count']?.toString() ?? '') ??
        int.tryParse(metaNode['unreadCount']?.toString() ?? '') ??
        int.tryParse(metaNode['unread_count']?.toString() ?? '') ??
        int.tryParse(json['unreadCount']?.toString() ?? '') ??
        int.tryParse(json['unread_count']?.toString() ?? '');

    int finalUnreadCount = explicitUnreadCount ?? manualUnreadCount;

    // If API explicitly states there are 0 unread notifications,
    // ensure no items are highlighted in the UI even if the backend forgot to set is_read = true on the items
    if (explicitUnreadCount == 0) {
      parsedNotifications = parsedNotifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
    }

    return StudentNotificationListResponse(
      notifications: parsedNotifications,
      total: int.tryParse(json['total']?.toString() ?? '') ?? 0,
      unreadCount: finalUnreadCount,
      page: int.tryParse(json['page']?.toString() ?? '') ?? 1,
      totalPages: int.tryParse(json['totalPages']?.toString() ?? '') ?? 1,
    );
  }
}
