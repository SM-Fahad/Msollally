import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:msollaally/core/models/response_data.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';
import 'package:msollaally/core/services/share_preferrance_helper.dart';
import 'package:msollaally/core/utils/logging/logger.dart';
import 'package:msollaally/feature/pro_partners/chat/model/pro_partners_chat_message_model.dart';
import 'package:msollaally/feature/pro_partners/chat/model/pro_partners_chat_room_model.dart';

class ProPartnersChatApiService {
  final NetworkCaller _networkCaller = NetworkCaller();
  final SharedPreferenceHelper _prefs = SharedPreferenceHelper();

  Future<List<ProPartnersChatRoomModel>> getChats() async {
    final token = await _requireToken();
    final response = await _networkCaller.getRequest(
      Urls.chat,
      token: 'Bearer $token',
    );

    final items = _extractListResponse(
      response,
      fallbackMessage: 'Failed to load chats.',
    );
    return items.map(ProPartnersChatRoomModel.fromJson).toList();
  }

  Future<ProPartnersChatRoomModel> createChat({
    required List<int> receiverIds,
    String? chatName,
  }) async {
    final token = await _requireToken();
    final body = <String, dynamic>{'receiverIds': receiverIds};
    if (chatName != null && chatName.trim().isNotEmpty) {
      body['chatName'] = chatName.trim();
    }

    final response = await _networkCaller.postJsonRequest(
      Urls.chat,
      token: 'Bearer $token',
      body: body,
    );

    final item = _extractMapResponse(
      response,
      fallbackMessage: 'Failed to create chat.',
    );
    return ProPartnersChatRoomModel.fromJson(item);
  }

  Future<ProPartnersChatRoomModel> getChatById(int chatId) async {
    final token = await _requireToken();
    final response = await _networkCaller.getRequest(
      Urls.chatById(chatId),
      token: 'Bearer $token',
    );

    final item = _extractMapResponse(
      response,
      fallbackMessage: 'Failed to load chat.',
    );
    return ProPartnersChatRoomModel.fromJson(item);
  }

  Future<ProPartnersChatHistoryModel> getChatMessages({
    required int chatId,
    int page = 1,
    int limit = 20,
  }) async {
    AppLoggerHelper.debug(
      '[StudentChatApi] Fetching messages chatId=$chatId page=$page limit=$limit',
    );
    final token = await _requireToken();
    final response = await _networkCaller.getRequest(
      Urls.chatMessages(chatId, page: page, limit: limit),
      token: 'Bearer $token',
    );

    final data = _extractPayloadResponse(
      response,
      fallbackMessage: 'Failed to load messages.',
    );
    final history = ProPartnersChatHistoryModel.fromJson(data);
    AppLoggerHelper.info(
      '[StudentChatApi] Messages fetched. chatId=$chatId count=${history.messages.length} page=${history.page} total=${history.total}',
    );
    return history;
  }

  Future<ProPartnersChatMessageModel> sendChatMessage({
    required int chatId,
    required String content,
    String type = 'text',
  }) async {
    final token = await _requireToken();
    final response = await _networkCaller.postJsonRequest(
      Urls.sendChatMessage,
      token: 'Bearer $token',
      body: <String, dynamic>{
        'chatId': chatId,
        'content': content,
        'type': type,
      },
    );

    final item = _extractMapResponse(
      response,
      fallbackMessage: 'Failed to send message.',
    );
    return ProPartnersChatMessageModel.fromJson(item);
  }

  Future<String> uploadChatImage({required File file}) async {
    final token = await _requireToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(Urls.uploadCloudinaryFile),
    );

    request.headers.addAll({'accept': '*/*', 'Authorization': 'Bearer $token'});

    request.files.add(await http.MultipartFile.fromPath('files', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to upload chat image.');
    }

    final uploadedUrl = _extractUploadedFileUrl(response.body);
    if (uploadedUrl == null || uploadedUrl.isEmpty) {
      throw Exception('Chat image upload succeeded but URL was missing.');
    }

    return uploadedUrl;
  }

  Future<void> markMessageRead({
    required int messageId,
    required int chatId,
  }) async {
    final token = await _requireToken();
    final response = await _networkCaller.patchJsonRequest(
      Urls.readChatMessage(messageId),
      token: 'Bearer $token',
      body: <String, dynamic>{'chatId': chatId},
    );
    _ensureSuccess(
      response,
      fallbackMessage: 'Failed to mark message as read.',
    );
  }

  Future<void> deleteMessage(int messageId) async {
    final token = await _requireToken();
    final response = await _networkCaller.deleteRequest(
      Urls.deleteChatMessage(messageId),
      token: 'Bearer $token',
    );
    _ensureSuccess(response, fallbackMessage: 'Failed to delete message.');
  }

  Future<void> leaveChat(int chatId) async {
    final token = await _requireToken();
    final response = await _networkCaller.postJsonRequest(
      Urls.leaveChat(chatId),
      token: 'Bearer $token',
      body: const <String, dynamic>{},
    );
    _ensureSuccess(response, fallbackMessage: 'Failed to leave chat.');
  }

  Future<String> _requireToken() async {
    final token = await _prefs.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please login again.');
    }
    return token;
  }

  String? _extractUploadedFileUrl(String rawBody) {
    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
        final first = decoded.first as Map;
        return (first['url'] ?? first['secure_url'] ?? first['fileUrl'])
            ?.toString();
      }
      if (decoded is Map) {
        final top =
            decoded['url'] ?? decoded['secure_url'] ?? decoded['fileUrl'];
        if (top != null) {
          return top.toString();
        }
        final data = decoded['data'];
        if (data is List && data.isNotEmpty && data.first is Map) {
          final first = data.first as Map;
          return (first['url'] ?? first['secure_url'] ?? first['fileUrl'])
              ?.toString();
        }
        if (data is Map) {
          return (data['url'] ?? data['secure_url'] ?? data['fileUrl'])
              ?.toString();
        }
      }
    } catch (_) {}
    return null;
  }

  List<Map<String, dynamic>> _extractListResponse(
    ResponseData response, {
    required String fallbackMessage,
  }) {
    _ensureSuccess(response, fallbackMessage: fallbackMessage);
    final payload = response.responseData;
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }
    return const <Map<String, dynamic>>[];
  }

  Map<String, dynamic> _extractMapResponse(
    ResponseData response, {
    required String fallbackMessage,
  }) {
    _ensureSuccess(response, fallbackMessage: fallbackMessage);
    final payload = response.responseData;
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
    }
    throw Exception(fallbackMessage);
  }

  Map<String, dynamic> _extractPayloadResponse(
    ResponseData response, {
    required String fallbackMessage,
  }) {
    _ensureSuccess(response, fallbackMessage: fallbackMessage);
    final payload = response.responseData;
    if (payload is Map<String, dynamic>) {
      return payload;
    }
    if (payload is Map) {
      return Map<String, dynamic>.from(payload);
    }
    throw Exception(fallbackMessage);
  }

  void _ensureSuccess(
    ResponseData response, {
    required String fallbackMessage,
  }) {
    if (!response.isSuccess) {
      throw Exception(
        response.errorMessage.isNotEmpty
            ? response.errorMessage
            : fallbackMessage,
      );
    }
  }
}
