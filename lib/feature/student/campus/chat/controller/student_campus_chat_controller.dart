import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/core/utils/logging/logger.dart';
import 'package:msollaally/feature/student/campus/chat/model/student_chat_message_model.dart';
import 'package:msollaally/feature/student/campus/chat/model/student_chat_room_model.dart';
import 'package:msollaally/feature/student/campus/chat/repository/student_chat_repository.dart';
import 'package:msollaally/feature/student/campus/chat/service/chat_badge_service.dart';

class StudentCampusChatController extends GetxController {
  static const Duration _chatRequestTimeout = Duration(seconds: 20);
  static const Duration _typingDebounce = Duration(milliseconds: 1500);
  final StudentChatRepository _repository;
  final SharedPreferenceHelper _prefs;
  final ImagePicker _picker;

  StudentCampusChatController({
    StudentChatRepository? repository,
    SharedPreferenceHelper? prefs,
    ImagePicker? picker,
  }) : _repository = repository ?? StudentChatRepository(),
       _prefs = prefs ?? SharedPreferenceHelper(),
       _picker = picker ?? ImagePicker();

  final userId = 0.obs;
  final chatId = RxnInt();
  final isGroup = false.obs;
  final isLoading = false.obs;
  final isConnecting = false.obs;
  final isSocketReady = false.obs;
  final typingUserIds = <int>{}.obs;
  final messages = <StudentChatMessageModel>[].obs;
  final selectedImagePath = ''.obs;
  final errorMessage = RxnString();
  final currentRoom = Rxn<StudentChatRoomModel>();
  final textController = TextEditingController();
  final _markingReadMessageIds = <int>{};
  bool _isInitializing = false;
  bool _isTyping = false;
  String _initializedChatKey = '';
  Timer? _typingDebounceTimer;

