// ignore_for_file: library_prefixes
import 'dart:async';

import 'package:get/get.dart';
import 'package:msollaally/core/chat/config/chat_socket_events.dart';
import 'package:msollaally/core/chat/model/chat_message_model.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/utils/logging/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatSocketService extends GetxService {
  static ChatSocketService ensureInitialized() {
    if (!Get.isRegistered<ChatSocketService>()) {
      Get.put<ChatSocketService>(ChatSocketService(), permanent: true);
    } else {}
    return Get.find<ChatSocketService>();
  }

  IO.Socket? _socket;
  String? _activeToken;

  final isConnected = false.obs;
  final isConnecting = false.obs;

  final _connectionSuccessCtrl =
      StreamController<Map<String, dynamic>>.broadcast();
  final _connectionErrorCtrl = StreamController<String>.broadcast();
  final _chatHistoryCtrl = StreamController<ChatHistoryModel>.broadcast();
  final _chatErrorCtrl = StreamController<String>.broadcast();
  final _newMessageCtrl = StreamController<ChatMessageModel>.broadcast();
  final _messageReceivedCtrl =
      StreamController<Map<String, dynamic>>.broadcast();
  final _messageReadCtrl = StreamController<Map<String, dynamic>>.broadcast();
  final _typingCtrl = StreamController<int>.broadcast();
  final _stopTypingCtrl = StreamController<int>.broadcast();

  Stream<Map<String, dynamic>> get connectionSuccessStream =>
      _connectionSuccessCtrl.stream;
  Stream<String> get connectionErrorStream => _connectionErrorCtrl.stream;
  Stream<ChatHistoryModel> get chatHistoryStream => _chatHistoryCtrl.stream;
  Stream<String> get chatErrorStream => _chatErrorCtrl.stream;
  Stream<ChatMessageModel> get newMessageStream => _newMessageCtrl.stream;
  Stream<Map<String, dynamic>> get messageReceivedStream =>
      _messageReceivedCtrl.stream;
  Stream<Map<String, dynamic>> get messageReadStream => _messageReadCtrl.stream;
  Stream<int> get typingStream => _typingCtrl.stream;
  Stream<int> get stopTypingStream => _stopTypingCtrl.stream;

  // Connection management

  void connectWithToken(String token) {
    if (_socket?.connected == true && _activeToken == token) {
      AppLoggerHelper.debug(
        '[ChatSocketService] Reusing active connection (same token).',
      );
      return;
    }

    if (_socket != null) {
      AppLoggerHelper.debug(
        '[ChatSocketService] Closing previous socket before reconnect.',
      );
      _closeSocket();
    }

    _activeToken = token;
    isConnecting.value = true;

    AppLoggerHelper.debug(
      '[ChatSocketService] Connecting to ${Urls.socketUrl} …',
    );

    _socket = IO.io(
      Urls.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .disableAutoConnect()
          .setAuth(<String, dynamic>{'token': token})
          .setExtraHeaders(<String, String>{'Authorization': 'Bearer $token'})
          .setQuery(<String, dynamic>{'token': token})
          .build(),
    );

    _registerSocketCallbacks();

    _socket!.connect();
  }

  void disconnect() {
    AppLoggerHelper.debug('[ChatSocketService] disconnect() called.');
    _closeSocket();
  }

  // Client-emitted events

  void joinChat({required int chatId, int page = 1, int limit = 50}) {
    _emit(ChatSocketEvents.joinChat, <String, dynamic>{
      'chatId': chatId,
      'page': page,
      'limit': limit,
    });
  }

  void sendMessage({
    required List<int> receiverIds,
    required String content,
    String type = 'TEXT',
    String? chatName,
    String? tempId,
  }) {
    final payload = <String, dynamic>{
      'receiverIds': receiverIds,
      'content': content,
      'type': type.toUpperCase(),
      if (tempId != null && tempId.trim().isNotEmpty) 'tempId': tempId.trim(),
    };
    if (chatName != null && chatName.trim().isNotEmpty) {
      payload['chatName'] = chatName.trim();
    }
    _emit(ChatSocketEvents.sendMessage, payload);
  }

  void markRead({required int chatId, required int messageId}) {
    _emit(ChatSocketEvents.markRead, <String, dynamic>{
      'chatId': chatId,
      'messageId': messageId,
    });
  }

  void sendTyping({required int chatId}) {
    _emit(ChatSocketEvents.typing, <String, dynamic>{'chatId': chatId});
  }

  void sendStopTyping({required int chatId}) {
    _emit(ChatSocketEvents.stopTyping, <String, dynamic>{'chatId': chatId});
  }

  // GetxService lifecycle

  @override
  void onClose() {
    AppLoggerHelper.debug('[ChatSocketService] onClose — disposing resources.');
    _closeSocket();
    _connectionSuccessCtrl.close();
    _connectionErrorCtrl.close();
    _chatHistoryCtrl.close();
    _chatErrorCtrl.close();
    _newMessageCtrl.close();
    _messageReceivedCtrl.close();
    _messageReadCtrl.close();
    _typingCtrl.close();
    _stopTypingCtrl.close();
    super.onClose();
  }

  // Private helpers

  void _closeSocket() {
    _socket?.dispose();
    _socket?.disconnect();
    _socket = null;
    _activeToken = null;
    isConnected.value = false;
    isConnecting.value = false;
  }

  void _emit(String event, Map<String, dynamic> payload) {
    if (_socket?.connected != true) {
      AppLoggerHelper.warning(
        '[ChatSocketService] Cannot emit "$event" — socket not connected.',
      );
      return;
    }
    AppLoggerHelper.debug('[ChatSocketService] emit "$event" payload=$payload');
    _socket!.emit(event, payload);
  }

  void _registerSocketCallbacks() {
    _socket!.onConnect((_) {
      AppLoggerHelper.info(
        '[ChatSocketService] Connected. socketId=${_socket?.id}',
      );
      isConnected.value = true;
      isConnecting.value = false;
    });

    _socket!.onDisconnect((reason) {
      AppLoggerHelper.warning(
        '[ChatSocketService] Disconnected. reason=$reason',
      );
      isConnected.value = false;
      isConnecting.value = false;
    });

    _socket!.onConnectError((data) {
      AppLoggerHelper.error(
        '[ChatSocketService] onConnectError: ${_stringify(data)}',
      );
      isConnecting.value = false;
      _connectionErrorCtrl.add(_extractMessage(data));
    });

    _socket!.onError((data) {
      AppLoggerHelper.error('[ChatSocketService] onError: ${_stringify(data)}');
      _chatErrorCtrl.add(_extractMessage(data));
    });

    _socket!.on('reconnect', (attempt) {});
    _socket!.on('reconnect_attempt', (attempt) {});
    _socket!.on('reconnect_failed', (_) {});

    // connection_success → { success: true, userId: 1 }
    _socket!.on(ChatSocketEvents.connectionSuccess, (data) {
      AppLoggerHelper.info(
        '[ChatSocketService] ${ChatSocketEvents.connectionSuccess}: ${_stringify(data)}',
      );
      _connectionSuccessCtrl.add(_asMap(data));
    });

    // connection_error → { message: "Invalid token" }
    _socket!.on(ChatSocketEvents.connectionError, (data) {
      AppLoggerHelper.warning(
        '[ChatSocketService] ${ChatSocketEvents.connectionError}: ${_stringify(data)}',
      );
      final msg = _extractMessage(data);
      _connectionErrorCtrl.add(msg);
      _showErrorSnackbar('Connection Error', msg);
    });

    // chatHistory → { total, page, limit, data: [...] }
    _socket!.on(ChatSocketEvents.chatHistory, (data) {
      AppLoggerHelper.debug(
        '[ChatSocketService] ${ChatSocketEvents.chatHistory}: received',
      );
      try {
        final history = ChatHistoryModel.fromJson(_asMap(data));
        if (history.messages.isNotEmpty) {}
        AppLoggerHelper.debug(
          '[ChatSocketService] chatHistory parsed: count=${history.messages.length}',
        );
        _chatHistoryCtrl.add(history);
      } catch (e) {
        AppLoggerHelper.error(
          '[ChatSocketService] chatHistory parse error: $e',
        );
      }
    });

    // newMessage → full message object
    _socket!.on(ChatSocketEvents.newMessage, (data) {
      AppLoggerHelper.debug(
        '[ChatSocketService] ${ChatSocketEvents.newMessage}: ${_stringify(data)}',
      );
      try {
        final message = ChatMessageModel.fromJson(_asMap(data));
        _newMessageCtrl.add(message);
      } catch (e) {
        AppLoggerHelper.error('[ChatSocketService] newMessage parse error: $e');
      }
    });

    // messageReceived → { id, content } lightweight broadcast
    _socket!.on(ChatSocketEvents.messageReceived, (data) {
      AppLoggerHelper.debug(
        '[ChatSocketService] ${ChatSocketEvents.messageReceived}: ${_stringify(data)}',
      );
      _messageReceivedCtrl.add(_asMap(data));
    });

    // messageRead → { userId, messageId }
    _socket!.on(ChatSocketEvents.messageRead, (data) {
      AppLoggerHelper.debug(
        '[ChatSocketService] ${ChatSocketEvents.messageRead}: ${_stringify(data)}',
      );
      _messageReadCtrl.add(_asMap(data));
    });

    // typingResponse → { userId }
    _socket!.on(ChatSocketEvents.typingResponse, (data) {
      AppLoggerHelper.debug(
        '[ChatSocketService] ${ChatSocketEvents.typingResponse}: ${_stringify(data)}',
      );
      _typingCtrl.add(_extractUserId(data));
    });

    // stopTyping response → { userId }
    _socket!.on(ChatSocketEvents.stopTypingResponse, (data) {
      AppLoggerHelper.debug(
        '[ChatSocketService] ${ChatSocketEvents.stopTypingResponse}: ${_stringify(data)}',
      );
      _stopTypingCtrl.add(_extractUserId(data));
    });

    // chat_error → { message: "..." }
    _socket!.on(ChatSocketEvents.chatError, (data) {
      final msg = _extractMessage(data);
      AppLoggerHelper.error(
        '[ChatSocketService] ${ChatSocketEvents.chatError}: $msg',
      );
      _chatErrorCtrl.add(msg);
      _showErrorSnackbar('Chat Error', msg);
    });
  }

  void _showErrorSnackbar(String title, String message) {
    if (!Get.isSnackbarOpen) {
      Get.snackbar(
        title,
        message,
        duration: const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
      );
    } else {}
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const <String, dynamic>{};
  }

  String _extractMessage(dynamic data) {
    final map = _asMap(data);
    final text = map['message']?.toString().trim();
    if (text != null && text.isNotEmpty) return text;
    return data?.toString() ?? 'Unknown socket error';
  }

  int _extractUserId(dynamic data) {
    final map = _asMap(data);
    final value = map['userId'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _stringify(dynamic data) => data?.toString() ?? 'null';
}
