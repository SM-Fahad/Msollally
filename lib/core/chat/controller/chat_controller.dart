import 'dart:async';

import 'package:get/get.dart';
import 'package:msollaally/core/chat/model/chat_message_model.dart';
import 'package:msollaally/core/chat/service/chat_socket_service.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/core/utils/logging/logger.dart';
import 'package:uuid/uuid.dart';

// Timeout: if chatHistory doesn't arrive within this duration, clear loading.
const Duration _kHistoryTimeout = Duration(seconds: 10);

const Duration _kTypingDebounce = Duration(milliseconds: 1500);
const Duration _kRemoteTypingTimeout = Duration(seconds: 3);

/// GetxController that drives a single chat conversation screen.
class ChatController extends GetxController {
  final ChatSocketService _socket;
  final SharedPreferenceHelper _prefs;

  ChatController({ChatSocketService? socket, SharedPreferenceHelper? prefs})
    : _socket = socket ?? ChatSocketService.ensureInitialized(),
      _prefs = prefs ?? SharedPreferenceHelper();

  final messages = <ChatMessageModel>[].obs;
  final typingUserIds = <int>{}.obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final currentUserId = 0.obs;

  bool get isSomeoneTyping => typingUserIds.isNotEmpty;

  int? _chatId;
  List<int> _receiverIds = <int>[];
  String _chatName = '';
  bool _isInitialized = false;

  final _uuid = const Uuid();
  Timer? _typingDebounceTimer;
  Timer? _historyTimeoutTimer;
  bool _isUserTyping = false;
  final Map<int, Timer> _remoteTypingTimers = <int, Timer>{};

  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final Set<int> _markingReadIds = {};

  int? get chatId => _chatId;
  String get chatName => _chatName;

  String get statusText {
    if (typingUserIds.isNotEmpty) return 'Typing…';
    if (_socket.isConnecting.value) return 'Connecting…';
    if (_socket.isConnected.value) return 'Online';
    return 'Offline';
  }

  // Lifecycle

  @override
  void onClose() {
    _cancelTyping();
    _historyTimeoutTimer?.cancel();
    _clearRemoteTypingState();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    super.onClose();
  }

  // Initialization

  Future<void> initialize(Map<String, dynamic>? args) async {
    if (_isInitialized) {
      _clearRemoteTypingState();
      AppLoggerHelper.debug('[ChatController] Already initialized — skipping.');
      return;
    }

    _chatId = _parseInt(args?['chatId']);
    _receiverIds = _extractReceiverIds(args);
    _chatName = (args?['chatName'] ?? args?['name'] ?? '').toString().trim();

    AppLoggerHelper.debug('[ChatController] initialize args=$args');

    final storedId = await _prefs.getUserId();
    currentUserId.value = int.tryParse(storedId ?? '') ?? 0;

    final token = await _prefs.getAccessToken();

    if (token == null || token.isEmpty) {
      errorMessage.value =
          'Authentication token not found. Please login again.';
      return;
    }

    _bindSocketListeners();

    // _joinChat() is triggered by connectionSuccessStream once the handshake
    // is confirmed — no fragile hardcoded delay needed here.
    _socket.connectWithToken(token);

    _isInitialized = true;
  }

  // Socket listener binding