  List<int> _receiverIds = <int>[];
  String _chatName = '';
  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];

  String get title {
    if (_chatName.trim().isNotEmpty) {
      return _chatName.trim();
    }
    return currentRoom.value?.name.trim().isNotEmpty == true
        ? currentRoom.value!.name.trim()
        : 'Chat';
  }

  int get otherUserId {
    if (isGroup.value) return 0;
    if (_receiverIds.isNotEmpty) return _receiverIds.first;
    final room = currentRoom.value;
    if (room != null && room.participants.isNotEmpty) {
      final other = room.participants.firstWhere(
        (p) => p.user.id != userId.value,
        orElse: () => room.participants.first,
      );
      return other.user.id;
    }
    return 0;
  }

  String get statusText {
    if (typingUserIds.isNotEmpty) {
      return typingLabel;
    }
    if (isConnecting.value && !isSocketReady.value) {
      return 'Connecting...';
    }
    final participantCount = currentRoom.value?.participants.length ?? 0;
    if (isGroup.value && participantCount > 0) {
      return '$participantCount members';
    }
    return 'Active Now';
  }

  String get typingLabel {
    if (typingUserIds.isEmpty) {
      return '';
    }
    if (!isGroup.value) {
      return 'Typing...';
    }

    final room = currentRoom.value;
    if (room == null) {
      return 'Typing...';
    }

    final typers = room.participants
        .where((participant) => typingUserIds.contains(participant.user.id))
        .map((participant) => participant.user.displayName)
        .toList();

    if (typers.isEmpty) {
      return 'Typing...';
    }
    if (typers.length == 1) {
      return '${typers.first} is typing';
    }
    return 'Several people typing';
  }

  @override
  void onClose() {
    _cancelTyping(notify: true);
    _typingDebounceTimer?.cancel();
    textController.dispose();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    super.onClose();
  }

  Future<void> initialize(Map<String, dynamic>? args) async {
    final nextChatKey = _buildChatKey(args);
    AppLoggerHelper.debug(
      '[StudentCampusChatController] initialize args=$args nextChatKey=$nextChatKey',
    );
    if (_isInitializing) {
      AppLoggerHelper.debug(
        '[StudentCampusChatController] initialize skipped: already initializing.',
      );
      return;
    }
    if (_initializedChatKey == nextChatKey &&
        (messages.isNotEmpty || currentRoom.value != null)) {
      AppLoggerHelper.debug(
        '[StudentCampusChatController] initialize skipped: chat already initialized.',
      );
      return;
    }

    _isInitializing = true;
    try {
      isLoading.value = false;
      messages.clear();
      typingUserIds.clear();
      errorMessage.value = null;
      currentRoom.value = null;
      chatId.value = null;
      _receiverIds = _extractReceiverIds(args);
      _chatName = (args?['chatName'] ?? args?['name'] ?? '').toString();
      isGroup.value = args?['isGroup'] == true || _receiverIds.length > 1;
      chatId.value = _parseInt(args?['chatId']) ?? _parseInt(args?['groupId']);
      AppLoggerHelper.debug(
        '[StudentCampusChatController] Parsed chatId=${chatId.value} receiverIds=$_receiverIds isGroup=${isGroup.value} chatName=$_chatName',
      );

      await _loadCurrentUser();
      await _resolveChat();
      isLoading.value = true;
      _bindSocketListeners();
      await _connectSocket();
      await _loadMessageHistory();
      _initializedChatKey = nextChatKey;
      AppLoggerHelper.info(
        '[StudentCampusChatController] Chat initialized. chatId=${chatId.value} messageCount=${messages.length}',
      );
    } catch (e) {
      AppLoggerHelper.error(
        '[StudentCampusChatController] initialize failed: $e',
      );
      errorMessage.value = _extractErrorMessage(e);
      isLoading.value = false;
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _loadCurrentUser() async {
    final storedUserId = await _prefs.getUserId();
    userId.value = int.tryParse(storedUserId ?? '') ?? 0;
    AppLoggerHelper.debug(
      '[StudentCampusChatController] Current user id=${userId.value}',
    );
  }

  void _bindSocketListeners() {
    if (_subscriptions.isNotEmpty) {
      return;
    }

    _subscriptions.add(
      _repository.socket.connectionSuccessStream.listen((event) {
        isSocketReady.value = true;
        final connectedUserId = _parseInt(event['userId']);
        if (connectedUserId != null && connectedUserId > 0) {
          userId.value = connectedUserId;
        }
        AppLoggerHelper.info(
          '[StudentCampusChatController] connectionSuccess userId=${userId.value} payload=$event',
        );
        _joinCurrentChat();
      }),
    );

    _subscriptions.add(
      _repository.socket.connectionErrorStream.listen((message) {
        AppLoggerHelper.warning(
          '[StudentCampusChatController] connectionError=$message',
        );
        errorMessage.value = message;
      }),
    );

    _subscriptions.add(
      _repository.socket.chatErrorStream.listen((message) {
        AppLoggerHelper.error(
          '[StudentCampusChatController] chatError=$message',
        );
        errorMessage.value = message;
      }),
    );

    _subscriptions.add(
      _repository.socket.chatHistoryStream.listen((history) {
        AppLoggerHelper.debug(
          '[StudentCampusChatController] chatHistory messages=${history.messages.length} page=${history.page} total=${history.total}',
        );
        messages.assignAll(history.messages);
        isLoading.value = false;
        AppLoggerHelper.debug(
          '[StudentCampusChatController] Loading cleared from socket chatHistory.',
        );
      }),
    );

    _subscriptions.add(
      _repository.socket.newMessageStream.listen((message) {
        final activeChatId = chatId.value;
        if (activeChatId == null) {
          AppLoggerHelper.warning(
            '[StudentCampusChatController] newMessage ignored: no active chat. messageId=${message.id}',
          );
          return;
        }
        if (message.chatId == null || message.chatId == activeChatId) {
          AppLoggerHelper.debug(
            '[StudentCampusChatController] newMessage accepted: messageId=${message.id} chatId=${message.chatId}',
          );
          _upsertMessage(message);
          if (isLoading.value) {
            isLoading.value = false;
          }
        } else {
          AppLoggerHelper.warning(
            '[StudentCampusChatController] newMessage ignored: activeChatId=$activeChatId incomingChatId=${message.chatId}',
          );
        }
      }),
    );

    _subscriptions.add(
      _repository.socket.messageReceivedStream.listen((data) {
        AppLoggerHelper.debug(
          '[StudentCampusChatController] messageReceived event observed: $data',
        );
        try {
          if (data.isNotEmpty) {
            final msgMap = data['message'] is Map
                ? data['message'] as Map<String, dynamic>
                : data;
            if (msgMap.containsKey('id') && msgMap.containsKey('content')) {
              final message = StudentChatMessageModel.fromJson(
                Map<String, dynamic>.from(msgMap),
              );
              final activeChatId = chatId.value;
              if (activeChatId == null ||
                  message.chatId == null ||
                  message.chatId == activeChatId) {
                _upsertMessage(message);
                return;
              }
            }
          }
        } catch (_) {}
        _loadMessageHistory();
      }),
    );

    _subscriptions.add(
      _repository.socket.typingStream.listen((typingUserId) {
        if (typingUserId != 0 && typingUserId != userId.value) {
          typingUserIds.add(typingUserId);
          AppLoggerHelper.debug(
            '[StudentCampusChatController] typing userId=$typingUserId',
          );
        }
      }),
    );

    _subscriptions.add(
      _repository.socket.stopTypingStream.listen((typingUserId) {
        typingUserIds.remove(typingUserId);
        AppLoggerHelper.debug(
          '[StudentCampusChatController] stopTyping userId=$typingUserId',
        );
      }),
    );

    _subscriptions.add(
      _repository.socket.messageReadStream.listen((event) {
        final messageId = _parseInt(event['messageId']);
        if (messageId == null) {
          AppLoggerHelper.warning(
            '[StudentCampusChatController] messageRead ignored: missing messageId payload=$event',
          );
          return;
        }
        final index = messages.indexWhere((message) => message.id == messageId);
        if (index == -1) {
          AppLoggerHelper.warning(
            '[StudentCampusChatController] messageRead ignored: unknown messageId=$messageId',
          );
          return;
        }
        final existing = messages[index];
        messages[index] = StudentChatMessageModel(
          id: existing.id,
          chatId: existing.chatId,
          content: existing.content,
          type: existing.type,
          sender: existing.sender,
          isRead: true,
          createdAt: existing.createdAt,
          updatedAt: existing.updatedAt,
        );
        AppLoggerHelper.debug(
          '[StudentCampusChatController] messageRead applied: messageId=$messageId',
        );
      }),
    );
  }

  Future<void> _connectSocket() async {
    final token = await _prefs.getAccessToken();
    if (token == null || token.isEmpty) {
      AppLoggerHelper.error(
        '[StudentCampusChatController] Missing access token for socket connection.',
      );
      errorMessage.value = 'Authentication token not found.';
      return;
    }

    if (_repository.socket.isConnected) {
      AppLoggerHelper.debug(
        '[StudentCampusChatController] Socket already connected — joining chat directly.',
      );
      isSocketReady.value = true;
      isConnecting.value = false;
      _joinCurrentChat();
      return;
    }

    AppLoggerHelper.debug('[StudentCampusChatController] Connecting socket...');
    isConnecting.value = true;
    isSocketReady.value = false;
    _repository.socket.connect(token: token);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    isSocketReady.value = _repository.socket.isConnected || isSocketReady.value;
    AppLoggerHelper.info(
      '[StudentCampusChatController] Socket connection status=${_repository.socket.isConnected} isSocketReady=${isSocketReady.value}',
    );
    isConnecting.value = false;
  }

  Future<void> _resolveChat() async {
    final activeChatId = chatId.value;
    if (activeChatId != null && activeChatId > 0) {
      AppLoggerHelper.debug(
        '[StudentCampusChatController] Loading chat details for chatId=$activeChatId',
      );
      currentRoom.value = await _repository
          .getChatById(activeChatId)
          .timeout(
            _chatRequestTimeout,
            onTimeout: () => throw Exception('Loading chat details timed out.'),
          );
      AppLoggerHelper.debug(
        '[StudentCampusChatController] Chat details loaded. roomId=${currentRoom.value?.id} name=${currentRoom.value?.name}',
      );
      if (_receiverIds.isEmpty && currentRoom.value != null) {
        _receiverIds = currentRoom.value!.participants
            .where((p) => p.user.id != userId.value)
            .map((p) => p.user.id)
            .toList();
        AppLoggerHelper.debug(
          '[StudentCampusChatController] Backfilled receiverIds=$_receiverIds from room participants',
        );
      }
      return;
    }

    if (_receiverIds.isEmpty) {
      AppLoggerHelper.warning(
        '[StudentCampusChatController] No chatId or receiverIds. Chat cannot be resolved.',
      );
      return;
    }

    AppLoggerHelper.debug(
      '[StudentCampusChatController] Creating chat for receiverIds=$_receiverIds',
    );
    final room = await _repository
        .createChat(
          receiverIds: _receiverIds,
          chatName: isGroup.value ? _chatName : null,
        )
        .timeout(
          _chatRequestTimeout,
          onTimeout: () => throw Exception('Creating chat timed out.'),
        );
    currentRoom.value = room;
    chatId.value = room.id;
    if (_chatName.trim().isEmpty) {
      _chatName = room.name;
    }
    AppLoggerHelper.info(
      '[StudentCampusChatController] Chat created. chatId=${room.id} name=${room.name}',
    );
  }

  Future<void> retry() => initialize(<String, dynamic>{
    'chatId': chatId.value,
    'receiverIds': _receiverIds,
    'chatName': _chatName,
    'isGroup': isGroup.value,
  });

  Future<void> _loadMessageHistory() async {
    final activeChatId = chatId.value;
    if (activeChatId == null || activeChatId <= 0) {
      AppLoggerHelper.warning(
        '[StudentCampusChatController] Loading message history skipped: invalid chatId=$activeChatId',
      );
      return;
    }

    AppLoggerHelper.debug(
      '[StudentCampusChatController] Loading message history for chatId=$activeChatId',
    );
    try {
      final history = await _repository
          .getChatMessages(chatId: activeChatId, page: 1, limit: 20)
          .timeout(
            _chatRequestTimeout,
            onTimeout: () => throw Exception('Loading messages timed out.'),
          );
      messages.assignAll(history.messages);
      AppLoggerHelper.info(
        '[StudentCampusChatController] Message history loaded. count=${history.messages.length}',
      );
      // Mark all incoming unread messages as read when opening the chat
      _markAllUnreadAsRead();
    } catch (e) {
      AppLoggerHelper.error(
        '[StudentCampusChatController] Loading message history failed: $e',
      );
      errorMessage.value = _extractErrorMessage(e);
    } finally {
      isLoading.value = false;
      AppLoggerHelper.debug(
        '[StudentCampusChatController] Loading state cleared. isLoading=${isLoading.value}',
      );
    }
  }

  /// Marks every unread message from others as read in a single pass,
  /// then clears this room from the global unread badge count.
  void _markAllUnreadAsRead() {
    final unread = messages
        .where((m) => !m.isRead && m.sender.id != userId.value)
        .toList();
    if (unread.isEmpty) return;
    for (final m in unread) {
      markRead(m.id);
    }
    // Decrement the global badge — this room is now read
    if (ChatBadgeService.unreadCount.value > 0) {
      ChatBadgeService.unreadCount.value--;
    }
    AppLoggerHelper.debug(
      '[StudentCampusChatController] Marked ${unread.length} messages as read on open.',
    );
  }

  void _joinCurrentChat() {
    final activeChatId = chatId.value;
    if (activeChatId == null ||
        activeChatId <= 0 ||
        !_repository.socket.isConnected) {
      AppLoggerHelper.warning(
        '[StudentCampusChatController] joinChat skipped. chatId=$activeChatId socketConnected=${_repository.socket.isConnected}',
      );
      return;
    }

    AppLoggerHelper.debug(
      '[StudentCampusChatController] Joining socket room for chatId=$activeChatId',
    );
    _repository.socket.joinChat(chatId: activeChatId, page: 1, limit: 50);
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImagePath.value = image.path;
    }
  }

  Future<void> sendMessage(String text) async {
    final activeChatId = chatId.value;
    if (activeChatId == null || activeChatId <= 0 || text.trim().isEmpty) {
      return;
    }

    if (_receiverIds.isEmpty && currentRoom.value != null) {
      _receiverIds = currentRoom.value!.participants
          .where((p) => p.user.id != userId.value)
          .map((p) => p.user.id)
          .toList();
    }
    if (_receiverIds.isEmpty && messages.isNotEmpty) {
      final otherMsg =
          messages.firstWhereOrNull((m) => m.sender.id != userId.value);
      if (otherMsg != null) {
        _receiverIds = [otherMsg.sender.id];
      }
    }

    final content = text.trim();
    try {
      _cancelTyping(notify: true);
      if (_repository.socket.isConnected) {
        _repository.socket.sendMessage(
          receiverIds: _receiverIds,
          content: content,
          type: 'text',
          chatName: isGroup.value ? _chatName : null,
        );
      } else {
        await _repository.sendChatMessage(
          chatId: activeChatId,
          content: content,
          type: 'text',
        );
        await _loadMessageHistory();
      }
    } catch (e) {
      errorMessage.value = _extractErrorMessage(e);
    }
  }

  void sendText() {
    final text = textController.text.trim();
    if (selectedImagePath.value.isNotEmpty) {
      sendImageMessage();
      selectedImagePath.value = '';
    } else if (text.isNotEmpty) {
      sendMessage(text);
    }
    textController.clear();
  }

  Future<void> sendImageMessage() async {
    final activeChatId = chatId.value;
    final imagePath = selectedImagePath.value.trim();
    if (activeChatId == null || activeChatId <= 0 || imagePath.isEmpty) {
      return;
    }

    if (_receiverIds.isEmpty && currentRoom.value != null) {
      _receiverIds = currentRoom.value!.participants
          .where((p) => p.user.id != userId.value)
          .map((p) => p.user.id)
          .toList();
    }
    if (_receiverIds.isEmpty && messages.isNotEmpty) {
      final otherMsg =
          messages.firstWhereOrNull((m) => m.sender.id != userId.value);
      if (otherMsg != null) {
        _receiverIds = [otherMsg.sender.id];
      }
    }

    try {
      _cancelTyping(notify: true);
      final uploadedImageUrl = await _repository.uploadChatImage(
        file: File(imagePath),
      );
      if (_repository.socket.isConnected) {
        _repository.socket.sendMessage(
          receiverIds: _receiverIds,
          content: uploadedImageUrl,
          type: 'image',
          chatName: isGroup.value ? _chatName : null,
        );
      } else {
        await _repository.sendChatMessage(
          chatId: activeChatId,
          content: uploadedImageUrl,
          type: 'image',
        );
        await _loadMessageHistory();
      }
      selectedImagePath.value = '';
    } catch (e) {
      errorMessage.value = _extractErrorMessage(e);
    }
  }

  Future<void> markRead(int messageId) async {
    final activeChatId = chatId.value;
    if (activeChatId == null ||
        activeChatId <= 0 ||
        _markingReadMessageIds.contains(messageId)) {
      return;
    }

    _markingReadMessageIds.add(messageId);
    try {
      await _repository.markMessageRead(
        messageId: messageId,
        chatId: activeChatId,
      );
      _repository.socket.markRead(chatId: activeChatId, messageId: messageId);
    } catch (e) {
      errorMessage.value = _extractErrorMessage(e);
    } finally {
      _markingReadMessageIds.remove(messageId);
    }
  }

  void onTypingChanged(String text) {
    final activeChatId = chatId.value;
    if (activeChatId == null || activeChatId <= 0) {
      return;
    }

    if (text.trim().isEmpty) {
      _cancelTyping(notify: true);
    } else {
      if (!_isTyping) {
        _isTyping = true;
        _repository.socket.sendTyping(chatId: activeChatId);
      }
      _typingDebounceTimer?.cancel();
      _typingDebounceTimer = Timer(
        _typingDebounce,
        () => _cancelTyping(notify: true),
      );
    }
  }

  void _cancelTyping({bool notify = false}) {
    _typingDebounceTimer?.cancel();
    final activeChatId = chatId.value;
    if (_isTyping && notify && activeChatId != null && activeChatId > 0) {
      _repository.socket.sendStopTyping(chatId: activeChatId);
    }
    _isTyping = false;
  }

  String formatTime(DateTime? createdAt) {
    if (createdAt == null) {
      return '';
    }
    final time = createdAt.toLocal();
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  void _upsertMessage(StudentChatMessageModel message) {
    final index = messages.indexWhere((item) => item.id == message.id);
    if (index == -1) {
      messages.add(message);
      AppLoggerHelper.debug(
        '[StudentCampusChatController] Message appended. id=${message.id} total=${messages.length}',
      );
    } else {
      messages[index] = message;
      AppLoggerHelper.debug(
        '[StudentCampusChatController] Message updated. id=${message.id} index=$index',
      );
    }
  }

  Future<void> leaveOrDeleteChat() async {
    final activeChatId = chatId.value;
    if (activeChatId == null || activeChatId <= 0) return;
    try {
      await _repository.leaveChat(activeChatId);
      AppLoggerHelper.info(
        '[StudentCampusChatController] Left/deleted chat chatId=$activeChatId',
      );
      _repository.socket.disconnect();
      Get.back(); // close chat screen
      Get.back(); // also close the bottom sheet if it's still open
    } catch (e) {
      AppLoggerHelper.error(
        '[StudentCampusChatController] leaveOrDeleteChat error: $e',
      );
      errorMessage.value = _extractErrorMessage(e);
    }
  }

  List<int> _extractReceiverIds(Map<String, dynamic>? args) {
    final raw = args?['receiverIds'];
    if (raw is List) {
      return raw
          .map((item) => _parseInt(item) ?? 0)
          .where((id) => id > 0)
          .toList();
    }

    final receiverId = _parseInt(args?['reciverId'] ?? args?['receiverId']);
    if (receiverId != null && receiverId > 0) {
      return <int>[receiverId];
    }
    return const <int>[];
  }

  int? _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    final parsed = int.tryParse(value?.toString() ?? '');
    return parsed;
  }

  String _buildChatKey(Map<String, dynamic>? args) {
    final directChatId = _parseInt(args?['chatId']);
    if (directChatId != null && directChatId > 0) {
      return 'chat:$directChatId';
    }

    final receiverIds = _extractReceiverIds(args)..sort();
    final name = (args?['chatName'] ?? args?['name'] ?? '').toString().trim();
    final groupFlag = args?['isGroup'] == true || receiverIds.length > 1;
    return 'receivers:${receiverIds.join(',')}|group:$groupFlag|name:$name';
  }

  String _extractErrorMessage(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    return message.isEmpty ? 'Chat request failed.' : message;
  }
}
