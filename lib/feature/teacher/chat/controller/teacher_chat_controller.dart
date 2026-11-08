import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/core/utils/logging/logger.dart';
import 'package:msollaally/feature/teacher/chat/model/teacher_chat_message_model.dart';
import 'package:msollaally/feature/teacher/chat/model/teacher_chat_room_model.dart';
import 'package:msollaally/feature/teacher/chat/repository/teacher_chat_repository.dart';

class TeacherChatController extends GetxController
    with GetSingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const Duration _chatRequestTimeout = Duration(seconds: 20);
  static const Duration _typingDebounce = Duration(milliseconds: 1500);
  final TeacherChatRepository _repository;
  final SharedPreferenceHelper _prefs;
  final ImagePicker _picker;

  TeacherChatController({
    TeacherChatRepository? repository,
    SharedPreferenceHelper? prefs,
    ImagePicker? picker,
  }) : _repository = repository ?? TeacherChatRepository(),
       _prefs = prefs ?? SharedPreferenceHelper(),
       _picker = picker ?? ImagePicker();

  final messageController = TextEditingController();
  final scrollController = ScrollController();
  late final AnimationController typingAnimationController;
  bool _scrollScheduled = false;

  final userId = 0.obs;
  final chatId = RxnInt();
  final isGroup = false.obs;
  final isLoading = false.obs;
  final isConnecting = false.obs;
  final isSocketReady = false.obs;
  final typingUserIds = <int>{}.obs;
  final messages = <TeacherChatMessageModel>[].obs;
  final selectedImagePath = ''.obs;
  final errorMessage = RxnString();
  final currentRoom = Rxn<TeacherChatRoomModel>();
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
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // Auto-scroll when messages list changes
    messages.listen((_) {
      _scheduleScrollToBottom();
    });
  }

  void _scheduleScrollToBottom() {
    if (_scrollScheduled) {
      return;
    }
    _scrollScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollScheduled = false;
      if (!scrollController.hasClients) {
        return;
      }
      try {
        final position = scrollController.position;
        if (!position.hasContentDimensions) {
          return;
        }
        final target = position.maxScrollExtent;
        if ((position.pixels - target).abs() < 1) {
          return;
        }
        scrollController.jumpTo(target);
      } catch (_) {
        return;
      }
    });
  }

  @override
  void didChangeMetrics() {
    _scheduleScrollToBottom();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    messageController.dispose();
    scrollController.dispose();
    typingAnimationController.dispose();
    _cancelTyping(notify: true);
    _typingDebounceTimer?.cancel();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    super.onClose();
  }

  Future<void> initialize(Map<String, dynamic>? args) async {
    final nextChatKey = _buildChatKey(args);
    AppLoggerHelper.debug(
      '[TeacherChatController] initialize args=$args nextChatKey=$nextChatKey',
    );
    if (_isInitializing) {
      AppLoggerHelper.debug(
        '[TeacherChatController] initialize skipped: already initializing.',
      );
      return;
    }
    if (_initializedChatKey == nextChatKey &&
        (messages.isNotEmpty || currentRoom.value != null)) {
      AppLoggerHelper.debug(
        '[TeacherChatController] initialize skipped: chat already initialized.',
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
      chatId.value = _parseInt(args?['chatId']);
      AppLoggerHelper.debug(
        '[TeacherChatController] Parsed chatId=${chatId.value} receiverIds=$_receiverIds isGroup=${isGroup.value} chatName=$_chatName',
      );

      await _loadCurrentUser();
      await _resolveChat();
      isLoading.value = true;
      _bindSocketListeners();
      await _connectSocket();
      await _loadMessageHistory();
      // NOTE: _joinCurrentChat() is NOT called here.
      // It is triggered exclusively by connectionSuccessStream once the
      // socket handshake is confirmed — avoids double joinChat/chatHistory.
      _initializedChatKey = nextChatKey;
      AppLoggerHelper.info(
        '[TeacherChatController] Chat initialized. chatId=${chatId.value} messageCount=${messages.length}',
      );
    } catch (e) {
      AppLoggerHelper.error('[TeacherChatController] initialize failed: $e');
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
      '[TeacherChatController] Current user id=${userId.value}',
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
          '[TeacherChatController] connectionSuccess userId=${userId.value} payload=$event',
        );
        _joinCurrentChat();
      }),
    );

    _subscriptions.add(
      _repository.socket.connectionErrorStream.listen((message) {
        AppLoggerHelper.warning(
          '[TeacherChatController] connectionError=$message',
        );
        errorMessage.value = message;
      }),
    );

    _subscriptions.add(
      _repository.socket.chatErrorStream.listen((message) {
        AppLoggerHelper.error('[TeacherChatController] chatError=$message');
        errorMessage.value = message;
      }),
    );

    _subscriptions.add(
      _repository.socket.chatHistoryStream.listen((history) {
        AppLoggerHelper.debug(
          '[TeacherChatController] chatHistory messages=${history.messages.length} page=${history.page} total=${history.total}',
        );
        _applyHistoryMessages(history.messages);
        // Always clear loading — handles the case where REST API completed
        // before the socket history arrived (isLoading already false), as
        // well as the case where only the socket path ran.
        isLoading.value = false;
        AppLoggerHelper.debug(
          '[TeacherChatController] Loading cleared from socket chatHistory.',
        );
      }),
    );

    _subscriptions.add(
      _repository.socket.newMessageStream.listen((message) {
        final activeChatId = chatId.value;
        if (activeChatId == null) {
          AppLoggerHelper.warning(
            '[TeacherChatController] newMessage ignored: no active chat. messageId=${message.id}',
          );
          return;
        }
        if (message.chatId == null || message.chatId == activeChatId) {
          AppLoggerHelper.debug(
            '[TeacherChatController] newMessage accepted: messageId=${message.id} chatId=${message.chatId}',
          );
          _upsertMessage(message);
          if (isLoading.value) {
            isLoading.value = false;
          }
        } else {
          AppLoggerHelper.warning(
            '[TeacherChatController] newMessage ignored: activeChatId=$activeChatId incomingChatId=${message.chatId}',
          );
        }
      }),
    );

    _subscriptions.add(
      _repository.socket.messageReceivedStream.listen((_) {
        // Server broadcasts this to the chat room. `newMessage` carries
        // the full payload, so the UI relies on that event for rendering.
        AppLoggerHelper.debug(
          '[TeacherChatController] messageReceived event observed.',
        );
      }),
    );

    _subscriptions.add(
      _repository.socket.typingStream.listen((typingUserId) {
        if (typingUserId != 0 && typingUserId != userId.value) {
          typingUserIds.add(typingUserId);
          AppLoggerHelper.debug(
            '[TeacherChatController] typing userId=$typingUserId',
          );
        }
      }),
    );

    _subscriptions.add(
      _repository.socket.stopTypingStream.listen((typingUserId) {
        typingUserIds.remove(typingUserId);
        AppLoggerHelper.debug(
          '[TeacherChatController] stopTyping userId=$typingUserId',
        );
      }),
    );

    _subscriptions.add(
      _repository.socket.messageReadStream.listen((event) {
        final messageId = _parseInt(event['messageId']);
        if (messageId == null) {
          AppLoggerHelper.warning(
            '[TeacherChatController] messageRead ignored: missing messageId payload=$event',
          );
          return;
        }
        final index = messages.indexWhere((message) => message.id == messageId);
        if (index == -1) {
          AppLoggerHelper.warning(
            '[TeacherChatController] messageRead ignored: unknown messageId=$messageId',
          );
          return;
        }
        final existing = messages[index];
        messages[index] = TeacherChatMessageModel(
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
          '[TeacherChatController] messageRead applied: messageId=$messageId',
        );
      }),
    );
  }

  Future<void> _connectSocket() async {
    final token = await _prefs.getAccessToken();
    if (token == null || token.isEmpty) {
      AppLoggerHelper.error(
        '[TeacherChatController] Missing access token for socket connection.',
      );
      errorMessage.value = 'Authentication token not found.';
      return;
    }

    if (_repository.socket.isConnected) {
      AppLoggerHelper.debug(
        '[TeacherChatController] Socket already connected — joining chat directly.',
      );
      isSocketReady.value = true;
      isConnecting.value = false;
      // connection_success won't fire again for an already-connected socket,
      // so we must trigger the join manually here.
      _joinCurrentChat();
      return;
    }

    AppLoggerHelper.debug('[TeacherChatController] Connecting socket...');
    isConnecting.value = true;
    isSocketReady.value = false;
    _repository.socket.connect(token: token);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    isSocketReady.value = _repository.socket.isConnected || isSocketReady.value;
    AppLoggerHelper.info(
      '[TeacherChatController] Socket connection status=${_repository.socket.isConnected} isSocketReady=${isSocketReady.value}',
    );
    isConnecting.value = false;
  }

  Future<void> _resolveChat() async {
    final activeChatId = chatId.value;
    if (activeChatId != null && activeChatId > 0) {
      AppLoggerHelper.debug(
        '[TeacherChatController] Loading chat details for chatId=$activeChatId',
      );
      currentRoom.value = await _repository
          .getChatById(activeChatId)
          .timeout(
            _chatRequestTimeout,
            onTimeout: () => throw Exception('Loading chat details timed out.'),
          );
      AppLoggerHelper.debug(
        '[TeacherChatController] Chat details loaded. roomId=${currentRoom.value?.id} name=${currentRoom.value?.name}',
      );
      if (currentRoom.value != null) {
        isGroup.value = currentRoom.value!.isGroup;
      }
      if (_receiverIds.isEmpty && currentRoom.value != null) {
        _receiverIds = currentRoom.value!.participants
            .where((participant) => participant.user.id != userId.value)
            .map((participant) => participant.user.id)
            .toList();
        AppLoggerHelper.debug(
          '[TeacherChatController] Backfilled receiverIds=$_receiverIds from room participants',
        );
      }
      return;
    }

    if (_receiverIds.isEmpty) {
      AppLoggerHelper.warning(
        '[TeacherChatController] No chatId or receiverIds. Chat cannot be resolved.',
      );
      return;
    }

    AppLoggerHelper.debug(
      '[TeacherChatController] Creating chat for receiverIds=$_receiverIds',
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
    isGroup.value = room.isGroup;
    if (_chatName.trim().isEmpty) {
      _chatName = room.name;
    }
    AppLoggerHelper.info(
      '[TeacherChatController] Chat created. chatId=${room.id} name=${room.name}',
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
        '[TeacherChatController] Loading message history skipped: invalid chatId=$activeChatId',
      );
      return;
    }

    AppLoggerHelper.debug(
      '[TeacherChatController] Loading message history for chatId=$activeChatId',
    );
    try {
      const pageSize = 50;
      final allMessages = <TeacherChatMessageModel>[];
      var page = 1;
      var total = 0;

      while (true) {
        final history = await _repository
            .getChatMessages(chatId: activeChatId, page: page, limit: pageSize)
            .timeout(
              _chatRequestTimeout,
              onTimeout: () => throw Exception('Loading messages timed out.'),
            );
        total = history.total > 0 ? history.total : total;
        allMessages.addAll(history.messages);
        AppLoggerHelper.debug(
          '[TeacherChatController] Loaded history page=$page count=${history.messages.length} total=$total',
        );
        if (history.messages.isEmpty ||
            history.messages.length < pageSize ||
            (total > 0 && allMessages.length >= total)) {
          break;
        }
        page++;
      }

      _applyHistoryMessages(allMessages);
      AppLoggerHelper.info(
        '[TeacherChatController] Message history loaded. count=${messages.length}',
      );
    } catch (e) {
      AppLoggerHelper.error(
        '[TeacherChatController] Loading message history failed: $e',
      );
      errorMessage.value = _extractErrorMessage(e);
    } finally {
      isLoading.value = false;
      AppLoggerHelper.debug(
        '[TeacherChatController] Loading state cleared. isLoading=${isLoading.value}',
      );
    }
  }

  void _joinCurrentChat() {
    final activeChatId = chatId.value;
    if (activeChatId == null ||
        activeChatId <= 0 ||
        !_repository.socket.isConnected) {
      AppLoggerHelper.warning(
        '[TeacherChatController] joinChat skipped. chatId=$activeChatId socketConnected=${_repository.socket.isConnected}',
      );
      return;
    }

    AppLoggerHelper.debug(
      '[TeacherChatController] Joining socket room for chatId=$activeChatId',
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

    final content = text.trim();
    try {
      _cancelTyping(notify: true);
      _repository.socket.sendMessage(
        receiverIds: _receiverIds,
        content: content,
        type: 'text',
        chatName: isGroup.value ? _chatName : null,
      );
    } catch (e) {
      errorMessage.value = _extractErrorMessage(e);
    }
  }

  Future<void> sendImageMessage() async {
    final activeChatId = chatId.value;
    final imagePath = selectedImagePath.value.trim();
    if (activeChatId == null || activeChatId <= 0 || imagePath.isEmpty) {
      return;
    }

    try {
      _cancelTyping(notify: true);
      final uploadedImageUrl = await _repository.uploadChatImage(
        file: File(imagePath),
      );
      _repository.socket.sendMessage(
        receiverIds: _receiverIds,
        content: uploadedImageUrl,
        type: 'image',
        chatName: isGroup.value ? _chatName : null,
      );
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

  void _upsertMessage(TeacherChatMessageModel message) {
    final index = messages.indexWhere((item) => item.id == message.id);
    if (index == -1) {
      messages.add(message);
      AppLoggerHelper.debug(
        '[TeacherChatController] Message appended. id=${message.id} total=${messages.length}',
      );
    } else {
      messages[index] = message;
      AppLoggerHelper.debug(
        '[TeacherChatController] Message updated. id=${message.id} index=$index',
      );
    }
  }

  Future<void> leaveOrDeleteChat() async {
    final activeChatId = chatId.value;
    if (activeChatId == null || activeChatId <= 0) return;
    try {
      await _repository.leaveChat(activeChatId);
      AppLoggerHelper.info(
        '[TeacherChatController] Left/deleted chat chatId=$activeChatId',
      );
      _repository.socket.disconnect();
      Get.back();
    } catch (e) {
      AppLoggerHelper.error(
        '[TeacherChatController] leaveOrDeleteChat error: $e',
      );
      errorMessage.value = _extractErrorMessage(e);
    }
  }

  void _applyHistoryMessages(List<TeacherChatMessageModel> incoming) {
    final merged = <TeacherChatMessageModel>[];
    final seenIds = <int>{};

    for (final message in [...messages, ...incoming]) {
      if (message.id > 0) {
        if (seenIds.add(message.id)) {
          merged.add(message);
        } else {
          final index = merged.indexWhere((item) => item.id == message.id);
          if (index != -1) {
            merged[index] = message;
          }
        }
      } else {
        merged.add(message);
      }
    }

    merged.sort((a, b) {
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final byTime = aTime.compareTo(bTime);
      return byTime != 0 ? byTime : a.id.compareTo(b.id);
    });

    messages.assignAll(merged);
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