  void _bindSocketListeners() {
    if (_subscriptions.isNotEmpty) {
      return;
    }

    // connection_success
    _subscriptions.add(
      _socket.connectionSuccessStream.listen((event) {
        AppLoggerHelper.info('[ChatController] connectionSuccess: $event');
        final serverUserId = _parseInt(event['userId']);
        if (serverUserId != null && serverUserId > 0) {
          currentUserId.value = serverUserId;
        }
        if (_chatId != null && _chatId! > 0) {
          _joinChat();
        }
      }),
    );

    // connection_error
    _subscriptions.add(
      _socket.connectionErrorStream.listen((msg) {
        AppLoggerHelper.warning('[ChatController] connectionError: $msg');
        errorMessage.value = msg;
      }),
    );

    // chat_error
    _subscriptions.add(
      _socket.chatErrorStream.listen((msg) {
        AppLoggerHelper.error('[ChatController] chatError: $msg');
        errorMessage.value = msg;
      }),
    );

    // chatHistory
    _subscriptions.add(
      _socket.chatHistoryStream.listen((history) {
        AppLoggerHelper.debug(
          '[ChatController] chatHistory received: count=${history.messages.length}',
        );
        // Cancel the safety timeout — history arrived in time.
        _historyTimeoutTimer?.cancel();
        messages.assignAll(history.messages);
        isLoading.value = false;
        errorMessage.value = null;
      }),
    );

    // newMessage
    _subscriptions.add(
      _socket.newMessageStream.listen((serverMsg) {
        AppLoggerHelper.debug(
          '[ChatController] newMessage: id=${serverMsg.id} chatId=${serverMsg.chatId}',
        );

        // Filter messages from other chats
        if (serverMsg.chatId != null &&
            _chatId != null &&
            serverMsg.chatId != _chatId) {
          return;
        }

        if (_chatId == null && serverMsg.chatId != null) {
          _chatId = serverMsg.chatId;
        }

        _upsertMessage(serverMsg);
        isLoading.value = false;
      }),
    );

    // messageReceived
    _subscriptions.add(
      _socket.messageReceivedStream.listen((_) {
        AppLoggerHelper.debug('[ChatController] messageReceived observed.');
      }),
    );

    // messageRead
    _subscriptions.add(
      _socket.messageReadStream.listen((event) {
        final messageId = _parseInt(event['messageId']);
        if (messageId == null) {
          return;
        }
        final idx = messages.indexWhere((m) => m.id == messageId);
        if (idx == -1) {
          return;
        }
        messages[idx] = messages[idx].copyWith(
          isRead: true,
          status: ChatMessageStatus.read,
        );
        AppLoggerHelper.debug(
          '[ChatController] messageRead applied: messageId=$messageId',
        );
      }),
    );

    // typingResponse
    _subscriptions.add(
      _socket.typingStream.listen((userId) {
        if (userId != 0 && userId != currentUserId.value) {
          _setUserTyping(userId);
          AppLoggerHelper.debug('[ChatController] typing userId=$userId');
        } else {}
      }),
    );

    // stopTyping
    _subscriptions.add(
      _socket.stopTypingStream.listen((userId) {
        _clearUserTyping(userId);
        AppLoggerHelper.debug('[ChatController] stopTyping userId=$userId');
      }),
    );
  }

  // Chat actions

  void _joinChat({int page = 1, int limit = 50}) {
    if (_chatId == null || _chatId! <= 0) {
      return;
    }
    if (!_socket.isConnected.value) {
      return;
    }
    AppLoggerHelper.debug('[ChatController] joinChat chatId=$_chatId');
    isLoading.value = true;
    _socket.joinChat(chatId: _chatId!, page: page, limit: limit);

    // Safety net: if chatHistory never arrives, clear loading after timeout.
    _historyTimeoutTimer?.cancel();
    _historyTimeoutTimer = Timer(_kHistoryTimeout, () {
      if (isLoading.value) {
        isLoading.value = false;
        if (messages.isEmpty) {
          errorMessage.value =
              'Could not load messages. Please check your connection.';
        }
      }
    });
  }

  void sendMessage(String text, {String type = 'TEXT'}) {
    final content = text.trim();

    if (content.isEmpty) {
      return;
    }

    _cancelTyping();

    if (!_socket.isConnected.value) {
      errorMessage.value = 'Not connected. Please wait and try again.';
      return;
    }

    final tempId = _uuid.v4();

    final optimistic = ChatMessageModel(
      id: 0,
      chatId: _chatId,
      content: content,
      type: type,
      sender: ChatSenderModel(id: currentUserId.value, name: 'Me'),
      isRead: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: ChatMessageStatus.sending,
      tempId: tempId,
    );

    messages.add(optimistic);
    AppLoggerHelper.debug(
      '[ChatController] Optimistic message added. tempId=$tempId',
    );

    _socket.sendMessage(
      receiverIds: _receiverIds,
      content: content,
      type: type,
      chatName: _chatName.isNotEmpty ? _chatName : null,
      tempId: tempId,
    );
  }

