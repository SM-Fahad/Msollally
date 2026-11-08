import 'dart:io';

import 'package:msollaally/feature/pro_partners/chat/model/pro_partners_chat_message_model.dart';
import 'package:msollaally/feature/pro_partners/chat/model/pro_partners_chat_room_model.dart';
import 'package:msollaally/feature/pro_partners/chat/service/pro_partners_chat_api_service.dart';
import 'package:msollaally/feature/pro_partners/chat/service/pro_partners_chat_socket_service.dart';

class ProPartnersChatRepository {
  static final ProPartnersChatSocketService _sharedSocketService =
      ProPartnersChatSocketService();

  final ProPartnersChatApiService _apiService;
  final ProPartnersChatSocketService _socketService;

  ProPartnersChatRepository({
    ProPartnersChatApiService? apiService,
    ProPartnersChatSocketService? socketService,
  }) : _apiService = apiService ?? ProPartnersChatApiService(),
       _socketService = socketService ?? _sharedSocketService;

  ProPartnersChatSocketService get socket => _socketService;

  Future<List<ProPartnersChatRoomModel>> getChats() => _apiService.getChats();

  Future<ProPartnersChatRoomModel> createChat({
    required List<int> receiverIds,
    String? chatName,
  }) => _apiService.createChat(receiverIds: receiverIds, chatName: chatName);

  Future<ProPartnersChatRoomModel> getChatById(int chatId) =>
      _apiService.getChatById(chatId);

  Future<ProPartnersChatHistoryModel> getChatMessages({
    required int chatId,
    int page = 1,
    int limit = 20,
  }) => _apiService.getChatMessages(chatId: chatId, page: page, limit: limit);

  Future<ProPartnersChatMessageModel> sendChatMessage({
    required int chatId,
    required String content,
    String type = 'text',
  }) =>
      _apiService.sendChatMessage(chatId: chatId, content: content, type: type);

  Future<String> uploadChatImage({required File file}) =>
      _apiService.uploadChatImage(file: file);

  Future<void> markMessageRead({required int messageId, required int chatId}) =>
      _apiService.markMessageRead(messageId: messageId, chatId: chatId);

  Future<void> deleteMessage(int messageId) =>
      _apiService.deleteMessage(messageId);

  Future<void> leaveChat(int chatId) => _apiService.leaveChat(chatId);
}
