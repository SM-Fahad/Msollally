import 'dart:io';

import 'package:msollaally/feature/teacher/chat/model/teacher_chat_message_model.dart';
import 'package:msollaally/feature/teacher/chat/model/teacher_chat_room_model.dart';
import 'package:msollaally/feature/teacher/chat/service/teacher_chat_api_service.dart';
import 'package:msollaally/feature/teacher/chat/service/teacher_chat_socket_service.dart';

class TeacherChatRepository {
  static final TeacherChatSocketService _sharedSocketService =
      TeacherChatSocketService();

  final TeacherChatApiService _apiService;
  final TeacherChatSocketService _socketService;

  TeacherChatRepository({
    TeacherChatApiService? apiService,
    TeacherChatSocketService? socketService,
  }) : _apiService = apiService ?? TeacherChatApiService(),
       _socketService = socketService ?? _sharedSocketService;

  TeacherChatSocketService get socket => _socketService;

  Future<List<TeacherChatRoomModel>> getChats() => _apiService.getChats();

  Future<TeacherChatRoomModel> createChat({
    required List<int> receiverIds,
    String? chatName,
  }) => _apiService.createChat(receiverIds: receiverIds, chatName: chatName);

  Future<TeacherChatRoomModel> getChatById(int chatId) =>
      _apiService.getChatById(chatId);

  Future<TeacherChatHistoryModel> getChatMessages({
    required int chatId,
    int page = 1,
    int limit = 20,
  }) => _apiService.getChatMessages(chatId: chatId, page: page, limit: limit);

  Future<TeacherChatMessageModel> sendChatMessage({
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

  Future<void> addMembers({required int chatId, required List<int> userIds}) =>
      _apiService.addMembers(chatId: chatId, userIds: userIds);

  Future<void> removeMember({required int chatId, required int userId}) =>
      _apiService.removeMember(chatId: chatId, userId: userId);
}
