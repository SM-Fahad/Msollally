import 'dart:io';

import 'package:msollaally/feature/student/campus/chat/model/student_chat_message_model.dart';
import 'package:msollaally/feature/student/campus/chat/model/student_chat_room_model.dart';
import 'package:msollaally/feature/student/campus/chat/service/student_chat_api_service.dart';
import 'package:msollaally/feature/student/campus/chat/service/student_chat_socket_service.dart';

class StudentChatRepository {
  static final StudentChatSocketService _sharedSocketService =
      StudentChatSocketService();

  final StudentChatApiService _apiService;
  final StudentChatSocketService _socketService;

  StudentChatRepository({
    StudentChatApiService? apiService,
    StudentChatSocketService? socketService,
  }) : _apiService = apiService ?? StudentChatApiService(),
       _socketService = socketService ?? _sharedSocketService;

  StudentChatSocketService get socket => _socketService;

  Future<List<StudentChatRoomModel>> getChats() => _apiService.getChats();

  Future<StudentChatRoomModel> createChat({
    required List<int> receiverIds,
    String? chatName,
  }) => _apiService.createChat(receiverIds: receiverIds, chatName: chatName);

  Future<StudentChatRoomModel> getChatById(int chatId) =>
      _apiService.getChatById(chatId);

  Future<StudentChatHistoryModel> getChatMessages({
    required int chatId,
    int page = 1,
    int limit = 20,
  }) => _apiService.getChatMessages(chatId: chatId, page: page, limit: limit);

  Future<StudentChatMessageModel> sendChatMessage({
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
