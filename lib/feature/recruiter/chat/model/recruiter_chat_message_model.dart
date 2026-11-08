import 'package:msollaally/feature/recruiter/chat/model/recruiter_chat_room_model.dart';

class RecruiterChatMessageModel {
  final int id;
  final int? chatId;
  final String content;
  final String type;
  final RecruiterChatUserModel sender;
  final bool isRead;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RecruiterChatMessageModel({
    required this.id,
    required this.chatId,
    required this.content,
    required this.type,
    required this.sender,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isImage => normalizedType == 'image';

  String get normalizedType => type.trim().toLowerCase();

  factory RecruiterChatMessageModel.fromJson(Map<String, dynamic> json) {
    final senderJson = _asMap(json['sender']);
    final chatJson = _asMap(json['chat']);

    return RecruiterChatMessageModel(
      id: _asInt(json['id']),
      chatId: _asNullableInt(json['chatId']) ?? _asNullableInt(chatJson['id']),
      content: _asString(json['content']),
      type: _asString(json['type'], fallback: 'text'),
      sender: RecruiterChatUserModel.fromJson(senderJson),
      isRead: json['isRead'] is bool ? json['isRead'] as bool : false,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }
}

class RecruiterChatHistoryModel {
  final int total;
  final int page;
  final int limit;
  final List<RecruiterChatMessageModel> messages;

  const RecruiterChatHistoryModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.messages,
  });

  factory RecruiterChatHistoryModel.fromJson(Map<String, dynamic> json) {
    final payload = _asMap(json['data']);
    final messageList = _asList(json['data']).isNotEmpty
        ? _asList(json['data'])
        : _asList(payload['data']).isNotEmpty
        ? _asList(payload['data'])
        : _asList(payload['messages']).isNotEmpty
        ? _asList(payload['messages'])
        : _asList(json['messages']);
    final items = messageList.map(RecruiterChatMessageModel.fromJson).toList();
    final meta = payload.isNotEmpty ? payload : json;

    return RecruiterChatHistoryModel(
      total: _asInt(meta['total']),
      page: _asInt(meta['page']),
      limit: _asInt(meta['limit']),
      messages: items,
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return const <String, dynamic>{};
}

List<Map<String, dynamic>> _asList(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
  return const <Map<String, dynamic>>[];
}

int _asInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? _asNullableInt(dynamic value) {
  if (value == null) {
    return null;
  }
  final parsed = _asInt(value);
  return parsed == 0 ? null : parsed;
}

String _asString(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty || text == 'null') {
    return fallback;
  }
  return text;
}

DateTime? _parseDateTime(dynamic value) {
  final raw = value?.toString();
  if (raw == null || raw.isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw);
}
