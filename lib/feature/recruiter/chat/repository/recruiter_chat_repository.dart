import 'dart:io';

import 'package:msollaally/feature/recruiter/chat/model/recruiter_chat_message_model.dart';
import 'package:msollaally/feature/recruiter/chat/model/recruiter_chat_room_model.dart';
import 'package:msollaally/feature/recruiter/chat/service/recruiter_chat_api_service.dart';
import 'package:msollaally/feature/recruiter/chat/service/recruiter_chat_socket_service.dart';

class RecruiterChatRepository {
  static final RecruiterChatSocketService _sharedSocketService =
      RecruiterChatSocketService();

  final RecruiterChatApiService _apiService;
  final RecruiterChatSocketService _socketService;

  RecruiterChatRepository({
    RecruiterChatApiService? apiService,
    RecruiterChatSocketService? socketService,
  }) : _apiService = apiService ?? RecruiterChatApiService(),
       _socketService = socketService ?? _sharedSocketService;

  RecruiterChatSocketService get socket => _socketService;

  Future<List<RecruiterChatRoomModel>> getChats() => _apiService.getChats();

  Future<RecruiterChatRoomModel> createChat({
    required List<int> receiverIds,
    String? chatName,
  }) => _apiService.createChat(receiverIds: receiverIds, chatName: chatName);

  Future<RecruiterChatRoomModel> getChatById(int chatId) =>
      _apiService.getChatById(chatId);

  Future<RecruiterChatHistoryModel> getChatMessages({
    required int chatId,
    int page = 1,
    int limit = 20,
  }) => _apiService.getChatMessages(chatId: chatId, page: page, limit: limit);

  Future<RecruiterChatMessageModel> sendChatMessage({
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
