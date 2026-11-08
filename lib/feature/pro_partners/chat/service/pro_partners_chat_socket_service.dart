import 'dart:async';

import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/utils/logging/logger.dart';
import 'package:msollaally/feature/pro_partners/chat/config/pro_partners_chat_socket_events.dart';
import 'package:msollaally/feature/pro_partners/chat/model/pro_partners_chat_message_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ProPartnersChatSocketService {
  io.Socket? _socket;
  String? _connectedToken;

  final StreamController<Map<String, dynamic>> _connectionSuccessController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<String> _connectionErrorController =
      StreamController<String>.broadcast();
  final StreamController<ProPartnersChatHistoryModel> _chatHistoryController =
      StreamController<ProPartnersChatHistoryModel>.broadcast();
  final StreamController<String> _chatErrorController =
      StreamController<String>.broadcast();
  final StreamController<ProPartnersChatMessageModel> _newMessageController =
      StreamController<ProPartnersChatMessageModel>.broadcast();
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
  Stream<ProPartnersChatHistoryModel> get chatHistoryStream =>
      _chatHistoryController.stream;
  Stream<String> get chatErrorStream => _chatErrorController.stream;
  Stream<ProPartnersChatMessageModel> get newMessageStream =>
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
        '[ProPartnersChatSocket] Reusing active socket connection.',
      );
      return;
    }

    if (_socket != null) {
      AppLoggerHelper.debug(
        '[ProPartnersChatSocket] Closing previous socket before reconnect.',
      );
      disconnect();
    }

    _connectedToken = token;
    AppLoggerHelper.debug(
      '[ProPartnersChatSocket] Connecting to ${Urls.chat} with websocket transport.',
    );

    _socket = io.io(
      Urls.chat,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .disableAutoConnect()
          .setExtraHeaders(<String, String>{'Authorization': 'Bearer $token'})
          .build(),
    );

    _socket?.onConnect((_) {
      AppLoggerHelper.info(
        '[ProPartnersChatSocket] Connected. socketId=${_socket?.id}',
      );
    });
    _socket?.onDisconnect((reason) {
      AppLoggerHelper.warning(
        '[ProPartnersChatSocket] Disconnected. reason=$reason',
      );
    });
    _socket?.on(ProPartnersChatSocketEvents.connectionSuccess, (data) {
      AppLoggerHelper.debug(
        '[ProPartnersChatSocket] Event ${ProPartnersChatSocketEvents.connectionSuccess}: ${_stringify(data)}',
      );
      _connectionSuccessController.add(_asMap(data));
    });
    _socket?.on(ProPartnersChatSocketEvents.connectionError, (data) {
      AppLoggerHelper.warning(
        '[ProPartnersChatSocket] Event ${ProPartnersChatSocketEvents.connectionError}: ${_stringify(data)}',
      );
      _connectionErrorController.add(_extractMessage(data));
    });
    _socket?.onConnectError((data) {
      AppLoggerHelper.error(
        '[ProPartnersChatSocket] onConnectError: ${_stringify(data)}',
      );
      _connectionErrorController.add(_extractMessage(data));
    });
    _socket?.onError((data) {
      AppLoggerHelper.error(
        '[ProPartnersChatSocket] onError: ${_stringify(data)}',
      );
      _chatErrorController.add(_extractMessage(data));
    });
    _socket?.on(ProPartnersChatSocketEvents.chatError, (data) {
      AppLoggerHelper.error(
        '[ProPartnersChatSocket] Event ${ProPartnersChatSocketEvents.chatError}: ${_stringify(data)}',
      );
      _chatErrorController.add(_extractMessage(data));
    });
    _socket?.on(ProPartnersChatSocketEvents.chatHistory, (data) {
      AppLoggerHelper.debug(
        '[ProPartnersChatSocket] Event ${ProPartnersChatSocketEvents.chatHistory}: ${_stringify(data)}',
      );
      try {
        final history = ProPartnersChatHistoryModel.fromJson(_asMap(data));
        AppLoggerHelper.debug(
          '[ProPartnersChatSocket] Parsed chatHistory count=${history.messages.length}',
        );
        _chatHistoryController.add(history);
      } catch (e) {
        AppLoggerHelper.error(
          '[ProPartnersChatSocket] Failed to parse chatHistory: $e',
        );
      }
    });
    _socket?.on(ProPartnersChatSocketEvents.newMessage, (data) {
      AppLoggerHelper.debug(
        '[ProPartnersChatSocket] Event ${ProPartnersChatSocketEvents.newMessage}: ${_stringify(data)}',
      );
      try {
        final message = ProPartnersChatMessageModel.fromJson(_asMap(data));
        _newMessageController.add(message);
      } catch (e) {
        AppLoggerHelper.error(
          '[ProPartnersChatSocket] Failed to parse newMessage: $e',
        );
      }
    });
    _socket?.on(ProPartnersChatSocketEvents.messageReceived, (data) {
      AppLoggerHelper.debug(
        '[ProPartnersChatSocket] Event ${ProPartnersChatSocketEvents.messageReceived}: ${_stringify(data)}',
      );
      _messageReceivedController.add(_asMap(data));
    });
    _socket?.on(ProPartnersChatSocketEvents.typing, (data) {
      AppLoggerHelper.debug(
        '[ProPartnersChatSocket] Event ${ProPartnersChatSocketEvents.typing}: ${_stringify(data)}',
      );
      _typingController.add(_extractUserId(data));
    });
    _socket?.on(ProPartnersChatSocketEvents.stopTyping, (data) {
      AppLoggerHelper.debug(
        '[ProPartnersChatSocket] Event ${ProPartnersChatSocketEvents.stopTyping}: ${_stringify(data)}',
      );
      _stopTypingController.add(_extractUserId(data));
    });
    _socket?.on(ProPartnersChatSocketEvents.messageRead, (data) {
      AppLoggerHelper.debug(
        '[ProPartnersChatSocket] Event ${ProPartnersChatSocketEvents.messageRead}: ${_stringify(data)}',
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
      '[ProPartnersChatSocket] Emit ${ProPartnersChatSocketEvents.joinChat}: $payload',
    );
    _socket?.emit(ProPartnersChatSocketEvents.joinChat, payload);
  }

  void sendMessage({
    required List<int> receiverIds,
    required String content,
    required String type,
    String? chatName,
    int? chatId,
  }) {
    final payload = <String, dynamic>{
      'receiverIds': receiverIds,
      'content': content,
      'type': type.toLowerCase(),
      if (chatId != null && chatId > 0) 'chatId': chatId,
    };
    if (chatName != null && chatName.trim().isNotEmpty) {
      payload['chatName'] = chatName.trim();
    }
    AppLoggerHelper.debug(
      '[ProPartnersChatSocket] Emit ${ProPartnersChatSocketEvents.sendMessage}: $payload',
    );
    _socket?.emit(ProPartnersChatSocketEvents.sendMessage, payload);
  }

  void markRead({required int chatId, required int messageId}) {
    final payload = <String, dynamic>{'chatId': chatId, 'messageId': messageId};
    AppLoggerHelper.debug(
      '[ProPartnersChatSocket] Emit ${ProPartnersChatSocketEvents.markRead}: $payload',
    );
    _socket?.emit(ProPartnersChatSocketEvents.markRead, payload);
  }

  void sendTyping({required int chatId}) {
    final payload = <String, dynamic>{'chatId': chatId};
    AppLoggerHelper.debug(
      '[ProPartnersChatSocket] Emit ${ProPartnersChatSocketEvents.typing}: $payload',
    );
    _socket?.emit(ProPartnersChatSocketEvents.typing, payload);
  }

  void sendStopTyping({required int chatId}) {
    final payload = <String, dynamic>{'chatId': chatId};
    AppLoggerHelper.debug(
      '[ProPartnersChatSocket] Emit ${ProPartnersChatSocketEvents.stopTyping}: $payload',
    );
    _socket?.emit(ProPartnersChatSocketEvents.stopTyping, payload);
  }

  void disconnect() {
    AppLoggerHelper.debug('[ProPartnersChatSocket] Disconnect requested.');
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