  void markRead(int messageId) {
    if (_chatId == null ||
        _chatId! <= 0 ||
        _markingReadIds.contains(messageId)) {
      return;
    }
    _markingReadIds.add(messageId);
    _socket.markRead(chatId: _chatId!, messageId: messageId);
    Future<void>.delayed(const Duration(seconds: 2)).then((_) {
      _markingReadIds.remove(messageId);
    });
  }

  // Typing indicator

  void onTextChanged(String text) {
    if (_chatId == null || _chatId! <= 0) return;

    if (text.trim().isEmpty) {
      _cancelTyping();
      return;
    }

    if (!_isUserTyping) {
      _isUserTyping = true;
      _socket.sendTyping(chatId: _chatId!);
      AppLoggerHelper.debug('[ChatController] typing emitted.');
    }

    _typingDebounceTimer?.cancel();
    _typingDebounceTimer = Timer(_kTypingDebounce, _cancelTyping);
  }

  void _cancelTyping() {
    _typingDebounceTimer?.cancel();
    if (_isUserTyping && _chatId != null && _chatId! > 0) {
      _isUserTyping = false;
      _socket.sendStopTyping(chatId: _chatId!);
      AppLoggerHelper.debug('[ChatController] stopTyping emitted.');
    }
  }

  // Utility

  String formatTime(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final suffix = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  void _upsertMessage(ChatMessageModel incoming) {
    // 1. Match by tempId
    if (incoming.tempId != null) {
      final idx = messages.indexWhere((m) => m.tempId == incoming.tempId);
      if (idx != -1) {
        messages[idx] = incoming;
        AppLoggerHelper.debug(
          '[ChatController] Optimistic replaced. tempId=${incoming.tempId} → id=${incoming.id}',
        );
        return;
      }
    }

    // 2. Match by server id
    if (incoming.id > 0) {
      final idx = messages.indexWhere((m) => m.id == incoming.id);
      if (idx != -1) {
        messages[idx] = incoming;
        AppLoggerHelper.debug(
          '[ChatController] Message updated in-place. id=${incoming.id}',
        );
        return;
      }
    }

    // 3. Fallback for senders when the server echoes the message without tempId.
    final optimisticIndex = _findMatchingOptimisticIndex(incoming);
    if (optimisticIndex != -1) {
      messages[optimisticIndex] = incoming;
      AppLoggerHelper.debug(
        '[ChatController] Optimistic fallback replaced. id=${incoming.id}',
      );
      return;
    }

    // 4. Append as new
    messages.add(incoming);
    AppLoggerHelper.debug(
      '[ChatController] Message appended. id=${incoming.id} total=${messages.length}',
    );
  }

  void _setUserTyping(int userId) {
    _remoteTypingTimers[userId]?.cancel();
    typingUserIds.add(userId);
    _remoteTypingTimers[userId] = Timer(_kRemoteTypingTimeout, () {
      _clearUserTyping(userId);
    });
  }

  void _clearUserTyping(int userId) {
    _remoteTypingTimers.remove(userId)?.cancel();
    typingUserIds.remove(userId);
  }

  void _clearRemoteTypingState() {
    for (final timer in _remoteTypingTimers.values) {
      timer.cancel();
    }
    _remoteTypingTimers.clear();
    typingUserIds.clear();
  }

  int _findMatchingOptimisticIndex(ChatMessageModel incoming) {
    if (incoming.sender.id != currentUserId.value) {
      return -1;
    }

    return messages.lastIndexWhere((message) {
      final createdGap = incoming.createdAt != null && message.createdAt != null
          ? incoming.createdAt!.difference(message.createdAt!).abs().inSeconds
          : 0;

      return message.isSending &&
          message.sender.id == incoming.sender.id &&
          message.type.trim().toUpperCase() ==
              incoming.type.trim().toUpperCase() &&
          message.content.trim() == incoming.content.trim() &&
          createdGap <= 30;
    });
  }

  List<int> _extractReceiverIds(Map<String, dynamic>? args) {
    final raw = args?['receiverIds'];
    if (raw is List) {
      return raw.map((e) => _parseInt(e) ?? 0).where((id) => id > 0).toList();
    }
    final single = _parseInt(args?['receiverId']);
    if (single != null && single > 0) return [single];
    return const <int>[];
  }

  int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
