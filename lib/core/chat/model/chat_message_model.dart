Map<String, dynamic> chatAsMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}

List<Map<String, dynamic>> chatAsList(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
  return const <Map<String, dynamic>>[];
}

int chatAsInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

int? chatAsNullableInt(dynamic value) {
  if (value == null) return null;
  final parsed = chatAsInt(value);
  return parsed == 0 ? null : parsed;
}

String chatAsString(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty || text == 'null') return fallback;
  return text;
}

DateTime? chatParseDateTime(dynamic value) {
  final raw = value?.toString();
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}

/// Represents the sender of a message.
class ChatSenderModel {
  final int id;
  final String name;
  final String? avatarUrl;

  const ChatSenderModel({required this.id, required this.name, this.avatarUrl});

  factory ChatSenderModel.fromJson(Map<String, dynamic> json) {
    return ChatSenderModel(
      id: chatAsInt(json['id']),
      name: chatAsString(json['name'] ?? json['username']),
      avatarUrl:
          json['avatarUrl']?.toString() ??
          json['profilePicture']?.toString() ??
          json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (avatarUrl != null) 'avatarUrl': avatarUrl,
  };
}

/// Tracks the delivery lifecycle of a locally-created optimistic message.
enum ChatMessageStatus {
  /// Optimistic — not yet confirmed by the server.
  sending,

  /// Server confirmed delivery.
  sent,

  /// Remote peer acknowledged the message was read.
  read,

  /// Delivery failed (network/timeout).
  failed,
}

/// Represents a single chat message.
///
/// Optimistic updates: messages created locally start with [status] ==
/// [ChatMessageStatus.sending]. When the server echoes `newMessage`, the
/// temporary entry is replaced via an upsert keyed on [tempId] or [id].
class ChatMessageModel {
  /// Server-assigned ID. 0 for optimistic (unsent) messages.
  final int id;

  /// The chat room this message belongs to.
  final int? chatId;

  /// Plain text or URL content.
  final String content;

  /// `TEXT`, `IMAGE`, etc.
  final String type;

  /// The user who sent this message.
  final ChatSenderModel sender;

  final bool isRead;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Delivery status — drives optimistic-update UI.
  final ChatMessageStatus status;

  /// Client-side UUID assigned before the server confirms the message.
  /// Used to match the optimistic entry with the real server response.
  final String? tempId;

  const ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.content,
    required this.type,
    required this.sender,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
    this.status = ChatMessageStatus.sent,
    this.tempId,
  });

  bool get isImage => type.trim().toLowerCase() == 'image';
  bool get isSending => status == ChatMessageStatus.sending;
  bool get hasFailed => status == ChatMessageStatus.failed;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final senderJson = chatAsMap(json['sender']);
    final chatJson = chatAsMap(json['chat']);

    return ChatMessageModel(
      id: chatAsInt(json['id']),
      chatId:
          chatAsNullableInt(json['chatId']) ??
          chatAsNullableInt(chatJson['id']),
      content: chatAsString(json['content']),
      type: chatAsString(json['type'], fallback: 'TEXT'),
      sender: ChatSenderModel.fromJson(senderJson),
      isRead: json['isRead'] is bool ? json['isRead'] as bool : false,
      createdAt: chatParseDateTime(json['createdAt']),
      updatedAt: chatParseDateTime(json['updatedAt']),
      status: ChatMessageStatus.sent,
      tempId:
          chatAsString(
            json['tempId'] ?? json['clientTempId'],
            fallback: '',
          ).isEmpty
          ? null
          : chatAsString(json['tempId'] ?? json['clientTempId']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (chatId != null) 'chatId': chatId,
    'content': content,
    'type': type,
    'sender': sender.toJson(),
    'isRead': isRead,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };

  ChatMessageModel copyWith({
    int? id,
    int? chatId,
    String? content,
    String? type,
    ChatSenderModel? sender,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
    ChatMessageStatus? status,
    String? tempId,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      content: content ?? this.content,
      type: type ?? this.type,
      sender: sender ?? this.sender,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      tempId: tempId ?? this.tempId,
    );
  }
}

/// Paginated response from the server's `chatHistory` event.
class ChatHistoryModel {
  final int total;
  final int page;
  final int limit;
  final List<ChatMessageModel> messages;

  const ChatHistoryModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.messages,
  });

  factory ChatHistoryModel.fromJson(Map<String, dynamic> json) {
    // The server may nest data under a `data` key or return it flat.
    final innerData = chatAsMap(json['data']);

    List<Map<String, dynamic>> rawList = chatAsList(json['data']);
    if (rawList.isEmpty) rawList = chatAsList(innerData['data']);
    if (rawList.isEmpty) rawList = chatAsList(innerData['messages']);
    if (rawList.isEmpty) rawList = chatAsList(json['messages']);

    final meta = innerData.isNotEmpty ? innerData : json;

    return ChatHistoryModel(
      total: chatAsInt(meta['total']),
      page: chatAsInt(meta['page']),
      limit: chatAsInt(meta['limit']),
      messages: rawList.map(ChatMessageModel.fromJson).toList(),
    );
  }
}
