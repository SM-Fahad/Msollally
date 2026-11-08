import 'dart:io';
import 'package:msollaally/core/models/response_data.dart';
import 'package:msollaally/core/services/end_points.dart';
import 'package:msollaally/core/services/network_caller.dart';

class StudentAIChatService {
  static Future<ResponseData> sendChatMessage({
    required String message,
    String? userId,
    String? threadId,
    File? audio,
    List<File>? files,
  }) async {
    Map<String, String> fields = {'message': message};
    if (userId != null) {
      fields['user_id'] = userId;
    }
    if (threadId != null) {
      fields['thread_id'] = threadId;
    }

    Map<String, List<File>> filesMap = {};
    if (audio != null) {
      filesMap['audio'] = [audio];
    }
    if (files != null && files.isNotEmpty) {
      filesMap['files'] = files;
    }

    final response = await NetworkCaller().multipartPostRequest(
      Urls.aiChat,
      fields: fields,
      files: filesMap,
    );

    return response;
  }
}
