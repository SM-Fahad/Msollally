import 'dart:async';

import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/utils/logging/logger.dart';
import 'package:msollaally/feature/recruiter/chat/config/recruiter_chat_socket_events.dart';
import 'package:msollaally/feature/recruiter/chat/model/recruiter_chat_message_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class RecruiterChatSocketService {
  io.Socket? _socket;
  String? _connectedToken;

  final StreamController<Map<String, dynamic>> _connectionSuccessController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<String> _connectionErrorController =
      StreamController<String>.broadcast();
  final StreamController<RecruiterChatHistoryModel> _chatHistoryController =
      StreamController<RecruiterChatHistoryModel>.broadcast();
  final StreamController<String> _chatErrorController =
      StreamController<String>.broadcast();
  final StreamController<RecruiterChatMessageModel> _newMessageController =
      StreamController<RecruiterChatMessageModel>.broadcast();
  final StreamController<Map<String, dynamic>> _messageReceivedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<int> _typingController =
      StreamController<int>.broadcast();
  final StreamController<int> _stopTypingController =
      StreamController<int>.broadcast();
  final StreamController<Map<String, dynamic>> _messageReadController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get connectionSuccessStream =>
      _connectionSuccessController.stream;
  Stream<String> get connectionErrorStream => _connectionErrorController.stream;
  Stream<RecruiterChatHistoryModel> get chatHistoryStream =>
      _chatHistoryController.stream;
  Stream<String> get chatErrorStream => _chatErrorController.stream;
  Stream<RecruiterChatMessageModel> get newMessageStream =>
      _newMessageController.stream;
  Stream<Map<String, dynamic>> get messageReceivedStream =>
      _messageReceivedController.stream;
  Stream<int> get typingStream => _typingController.stream;
  Stream<int> get stopTypingStream => _stopTypingController.stream;
  Stream<Map<String, dynamic>> get messageReadStream =>
      _messageReadController.stream;

  bool get isConnected => _socket?.connected == true;

  void connect({required String token}) {
    if (_socket?.connected == true && _connectedToken == token) {
      AppLoggerHelper.debug(
        '[RecruiterChatSocket] Reusing active socket connection.',
      );
      return;
    }

    if (_socket != null) {
      AppLoggerHelper.debug(
        '[RecruiterChatSocket] Closing previous socket before reconnect.',
      );
      disconnect();
    }

    _connectedToken = token;
    AppLoggerHelper.debug(
      '[RecruiterChatSocket] Connecting to ${Urls.chat} with websocket transport.',
    );

    _socket = io.io(
      Urls.chat,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .disableAutoConnect()
          .setAuth(<String, dynamic>{'token': token})
          .setExtraHeaders(<String, String>{'Authorization': 'Bearer $token'})
          .setQuery(<String, dynamic>{'token': token})
          .build(),
    );

    _socket?.onConnect((_) {
      AppLoggerHelper.info(
        '[RecruiterChatSocket] Connected. socketId=${_socket?.id}',
      );
    });
    _socket?.onDisconnect((reason) {
      AppLoggerHelper.warning(
        '[RecruiterChatSocket] Disconnected. reason=$reason',
      );
    });
    _socket?.on(RecruiterChatSocketEvents.connectionSuccess, (data) {
      AppLoggerHelper.debug(
        '[RecruiterChatSocket] Event ${RecruiterChatSocketEvents.connectionSuccess}: ${_stringify(data)}',
      );
      _connectionSuccessController.add(_asMap(data));
    });
    _socket?.on(RecruiterChatSocketEvents.connectionError, (data) {
      AppLoggerHelper.warning(
        '[RecruiterChatSocket] Event ${RecruiterChatSocketEvents.connectionError}: ${_stringify(data)}',
      );
      _connectionErrorController.add(_extractMessage(data));
    });
    _socket?.onConnectError((data) {
      AppLoggerHelper.error(
        '[RecruiterChatSocket] onConnectError: ${_stringify(data)}',
      );
      _connectionErrorController.add(_extractMessage(data));
    });
    _socket?.onError((data) {
      AppLoggerHelper.error(
        '[RecruiterChatSocket] onError: ${_stringify(data)}',
      );
      _chatErrorController.add(_extractMessage(data));
    });
    _socket?.on(RecruiterChatSocketEvents.chatError, (data) {
      AppLoggerHelper.error(
        '[RecruiterChatSocket] Event ${RecruiterChatSocketEvents.chatError}: ${_stringify(data)}',
      );
      _chatErrorController.add(_extractMessage(data));
    });
    _socket?.on(RecruiterChatSocketEvents.chatHistory, (data) {
      AppLoggerHelper.debug(
        '[RecruiterChatSocket] Event ${RecruiterChatSocketEvents.chatHistory}: ${_stringify(data)}',
      );
      try {
        final history = RecruiterChatHistoryModel.fromJson(_asMap(data));
        AppLoggerHelper.debug(
          '[RecruiterChatSocket] Parsed chatHistory count=${history.messages.length}',
        );
        _chatHistoryController.add(history);
      } catch (e) {
        AppLoggerHelper.error(
          '[RecruiterChatSocket] Failed to parse chatHistory: $e',
        );
      }
    });
    _socket?.on(RecruiterChatSocketEvents.newMessage, (data) {
      AppLoggerHelper.debug(
        '[RecruiterChatSocket] Event ${RecruiterChatSocketEvents.newMessage}: ${_stringify(data)}',
      );
      try {
        final message = RecruiterChatMessageModel.fromJson(_asMap(data));
        _newMessageController.add(message);
      } catch (e) {
        AppLoggerHelper.error(
          '[RecruiterChatSocket] Failed to parse newMessage: $e',
        );
      }
    });
    _socket?.on(RecruiterChatSocketEvents.messageReceived, (data) {
      AppLoggerHelper.debug(
        '[RecruiterChatSocket] Event ${RecruiterChatSocketEvents.messageReceived}: ${_stringify(data)}',
      );
      _messageReceivedController.add(_asMap(data));
    });
    _socket?.on(RecruiterChatSocketEvents.typing, (data) {
      AppLoggerHelper.debug(
        '[RecruiterChatSocket] Event ${RecruiterChatSocketEvents.typing}: ${_stringify(data)}',
      );
      _typingController.add(_extractUserId(data));
    });
    _socket?.on(RecruiterChatSocketEvents.stopTyping, (data) {
      AppLoggerHelper.debug(
        '[RecruiterChatSocket] Event ${RecruiterChatSocketEvents.stopTyping}: ${_stringify(data)}',
      );
      _stopTypingController.add(_extractUserId(data));
    });
    _socket?.on(RecruiterChatSocketEvents.messageRead, (data) {
      AppLoggerHelper.debug(
        '[RecruiterChatSocket] Event ${RecruiterChatSocketEvents.messageRead}: ${_stringify(data)}',
      );
      _messageReadController.add(_asMap(data));
    });

    _socket?.connect();
  }

  void joinChat({required int chatId, int page = 1, int limit = 50}) {
    final payload = <String, dynamic>{
      'chatId': chatId,
      'page': page,
      'limit': limit,
    };
    AppLoggerHelper.debug(
      '[RecruiterChatSocket] Emit ${RecruiterChatSocketEvents.joinChat}: $payload',
    );
    _socket?.emit(RecruiterChatSocketEvents.joinChat, payload);
  }

  void sendMessage({
    required List<int> receiverIds,
    required String content,
    required String type,
    String? chatName,
  }) {
    final payload = <String, dynamic>{
      'receiverIds': receiverIds,
      'content': content,
      'type': type.toLowerCase(),
    };
    if (chatName != null && chatName.trim().isNotEmpty) {
      payload['chatName'] = chatName.trim();
    }
    AppLoggerHelper.debug(
      '[RecruiterChatSocket] Emit ${RecruiterChatSocketEvents.sendMessage}: $payload',
    );
    _socket?.emit(RecruiterChatSocketEvents.sendMessage, payload);
  }

  void markRead({required int chatId, required int messageId}) {
    final payload = <String, dynamic>{'chatId': chatId, 'messageId': messageId};
    AppLoggerHelper.debug(
      '[RecruiterChatSocket] Emit ${RecruiterChatSocketEvents.markRead}: $payload',
    );
    _socket?.emit(RecruiterChatSocketEvents.markRead, payload);
  }

  void sendTyping({required int chatId}) {
    final payload = <String, dynamic>{'chatId': chatId};
    AppLoggerHelper.debug(
      '[RecruiterChatSocket] Emit ${RecruiterChatSocketEvents.typing}: $payload',
    );
    _socket?.emit(RecruiterChatSocketEvents.typing, payload);
  }

  void sendStopTyping({required int chatId}) {
    final payload = <String, dynamic>{'chatId': chatId};
    AppLoggerHelper.debug(
      '[RecruiterChatSocket] Emit ${RecruiterChatSocketEvents.stopTyping}: $payload',
    );
    _socket?.emit(RecruiterChatSocketEvents.stopTyping, payload);
  }

  void disconnect() {
    AppLoggerHelper.debug('[RecruiterChatSocket] Disconnect requested.');
    _socket?.dispose();
    _socket?.disconnect();
    _socket = null;
    _connectedToken = null;
  }

  Future<void> dispose() async {
    disconnect();
    await _connectionSuccessController.close();
    await _connectionErrorController.close();
    await _chatHistoryController.close();
    await _chatErrorController.close();
    await _newMessageController.close();
    await _messageReceivedController.close();
    await _typingController.close();
    await _stopTypingController.close();
    await _messageReadController.close();
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

  String _extractMessage(dynamic data) {
    final map = _asMap(data);
    final text = map['message']?.toString().trim();
    if (text != null && text.isNotEmpty) {
      return text;
    }
    return data?.toString() ?? 'Unknown socket error';
  }

  int _extractUserId(dynamic data) {
    final map = _asMap(data);
    final value = map['userId'];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _stringify(dynamic data) {
    if (data == null) {
      return 'null';
    }
    return data.toString();
  }
}
